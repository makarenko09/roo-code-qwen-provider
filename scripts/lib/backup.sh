#!/bin/bash
# lib/backup.sh - Создание резервных копий

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"
source "${SCRIPT_DIR}/check.sh"

# Создание резервной копии задач Roo Code
backup_roo_data() {
    local backup_dir="${1:-}"
    local verbose="${2:-true}"
    
    # Создать имя директории по умолчанию если не указано
    if [ -z "$backup_dir" ]; then
        backup_dir="$ROO_STORAGE/backup_$(date +%Y%m%d_%H%M%S)"
    fi
    
    if [ "$verbose" = "true" ]; then
        echo ""
        echo -e "${YELLOW}=== Создание резервной копии ===${NC}"
        echo "  Путь: $backup_dir"
    fi
    
    # Создать директорию
    mkdir -p "$backup_dir"
    
    # Скопировать задачи
    if [ -d "$ROO_TASKS" ]; then
        cp -r "$ROO_TASKS" "$backup_dir/" 2>/dev/null
        if [ $? -eq 0 ]; then
            if [ "$verbose" = "true" ]; then
                echo -e "${GREEN}  ✓ Резервная копия задач создана${NC}"
            fi
            
            # Показать размер
            local size=$(du -sh "$backup_dir/tasks" 2>/dev/null | cut -f1)
            if [ "$verbose" = "true" ] && [ -n "$size" ]; then
                echo "  Размер: $size"
            fi
            
            echo "$backup_dir"
            return 0
        else
            if [ "$verbose" = "true" ]; then
                echo -e "${RED}  ✗ Не удалось создать резервную копию${NC}"
            fi
            return 1
        fi
    else
        if [ "$verbose" = "true" ]; then
            echo -e "${RED}  ✗ Директория задач не найдена${NC}"
        fi
        return 1
    fi
}

# Очистка старых резервных копий
cleanup_old_backups() {
    local keep_count="${1:-5}" # Сколько последних хранить
    local verbose="${2:-true}"
    
    if [ ! -d "$ROO_STORAGE" ]; then
        return 1
    fi
    
    # Найти все backup директории и отсортировать по дате
    local backups=$(ls -dt "$ROO_STORAGE"/backup_* 2>/dev/null | tail -n +$((keep_count + 1)))
    
    if [ -n "$backups" ]; then
        if [ "$verbose" = "true" ]; then
            echo -e "${YELLOW}Очистка старых резервных копий...${NC}"
        fi
        
        for backup in $backups; do
            rm -rf "$backup"
            if [ "$verbose" = "true" ]; then
                echo "  Удалено: $backup"
            fi
        done
    fi
}

# Экспорт функций
export -f backup_roo_data cleanup_old_backups
