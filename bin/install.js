#!/usr/bin/env node

/**
 * Roo Code Provider Installer
 * Глобальная установка и настройка Roo Code provider для Qwen Code CLI
 */

const fs = require('fs');
const path = require('path');
const { generateConfig, saveConfig, loadConfig } = require('../lib/config-generator');
const { 
  getHomeDir, 
  pathExists, 
  findQwenCliDir, 
  findRooCodeStorage,
  checkQwenCliInstalled 
} = require('../lib/utils');

const VERSION = '1.0.0';
const CONFIG_FILENAME = 'roo-code-provider.json';

/**
 * Вывод цветного текста
 */
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  gray: '\x1b[90m'
};

function log(color, message) {
  console.log(`${color}${message}${colors.reset}`);
}

function showHelp() {
  console.log(`
${colors.cyan}Roo Code Provider Installer v${VERSION}${colors.reset}

Использование:
  roo-code-provider [команда] [опции]

Команды:
  install, i     Установить конфигурацию (по умолчанию)
  generate, g    Сгенерировать конфигурацию без сохранения
  check, c       Проверить систему
  update, u      Обновить существующую конфигурацию
  remove, r      Удалить конфигурацию
  help, h        Показать эту справку

Опции:
  --output, -o   Путь для сохранения конфигурации
  --qwen-path    Путь к Qwen CLI
  --model        Имя модели по умолчанию
  --force        Перезаписать существующий файл
  --quiet, -q    Тихий режим (минимум вывода)
  --verbose, -v  Подробный вывод

Примеры:
  roo-code-provider install
  roo-code-provider install -o ~/.roo-code-provider.json
  roo-code-provider check --verbose
  roo-code-provider generate
`);
}

/**
 * Проверка системы
 */
function checkSystem(verbose = false) {
  log(colors.blue, '\n=== Проверка системы ===\n');
  
  const homeDir = getHomeDir();
  const qwenCliDir = findQwenCliDir();
  const rooCodeStorage = findRooCodeStorage();
  const qwenInstalled = checkQwenCliInstalled();
  
  let allGood = true;
  
  // Проверка домашней директории
  if (homeDir) {
    log(colors.green, '✓'), log(colors.gray, `  Домашняя директория: ${homeDir}`);
  } else {
    log(colors.red, '✗'), log(colors.red, '  Домашняя директория не найдена');
    allGood = false;
  }
  
  // Проверка Qwen CLI
  if (qwenInstalled) {
    log(colors.green, '✓'), log(colors.gray, '  Qwen CLI установлен');
  } else {
    log(colors.yellow, '⚠'), log(colors.yellow, '  Qwen CLI не найден в PATH');
    if (verbose) {
      log(colors.gray, '    Установите: npm install -g @qwen-code/qwen-cli');
    }
  }
  
  // Проверка директории Qwen
  if (qwenCliDir) {
    log(colors.green, '✓'), log(colors.gray, `  Qwen config: ${qwenCliDir}`);
    
    const settingsPath = path.join(qwenCliDir, 'settings.json');
    const oauthPath = path.join(qwenCliDir, 'oauth_creds.json');
    
    if (pathExists(settingsPath)) {
      log(colors.green, '✓'), log(colors.gray, `  settings.json найден`);
    } else {
      log(colors.yellow, '⚠'), log(colors.yellow, '  settings.json не найден');
    }
    
    if (pathExists(oauthPath)) {
      log(colors.green, '✓'), log(colors.gray, `  oauth_creds.json найден`);
    } else {
      log(colors.yellow, '⚠'), log(colors.yellow, '  oauth_creds.json не найден (выполните qwen login)');
    }
  } else {
    log(colors.red, '✗'), log(colors.red, '  Директория Qwen CLI не найдена');
    log(colors.gray, '    Выполните: qwen login');
    allGood = false;
  }
  
  // Проверка Roo Code
  if (rooCodeStorage) {
    log(colors.green, '✓'), log(colors.gray, `  Roo Code storage: ${rooCodeStorage}`);
  } else {
    log(colors.yellow, '⚠'), log(colors.yellow, '  Roo Code storage не найден');
    if (verbose) {
      log(colors.gray, '    Установите расширение Roo Code в VSCode');
    }
  }
  
  return allGood;
}

/**
 * Установка конфигурации
 */
