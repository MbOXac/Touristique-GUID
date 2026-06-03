import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  late final GenerativeModel _model;
  late ChatSession _chat;

  GeminiService() {
    if (_apiKey.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY not found. Make sure .env file exists in project root.',
      );
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash', // ✅ This model works with your key
      apiKey: _apiKey,
      systemInstruction: Content.system(
        '''You are a friendly AI travel assistant for the Touristique GUID app, 
specialized in Southeast Morocco (Errachidia, Merzouga, Rissani, Erfoud, 
Tinghir, Ouarzazate, Zagora, Midelt).

Help users with:
- Travel itineraries and day plans
- Riads, hotels, and accommodations
- Desert tours, hiking, camel trekking, 4x4 trips
- Local culture, souks, traditional food
- Hidden gems and authentic experiences

Reply in the SAME LANGUAGE the user writes in (Arabic, French, English).
Keep responses concise, friendly, and practical. Use emojis when appropriate.''',
      ),
    );

    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? 'Sorry, I could not generate a response. Please try again.';
    } catch (e) {
      return '⚠️ Error: ${e.toString()}\n\nPlease check your internet connection.';
    }
  }

  void resetChat() {
    _chat = _model.startChat();
  }
}