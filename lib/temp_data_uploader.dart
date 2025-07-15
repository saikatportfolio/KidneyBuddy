import 'package:myapp/models/food_item.dart';
import 'package:myapp/services/food_recommendation_service.dart';
import 'package:myapp/utils/logger_config.dart'; // Import the logger

class TempDataUploTempader {
  static Future<void> uploadSampleFoods() async {
    final service = FoodRecommendationService();

    List<FoodItem> sampleFoods = [
      FoodItem(
        id: 1,
        name: 'Idli',
        sodium: 50,
        potassium: 60,
        phosphorus: 40,
        protein: 2.5,
        carbs: 20.0, // Placeholder
        fat: 1.0, // Placeholder
        category: 'Plant Protein', // Changed from 'Breakfast'
        source: 'South Indian', // Placeholder
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Idli_Sambar_and_Chutney.jpg/1200px-Idli_Sambar_and_Chutney.jpg',
      ),
      FoodItem(
        id: 2,
        name: 'Dosa',
        sodium: 70,
        potassium: 80,
        phosphorus: 50,
        protein: 3.0,
        carbs: 25.0, // Placeholder
        fat: 2.0, // Placeholder
        category: 'Plant Protein', // Changed from 'Breakfast'
        source: 'South Indian', // Placeholder
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Masala_Dosa_with_Sambar_and_Chutney.jpg/1200px-Masala_Dosa_with_Sambar_and_Chutney.jpg',
      ),
      FoodItem(
        id: 3,
        name: 'Palak Paneer',
        sodium: 300,
        potassium: 450,
        phosphorus: 200,
        protein: 15.0,
        carbs: 10.0, // Placeholder
        fat: 18.0, // Placeholder
        category: 'Vegetable',
        source: 'North Indian', // Placeholder
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Palak_Paneer.jpg/1200px-Palak_Paneer.jpg',
      ),
      FoodItem(
        id: 4,
        name: 'Carrot',
        sodium: 40,
        potassium: 320,
        phosphorus: 35,
        protein: 0.9,
        carbs: 10.0, // Placeholder
        fat: 0.2, // Placeholder
        category: 'Vegetable',
        source: 'General', // Placeholder
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Carrots_in_a_basket.jpg/1200px-Carrots_in_a_basket.jpg',
      ),
      FoodItem(
        id: 5,
        name: 'Dal Makhani',
        sodium: 350,
        potassium: 500,
        phosphorus: 250,
        protein: 12.0,
        carbs: 30.0, // Placeholder
        fat: 10.0, // Placeholder
        category: 'Main Course',
        source: 'Punjabi', // Placeholder
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Dal_Makhani.jpg/1200px-Dal_Makhani.jpg',
      ),
      FoodItem(
        id: 6,
        name: 'Chapati (Whole Wheat)',
        sodium: 5,
        potassium: 70,
        phosphorus: 60,
        protein: 3.0,
        carbs: 15.0, // Placeholder
        fat: 0.5, // Placeholder
        category: 'Bread',
        source: 'Indian', // Placeholder
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/Chapati_Roti.jpg/1200px-Chapati_Roti.jpg',
      ),
      FoodItem(
        id: 7,
        name: 'White Rice',
        sodium: 1,
        potassium: 55,
        phosphorus: 45,
        protein: 2.7,
        carbs: 28.0, // Placeholder
        fat: 0.3, // Placeholder
        category: 'Grains',
        source: 'General', // Placeholder
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/Cooked_white_rice.jpg/1200px-Cooked_white_rice.jpg',
      ),
      FoodItem(
        id: 8,
        name: 'Banana',
        sodium: 1,
        potassium: 422,
        phosphorus: 22,
        protein: 1.3,
        carbs: 23.0, // Placeholder
        fat: 0.3, // Placeholder
        category: 'Fruit',
        source: 'General', // Placeholder
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Bananas_white_background_DS.jpg/1200px-Bananas_white_background_DS.jpg',
      ),
      FoodItem(
        id: 9,
        name: 'Apple',
        sodium: 1,
        potassium: 195,
        phosphorus: 10,
        protein: 0.5,
        carbs: 14.0, // Placeholder
        fat: 0.2, // Placeholder
        category: 'Fruit',
        source: 'General', // Placeholder
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Red_Apple.jpg/1200px-Red_Apple.jpg',
      ),
    ];

    for (var food in sampleFoods) {
      // Check if food item already exists by name before adding
      bool exists = await service.foodItemExistsByName(food.name);
      if (!exists) {
        await service.addFoodItem(food);
      } else {
        logger.d("Food item '${food.name}' already exists, skipping upload.");
      }
    }
    logger.i("Sample food data upload to Supabase complete.");
  }
}
