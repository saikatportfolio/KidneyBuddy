import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import '../models/food_item.dart';
import '../utils/logger_config.dart'; // Import the logger

class FoodRecommendationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<FoodItem>> getRecommendedFoods(String ckdStage) async {
    try {
      final response = await _supabase
          .from('foodlist') // Change to your Supabase table name
          .select(); // Select all columns

      if (response.isEmpty) {
        logger.i('No data or empty response from Supabase for foodlist.');
        return [];
      }

      List<FoodItem> foods = (response as List).map((map) {
        return FoodItem.fromMap(map as Map<String, dynamic>);
      }).toList();

      return foods;
    } catch (e) {
      logger.e("Error fetching recommended foods from Supabase: $e");
      return [];
    }
  }
}
