import 'package:flutter/material.dart';

enum SafetyFlag {
  green,
  yellow,
  red,
}

class FoodItem {
  final String id;
  final String name;
  final String description;
  final double sodium; // in mg
  final double potassium; // in mg
  final double phosphorus; // in mg
  final double protein; // in grams
  final String category;
  final bool isIndianFood;
  final String? imageUrl;

  // Properties to be calculated dynamically based on patient's CKD stage
  SafetyFlag? safetyFlag;
  String? safetyExplanation;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.sodium,
    required this.potassium,
    required this.phosphorus,
    required this.protein,
    required this.category,
    this.isIndianFood = true,
    this.imageUrl,
    this.safetyFlag,
    this.safetyExplanation,
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      sodium: (map['sodium'] as num).toDouble(),
      potassium: (map['potassium'] as num).toDouble(),
      phosphorus: (map['phosphorus'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      category: map['category'] as String,
      isIndianFood: map['is_indian_food'] as bool? ?? true,
      imageUrl: map['image_url'] as String?,
      // Safety flag and explanation are not stored in DB, calculated dynamically
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sodium': sodium,
      'potassium': potassium,
      'phosphorus': phosphorus,
      'protein': protein,
      'category': category,
      'is_indian_food': isIndianFood,
      'image_url': imageUrl,
    };
  }

  // Helper to get color for the safety flag
  Color get flagColor {
    switch (safetyFlag) {
      case SafetyFlag.green:
        return Colors.green;
      case SafetyFlag.yellow:
        return Colors.yellow[700]!;
      case SafetyFlag.red:
        return Colors.red;
      default:
        return Colors.grey; // Default for uncalculated or unknown
    }
  }
}
