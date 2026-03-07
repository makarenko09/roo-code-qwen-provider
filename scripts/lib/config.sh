#!/bin/bash
# lib/config.sh - Конфигурация и общие переменные

# Пути по умолчанию
QWEN_SETTINGS="${QWEN_SETTINGS:-$HOME/.qwen/settings.json}"
QWEN_OAUTH="${QWEN_OAUTH:-$HOME/.qwen/oauth_creds.json}"
ROO_STORAGE="${ROO_STORAGE:-$HOME/.vscode-server/data/User/globalStorage/rooveterinaryinc.roo-cline}"
ROO_TASKS="${ROO_TASKS:-$ROO_STORAGE/tasks}"

# Путь для генерации roo-code-provider.json
ROO_PROVIDER_CONFIG="${ROO_PROVIDER_CONFIG:-$HOME/roo-code-provider.json}"

# Проект (можно переопределить через env)
PROJECT_WORKSPACE="${PROJECT_WORKSPACE:-$(pwd)}"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Версия скрипта
SCRIPT_VERSION="2.0.0"

# Экспорт переменных для других модулей
export QWEN_SETTINGS QWEN_OAUTH ROO_STORAGE ROO_TASKS ROO_PROVIDER_CONFIG
export PROJECT_WORKSPACE
export RED GREEN YELLOW BLUE CYAN NC
export SCRIPT_VERSION
