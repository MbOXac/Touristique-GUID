const axios = require('axios');

const GEMINI_API_ENDPOINT = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

async function callGeminiAPI(userMessage, systemInstruction, apiKey) {
  if (!apiKey) {
    throw new Error('Gemini API key not configured');
  }

  const requestBody = {
    systemInstruction: {
      parts: [{ text: systemInstruction }],
    },
    contents: [
      {
        parts: [{ text: userMessage }],
      },
    ],
  };

  try {
    const response = await axios.post(
      `${GEMINI_API_ENDPOINT}?key=${apiKey}`,
      requestBody,
      {
        timeout: 30000,
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    const candidates = response.data?.candidates;
    if (!candidates || candidates.length === 0) {
      throw new Error('No response candidates from Gemini API');
    }

    const content = candidates[0]?.content;
    if (!content || !content.parts || content.parts.length === 0) {
      throw new Error('Invalid response structure from Gemini API');
    }

    const responseText = content.parts[0].text;
    if (!responseText) {
      throw new Error('Empty response text from Gemini API');
    }

    return responseText.trim();
  } catch (error) {
    if (error.response?.status === 429) {
      throw new Error('Rate limited by Gemini API. Please try again later.');
    }
    if (error.response?.status === 401) {
      throw new Error('Invalid Gemini API key');
    }
    if (error.code === 'ECONNABORTED') {
      throw new Error('Gemini API request timeout');
    }
    throw new Error(`Gemini API error: ${error.message}`);
  }
}

module.exports = {
  callGeminiAPI,
};
