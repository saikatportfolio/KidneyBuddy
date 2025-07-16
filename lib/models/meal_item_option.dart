class MealItemOption {
  String? optionId;
  String? itemId;
  String foodName;
  String? notes;

  MealItemOption({
    this.optionId,
    required this.itemId,
    required this.foodName,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'option_id': optionId,
      'item_id': itemId,
      'food_name': foodName,
      'notes': notes,
    };
  }

  factory MealItemOption.fromMap(Map<String, dynamic> map) {
    return MealItemOption(
      optionId: map['option_id'] as String?,
      itemId: map['item_id'] as String?,
      foodName: map['food_name'],
      notes: map['notes'] as String?,
    );
  }
}
