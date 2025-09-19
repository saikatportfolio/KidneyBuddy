import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import '../models/food_item.dart';
import '../utils/logger_config.dart'; // Import the logger

class FoodRecommendationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<FoodItem>> getRecommendedFoods(
    String selectedCategory,
    int selectedFilters,
  ) async {
    try {
      var query = _supabase
          .from('foodlist') // Change to your Supabase table name
          .select(); // Select all columns

      if (selectedCategory.isNotEmpty) {
        if (selectedCategory != "All") {
          query = query.eq('category', selectedCategory);
        }
      }

        switch (selectedFilters) {
          case 12:
            query = query.eq('potassium', selectedFilters);
            break;
          case 13:
            query = query.eq('potassium', selectedFilters);
            break;
          case 14:
            query = query.eq('potassium', selectedFilters);
            break;
          case 22:
            query = query.eq('phosphorus', selectedFilters);
            break;
          case 23:
            query = query.eq('phosphorus', selectedFilters);
            break;
          case 24:
            query = query.eq('phosphorus', selectedFilters);
            break;
          case 32:
            query = query.eq('sodium', selectedFilters);
            break;
          case 33:
            query = query.eq('sodium', selectedFilters);
            break;
          case 34:
            query = query.eq('sodium', selectedFilters);
            break;
          default:
            query = query;
        }
      

      final response = await query;

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
