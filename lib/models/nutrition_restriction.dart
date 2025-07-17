import 'package:uuid/uuid.dart';

class NutritionRestriction {
  final String nutritionId;
  final String nutritionKey;
  final String nutritionValue;
  final String userId;
  final int sequence;

  NutritionRestriction({
    String? nutritionId,
    required this.nutritionKey,
    required this.nutritionValue,
    required this.userId,
    required this.sequence,
  }) : nutritionId = nutritionId ?? const Uuid().v4();

  factory NutritionRestriction.fromMap(Map<String, dynamic> map) {
    return NutritionRestriction(
      nutritionId: map['nutritionId'] as String,
      nutritionKey: map['nutritionKey'] as String,
      nutritionValue: map['nutritionValue'] as String,
      userId: map['userId'] as String,
      sequence: map['sequence'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nutritionId': nutritionId,
      'nutritionKey': nutritionKey,
      'nutritionValue': nutritionValue,
      'userId': userId,
      'sequence': sequence,
    };
  }
}
