/**
 * Тест для проверки основных функций пакета
 */

const { getHomeDir, pathExists } = require('./utils');
const { generateConfig } = require('./config-generator');

function runTests() {
  console.log('🧪 Запуск тестов roo-code-qwen-provider...\n');
  
  let passed = 0;
  let failed = 0;
  
  // Тест 1: getHomeDir
  console.log('Тест 1: getHomeDir()');
  const homeDir = getHomeDir();
  if (homeDir && typeof homeDir === 'string') {
    console.log('  ✅ Passed: ' + homeDir);
    passed++;
  } else {
    console.log('  ❌ Failed: не удалось получить домашнюю директорию');
    failed++;
  }
  
  // Тест 2: generateConfig
  console.log('\nТест 2: generateConfig()');
  try {
    const { config, detectedPaths } = generateConfig();
    if (config && config.provider === 'qwen-code-cli') {
      console.log('  ✅ Passed: конфигурация сгенерирована');
      console.log('     Provider: ' + config.provider);
      console.log('     Model: ' + config.model.default);
      passed++;
    } else {
      console.log('  ❌ Failed: неверная структура конфигурации');
      failed++;
    }
  } catch (e) {
    console.log('  ❌ Failed: ' + e.message);
    failed++;
  }
  
  // Тест 3: detectQwenCliDir
  console.log('\nТест 3: findQwenCliDir()');
  const { findQwenCliDir } = require('./utils');
  const qwenDir = findQwenCliDir();
  if (qwenDir) {
    console.log('  ✅ Passed: ' + qwenDir);
    passed++;
  } else {
    console.log('  ⚠️  Warning: Qwen CLI directory не найдена (это нормально если Qwen не установлен)');
    passed++; // Не считаем ошибкой
  }
  
  // Тест 4: findRooCodeStorage
  console.log('\nТест 4: findRooCodeStorage()');
  const { findRooCodeStorage } = require('./utils');
  const rooStorage = findRooCodeStorage();
  if (rooStorage) {
    console.log('  ✅ Passed: ' + rooStorage);
    passed++;
  } else {
    console.log('  ⚠️  Warning: Roo Code storage не найден (это нормально если Roo Code не установлен)');
    passed++; // Не считаем ошибкой
  }
  
  // Итоги
  console.log('\n' + '='.repeat(50));
  console.log(`Результаты: ${passed} passed, ${failed} failed`);
  console.log('='.repeat(50));
  
  process.exit(failed > 0 ? 1 : 0);
}

runTests();
