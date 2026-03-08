#!/bin/bash
# sync-roo-quota.sh - Главный скрипт синхронизации квот Roo Code + Qwen CLI
# Версия 2.0.0 с модульной архитектурой

set -e

# Определить директорию скрипта
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "$0")"

# Подключить модули
LIB_DIR="${SCRIPT_DIR}/lib"
source "${LIB_DIR}/config.sh"
source "${LIB_DIR}/check.sh"
source "${LIB_DIR}/check-oauth.sh"
source "${LIB_DIR}/check-qwen.sh"
source "${LIB_DIR}/get-stats.sh"
source "${LIB_DIR}/backup.sh"

# Переменные командной строки
NO_BACKUP=false
VERBOSE=false
SHOW_HELP=false
SHOW_VERSION=false

# Показать справку
show_help() {
    cat << EOF
${CYAN}Roo Code Quota Sync v${SCRIPT_VERSION}${NC}

Проверка конфигурации и синхронизация квот между Qwen Code CLI и Roo Code VSCode

${YELLOW}Использование:${NC}
  $SCRIPT_NAME [опции]

${YELLOW}Опции:${NC}
  -b, --no-backup          Не создавать резервную копию
  -v, --verbose            Подробный вывод
  -c, --check              Только проверка (без статистики)
  -h, --help               Показать эту справку
  -V, --version            Показать версию

${YELLOW}Примеры:${NC}
  $SCRIPT_NAME              # Запуск с проверками и статистикой
  $SCRIPT_NAME -c           # Только проверка системы
  $SCRIPT_NAME -v           # Подробный вывод

${YELLOW}Переменные окружения:${NC}
  QWEN_SETTINGS           Путь к settings.json Qwen
  QWEN_OAUTH              Путь к oauth_creds.json Qwen
  ROO_STORAGE             Путь к хранилищу Roo Code

${YELLOW}Статус возврата:${NC}
  0 - успех
  1 - ошибки конфигурации
  2 - предупреждения (некритично)
EOF
}

# Показать версию
show_version() {
    echo "Roo Code Quota Sync v${SCRIPT_VERSION}"
}

# Парсинг аргументов
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -b|--no-backup)
                NO_BACKUP=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -c|--check)
                CHECK_ONLY=true
                shift
                ;;
            -h|--help)
                SHOW_HELP=true
                shift
                ;;
            -V|--version)
                SHOW_VERSION=true
                shift
                ;;
            *)
                echo -e "${RED}Неизвестная опция: $1${NC}"
                echo -e "${YELLOW}Используйте -h для справки${NC}"
                exit 1
                ;;
        esac
    done
}

# Основная функция проверки
run_checks() {
    local exit_code=0
    
    if [ "$QUIET" = "false" ]; then
        echo -e "${GREEN}=== Roo Code Quota Sync ===${NC}"
        echo ""
        echo "Проверка файлов конфигурации..."
        echo ""
    fi
    
    # Проверка файлов
    if ! check_all_files "$VERBOSE"; then
        echo ""
        echo -e "${RED}Обнаружены проблемы с конфигурацией!${NC}"
        echo "Убедитесь, что:"
        echo "  1. Qwen CLI установлен в WSL2"
        echo "  2. Выполнена аутентификация: qwen login"
        echo "  3. Roo Code extension установлен в VS Code"
        exit_code=1
    fi
    
    return $exit_code
}

# Показать конфигурацию Qwen
show_qwen_config() {
    if [ "$QUIET" = "true" ]; then
        return
    fi
    check_qwen_config "$VERBOSE"
}

# Показать статус OAuth
show_oauth_status() {
    if [ "$QUIET" = "true" ]; then
        return
    fi
    check_oauth_token "$VERBOSE"
}

# Показать статистику Roo Code
show_roo_stats() {
    if [ "$QUIET" = "true" ]; then
        return
    fi
    get_roo_usage "$VERBOSE"
}

# Создать резервную копию
create_backup() {
    if [ "$NO_BACKUP" = "true" ] || [ "$QUIET" = "true" ]; then
        return
    fi
    backup_roo_data "" "$VERBOSE"
}

# Показать итоговую информацию
show_summary() {
    if [ "$QUIET" = "true" ]; then
        return
    fi
    
    echo ""
    echo -e "${GREEN}=== Синхронизация завершена ===${NC}"
    echo ""
    echo "📁 Пути:"
    echo "  Qwen CLI config: $QWEN_SETTINGS"
    echo "  Qwen OAuth:      $QWEN_OAUTH"
    echo "  Roo Code storage: $ROO_STORAGE"
    echo ""
    echo "💡 Roo Code автоматически использует:"
    echo "  ~/.qwen/oauth_creds.json"
    echo ""
}

# Главная функция
main() {
    parse_args "$@"
    
    # Помощь или версия
    if [ "$SHOW_HELP" = "true" ]; then
        show_help
        exit 0
    fi
    
    if [ "$SHOW_VERSION" = "true" ]; then
        show_version
        exit 0
    fi
    
    local exit_code=0
    
    # Запуск проверок
    run_checks || exit_code=$?
    
    # Если только проверка - завершить
    if [ "${CHECK_ONLY:-false}" = "true" ]; then
        if [ $exit_code -eq 0 ]; then
            echo -e "${GREEN}✓ Все проверки пройдены${NC}"
        fi
        exit $exit_code
    fi
    
    # Если есть критические ошибки - не продолжать
    if [ $exit_code -ne 0 ]; then
        exit $exit_code
    fi
    
    # Показать информацию
    show_qwen_config
    show_oauth_status
    show_roo_stats
    
    # Создать резервную копию
    create_backup
    
    # Итог
    show_summary
    
    exit $exit_code
}

# Запуск
main "$@"
