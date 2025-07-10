import '../models/food_item.dart';

class CKDDietCalculator {
  // Define nutrient thresholds based on user-provided guidelines (per 100g)
  static const Map<String, Map<String, Map<String, double>>> _nutrientThresholds = {
    'Sodium': {
      'Stage 1': {'safe': 120, 'limit': 300},
      'Stage 2': {'safe': 120, 'limit': 300},
      'Stage 3': {'safe': 100, 'limit': 250},
      'Stage 4': {'safe': 80, 'limit': 200},
      'Stage 5': {'safe': 80, 'limit': 200}, // Assuming Stage 5 follows Stage 4 for now
    },
    'Potassium': {
      'Stage 1': {'safe': 200, 'limit': 300},
      'Stage 2': {'safe': 200, 'limit': 300},
      'Stage 3': {'safe': 180, 'limit': 250},
      'Stage 4': {'safe': 150, 'limit': 220},
      'Stage 5': {'safe': 150, 'limit': 220}, // Assuming Stage 5 follows Stage 4 for now
    },
    'Phosphorus': {
      'Stage 1': {'safe': 120, 'limit': 180},
      'Stage 2': {'safe': 120, 'limit': 180},
      'Stage 3': {'safe': 100, 'limit': 150},
      'Stage 4': {'safe': 80, 'limit': 120},
      'Stage 5': {'safe': 80, 'limit': 120}, // Assuming Stage 5 follows Stage 4 for now
    },
    'Protein': {
      'Stage 1': {'safe': 10, 'limit': 15},
      'Stage 2': {'safe': 10, 'limit': 15},
      'Stage 3': {'safe': 8, 'limit': 12},
      'Stage 4': {'safe': 6, 'limit': 10},
      'Stage 5': {'safe': 6, 'limit': 10}, // Assuming Stage 5 follows Stage 4 for now
    },
  };

  static void calculateSafetyFlag({
    required FoodItem foodItem,
    required String ckdStage, // e.g., "Stage 1", "Stage 2", "Stage 3", "Stage 4", "Stage 5"
  }) {
    // Ensure ckdStage is valid, default to Stage 1 if not found
    final String effectiveCkdStage = _nutrientThresholds['Sodium']!.containsKey(ckdStage) ? ckdStage : 'Stage 1';

    SafetyFlag sodiumFlag = getNutrientFlag(foodItem.sodium, 'Sodium', effectiveCkdStage);
    SafetyFlag potassiumFlag = getNutrientFlag(foodItem.potassium, 'Potassium', effectiveCkdStage);
    SafetyFlag phosphorusFlag = getNutrientFlag(foodItem.phosphorus, 'Phosphorus', effectiveCkdStage);
    SafetyFlag proteinFlag = getNutrientFlag(foodItem.protein, 'Protein', effectiveCkdStage);

    // Determine overall safety flag: Red > Yellow > Green
    SafetyFlag overallFlag = SafetyFlag.green;
    String explanation = "";

    List<String> reasons = [];

    if (sodiumFlag == SafetyFlag.red || potassiumFlag == SafetyFlag.red || phosphorusFlag == SafetyFlag.red || proteinFlag == SafetyFlag.red) {
      overallFlag = SafetyFlag.red;
      if (sodiumFlag == SafetyFlag.red) reasons.add("High sodium content");
      if (potassiumFlag == SafetyFlag.red) reasons.add("High potassium content");
      if (phosphorusFlag == SafetyFlag.red) reasons.add("High phosphorus content");
      if (proteinFlag == SafetyFlag.red) reasons.add("High protein content");
      explanation = "${reasons.join(', ')}—best to avoid in your CKD stage.";
    } else if (sodiumFlag == SafetyFlag.yellow || potassiumFlag == SafetyFlag.yellow || phosphorusFlag == SafetyFlag.yellow || proteinFlag == SafetyFlag.yellow) {
      overallFlag = SafetyFlag.yellow;
      if (sodiumFlag == SafetyFlag.yellow) reasons.add("Moderate sodium content");
      if (potassiumFlag == SafetyFlag.yellow) reasons.add("Moderate potassium content");
      if (phosphorusFlag == SafetyFlag.yellow) reasons.add("Moderate phosphorus content");
      if (proteinFlag == SafetyFlag.yellow) reasons.add("Moderate protein content");
      explanation = "${reasons.join(', ')}—limit portions in your CKD stage.";
    } else {
      overallFlag = SafetyFlag.green;
      explanation = "Generally safe for your CKD stage.";
    }

    foodItem.safetyFlag = overallFlag;
    foodItem.safetyExplanation = explanation;
  }

  static SafetyFlag getNutrientFlag(double value, String nutrientName, String ckdStage) {
    final thresholds = _nutrientThresholds[nutrientName]![ckdStage]!;
    final double safeMax = thresholds['safe']!;
    final double limitMax = thresholds['limit']!;

    if (value > limitMax) {
      return SafetyFlag.red;
    } else if (value > safeMax) {
      return SafetyFlag.yellow;
    } else {
      return SafetyFlag.green;
    }
  }
}
