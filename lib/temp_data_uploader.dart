import 'package:uuid/uuid.dart';
import 'package:myapp/models/food_item.dart';
import 'package:myapp/services/food_recommendation_service.dart';

class TempDataUploader {
  static Future<void> uploadSampleFoods() async {
    final service = FoodRecommendationService();
    var uuid = const Uuid();

    List<FoodItem> sampleFoods = [
      FoodItem(
        id: uuid.v4(),
        name: 'Idli',
        description: 'Steamed rice and lentil cakes, a popular South Indian breakfast.',
        sodium: 50,
        potassium: 60,
        phosphorus: 40,
        protein: 2.5,
        category: 'Breakfast',
        isIndianFood: true,
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Idli_Sambar_and_Chutney.jpg/1200px-Idli_Sambar_and_Chutney.jpg',
      ),
      FoodItem(
        id: uuid.v4(),
        name: 'Dosa',
        description: 'Thin, crispy pancake made from fermented batter, often served with sambar and chutney.',
        sodium: 70,
        potassium: 80,
        phosphorus: 50,
        protein: 3.0,
        category: 'Breakfast',
        isIndianFood: true,
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Masala_Dosa_with_Sambar_and_Chutney.jpg/1200px-Masala_Dosa_with_Sambar_and_Chutney.jpg',
      ),
      FoodItem(
        id: uuid.v4(),
        name: 'Palak Paneer',
        description: 'Spinach and cottage cheese curry, rich in flavor.',
        sodium: 300,
        potassium: 450,
        phosphorus: 200,
        protein: 15.0,
        category: 'Main Course',
        isIndianFood: true,
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Palak_Paneer.jpg/1200px-Palak_Paneer.jpg',
      ),
      FoodItem(
        id: uuid.v4(),
        name: 'Dal Makhani',
        description: 'Creamy black lentil curry, a Punjabi specialty.',
        sodium: 350,
        potassium: 500,
        phosphorus: 250,
        protein: 12.0,
        category: 'Main Course',
        isIndianFood: true,
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Dal_Makhani.jpg/1200px-Dal_Makhani.jpg',
      ),
      FoodItem(
        id: uuid.v4(),
        name: 'Chapati (Whole Wheat)',
        description: 'Unleavened flatbread, a staple in Indian cuisine.',
        sodium: 5,
        potassium: 70,
        phosphorus: 60,
        protein: 3.0,
        category: 'Bread',
        isIndianFood: true,
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/Chapati_Roti.jpg/1200px-Chapati_Roti.jpg',
      ),
      FoodItem(
        id: uuid.v4(),
        name: 'White Rice',
        description: 'Plain cooked white rice.',
        sodium: 1,
        potassium: 55,
        phosphorus: 45,
        protein: 2.7,
        category: 'Grains',
        isIndianFood: false, // Though common in India, it's a general food
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/Cooked_white_rice.jpg/1200px-Cooked_white_rice.jpg',
      ),
      FoodItem(
        id: uuid.v4(),
        name: 'Banana',
        description: 'A common fruit, high in potassium.',
        sodium: 1,
        potassium: 422,
        phosphorus: 22,
        protein: 1.3,
        category: 'Fruit',
        isIndianFood: false,
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Bananas_white_background_DS.jpg/1200px-Bananas_white_background_DS.jpg',
      ),
      FoodItem(
        id: uuid.v4(),
        name: 'Apple',
        description: 'A common fruit, generally kidney-friendly.',
        sodium: 1,
        potassium: 195,
        phosphorus: 10,
        protein: 0.5,
        category: 'Fruit',
        isIndianFood: false,
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Red_Apple.jpg/1200px-Red_Apple.jpg',
      ),
    ];

    for (var food in sampleFoods) {
      await service.addFoodItem(food);
    }
    print("Sample food data uploaded to Firestore.");
  }
}
