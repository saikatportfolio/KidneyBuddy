class MealItem {
  String? itemId;
  String? mealId;
  String itemName;
  String? notes;
  int sequence;

  MealItem({
    this.itemId,
    required this.mealId,
    required this.itemName,
    this.notes,
    required this.sequence,
  });

  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId,
      'meal_id': mealId,
      'item_name': itemName,
      'notes': notes,
      'sequence': sequence,
    };
  }

  factory MealItem.fromMap(Map<String, dynamic> map) {
    return MealItem(
      itemId: map['item_id'] as String?,
      mealId: map['meal_id'] as String?,
      itemName: map['item_name'],
      notes: map['notes'] as String?,
      sequence: map['sequence'],
    );
  }
}
