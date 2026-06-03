import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AiChatService {
  static final AiChatService _instance = AiChatService._internal();

  factory AiChatService.instance() => _instance;

  AiChatService._internal();

  static const String _functionUrlOverride = String.fromEnvironment(
    'AI_CHAT_FUNCTION_URL',
  );
  static const String _functionUrl =
      'https://us-central1-touristique-guide-2026.cloudfunctions.net/geminiChat';
  static const String _localFunctionUrl =
      'http://127.0.0.1:5001/touristique-guide-2026/us-central1/geminiChat';

  final _auth = FirebaseAuth.instance;

  String get _resolvedFunctionUrl {
    if (_functionUrlOverride.isNotEmpty) {
      return _functionUrlOverride;
    }
    if (kDebugMode && kIsWeb) {
      return _localFunctionUrl;
    }
    return _functionUrl;
  }

  /// Sends a message to the AI chat backend and returns the AI response.
  ///
  /// [message] - The user's chat message (required, non-empty)
  /// [language] - Optional language code, auto-detected if omitted
  ///
  /// Returns the AI's response text.
  ///
  /// Throws [AiChatException] with codes:
  ///   - 'auth_error': User not authenticated or Firebase token invalid
  ///   - 'network_error': Network connection failed or timeout
  ///   - 'api_error': Cloud Function returned an error
  ///   - 'parse_error': Response parsing failed
  Future<String> sendMessage(String message, {String? language}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw AiChatException(
        'You must be logged in to use the chat feature.',
        code: 'auth_error',
      );
    }

    String? idToken;
    try {
      idToken = await currentUser.getIdToken();
    } catch (e) {
      throw AiChatException(
        'Failed to obtain authentication token: $e',
        code: 'auth_error',
      );
    }

    if (idToken == null) {
      throw AiChatException(
        'Failed to obtain authentication token.',
        code: 'auth_error',
      );
    }

    final requestBody = {
      'message': message,
      if (language != null) 'language': language,
    };

    try {
      final response = await http
          .post(
            Uri.parse(_resolvedFunctionUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw AiChatException(
              'Request timed out. Please try again.',
              code: 'network_error',
            ),
          );

      if (response.statusCode == 401) {
        if (kDebugMode && kIsWeb) {
          debugPrint('geminiChat 401 response body: ${response.body}');
        }
        throw AiChatException(
          kDebugMode && response.body.isNotEmpty
              ? 'Authentication failed. Please log in again. Server response: ${response.body}'
              : 'Authentication failed. Please log in again.',
          code: 'auth_error',
        );
      }

      if (response.statusCode == 400) {
        try {
          final errorData = jsonDecode(response.body);
          throw AiChatException(
            errorData['error'] ?? 'Invalid request.',
            code: 'api_error',
          );
        } catch (e) {
          if (e is AiChatException) rethrow;
          throw AiChatException(
            'Invalid request to AI service.',
            code: 'api_error',
          );
        }
      }

      if (response.statusCode == 502 || response.statusCode == 503) {
        throw AiChatException(
          'AI service temporarily unavailable. Please try again in a moment.',
          code: 'api_error',
        );
      }

      if (response.statusCode != 200) {
        throw AiChatException(
          'Unexpected error from AI service (${response.statusCode}).',
          code: 'api_error',
        );
      }

      final responseData = jsonDecode(response.body);
      if (responseData['success'] != true) {
        final error = responseData['error'] ?? 'Unknown error';
        throw AiChatException(
          error,
          code: responseData['code'] ?? 'api_error',
        );
      }

      final text = responseData['text'];
      if (text is! String || text.isEmpty) {
        throw AiChatException(
          'Invalid response from AI service.',
          code: 'parse_error',
        );
      }

      return text;
    } on AiChatException {
      rethrow;
    } on http.ClientException catch (e) {
      throw AiChatException(
        'Network error: ${e.message}',
        code: 'network_error',
      );
    } catch (e) {
      throw AiChatException(
        'Unexpected error: $e',
        code: 'api_error',
      );
    }
  }
}

/// Exception thrown by the AI chat service.
class AiChatException implements Exception {
  final String message;
  final String? code; // 'auth_error', 'network_error', 'api_error', 'parse_error'

  const AiChatException(this.message, {this.code});

  @override
  String toString() => 'AiChatException: $message (code: $code)';
}
