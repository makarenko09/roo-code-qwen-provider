#!/bin/bash
# lib/check.sh - Проверка существования файлов и директорий

# Источник конфигурации
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# Проверка существования пути (файл или директория)
path_exists() {
    local path="$1"
    local type="${2:-any}" # file, dir, any
    
    case "$type" in
        file)
            [ -f "$path" ]
            ;;
        dir)
            [ -d "$path" ]
            ;;
        *)
            [ -e "$path" ]
            ;;
    esac
}

# Проверка всех необходимых файлов
check_all_files() {
    local missing=0
    local verbose="${1:-false}"
    
    if [ "$verbose" = "true" ]; then
        echo -e "${CYAN}Проверка файлов конфигурации...${NC}"
        echo ""
    fi
    
    # Проверка Qwen settings
    if path_exists "$QWEN_SETTINGS" "file"; then
        [ "$verbose" = "true" ] && echo -e "${GREEN}✓${NC} Qwen settings: $QWEN_SETTINGS"
    else
        echo -e "${RED}✗${NC} Qwen settings не найден: $QWEN_SETTINGS"
        missing=$((missing + 1))
    fi
    
    # Проверка Qwen OAuth
    if path_exists "$QWEN_OAUTH" "file"; then
        [ "$verbose" = "true" ] && echo -e "${GREEN}✓${NC} OAuth credentials: $QWEN_OAUTH"
    else
        echo -e "${RED}✗${NC} OAuth credentials не найдены: $QWEN_OAUTH"
        missing=$((missing + 1))
    fi
    
    # Проверка Roo Code storage
    if path_exists "$ROO_STORAGE" "dir"; then
        [ "$verbose" = "true" ] && echo -e "${GREEN}✓${NC} Roo Code storage: $ROO_STORAGE"
    else
        echo -e "${RED}✗${NC} Roo Code storage не найден: $ROO_STORAGE"
        missing=$((missing + 1))
    fi
    
    # Проверка Roo Code tasks
    if path_exists "$ROO_TASKS" "dir"; then
        [ "$verbose" = "true" ] && echo -e "${GREEN}✓${NC} Roo Code tasks: $ROO_TASKS"
    else
        echo -e "${RED}✗${NC} Roo Code tasks не найден: $ROO_TASKS"
        missing=$((missing + 1))
    fi
    
    # Проверка qwen CLI
    if command -v qwen &> /dev/null; then
        [ "$verbose" = "true" ] && echo -e "${GREEN}✓${NC} Qwen CLI установлен: $(which qwen)"
    else
        echo -e "${YELLOW}⚠${NC} Qwen CLI не найден в PATH"
        # Не считаем это критичной ошибкой
    fi
    
    if [ "$verbose" = "true" ]; then
        echo ""
    fi
    
    return $missing
}

# Проверка jq
check_jq() {
    if command -v jq &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Проверка bc (fallback для jq)
check_bc() {
    if command -v bc &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Получить статус проверки
get_check_status() {
    local missing=0
    check_all_files "false" || missing=$?
    echo "$missing"
}

# Экспорт функций
export -f path_exists check_all_files check_jq check_bc get_check_status
