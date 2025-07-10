import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';
import '../utils/ckd_diet_calculator.dart';

class FoodRecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<FoodItem>> getRecommendedFoods(String ckdStage) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('food_items').get();
      List<FoodItem> foods = snapshot.docs.map((doc) {
        return FoodItem.fromMap(doc.data() as Map<String, dynamic>);
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
      print("Error fetching recommended foods: $e");
      return [];
    }
  }

  // Method to add a new food item to Firestore (for initial data population)
  Future<void> addFoodItem(FoodItem foodItem) async {
    try {
      await _firestore.collection('food_items').doc(foodItem.id).set(foodItem.toMap());
      print("Food item added: ${foodItem.name}");
    } catch (e) {
      print("Error adding food item: $e");
    }
  }
}
