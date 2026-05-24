const admin = require('firebase-admin');
const functions = require('firebase-functions');
const { onRequest } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const { extractTokenFromHeader, verifyIdToken } = require('./utils/auth');
const { callGeminiAPI } = require('./utils/gemini');
const { detectLanguage, getLanguageName } = require('./utils/language');
const {
  TRIPMATE_SYSTEM_INSTRUCTION,
  ERROR_MESSAGES,
} = require('./constants');

admin.initializeApp();

const geminiApiKey = defineSecret('GEMINI_API_KEY');

exports.geminiChat = onRequest(
  { secrets: [geminiApiKey], region: 'us-central1' },
  async (req, res) => {
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    if (req.method === 'OPTIONS') {
      return res.status(204).send('');
    }

    if (req.method !== 'POST') {
      return res.status(405).json({
        success: false,
        error: 'Method Not Allowed',
        code: 'method_not_allowed',
      });
    }

    try {
      const authHeader = req.headers.authorization;
      if (!authHeader) {
        return res.status(401).json({
          success: false,
          error: ERROR_MESSAGES.MISSING_TOKEN,
          code: 'auth_error',
        });
      }

      const token = extractTokenFromHeader(authHeader);
      if (!token) {
        return res.status(401).json({
          success: false,
          error: ERROR_MESSAGES.INVALID_TOKEN,
          code: 'auth_error',
        });
      }

      let decodedToken;
      try {
        decodedToken = await verifyIdToken(token);
      } catch (authError) {
        return res.status(401).json({
          success: false,
          error: ERROR_MESSAGES.INVALID_TOKEN,
          code: 'auth_error',
        });
      }

      const { message } = req.body;

      if (typeof message !== 'string' || message.trim().length === 0) {
        return res.status(400).json({
          success: false,
          error: ERROR_MESSAGES.INVALID_REQUEST,
          code: 'invalid_request',
        });
      }

      if (message.length > 1000) {
        return res.status(400).json({
          success: false,
          error: ERROR_MESSAGES.MESSAGE_TOO_LONG,
          code: 'invalid_request',
        });
      }

      const userLanguage = detectLanguage(message);
      const languageName = getLanguageName(userLanguage);

      const systemInstruction = TRIPMATE_SYSTEM_INSTRUCTION.replace(
        '{LANGUAGE}',
        languageName
      );

      const apiKey = geminiApiKey.value();
      if (!apiKey) {
        console.error('GEMINI_API_KEY secret not set');
        return res.status(502).json({
          success: false,
          error: ERROR_MESSAGES.MISSING_API_KEY,
          code: 'api_error',
        });
      }

      let aiResponse;
      try {
        aiResponse = await callGeminiAPI(
          message,
          systemInstruction,
          apiKey
        );
      } catch (geminiError) {
        console.error('Gemini API error:', geminiError.message);
        return res.status(502).json({
          success: false,
          error: `${ERROR_MESSAGES.GEMINI_ERROR}: ${geminiError.message}`,
          code: 'api_error',
        });
      }

      return res.status(200).json({
        success: true,
        text: aiResponse,
      });
    } catch (error) {
      console.error('Unexpected error in geminiChat:', error);
      return res.status(500).json({
        success: false,
        error: ERROR_MESSAGES.INTERNAL_ERROR,
        code: 'internal_error',
      });
    }
  }
);
