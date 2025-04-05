import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class GeminiService {
  final String _apiKey = AppConstants.geminiApiKey;
  final String _endpoint = AppConstants.geminiApiEndpoint;

  Future<String> generateContent(String prompt) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY_PLACEHOLDER' || _apiKey.isEmpty) {
       throw Exception('Gemini API Key not configured.');
    }

    final url = Uri.parse('$_endpoint?key=$_apiKey');
    final headers = {'Content-Type': 'application/json'};
    // Basic prompt structure for gemini-pro model
    final body = jsonEncode({
      "contents": [
        {"parts": [{"text": prompt}]}
      ],
      // Add safetySettings, generationConfig if needed
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Adjust parsing based on the actual Gemini API response structure
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content']['parts'][0]['text'];
          return content;
        } else if (data['promptFeedback'] != null) {
          // Handle content filtering or other issues
           return "Error: Received prompt feedback - ${data['promptFeedback']['blockReason'] ?? 'Unknown reason'}";
        }
        return "Error: No content generated.";
      } else {
        print("Gemini API Error: ${response.statusCode} ${response.body}");
        throw Exception('Failed to generate content: ${response.statusCode}');
      }
    } catch (e) {
      print("Error calling Gemini API: $e");
      throw Exception('Failed to connect to Gemini service: $e');
    }
  }
}

// Riverpod provider for the service
final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());