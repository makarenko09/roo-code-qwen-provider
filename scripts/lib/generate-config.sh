#!/bin/bash
# lib/generate-config.sh - Генерация roo-code-provider.json

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"
source "${SCRIPT_DIR}/check.sh"

# Получить значение из JSON файла (требует jq)
get_json_value() {
    local file="$1"
    local key="$2"
    local default="${3:-}"
    
    if [ ! -f "$file" ]; then
        echo "$default"
        return
    fi
    
    if check_jq; then
        local value=$(jq -r "$key // \"$default\"" "$file" 2>/dev/null)
        echo "$value"
    else
        echo "$default"
    fi
}

# Получить имя модели из настроек Qwen
get_model_name() {
    local model=$(get_json_value "$QWEN_SETTINGS" ".model.name" "coder-model")
    echo "$model"
}

# Получить тип аутентификации
get_auth_type() {
    local auth_type=$(get_json_value "$QWEN_SETTINGS" ".security.auth.selectedType" "qwen-oauth")
    echo "$auth_type"
}

# Сгенерировать конфигурацию roo-code-provider.json
generate_provider_config() {
    local output_path="${1:-$ROO_PROVIDER_CONFIG}"
    local verbose="${2:-false}"
    
    # Разрешить ~ в пути
    output_path="${output_path/#\~/$HOME}"
    
    if [ "$verbose" = "true" ]; then
        echo -e "${CYAN}Генерация конфигурации провайдера...${NC}"
    fi
    
    # Получить значения
    local model_name=$(get_model_name)
    local qwen_cli_path="qwen"
    
    if command -v qwen &> /dev/null; then
        qwen_cli_path=$(which qwen)
    fi
    
    # Создать JSON конфигурацию
    cat > "$output_path" << EOF
{
  "provider": "qwen-code-cli",
  "apiConfigName": "qwen",
  "qwenCliPath": "${qwen_cli_path}",
  "authConfig": {
    "type": "oauth",
    "credsPath": "${QWEN_OAUTH}",
    "settingsPath": "${QWEN_SETTINGS}"
  },
  "model": {
    "default": "${model_name}",
    "temperature": 0.2,
    "maxTokens": 4096
  },
  "quotaTracking": {
    "enabled": true,
    "syncWithCli": true,
    "storagePath": "${ROO_TASKS}"
  },
  "endpoints": {
    "oauth": "https://oauth.qwen.ai",
    "dashscope": "https://dashscope.aliyuncs.com/compatible-mode/v1",
    "codingPlan": "https://coding.dashscope.aliyuncs.com/v1"
  }
}
EOF
    
    if [ "$verbose" = "true" ]; then
        echo -e "${GREEN}✓${NC} Конфигурация сохранена: $output_path"
        echo ""
        echo -e "${YELLOW}Сгенерированная конфигурация:${NC}"
        cat "$output_path"
        echo ""
    fi
    
    # Вернуть путь к созданному файлу
    echo "$output_path"
}

# Валидация сгенерированной конфигурации
validate_config() {
    local config_path="$1"
    local errors=0
    
    if [ ! -f "$config_path" ]; then
        echo -e "${RED}✗${NC} Файл конфигурации не найден: $config_path"
        return 1
    fi
    
    # Проверка JSON синтаксиса
    if check_jq; then
        if ! jq empty "$config_path" 2>/dev/null; then
            echo -e "${RED}✗${NC} Ошибка JSON синтаксиса в $config_path"
            return 1
        fi
        echo -e "${GREEN}✓${NC} JSON синтаксис валиден"
    fi
    
    # Проверка обязательных полей
    if check_jq; then
        local required_fields=(
            ".provider"
            ".apiConfigName"
            ".qwenCliPath"
            ".authConfig.credsPath"
            ".authConfig.settingsPath"
            ".model.default"
            ".quotaTracking.storagePath"
        )
        
        for field in "${required_fields[@]}"; do
            local value=$(jq -r "$field // empty" "$config_path")
            if [ -z "$value" ]; then
                echo -e "${RED}✗${NC} Отсутствует поле: $field"
                errors=$((errors + 1))
            fi
        done
        
        if [ $errors -eq 0 ]; then
            echo -e "${GREEN}✓${NC} Все обязательные поля присутствуют"
        fi
    fi
    
    return $errors
}

# Экспорт функций
export -f get_json_value get_model_name get_auth_type generate_provider_config validate_config
