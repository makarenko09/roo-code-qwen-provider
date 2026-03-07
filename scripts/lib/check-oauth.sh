#!/bin/bash
# lib/check-oauth.sh - Проверка статуса OAuth токена

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"
source "${SCRIPT_DIR}/check.sh"

# Проверка статуса OAuth токена
check_oauth_token() {
    local verbose="${1:-true}"
    
    if [ "$verbose" = "true" ]; then
        echo ""
        echo -e "${YELLOW}=== Статус OAuth токена ===${NC}"
    fi
    
    if [ ! -f "$QWEN_OAUTH" ]; then
        if [ "$verbose" = "true" ]; then
            echo -e "${RED}  OAuth файл не найден: $QWEN_OAUTH${NC}"
        fi
        return 1
    fi
    
    if check_jq; then
        local expiry_date=$(jq -r '.expiry_date // 0' "$QWEN_OAUTH")
        local token_type=$(jq -r '.token_type // "unknown"' "$QWEN_OAUTH")
        local current_date=$(date +%s%3N)
        local expiry_remaining=$(( (expiry_date - current_date) / 1000 / 3600 ))
        
        if [ "$verbose" = "true" ]; then
            if [ $expiry_remaining -gt 0 ]; then
                echo -e "${GREEN}  ✓ Токен действителен (осталось ~${expiry_remaining} ч.)${NC}"
            else
                echo -e "${RED}  ✗ Токен истек! Требуется повторная аутентификация${NC}"
                echo -e "${YELLOW}  Выполните: qwen login${NC}"
            fi
            
            echo "  Тип токена: $token_type"
        fi
        
        # Вернуть 0 если токен действителен, 1 если истек
        if [ $expiry_remaining -gt 0 ]; then
            return 0
        else
            return 1
        fi
    else
        if [ "$verbose" = "true" ]; then
            echo -e "${YELLOW}  jq не установлен - не удалось проверить статус токена${NC}"
        fi
        return 2
    fi
}

# Получить информацию о токене (для использования в других скриптах)
get_token_info() {
    if [ ! -f "$QWEN_OAUTH" ] || ! check_jq; then
        echo ""
        return 1
    fi
    
    local expiry_date=$(jq -r '.expiry_date // 0' "$QWEN_OAUTH")
    local token_type=$(jq -r '.token_type // "unknown"' "$QWEN_OAUTH")
    local has_refresh=$(jq -r 'if .refresh_token then "yes" else "no" end' "$QWEN_OAUTH")
    
    echo "expiry_date=$expiry_date"
    echo "token_type=$token_type"
    echo "has_refresh_token=$has_refresh"
}

# Проверка необходимости обновления токена
needs_token_refresh() {
    local threshold_hours="${1:-2}" # Порог в часах
    
    if [ ! -f "$QWEN_OAUTH" ] || ! check_jq; then
        return 0 # Считаем что нужно обновление
    fi
    
    local expiry_date=$(jq -r '.expiry_date // 0' "$QWEN_OAUTH")
    local current_date=$(date +%s%3N)
    local expiry_remaining=$(( (expiry_date - current_date) / 1000 / 3600 ))
    
    if [ $expiry_remaining -lt $threshold_hours ]; then
        return 0 # Нужно обновление
    else
        return 1 # Не нужно
    fi
}

# Экспорт функций
export -f check_oauth_token get_token_info needs_token_refresh
