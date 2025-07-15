import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import '../models/food_item.dart';
import '../utils/ckd_diet_calculator.dart';
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

      // Calculate safety flags for each food item based on the patient's CKD stage
      for (var food in foods) {
        CKDDietCalculator.calculateSafetyFlag(
          foodItem: food,
          ckdStage: ckdStage,
        );
      }

      return foods;
    } catch (e) {
      logger.e("Error fetching recommended foods from Supabase: $e");
      return [];
    }
  }

  // Method to add a new food item to Supabase (for initial data population)
  Future<void> addFoodItem(FoodItem foodItem) async {
    try {
      await _supabase.from('foodlist').upsert(foodItem.toMap());
      logger.i("Food item upserted to Supabase: ${foodItem.name}");
    } catch (e) {
      logger.e("Error upserting food item to Supabase: $e");
    }
  }

  // Method to check if a food item exists by name in Supabase
  Future<bool> foodItemExistsByName(String name) async {
    try {
      final response = await _supabase
          .from('foodlist')
          .select('name')
          .eq('name', name)
          .limit(1);
      return response.isNotEmpty;
    } catch (e) {
      logger.e("Error checking food item existence in Supabase: $e");
      return false;
    }
  }
}
