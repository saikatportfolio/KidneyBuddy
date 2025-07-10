import '../models/food_item.dart';

class CKDDietCalculator {
  // Define general nutrient thresholds based on common CKD dietary guidelines.
  // These are simplified and can be refined with more specific Indian guidelines.
  // Values are per serving.

  // Sodium thresholds (mg)
  static const double SODIUM_GREEN_MAX = 140; // Low sodium
  static const double SODIUM_YELLOW_MAX = 400; // Moderate sodium
  // Red if > 400mg

  // Potassium thresholds (mg)
  // Note: Potassium limits become stricter in later stages (3-4)
  static const double POTASSIUM_GREEN_MAX_EARLY_STAGE = 200; // e.g., Stage 1-2
  static const double POTASSIUM_YELLOW_MAX_EARLY_STAGE = 400;
  static const double POTASSIUM_GREEN_MAX_LATER_STAGE = 150; // e.g., Stage 3-4
  static const double POTASSIUM_YELLOW_MAX_LATER_STAGE = 300;
  // Red if > 400mg (early) or > 300mg (later)

  // Phosphorus thresholds (mg)
  static const double PHOSPHORUS_GREEN_MAX = 100;
  static const double PHOSPHORUS_YELLOW_MAX = 250;
  // Red if > 250mg

  // Protein thresholds (g)
  // Note: Protein limits vary greatly based on CKD stage and whether on dialysis.
  // These are general guidelines for non-dialysis CKD.
  static const double PROTEIN_GREEN_MAX_NON_DIALYSIS = 10; // Low protein
  static const double PROTEIN_YELLOW_MAX_NON_DIALYSIS = 20;
  // Red if > 20g (for non-dialysis)

  static void calculateSafetyFlag({
    required FoodItem foodItem,
    required String ckdStage, // e.g., "Stage 1", "Stage 2", "Stage 3", "Stage 4", "Stage 5"
  }) {
    SafetyFlag sodiumFlag = _getSodiumFlag(foodItem.sodium);
    SafetyFlag potassiumFlag = _getPotassiumFlag(foodItem.potassium, ckdStage);
    SafetyFlag phosphorusFlag = _getPhosphorusFlag(foodItem.phosphorus);
    SafetyFlag proteinFlag = _getProteinFlag(foodItem.protein, ckdStage); // Assuming non-dialysis for now

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

  static SafetyFlag _getSodiumFlag(double sodium) {
    if (sodium > SODIUM_YELLOW_MAX) {
      return SafetyFlag.red;
    } else if (sodium > SODIUM_GREEN_MAX) {
      return SafetyFlag.yellow;
    } else {
      return SafetyFlag.green;
    }
  }

  static SafetyFlag _getPotassiumFlag(double potassium, String ckdStage) {
    // Simplified stage check for demonstration. Real app might use eGFR.
    bool isLaterStage = ['Stage 3', 'Stage 4', 'Stage 5'].contains(ckdStage);

    if (isLaterStage) {
      if (potassium > POTASSIUM_YELLOW_MAX_LATER_STAGE) {
        return SafetyFlag.red;
      } else if (potassium > POTASSIUM_GREEN_MAX_LATER_STAGE) {
        return SafetyFlag.yellow;
      } else {
        return SafetyFlag.green;
      }
    } else {
      // Early stages
      if (potassium > POTASSIUM_YELLOW_MAX_EARLY_STAGE) {
        return SafetyFlag.red;
      } else if (potassium > POTASSIUM_GREEN_MAX_EARLY_STAGE) {
        return SafetyFlag.yellow;
      } else {
        return SafetyFlag.green;
      }
    }
  }

  static SafetyFlag _getPhosphorusFlag(double phosphorus) {
    if (phosphorus > PHOSPHORUS_YELLOW_MAX) {
      return SafetyFlag.red;
    } else if (phosphorus > PHOSPHORUS_GREEN_MAX) {
      return SafetyFlag.yellow;
    } else {
      return SafetyFlag.green;
    }
  }

  static SafetyFlag _getProteinFlag(double protein, String ckdStage) {
    // Assuming non-dialysis CKD for these thresholds.
    // Protein restriction is common in non-dialysis CKD to slow progression.
    // If patient is on dialysis, protein needs are higher.
    bool isNonDialysisCKD = !['Stage 5'].contains(ckdStage); // Simplified check

    if (isNonDialysisCKD) {
      if (protein > PROTEIN_YELLOW_MAX_NON_DIALYSIS) {
        return SafetyFlag.red;
      } else if (protein > PROTEIN_GREEN_MAX_NON_DIALYSIS) {
        return SafetyFlag.yellow;
      } else {
        return SafetyFlag.green;
      }
    } else {
      // For Stage 5 (dialysis), protein needs are generally higher, so less restriction.
      // This part can be refined based on specific dialysis guidelines.
      return SafetyFlag.green; // Placeholder: assume safe for dialysis patients for now
    }
  }
}
