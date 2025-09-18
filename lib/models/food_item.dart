
class FoodItem {
  final String id;
  final String name;
  final int sodium; // in mg
  final int potassium; // in mg
  final int phosphorus; // in mg
  final int protein; // in grams
  final String category;
  final String? imageUrl;

  // Properties to be calculated dynamically based on patient's CKD stage

  FoodItem({
    required this.id,
    required this.name,
    required this.sodium,
    required this.potassium,
    required this.phosphorus,
    required this.protein,
    required this.category,
    this.imageUrl,
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] as String,
      name: map['name'] as String,
      sodium: (map['sodium'] as num?)?.toInt() ?? 0,
      potassium: (map['potassium'] as num?)?.toInt() ?? 0,
      phosphorus: (map['phosphorus'] as num?)?.toInt() ?? 0,
      protein: (map['protein'] as num?)?.toInt() ?? 0,
      category: map['category'] as String,
      imageUrl: map['imageUrl'] as String?,
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
      'category': category,
      'imageUrl': imageUrl,
    };
  }
}
