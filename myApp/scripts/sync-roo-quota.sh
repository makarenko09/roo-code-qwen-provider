#!/bin/bash
# Roo Code Quota Sync Script
# Синхронизирует квоты между Qwen CLI и Roo Code VSCode

set -e

# Конфигурация
QWEN_SETTINGS="$HOME/.qwen/settings.json"
QWEN_OAUTH="$HOME/.qwen/oauth_creds.json"
ROO_STORAGE="$HOME/.vscode-server/data/User/globalStorage/rooveterinaryinc.roo-cline"
ROO_TASKS="$ROO_STORAGE/tasks"
PROJECT_WORKSPACE="/home/DEV/PRS/PR3_AI_hunt/myApp"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Roo Code Quota Sync ===${NC}"
echo ""

# Проверка существования файлов
check_files() {
    local missing=0
    
    if [ ! -f "$QWEN_SETTINGS" ]; then
        echo -e "${RED}✗ Qwen settings не найден: $QWEN_SETTINGS${NC}"
        missing=1
    else
        echo -e "${GREEN}✓ Qwen settings найден${NC}"
    fi
    
    if [ ! -f "$QWEN_OAUTH" ]; then
        echo -e "${RED}✗ OAuth credentials не найдены: $QWEN_OAUTH${NC}"
        missing=1
    else
        echo -e "${GREEN}✓ OAuth credentials найдены${NC}"
    fi
    
    if [ ! -d "$ROO_TASKS" ]; then
        echo -e "${RED}✗ Roo Code tasks директория не найдена: $ROO_TASKS${NC}"
        missing=1
    else
        echo -e "${GREEN}✓ Roo Code tasks директория найдена${NC}"
    fi
    
    return $missing
}

# Получение статистики использования из Roo Code
get_roo_usage() {
    echo ""
    echo -e "${YELLOW}=== Статистика Roo Code ===${NC}"
    
    if [ -f "$ROO_TASKS/_index.json" ]; then
        # Подсчет токенов из всех задач
        local total_tokens_in=0
        local total_tokens_out=0
        local task_count=0
        
        # Используем jq для парсинга JSON если доступен
        if command -v jq &> /dev/null; then
            total_tokens_in=$(jq '[.entries[].tokensIn // 0] | add' "$ROO_TASKS/_index.json" 2>/dev/null || echo "0")
            total_tokens_out=$(jq '[.entries[].tokensOut // 0] | add' "$ROO_TASKS/_index.json" 2>/dev/null || echo "0")
            task_count=$(jq '.entries | length' "$ROO_TASKS/_index.json" 2>/dev/null || echo "0")
        else
            # Fallback без jq - приблизительный подсчет
            total_tokens_in=$(grep -o '"tokensIn":[0-9]*' "$ROO_TASKS/_index.json" | cut -d: -f2 | paste -sd+ | bc 2>/dev/null || echo "0")
            total_tokens_out=$(grep -o '"tokensOut":[0-9]*' "$ROO_TASKS/_index.json" | cut -d: -f2 | paste -sd+ | bc 2>/dev/null || echo "0")
            task_count=$(grep -c '"id":' "$ROO_TASKS/_index.json" 2>/dev/null || echo "0")
        fi
        
        echo "  Задач выполнено: $task_count"
        echo "  Токенов входящих: $total_tokens_in"
        echo "  Токенов исходящих: $total_tokens_out"
        echo "  Всего токенов: $((total_tokens_in + total_tokens_out))"
    else
        echo -e "${RED}  _index.json не найден${NC}"
    fi
}

# Проверка статуса OAuth токена
check_oauth_token() {
    echo ""
    echo -e "${YELLOW}=== Статус OAuth токена ===${NC}"
    
    if [ -f "$QWEN_OAUTH" ] && command -v jq &> /dev/null; then
        local expiry_date=$(jq -r '.expiry_date' "$QWEN_OAUTH")
        local current_date=$(date +%s%3N)
        local expiry_remaining=$(( (expiry_date - current_date) / 1000 / 3600 ))
        
        if [ $expiry_remaining -gt 0 ]; then
            echo -e "${GREEN}  Токен действителен (осталось ~${expiry_remaining} ч.)${NC}"
        else
            echo -e "${RED}  Токен истек! Требуется повторная аутентификация${NC}"
            echo "  Выполните: qwen login"
        fi
        
        local token_type=$(jq -r '.token_type' "$QWEN_OAUTH")
        echo "  Тип токена: $token_type"
    else
        echo -e "${RED}  Не удалось проверить статус токена${NC}"
    fi
}

# Проверка настроек Qwen CLI
check_qwen_config() {
    echo ""
    echo -e "${YELLOW}=== Конфигурация Qwen CLI ===${NC}"
    
    if [ -f "$QWEN_SETTINGS" ] && command -v jq &> /dev/null; then
        local model=$(jq -r '.model.name // "не указано"' "$QWEN_SETTINGS")
        local auth_type=$(jq -r '.security.auth.selectedType // "не указано"' "$QWEN_SETTINGS")
        local output_lang=$(jq -r '.general.outputLanguage // "English"' "$QWEN_SETTINGS")
        
        echo "  Модель: $model"
        echo "  Тип аутентификации: $auth_type"
        echo "  Язык вывода: $output_lang"
    fi
}

# Создание резервной копии
backup_roo_data() {
    local backup_dir="$ROO_STORAGE/backup_$(date +%Y%m%d_%H%M%S)"
    echo ""
    echo -e "${YELLOW}=== Создание резервной копии ===${NC}"
    echo "  Путь: $backup_dir"
    
    mkdir -p "$backup_dir"
    cp -r "$ROO_TASKS" "$backup_dir/" 2>/dev/null && \
        echo -e "${GREEN}  ✓ Резервная копия создана${NC}" || \
        echo -e "${RED}  ✗ Не удалось создать резервную копию${NC}"
}

# Основная функция
main() {
    echo "Проверка файлов конфигурации..."
    echo ""
    
    if ! check_files; then
        echo ""
        echo -e "${RED}Обнаружены проблемы с конфигурацией!${NC}"
        echo "Убедитесь, что:"
        echo "  1. Qwen CLI установлен в WSL2"
        echo "  2. Выполнена аутентификация: qwen login"
        echo "  3. Roo Code extension установлен в VS Code"
        exit 1
    fi
    
    check_qwen_config
    check_oauth_token
    get_roo_usage
    
    echo ""
    echo -e "${GREEN}=== Синхронизация завершена ===${NC}"
    echo ""
    echo "📁 Пути:"
    echo "  Qwen CLI config: $QWEN_SETTINGS"
    echo "  Qwen OAuth:      $QWEN_OAUTH"
    echo "  Roo Code storage: $ROO_STORAGE"
    echo ""
    echo "💡 Для обновления квот:"
    echo "  1. Запустите этот скрипт после каждой сессии"
    echo "  2. Или настройте автозапуск через cron"
}

# Запуск
main "$@"
