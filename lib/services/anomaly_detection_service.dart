import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/models/blood_pressure.dart';
import 'package:myapp/models/creatine.dart';
import 'package:myapp/models/weight.dart';
import 'package:myapp/utils/logger_config.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // Import Gemini AI

class AnomalyDetectionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _gemini = GenerativeModel(model: 'gemini-2.0-flash', apiKey: 'AIzaSyDVg3LAJPdd7S1KKHn7G2210kVzTrXYm4Q'); // Replace with your Gemini API key

  Future<Map<String, dynamic>> detectVitalAnomaly({
    BloodPressure? bloodPressure,
    Creatine? creatine,
    Weight? weight,
  }) async {
    try {
      String prompt = '';
      if (bloodPressure != null) {
        prompt = 'Analyze the following blood pressure reading: Systolic: ${bloodPressure.systolic}, Diastolic: ${bloodPressure.diastolic}. Is this reading anomalous? Provide a brief explanation and recommendations.';
      } else if (creatine != null) {
        prompt = 'Analyze the following creatinine level: ${creatine.value}. Is this level anomalous? Provide a brief explanation and recommendations.';
      } else if (weight != null) {
        prompt = 'Analyze the following weight: ${weight.value}. Is this weight anomalous? Provide a brief explanation and recommendations.';
      }

      final content = [Content.text(prompt)];
      logger.i('Sending prompt to Gemini: $prompt');
      final response = await _gemini.generateContent(content);
      final text = response.text;
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
      List<String> recommendations = []; // You'll need to parse these from the text as well

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
}