function install(options = {}) {
  const { output, qwenPath, model, force, quiet, verbose } = options;
  
  if (!quiet) {
    log(colors.cyan, '\n=== Установка Roo Code Provider ===\n');
  }
  
  // Генерация конфигурации
  const genOptions = {};
  if (qwenPath) genOptions.qwenCliPath = qwenPath;
  if (model) genOptions.modelName = model;
  
  const { config, detectedPaths } = generateConfig(genOptions);
  
  if (verbose) {
    log(colors.blue, '\nОбнаруженные пути:');
    console.log(detectedPaths);
  }
  
  // Определение пути сохранения
  let outputPath = output;
  if (!outputPath) {
    const homeDir = getHomeDir();
    outputPath = path.join(homeDir, CONFIG_FILENAME);
  }
  
  // Проверка существования файла
  if (pathExists(outputPath) && !force) {
    log(colors.yellow, `\n⚠ Файл уже существует: ${outputPath}`);
    log(colors.yellow, '  Используйте --force для перезаписи или укажите другой --output\n');
    return false;
  }
  
  // Сохранение
  try {
    saveConfig(config, outputPath);
    
    if (!quiet) {
      log(colors.green, '\n✓ Конфигурация успешно сохранена!\n');
      log(colors.gray, `  Путь: ${outputPath}`);
      log(colors.gray, `  Модель: ${config.model.default}`);
      log(colors.gray, `  Qwen CLI: ${config.qwenCliPath}\n`);
      
      log(colors.blue, 'Следующие шаги:');
      log(colors.gray, '  1. Откройте VSCode');
      log(colors.gray, '  2. Перейдите в настройки Roo Code');
      log(colors.gray, `  3. Укажите путь к конфигу: ${outputPath}`);
      log(colors.gray, '  4. Перезапустите VSCode\n');
    }
    
    return true;
  } catch (e) {
    log(colors.red, `\n✗ Ошибка сохранения: ${e.message}\n`);
    return false;
  }
}

/**
 * Обновление конфигурации
 */
function update(options = {}) {
  const homeDir = getHomeDir();
  const defaultOutput = path.join(homeDir, CONFIG_FILENAME);
  
  options.output = options.output || defaultOutput;
  options.force = true; // Всегда перезаписывать при обновлении
  
  log(colors.cyan, '\n=== Обновление конфигурации ===\n');
  
  if (!pathExists(options.output)) {
    log(colors.yellow, `  Конфигурация не найдена: ${options.output}`);
    log(colors.gray, '  Выполните установку: roo-code-provider install\n');
    return false;
  }
  
  return install(options);
}

/**
 * Удаление конфигурации
 */
function remove(output) {
  const homeDir = getHomeDir();
  const configPath = output || path.join(homeDir, CONFIG_FILENAME);
  
  log(colors.cyan, '\n=== Удаление конфигурации ===\n');
  
  if (!pathExists(configPath)) {
    log(colors.yellow, `  Конфигурация не найдена: ${configPath}\n`);
    return false;
  }
  
  try {
    fs.unlinkSync(configPath);
    log(colors.green, `✓ Конфигурация удалена: ${configPath}\n`);
    return true;
  } catch (e) {
    log(colors.red, `\n✗ Ошибка удаления: ${e.message}\n`);
    return false;
  }
}

/**
 * Генерация без сохранения
 */
function generate(options = {}) {
  log(colors.cyan, '\n=== Генерация конфигурации ===\n');
  
  const genOptions = {};
  if (options.qwenPath) genOptions.qwenCliPath = options.qwenPath;
  if (options.model) genOptions.modelName = options.model;
  
  const { config, detectedPaths } = generateConfig(genOptions);
  
  console.log(JSON.stringify(config, null, 2));
  
  if (options.verbose) {
    log(colors.blue, '\n# Обнаруженные пути:');
    console.log(JSON.stringify(detectedPaths, null, 2));
  }
}

/**
 * Парсинг аргументов командной строки
 */
function parseArgs(args) {
  const options = {
    command: 'install',
    output: null,
    qwenPath: null,
    model: null,
    force: false,
    quiet: false,
    verbose: false
  };
  
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    
    if (arg === '--help' || arg === '-h' || arg === 'help') {
      showHelp();
      process.exit(0);
    }
    
    if (arg === '--version' || arg === '-v' && i === 0) {
      console.log(`v${VERSION}`);
      process.exit(0);
    }
    
    if (arg === '--verbose' || arg === '-v') {
      options.verbose = true;
    } else if (arg === '--quiet' || arg === '-q') {
      options.quiet = true;
    } else if (arg === '--force' || arg === '-f') {
      options.force = true;
    } else if (arg === '--output' || arg === '-o') {
      options.output = args[++i];
    } else if (arg === '--qwen-path') {
      options.qwenPath = args[++i];
    } else if (arg === '--model') {
      options.model = args[++i];
    } else if (arg.startsWith('-')) {
      log(colors.yellow, `Неизвестная опция: ${arg}`);
    } else if (!arg.startsWith('-')) {
      // Команда
      if (['install', 'i'].includes(arg)) options.command = 'install';
      else if (['generate', 'g'].includes(arg)) options.command = 'generate';
      else if (['check', 'c'].includes(arg)) options.command = 'check';
      else if (['update', 'u'].includes(arg)) options.command = 'update';
      else if (['remove', 'r'].includes(arg)) options.command = 'remove';
    }
  }
  
  return options;
}

/**
 * Главная функция
 */
function main() {
  const args = process.argv.slice(2);
  const options = parseArgs(args);
  
  switch (options.command) {
    case 'install':
      install(options);
      break;
    case 'generate':
      generate(options);
      break;
    case 'check':
      checkSystem(options.verbose);
      break;
    case 'update':
      update(options);
      break;
    case 'remove':
      remove(options.output);
      break;
    default:
      install(options);
  }
}

// Запуск
main();
