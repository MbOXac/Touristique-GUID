const arabicRegex = /[\u0600-\u06FF]/g;
const frenchRegex = /[àâäéèêëïîôùûüœç]/gi;
const englishRegex = /[a-zA-Z]/g;

function detectLanguage(text) {
  if (!text || text.length === 0) return 'en';

  const arabicMatches = (text.match(arabicRegex) || []).length;
  const frenchMatches = (text.match(frenchRegex) || []).length;
  const englishMatches = (text.match(englishRegex) || []).length;

  const totalLetters = arabicMatches + frenchMatches + englishMatches;
  if (totalLetters === 0) return 'en';

  if (arabicMatches > totalLetters * 0.3) return 'ar';
  if (frenchMatches > totalLetters * 0.2) return 'fr';

  return 'en';
}

function normalizeLanguage(langCode) {
  const supportedLangs = {
    ar: 'ar',
    en: 'en',
    fr: 'fr',
    es: 'es',
    de: 'de',
    'ar-SA': 'ar',
    'ar-AE': 'ar',
    'en-US': 'en',
    'en-GB': 'en',
    'fr-FR': 'fr',
    'es-ES': 'es',
    'de-DE': 'de',
  };

  return supportedLangs[langCode] || 'en';
}

function getLanguageName(langCode) {
  const names = {
    ar: 'Arabic',
    en: 'English',
    fr: 'French',
    es: 'Spanish',
    de: 'German',
  };
  return names[langCode] || 'English';
}

module.exports = {
  detectLanguage,
  normalizeLanguage,
  getLanguageName,
};
