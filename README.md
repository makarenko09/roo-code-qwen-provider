# 🔄 Roo Code Qwen Provider

[![npm version](https://img.shields.io/npm/v/roo-code-qwen-provider.svg)](https://www.npmjs.com/package/roo-code-qwen-provider)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub](https://img.shields.io/badge/GitHub-repo-green.svg)](https://github.com/makarenko09/roo-code-qwen-provider)

Утилиты синхронизации квот между Qwen Code CLI и Roo Code VSCode.

## 📦 Установка

```bash
npm install -g roo-code-qwen-provider
```

## 🚀 Быстрый старт

После установки доступна команда:

```bash
# Проверка системы
roo-sync -c -v

# Запуск синхронизации
roo-sync
```

## 📖 Команды

### roo-sync

| Опция | Описание |
|-------|----------|
| `-b, --no-backup` | Не создавать резервную копию |
| `-v, --verbose` | Подробный вывод |
| `-c, --check` | Только проверка (без статистики) |
| `-h, --help` | Показать справку |


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

### Настройка Roo Code в VSCode

1. Откройте **VSCode**
2. Перейдите в панель **Roo Code**
3. Нажмите **Settings** (⚙️) → **Provider**
4. Выберите **"Qwen Code CLI API"**
5. Roo Code автоматически использует `~/.qwen/oauth_creds.json`
6. Перезапустите VSCode

## 🔧 Требования

- **Node.js** >= 14.0.0
- **Qwen Code CLI** (установлен и аутентифицирован через Qwen OAuth):
  > <small>Вы можете использовать любую другую аутентификацию, если у вас есть такая потребность, но данный npm не тестировался в этих целях!</small>
- **Roo Code Extension** для VSCode
- **bash** >= 4.0
- **jq** (рекомендуется, для парсинга JSON)

## 🖥️ Поддерживаемые среды

- **ОС:** Linux, WSL2 (Windows Subsystem for Linux)
- **IDE:** VSCode с расширением Roo Code
- **Терминал:** bash, zsh

> <small>Другие операционные системы (macOS, Windows без WSL2) не тестировались — работа не гарантируется.</small>

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
│   └── roo-sync.js        # CLI: roo-sync (обёртка)
├── lib/
│   └── utils.js           # Утилиты обнаружения путей
├── scripts/
│   ├── sync-roo-quota.sh  # Главный скрипт
│   └── lib/
│       ├── config.sh          # Конфигурация
│       ├── check.sh           # Проверка файлов
│       ├── check-oauth.sh     # Проверка OAuth
│       ├── check-qwen.sh      # Проверка Qwen
│       ├── get-stats.sh       # Статистика Roo Code
│       └── backup.sh          # Резервное копирование
├── package.json
└── README.md
```

## 🛠️ Разработка

### Локальная установка для разработки

```bash
git clone https://github.com/makarenko09/roo-code-qwen-provider.git
cd roo-code-qwen-provider
npm install -g .
```

### Тестирование

```bash
# Проверка системы
npm run check

# Запуск синхронизации
npm run sync
```

### Обновление из GitHub

```bash
npm update -g roo-code-qwen-provider
# или переустановить
npm install -g git+https://github.com/makarenko09/roo-code-qwen-provider.git
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

### Ошибка при установке из GitHub

```bash
# Очистить кэш npm
npm cache clean --force

# Попробовать снова
npm install -g git+https://github.com/makarenko09/roo-code-qwen-provider.git
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

## 💻 Built With

![Node.js](https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white)
![Shell Script](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Semantic Release](https://img.shields.io/badge/Semantic%20Release-0xFFD700?style=for-the-badge&logo=semantic-release&logoColor=white)

##  Поддержка

- GitHub Issues: https://github.com/makarenko09/roo-code-qwen-provider/issues
- Документация Roo Code: https://docs.roocode.com
- Qwen CLI Documentation: https://qwenlm.github.io/qwen-code-docs

## 📈 Changelog

### v1.0.0 (2026-03-07)

- ✅ Начальная версия пакета
- ✅ Автообнаружение путей Qwen CLI и Roo Code
- ✅ Модульные скрипты синхронизации
- ✅ Проверка статуса OAuth токена
- ✅ Статистика использования токенов
- ✅ Резервное копирование данных

---

**Версия:** 1.0.0  
**Дата:** 2026-03-07  
**Автор:** DEV  
**License:** MIT  
**GitHub:** https://github.com/makarenko09/roo-code-qwen-provider
