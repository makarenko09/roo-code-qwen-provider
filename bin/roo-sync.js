#!/usr/bin/env node

/**
 * roo-sync CLI
 * Обёртка для запуска bash-скрипта синхронизации
 */

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

// Найти директорию пакета
let scriptDir = __dirname;

// Если установлено глобально, scriptDir будет в node_modules/roo-code-qwen-provider/bin
// или в lib/node_modules/roo-code-qwen-provider/bin
if (scriptDir.includes('node_modules')) {
  // Ищем директорию пакета (родительская директория node_modules)
  const pkgDir = path.join(scriptDir, '..');
  // scripts находится на том же уровне что и bin
  scriptDir = path.join(pkgDir, 'scripts');
} else {
  // Локальная разработка
  scriptDir = path.join(__dirname, '..', 'scripts');
}

const syncScript = path.join(scriptDir, 'sync-roo-quota.sh');

// Проверка существования скрипта
if (!fs.existsSync(syncScript)) {
  console.error('❌ Скрипт синхронизации не найден:', syncScript);
  console.error('Путь поиска:', scriptDir);
  console.error('Убедитесь, что пакет установлен корректно.');
  process.exit(1);
}

// Запуск bash-скрипта с передачей аргументов
const args = process.argv.slice(2);
const bash = spawn('bash', [syncScript, ...args], {
  stdio: 'inherit',
  shell: true
});

bash.on('close', (code) => {
  process.exit(code);
});

bash.on('error', (err) => {
  console.error('❌ Ошибка запуска скрипта:', err.message);
  process.exit(1);
});
