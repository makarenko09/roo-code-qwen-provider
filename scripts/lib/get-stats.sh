#!/bin/bash
# lib/get-stats.sh - Получение статистики использования Roo Code

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"
source "${SCRIPT_DIR}/check.sh"

# Получить статистику из Roo Code
get_roo_usage() {
    local verbose="${1:-true}"
    
    if [ "$verbose" = "true" ]; then
        echo ""
        echo -e "${YELLOW}=== Статистика Roo Code ===${NC}"
    fi
    
    if [ ! -f "$ROO_TASKS/_index.json" ]; then
        if [ "$verbose" = "true" ]; then
            echo -e "${RED}  _index.json не найден в $ROO_TASKS${NC}"
        fi
        return 1
    fi
    
    local total_tokens_in=0
    local total_tokens_out=0
    local total_cost=0
    local task_count=0
    
    if check_jq; then
        # Подсчет токенов из всех задач
        total_tokens_in=$(jq '[.entries[].tokensIn // 0] | add' "$ROO_TASKS/_index.json" 2>/dev/null || echo "0")
        total_tokens_out=$(jq '[.entries[].tokensOut // 0] | add' "$ROO_TASKS/_index.json" 2>/dev/null || echo "0")
        total_cost=$(jq '[.entries[].totalCost // 0] | add' "$ROO_TASKS/_index.json" 2>/dev/null || echo "0")
        task_count=$(jq '.entries | length' "$ROO_TASKS/_index.json" 2>/dev/null || echo "0")
        
        if [ "$verbose" = "true" ]; then
            echo "  Задач выполнено: $task_count"
            echo "  Токенов входящих: $total_tokens_in"
            echo "  Токенов исходящих: $total_tokens_out"
            echo "  Всего токенов: $((total_tokens_in + total_tokens_out))"
            
            # Показать стоимость если есть
            if [ "$total_cost" != "0" ] && [ "$total_cost" != "null" ]; then
                echo "  Общая стоимость: \$$total_cost"
            fi
        fi
    else
        # Fallback без jq - приблизительный подсчет
        if command -v grep &> /dev/null && command -v bc &> /dev/null; then
            total_tokens_in=$(grep -o '"tokensIn":[0-9]*' "$ROO_TASKS/_index.json" 2>/dev/null | cut -d: -f2 | paste -sd+ | bc 2>/dev/null || echo "0")
            total_tokens_out=$(grep -o '"tokensOut":[0-9]*' "$ROO_TASKS/_index.json" 2>/dev/null | cut -d: -f2 | paste -sd+ | bc 2>/dev/null || echo "0")
            task_count=$(grep -c '"id":' "$ROO_TASKS/_index.json" 2>/dev/null || echo "0")
            
            if [ "$verbose" = "true" ]; then
                echo "  Задач выполнено: $task_count (прибл.)"
                echo "  Токенов входящих: $total_tokens_in (прибл.)"
                echo "  Токенов исходящих: $total_tokens_out (прибл.)"
                echo "  Всего токенов: $((total_tokens_in + total_tokens_out))"
            fi
        else
            if [ "$verbose" = "true" ]; then
                echo -e "${RED}  Требуется jq или bc для подсчета статистики${NC}"
            fi
            return 2
        fi
    fi
    
    # Вернуть значения для использования в других скриптах
    echo "TASK_COUNT=$task_count"
    echo "TOKENS_IN=$total_tokens_in"
    echo "TOKENS_OUT=$total_tokens_out"
    echo "TOTAL_TOKENS=$((total_tokens_in + total_tokens_out))"
    
    return 0
}

# Получить детальную статистику по последней задаче
get_last_task_stats() {
    if [ ! -f "$ROO_TASKS/_index.json" ] || ! check_jq; then
        return 1
    fi
    
    # Получить последнюю задачу
    local last_task=$(jq -r '.entries | sort_by(.ts) | last' "$ROO_TASKS/_index.json" 2>/dev/null)
    
    if [ -z "$last_task" ] || [ "$last_task" = "null" ]; then
        return 1
    fi
    
    local task_id=$(echo "$last_task" | jq -r '.id // "unknown"')
    local task_number=$(echo "$last_task" | jq -r '.number // 0')
    local task_tokens_in=$(echo "$last_task" | jq -r '.tokensIn // 0')
    local task_tokens_out=$(echo "$last_task" | jq -r '.tokensOut // 0')
    local task_mode=$(echo "$last_task" | jq -r '.mode // "unknown"')
    local task_workspace=$(echo "$last_task" | jq -r '.workspace // "unknown"')
    
    echo "LAST_TASK_ID=$task_id"
    echo "LAST_TASK_NUMBER=$task_number"
    echo "LAST_TASK_TOKENS_IN=$task_tokens_in"
    echo "LAST_TASK_TOKENS_OUT=$task_tokens_out"
    echo "LAST_TASK_MODE=$task_mode"
    echo "LAST_TASK_WORKSPACE=$task_workspace"
}

# Получить список API конфигураций
get_api_configs() {
    if [ ! -f "$ROO_TASKS/_index.json" ] || ! check_jq; then
        return 1
    fi
    
    # Уникальные конфигурации API
    jq -r '[.entries[].apiConfigName] | unique | .[]' "$ROO_TASKS/_index.json" 2>/dev/null
}

# Экспорт функций
export -f get_roo_usage get_last_task_stats get_api_configs
