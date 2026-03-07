/**
 * Генератор конфигурации roo-code-provider.json
 */

const fs = require('fs');
const path = require('path');
const { getHomeDir, findQwenCliDir, findRooCodeStorage, getQwenCliPath, readQwenSettings, getModelName, getRooCodeTasksPath } = require('./utils');

/**
 * Шаблон конфигурации
 */
const TEMPLATE = `{
  "provider": "qwen-code-cli",
  "apiConfigName": "qwen",
  "qwenCliPath": "{{QWEN_CLI_PATH}}",
  "authConfig": {
    "type": "oauth",
    "credsPath": "{{QWEN_OAUTH_PATH}}",
    "settingsPath": "{{QWEN_SETTINGS_PATH}}"
  },
  "model": {
    "default": "{{MODEL_NAME}}",
    "temperature": 0.2,
    "maxTokens": 4096
  },
  "quotaTracking": {
    "enabled": true,
    "syncWithCli": true,
    "storagePath": "{{ROO_CODE_STORAGE_PATH}}"
  },
  "endpoints": {
    "oauth": "https://oauth.qwen.ai",
    "dashscope": "https://dashscope.aliyuncs.com/compatible-mode/v1",
    "codingPlan": "https://coding.dashscope.aliyuncs.com/v1"
  }
}
`;

/**
 * Заменить плейсхолдеры в шаблоне
 */
function replaceTemplate(template, values) {
  let result = template;
  for (const [key, value] of Object.entries(values)) {
    result = result.replace(new RegExp(`{{${key}}}`, 'g'), value || '');
  }
  return result;
}

/**
 * Сгенерировать конфигурацию
 */
function generateConfig(options = {}) {
  const homeDir = getHomeDir();
  const qwenCliDir = findQwenCliDir();
  const rooCodeStorage = findRooCodeStorage();
  const qwenCliPath = getQwenCliPath();

  // Пути к файлам Qwen
  const qwenSettingsPath = qwenCliDir ? path.join(qwenCliDir, 'settings.json') : '';
  const qwenOauthPath = qwenCliDir ? path.join(qwenCliDir, 'oauth_creds.json') : '';

  // Путь к задачам Roo Code
  const rooCodeTasksPath = getRooCodeTasksPath(rooCodeStorage);

  // Получить имя модели из настроек
  let modelName = 'coder-model';
  if (qwenCliDir) {
    const settings = readQwenSettings(qwenCliDir);
    modelName = getModelName(settings);
  }

  // Переопределение из опций
  const finalQwenCliPath = options.qwenCliPath || qwenCliPath;
  const finalModelName = options.modelName || modelName;

  const values = {
    QWEN_CLI_PATH: finalQwenCliPath,
    QWEN_OAUTH_PATH: qwenOauthPath,
    QWEN_SETTINGS_PATH: qwenSettingsPath,
    MODEL_NAME: finalModelName,
    ROO_CODE_STORAGE_PATH: rooCodeTasksPath || ''
  };

  return {
    config: JSON.parse(replaceTemplate(TEMPLATE, values)),
    raw: replaceTemplate(TEMPLATE, values),
    detectedPaths: {
      qwenCliDir,
      qwenSettingsPath,
      qwenOauthPath,
      rooCodeStorage,
      rooCodeTasksPath,
      qwenCliPath: finalQwenCliPath,
      modelName: finalModelName
    }
  };
}

/**
 * Сохранить конфигурацию в файл
 */
function saveConfig(config, outputPath) {
  const dir = path.dirname(outputPath);
  
  // Создать директорию если не существует
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  fs.writeFileSync(outputPath, JSON.stringify(config, null, 2), 'utf8');
  return true;
}

/**
 * Загрузить существующую конфигурацию
 */
function loadConfig(configPath) {
  try {
    const content = fs.readFileSync(configPath, 'utf8');
    return JSON.parse(content);
  } catch (e) {
    return null;
  }
}

module.exports = {
  generateConfig,
  saveConfig,
  loadConfig,
  TEMPLATE
};
