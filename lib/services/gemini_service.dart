import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:myapp/models/blood_pressure.dart';
import 'package:myapp/models/creatine.dart';
import 'package:myapp/models/weight.dart';
import 'package:myapp/utils/logger_config.dart';
import '../config/app_config.dart';
// Import SupabaseService
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiService {
  static const _proxyUrl = AppConfig.geminiProxyUrl;
  

  static Future<String> getFoodRecommendation(String foodItemName) async {
    final jwt = Supabase.instance.client.auth.currentSession?.accessToken;
    logger.i('Requested JWT: $jwt');
    if (jwt == null) {
      throw Exception('User is not authenticated. Please log in first.');
    }
    final systemPreamble =
      'You are an expert renal dietician with 20 years of experience for Indian adult CKD patients. '
      'Give short and concise, plain-English explanations.';
    final prompt = '''
 provide potassium phosporus sodium and protein content per 100 gram with a approx range in side by side format for $foodItemName for Indian CKD patient. 
 Also Provide a short and concise general explanation on whether $foodItemName is generally good, moderate, or to be 
 avoided for Indian CKD patients. Keep the explanation easy to understand.
''';
    final body = {
      'model': 'gemini-2.0-flash', // or omit to use DEFAULT_MODEL in your function
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': systemPreamble}, // your system instruction
            {'text': prompt},
          ],
        }
      ],
    };
final resp = await http
        .post(
          Uri.parse(_proxyUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));

    if (resp.statusCode != 200) {
      throw Exception('Proxy error ${resp.statusCode}: ${resp.body}');
    }
    
    try {
      //final content = [Content.text(prompt)];
      //final response = await model.generateContent(content);
      final Map<String, dynamic> data = jsonDecode(resp.body);
    final text = _extractGeminiText(data);
      //final text = response.text;
      logger.i('Received response from Gemini: $text');
      return text ?? 'No response from Gemini API';
    } catch (e) {
      return 'Error fetching data from Gemini API: $e';
    }
  }

  static Future<Map<String, dynamic>> detectVitalAnomaly({
    BloodPressure? bloodPressure,
    Creatine? creatine,
    Weight? weight,
  }) async {
        final jwt = Supabase.instance.client.auth.currentSession?.accessToken;
    try {
          final systemPreamble = 'You are a nephrology clinician writing for Indian adult CKD patients. '
      'Give concise, plain-English explanations. Avoid diagnosis or medication changes.';
      String prompt = '';
      if (bloodPressure != null) {
        prompt =
            '''Analyze the following BP ${bloodPressure.systolic}, Diastolic: ${bloodPressure.diastolic}. 
        Targets for adult CKD patients: recommended goal <=130/80 mmHg.
         Provide a brief explanation and recommendations.
''';
      } else if (creatine != null) {
        prompt =
            'Analyze the following creatinine level: ${creatine.value}. Is this level anomalous? Provide a brief explanation and recommendations.';
      } else if (weight != null) {
        prompt =
            'Analyze the following weight: ${weight.value}. Is this weight anomalous? Provide a brief explanation and recommendations.';
      }

          final body = {
      'model': 'gemini-2.0-flash', // or omit to use DEFAULT_MODEL in your function
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': systemPreamble}, // your system instruction
            {'text': prompt},
          ],
        }
      ],
    };
final resp = await http
        .post(
          Uri.parse(_proxyUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));

    if (resp.statusCode != 200) {
      throw Exception('Proxy error ${resp.statusCode}: ${resp.body}');
    }

      //final content = [Content.text(prompt)];
      logger.i('Sending prompt to Gemini: $prompt');
      //final response = await _gemini.generateContent(content);

            final Map<String, dynamic> data = jsonDecode(resp.body);
    final text = _extractGeminiText(data);
      //final text = response.text;
      logger.i('Received response from Gemini: $text');

      if (text == null) {
        logger.e('No response from Gemini API.');
        return {
          'isAnomalous': false,
          'explanation': 'No response from Gemini API.',
          'recommendations': [],
        };
      }

      // Parse the response from Gemini (This will need to be adjusted based on the actual response format)
      bool isAnomalous = text.toLowerCase().contains('anomalous');
      String explanation = text;
      List<String> recommendations =
          []; // You'll need to parse these from the text as well

      return {
        'isAnomalous': isAnomalous,
        'explanation': explanation,
        'recommendations': recommendations,
      };
    } catch (e) {
      logger.e('Error detecting anomaly: $e');
      return {
        'isAnomalous': false,
        'explanation': 'Error detecting anomaly: $e',
        'recommendations': [],
      };
    }
  }

  static String? _extractGeminiText(Map<String, dynamic> json) {
    // Expected path: candidates[0].content.parts[0].text
    final candidates = json['candidates'];
    if (candidates is List && candidates.isNotEmpty) {
      final content = candidates[0]['content'];
      final parts = content?['parts'];
      if (parts is List && parts.isNotEmpty) {
        final first = parts[0];
        final t = first['text'];
        if (t is String) return t;
      }
    }
    // Some models return safety or alternate parts; try to join any text parts
    if (candidates is List && candidates.isNotEmpty) {
      final content = candidates[0]['content'];
      final parts = content?['parts'];
      if (parts is List) {
        final texts = parts
            .map((p) => p is Map && p['text'] is String ? p['text'] as String : '')
            .where((s) => s.isNotEmpty)
            .toList();
        if (texts.isNotEmpty) return texts.join('\n');
      }
    }
    return null;
    }
}
