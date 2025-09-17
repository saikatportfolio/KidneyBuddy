import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:myapp/utils/logger_config.dart';
import '../config/app_config.dart';

class GeminiService {
  static Future<String> getFoodRecommendation(String foodItemName) async {
    final apiKey = AppConfig.geminiApiKey;
    final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey,systemInstruction: Content.text(
          'You are a expert reneal dietician with 20 years of expereince for Indian adult CKD (Chronic Kidney Disease) patients. '
          'Give short and concise, plain-English explanations.',
        ));

    final prompt = '''
 provide potassium phosporus sodium and protein content per 100 gram with a approx range in side by side format for $foodItemName for Indian CKD patient. 
 Also Provide a short and concise general explanation on whether $foodItemName is generally good, moderate, or to be 
 avoided for Indian CKD patients. Keep the explanation easy to understand.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final text = response.text;
      logger.i('Received response from Gemini: $text');
      return response.text ?? 'No response from Gemini API';
    } catch (e) {
      return 'Error fetching data from Gemini API: $e';
    }
  }
}
