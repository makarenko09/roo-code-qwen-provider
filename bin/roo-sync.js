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
// Если установлено глобально, scriptDir будет в node_modules
if (scriptDir.includes('node_modules')) {
  // Ищем директорию scripts относительно bin
  scriptDir = path.join(scriptDir, '..', 'roo-code-qwen-provider', 'scripts');
} else {
  // Локальная разработка
  scriptDir = path.join(__dirname, '..', 'scripts');
}

const syncScript = path.join(scriptDir, 'sync-roo-quota.sh');

// Проверка существования скрипта
if (!fs.existsSync(syncScript)) {
  console.error('❌ Скрипт синхронизации не найден:', syncScript);
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
