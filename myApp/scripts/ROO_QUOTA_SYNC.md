# 🔄 Roo Code Quota Sync

Синхронизация квот и настроек между **Qwen Code CLI** и **Roo Code VSCode Extension**

---

## 📋 Обзор

Эта конфигурация позволяет:
- ✅ Использовать единые OAuth credentials для CLI и VSCode
- ✅ Отслеживать использование токенов в обоих интерфейсах
- ✅ Синхронизировать настройки моделей и провайдеров
- ✅ Автоматически проверять статус аутентификации

---

## 🏗️ Архитектура

```
┌─────────────────┐         ┌──────────────────┐
│  Qwen Code CLI  │◄───────►│  OAuth Credentials │
│  (WSL2 Terminal)│         │  ~/.qwen/         │
└────────┬────────┘         └──────────────────┘
         │
         │ (shared config)
         │
         ▼
┌─────────────────┐         ┌──────────────────┐
│  Roo Code       │◄───────►│  Task History    │
│  (VSCode Ext)   │         │  ~/.vscode-server/│
└─────────────────┘         └──────────────────┘
```

---

## 📁 Структура файлов

### Конфигурация Qwen CLI
```
~/.qwen/
├── settings.json          # Основные настройки (модель, язык, auth)
├── oauth_creds.json       # OAuth токены (access/refresh token)
└── installation_id        # ID установки
```

### Конфигурация Roo Code
```
~/.vscode-server/data/User/globalStorage/rooveterinaryinc.roo-cline/
├── settings/
│   ├── mcp_settings.json   # MCP серверы
│   └── custom_modes.yaml   # Кастомные режимы
├── tasks/
│   ├── _index.json         # Индекс всех задач со статистикой
│   └── {task-id}/          # История отдельных задач
└── cache/                  # Кэш моделей API
```

### Проектная конфигурация
```
myApp/.vscode/
├── roo-code-provider.json  # Конфигурация провайдера для проекта
└── settings.json           # Настройки VS Code для проекта
```

---

## 🚀 Быстрый старт

### 1. Проверка установки

```bash
# Проверить наличие Qwen CLI
which qwen
qwen --version

# Проверить расширения VS Code
code --list-extensions | grep -iE "roo|qwen"
```

### 2. Аутентификация

```bash
# Войти через OAuth (WSL2)
wsl
qwen login

# Проверить статус токена
cat ~/.qwen/oauth_creds.json | jq '.expiry_date'
```

### 3. Запуск синхронизации

```bash
# Выполнить синхронизацию квот
./scripts/sync-roo-quota.sh
```

---

## 📊 Мониторинг квот

### Статистика использования

Скрипт `sync-roo-quota.sh` показывает:
- Количество выполненных задач
- Общее количество входящих/исходящих токенов
- Статус OAuth токена (время до истечения)
- Текущую модель и настройки

### Пример вывода

```
=== Статистика Roo Code ===
  Задач выполнено: 8
  Токенов входящих: 611187
  Токенов исходящих: 5238
  Всего токенов: 616425

=== Статус OAuth токена ===
  Токен действителен (осталось ~5 ч.)
```

---

## ⚙️ Настройка провайдера в Roo Code

### Вариант 1: Через UI VS Code

1. Открыть Roo Code панель
2. Settings (⚙️) → Provider
3. Выбрать **"Qwen Code CLI API"**
4. Указать путь к credentials: `~/.qwen/oauth_creds.json`

### Вариант 2: Через конфигурационный файл

Создать/отредактировать `.vscode/roo-code-provider.json`:

```json
{
  "provider": "qwen-code-cli",
  "apiConfigName": "qwen",
  "qwenCliPath": "qwen",
  "authConfig": {
    "type": "oauth",
    "credsPath": "/home/DEV/.qwen/oauth_creds.json"
  },
  "model": {
    "default": "coder-model"
  }
}
```

---

## 🔧 Автоматизация

### Cron job для авто-синхронизации

```bash
# Добавить в crontab (каждые 6 часов)
0 */6 * * * /home/DEV/PRS/PR3_AI_hunt/myApp/scripts/sync-roo-quota.sh >> /tmp/roo-sync.log 2>&1
```

### Git hook (pre-commit)

```bash
# .git/hooks/pre-commit
#!/bin/bash
./scripts/sync-roo-quota.sh --quiet
```

---

## 🛠️ Решение проблем

### OAuth токен истек

```bash
# Обновить токен
qwen logout
qwen login
```

### Roo Code не видит CLI

1. Убедитесь, что CLI установлен в WSL2:
   ```bash
   wsl
   which qwen
   ```

2. Проверьте путь в настройках Roo Code

3. Перезапустите VS Code Remote WSL

### Несоответствие квот

```bash
# Очистить кэш Roo Code
rm -rf ~/.vscode-server/data/User/globalStorage/rooveterinaryinc.roo-cline/cache/*

# Пересоздать индекс задач
./scripts/sync-roo-quota.sh --rebuild-index
```

---

## 📈 Лимиты и ограничения

| Провайдер | Лимит | Примечание |
|-----------|-------|------------|
| Qwen OAuth | 1000 запросов/день | Бесплатный тариф |
| DashScope API Key | Зависит от тарифа | Платный |
| Coding Plan | По подписке | Приоритетная очередь |

---

## 🔒 Безопасность

### Защита OAuth credentials

```bash
# Установить правильные права
chmod 600 ~/.qwen/oauth_creds.json
chmod 700 ~/.qwen/
```

### Рекомендации

- ❌ Не коммитьте `oauth_creds.json` в git
- ✅ Используйте `.gitignore` для `.qwen/`
- ✅ Регулярно обновляйте токены
- ✅ Мониторьте использование через скрипт

---

## 📞 Поддержка

- Документация Roo Code: https://docs.roocode.com
- Qwen CLI: https://qwenlm.github.io/qwen-code-docs
- Issues: GitHub repository проекта

---

**Последнее обновление:** 2026-03-07  
**Версия конфигурации:** 1.0
