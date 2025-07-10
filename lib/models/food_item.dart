import 'package:flutter/material.dart';

enum SafetyFlag {
  green,
  yellow,
  red,
}

class FoodItem {
  final int id;
  final String name;
  final double sodium; // in mg
  final double potassium; // in mg
  final double phosphorus; // in mg
  final double protein; // in grams
  final double carbs; // in grams
  final double fat; // in grams
  final String category;
  final String? source;
  final String? imageUrl;

  // Properties to be calculated dynamically based on patient's CKD stage
  SafetyFlag? safetyFlag;
  String? safetyExplanation;

  FoodItem({
    required this.id,
    required this.name,
    required this.sodium,
    required this.potassium,
    required this.phosphorus,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.category,
    this.source,
    this.imageUrl,
    this.safetyFlag,
    this.safetyExplanation,
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] as int,
      name: map['name'] as String,
      sodium: (map['sodium'] as num).toDouble(),
      potassium: (map['potassium'] as num).toDouble(),
      phosphorus: (map['phosphorus'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      category: map['category'] as String,
      source: map['source'] as String?,
      imageUrl: map['image_url'] as String?,
      // Safety flag and explanation are not stored in DB, calculated dynamically
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sodium': sodium,
      'potassium': potassium,
      'phosphorus': phosphorus,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'category': category,
      'source': source,
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

  // Helper to get text for the safety flag
  String get flagText {
    switch (safetyFlag) {
      case SafetyFlag.green:
        return 'Safe';
      case SafetyFlag.yellow:
        return 'Limit';
      case SafetyFlag.red:
        return 'Avoid';
      default:
        return 'N/A'; // Default for uncalculated or unknown
    }
  }
}
