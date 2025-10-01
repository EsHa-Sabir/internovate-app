// lib/services/ai_courses/gemini_api_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intern_management_app/api_key.dart';

class GeminiApiClient {
  final String _apiKey = aiCoursesAPIKey;
  final String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=';

  Future<Map<String, dynamic>> generateLayout({required String prompt}) async {
    return _callGeminiAPI(prompt, isContent: false);
  }

  Future<Map<String, dynamic>> generateContent({required String prompt}) async {
    return _callGeminiAPI(prompt, isContent: true);
  }

  Future<Map<String, dynamic>> _callGeminiAPI(String prompt,
      {bool isContent = false}) async {
    if (_apiKey.isEmpty) {
      throw Exception("Gemini API key is not configured.");
    }

    final url = Uri.parse('$_baseUrl$_apiKey');

    final body = jsonEncode({
      'contents': [
        {'parts': [{'text': prompt}]}
      ]
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
          'API request failed with status: ${response.statusCode}\nResponse body: ${response.body}');
    }

    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse['candidates'] == null ||
        jsonResponse['candidates'].isEmpty) {
      throw Exception("No candidates returned from Gemini.");
    }

    String textContent =
        jsonResponse['candidates'][0]['content']['parts'][0]['text'] ?? '';
    print("📥 Raw AI Response: $textContent");

    try {
      // ✅ JSON ko ```json se pehchan kar extract karay
      final jsonStartMarker = '```json';
      final jsonEndMarker = '```';

      int startIndex = textContent.indexOf(jsonStartMarker);
      int endIndex = textContent.lastIndexOf(jsonEndMarker);

      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        startIndex += jsonStartMarker.length;
        textContent = textContent.substring(startIndex, endIndex);
      } else {
        // Fallback: Agar markers na milen, toh pehle aur aakhri curly brace ko dhoondhen
        startIndex = textContent.indexOf('{');
        endIndex = textContent.lastIndexOf('}');
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
          textContent = textContent.substring(startIndex, endIndex + 1);
        }
      }

      // ✅ Aam ghaltiyon ko theek karein (smart quotes, trailing commas)
      textContent = textContent
          .replaceAll(RegExp(r'“|”', multiLine: true), '"')
          .replaceAll(RegExp(r',\s*}', multiLine: true), '}')
          .replaceAll(RegExp(r',\s*]', multiLine: true), ']')
          .trim();

      print("✅ CLEANED AI Response: $textContent");

      return jsonDecode(textContent);
    } catch (e) {
      // Agar JSON parse na ho paye
      if (isContent) {
        return {"chapters": []};
      }
      throw Exception(
          'Failed to parse JSON from AI response: $e\nOriginal content: $textContent');
    }
  }
}