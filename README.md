# 🔄 Roo Code Qwen Provider

[![npm version](https://img.shields.io/npm/v/roo-code-qwen-provider.svg)](https://www.npmjs.com/package/roo-code-qwen-provider)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub](https://img.shields.io/badge/GitHub-repo-green.svg)](https://github.com/avare41lll/roo-code-qwen-provider)

Глобальная установка и настройка Roo Code provider для Qwen Code CLI с автоматической генерацией индивидуальной конфигурации и утилитами синхронизации квот.

## 📦 Установка

### Из npm (рекомендуется)

```bash
npm install -g roo-code-qwen-provider
```

### Через GitHub

```bash
# Глобальная установка из GitHub
npm install -g git+https://github.com/avare41lll/roo-code-qwen-provider.git
```

### Локальная установка (для разработки)

```bash
# Клонировать репозиторий
git clone https://github.com/avare41lll/roo-code-qwen-provider.git
cd roo-code-qwen-provider

# Установить локально
npm install -g .
```

### Из локальной директории

```bash
# Если пакет уже скачан
npm install -g /path/to/roo-code-qwen-provider
```

## 🚀 Быстрый старт

После установки доступны команды:

```bash
# Проверка системы
roo-sync -c -v

# Синхронизация с генерацией конфигурации
roo-sync -g

# Тихий режим (для cron)
roo-sync -q
```

## 📖 Команды

### roo-sync

| Опция | Описание |
|-------|----------|
| `-g, --generate [путь]` | Сгенерировать roo-code-provider.json |
| `-o, --output путь` | Путь для сохранения конфигурации |
| `-b, --no-backup` | Не создавать резервную копию |
| `-v, --verbose` | Подробный вывод |
| `-q, --quiet` | Тихий режим (для cron) |
| `-c, --check` | Только проверка (без статистики) |
| `-h, --help` | Показать справку |

### roo-code-provider (rcp)

| Команда | Описание |
|---------|----------|
| `install`, `i` | Установить конфигурацию |
| `generate`, `g` | Сгенерировать конфигурацию |
| `check`, `c` | Проверить систему |
| `update`, `u` | Обновить конфигурацию |
| `remove`, `r` | Удалить конфигурацию |

## 📋 Примеры использования

### Базовая проверка системы

```bash
roo-sync
```

Выводит:
- ✅ Статус файлов конфигурации
- 🔧 Конфигурацию Qwen CLI
- 🔑 Статус OAuth токена
- 📊 Статистику Roo Code
- 💾 Создаёт резервную копию

### Генерация конфигурации провайдера

```bash
roo-sync -g
```

Создаёт `~/roo-code-provider.json` с индивидуальными путями:

```json
{
  "provider": "qwen-code-cli",
  "qwenCliPath": "/home/user/.nvm/versions/node/v24/bin/qwen",
  "authConfig": {
    "type": "oauth",
    "credsPath": "/home/user/.qwen/oauth_creds.json",
    "settingsPath": "/home/user/.qwen/settings.json"
  },
  "model": {
    "default": "coder-model",
    "temperature": 0.2,
    "maxTokens": 4096
  },
  "quotaTracking": {
    "enabled": true,
    "syncWithCli": true,
    "storagePath": "/home/user/.vscode-server/.../tasks"
  }
}
```

### Настройка Roo Code в VSCode

1. Откройте **VSCode**
2. Перейдите в панель **Roo Code**
3. Нажмите **Settings** (⚙️) → **Provider**
4. Выберите **"Qwen Code CLI API"**
5. Укажите путь к конфигурации: `~/roo-code-provider.json`
6. Перезапустите VSCode

## 🤖 Автоматизация

### Cron (каждые 6 часов)

```bash
crontab -e
# Запуск каждые 6 часов в тихом режиме
0 */6 * * * roo-sync -q >> /tmp/roo-sync.log 2>&1
```

### Git hook (pre-commit)

```bash
# .git/hooks/pre-commit
#!/bin/bash
roo-sync -q
```

## 🔧 Требования

- **Node.js** >= 14.0.0
- **Qwen Code CLI** (установлен и настроен)
- **Roo Code Extension** для VSCode
- **bash** >= 4.0
- **jq** (рекомендуется, для парсинга JSON)

### Проверка зависимостей

```bash
# Проверить установку Qwen CLI
qwen --version

# Проверить jq
jq --version
```

## 📁 Структура пакета

```
roo-code-qwen-provider/
├── bin/
│   ├── install.js         # CLI: roo-code-provider
│   └── roo-sync.js        # CLI: roo-sync (обёртка)
├── lib/
│   ├── utils.js           # Утилиты обнаружения путей
│   ├── config-generator.js # Генератор конфигурации
│   └── test.js            # Тесты
├── scripts/
│   ├── sync-roo-quota.sh  # Главный скрипт
│   └── lib/
│       ├── config.sh          # Конфигурация
│       ├── check.sh           # Проверка файлов
│       ├── check-oauth.sh     # Проверка OAuth
│       ├── check-qwen.sh      # Проверка Qwen
│       ├── get-stats.sh       # Статистика Roo Code
│       ├── generate-config.sh # Генерация конфига
│       └── backup.sh          # Резервное копирование
├── templates/
│   └── roo-code-provider.json.template
├── package.json
└── README.md
```

## 🛠️ Разработка

### Локальная установка для разработки

```bash
git clone https://github.com/avare41lll/roo-code-qwen-provider.git
cd roo-code-qwen-provider
npm install -g .
```

### Тестирование

```bash
# Проверка системы
npm run check

# Генерация конфигурации
npm run generate

# Запуск синхронизации
npm run sync
```

### Обновление из GitHub

```bash
npm update -g roo-code-qwen-provider
# или переустановить
npm install -g git+https://github.com/avare41lll/roo-code-qwen-provider.git
```

## 🔐 Безопасность

- ❌ **Не коммитьте** `oauth_creds.json` в git
- ✅ Используйте `.gitignore` для `.qwen/`
- ✅ Установите правильные права: `chmod 600 ~/.qwen/oauth_creds.json`

## 🐛 Решение проблем

### Qwen CLI не найден

```bash
# Установить Qwen CLI
npm install -g @qwen-code/qwen-cli
```

### OAuth токен истёк

```bash
qwen logout
qwen login
```

### Roo Code не видит конфигурацию

1. Проверьте путь к конфигурации в настройках Roo Code
2. Убедитесь, что файл существует: `ls -la ~/roo-code-provider.json`
3. Перезапустите VSCode

### Ошибка при установке из GitHub

```bash
# Очистить кэш npm
npm cache clean --force

# Попробовать снова
npm install -g git+https://github.com/avare41lll/roo-code-qwen-provider.git
```

## 📊 Синхронизация квот

Пакет обеспечивает синхронизацию квот между:

- **Qwen Code CLI** (WSL2/Terminal)
- **Roo Code VSCode Extension**

Оба интерфейса используют:
- Единые OAuth credentials (`~/.qwen/oauth_creds.json`)
- Общую статистику использования токенов
- Одинаковые настройки модели

## 📝 Лицензия

MIT

## 🤝 Вклад

1. Fork репозитория
2. Создайте ветку: `git checkout -b feature/new-feature`
3. Commit изменения: `git commit -m 'Add new feature'`
4. Push: `git push origin feature/new-feature`
5. Откройте Pull Request

## 📞 Поддержка

- GitHub Issues: https://github.com/avare41lll/roo-code-qwen-provider/issues
- Документация Roo Code: https://docs.roocode.com
- Qwen CLI Documentation: https://qwenlm.github.io/qwen-code-docs

## 📈 Changelog

### v1.0.0 (2026-03-07)

- ✅ Начальная версия пакета
- ✅ Автообнаружение путей Qwen CLI и Roo Code
- ✅ Генерация индивидуального roo-code-provider.json
- ✅ Модульные скрипты синхронизации
- ✅ Проверка статуса OAuth токена
- ✅ Статистика использования токенов
- ✅ Резервное копирование данных

---

**Версия:** 1.0.0  
**Дата:** 2026-03-07  
**Автор:** DEV  
**License:** MIT  
**GitHub:** https://github.com/avare41lll/roo-code-qwen-provider
