#!/bin/bash
# lib/check-qwen.sh - Проверка конфигурации Qwen CLI

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"
source "${SCRIPT_DIR}/check.sh"

# Проверка настроек Qwen CLI
check_qwen_config() {
    local verbose="${1:-true}"
    
    if [ "$verbose" = "true" ]; then
        echo ""
        echo -e "${YELLOW}=== Конфигурация Qwen CLI ===${NC}"
    fi
    
    if [ ! -f "$QWEN_SETTINGS" ]; then
        if [ "$verbose" = "true" ]; then
            echo -e "${RED}  settings.json не найден: $QWEN_SETTINGS${NC}"
        fi
        return 1
    fi
    
    if check_jq; then
        local model=$(jq -r '.model.name // "не указано"' "$QWEN_SETTINGS")
        local auth_type=$(jq -r '.security.auth.selectedType // "не указано"' "$QWEN_SETTINGS")
        local output_lang=$(jq -r '.general.outputLanguage // "English"' "$QWEN_SETTINGS")
        local ide_enabled=$(jq -r '.ide.enabled // false' "$QWEN_SETTINGS")
        
        if [ "$verbose" = "true" ]; then
            echo "  Модель: $model"
            echo "  Тип аутентификации: $auth_type"
            echo "  Язык вывода: $output_lang"
            echo "  IDE интеграция: $ide_enabled"
        fi
        
        # Вернуть значения
        echo "QWEN_MODEL=$model"
        echo "QWEN_AUTH_TYPE=$auth_type"
        echo "QWEN_OUTPUT_LANG=$output_lang"
        echo "QWEN_IDE_ENABLED=$ide_enabled"
    else
        if [ "$verbose" = "true" ]; then
            echo -e "${YELLOW}  jq не установлен - показываю raw содержимое${NC}"
            echo ""
            cat "$QWEN_SETTINGS"
        fi
    fi
    
    return 0
}

# Проверка версии Qwen CLI
check_qwen_version() {
    if ! command -v qwen &> /dev/null; then
        echo "QWEN_INSTALLED=no"
        return 1
    fi
    
    local version=$(qwen --version 2>&1 | head -1)
    echo "QWEN_INSTALLED=yes"
    echo "QWEN_VERSION=$version"
    echo "QWEN_PATH=$(which qwen)"
}

# Проверка IDE интеграции
check_ide_integration() {
    if [ ! -f "$QWEN_SETTINGS" ] || ! check_jq; then
        return 1
    fi
    
    local ide_enabled=$(jq -r '.ide.enabled // false' "$QWEN_SETTINGS")
    local has_seen_nudge=$(jq -r '.ide.hasSeenNudge // false' "$QWEN_SETTINGS")
    
    echo "IDE_ENABLED=$ide_enabled"
    echo "IDE_HAS_SEEN_NUDGE=$has_seen_nudge"
}

# Экспорт функций
export -f check_qwen_config check_qwen_version check_ide_integration
