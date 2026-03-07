/**
 * Утилиты для обнаружения путей к конфигурационным файлам
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

/**
 * Получить домашнюю директорию пользователя
 */
function getHomeDir() {
  return process.env.HOME || process.env.USERPROFILE || process.env.HOMEPATH;
}

/**
 * Проверить существование пути
 */
function pathExists(filePath) {
  try {
    return fs.existsSync(filePath);
  } catch (e) {
    return false;
  }
}

/**
 * Найти директорию Qwen CLI
 */
function findQwenCliDir() {
  const homeDir = getHomeDir();
  const possiblePaths = [
    path.join(homeDir, '.qwen'),
    path.join(homeDir, '.config', 'qwen'),
    '/home/*/.qwen',
    '/root/.qwen'
  ];

  for (const p of possiblePaths) {
    if (p.includes('*')) {
      // Глоб-поиск для /home/*
      try {
        const result = execSync(`ls -d ${p} 2>/dev/null`, { encoding: 'utf8' });
        const dirs = result.trim().split('\n').filter(Boolean);
        for (const dir of dirs) {
          if (pathExists(path.join(dir, 'settings.json'))) {
            return dir;
          }
        }
      } catch (e) {
        // Игнорируем ошибки
      }
    } else {
      if (pathExists(path.join(p, 'settings.json'))) {
        return p;
      }
    }
  }

  return null;
}

/**
 * Найти директорию Roo Code
 */
function findRooCodeStorage() {
  const homeDir = getHomeDir();
  const possiblePaths = [
    path.join(homeDir, '.vscode-server', 'data', 'User', 'globalStorage', 'rooveterinaryinc.roo-cline'),
    path.join(homeDir, '.vscode', 'globalStorage', 'rooveterinaryinc.roo-cline'),
    path.join(homeDir, 'AppData', 'Roaming', 'Code', 'User', 'globalStorage', 'rooveterinaryinc.roo-cline'),
    path.join(homeDir, 'Library', 'Application Support', 'Code', 'User', 'globalStorage', 'rooveterinaryinc.roo-cline')
  ];

  for (const p of possiblePaths) {
    if (pathExists(p)) {
      return p;
    }
  }

  return null;
}

/**
 * Проверить установку qwen CLI
 */
function checkQwenCliInstalled() {
  try {
    execSync('which qwen', { stdio: 'ignore' });
    return true;
  } catch (e) {
    try {
      execSync('where qwen', { stdio: 'ignore' });
      return true;
    } catch (e2) {
      return false;
    }
  }
}

/**
 * Получить путь к бинарнику qwen
 */
function getQwenCliPath() {
  try {
    const result = execSync('which qwen 2>/dev/null || where qwen 2>/dev/null', { encoding: 'utf8' });
    return result.trim().split('\n')[0].trim() || 'qwen';
  } catch (e) {
    return 'qwen';
  }
}

/**
 * Прочитать settings.json Qwen CLI
 */
function readQwenSettings(settingsPath) {
  try {
    const content = fs.readFileSync(path.join(settingsPath, 'settings.json'), 'utf8');
    return JSON.parse(content);
  } catch (e) {
    return null;
  }
}

/**
 * Получить имя модели из настроек
 */
function getModelName(settings) {
  if (settings && settings.model && settings.model.name) {
    return settings.model.name;
  }
  return 'coder-model';
}

/**
 * Получить путь к задачам Roo Code
 */
function getRooCodeTasksPath(storagePath) {
  if (!storagePath) return null;
  const tasksPath = path.join(storagePath, 'tasks');
  return pathExists(tasksPath) ? tasksPath : storagePath;
}

module.exports = {
  getHomeDir,
  pathExists,
  findQwenCliDir,
  findRooCodeStorage,
  checkQwenCliInstalled,
  getQwenCliPath,
  readQwenSettings,
  getModelName,
  getRooCodeTasksPath
};
