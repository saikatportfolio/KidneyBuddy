class MealItemOption {
  String? optionId;
  String? itemId;
  String foodName;
  String? notes;
  String? amount;

  MealItemOption({
    this.optionId,
    required this.itemId,
    required this.foodName,
    this.notes,
    this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'option_id': optionId,
      'item_id': itemId,
      'food_name': foodName,
      'notes': notes,
      'amount': amount,
    };
  }

  factory MealItemOption.fromMap(Map<String, dynamic> map) {
    return MealItemOption(
      optionId: map['option_id'] as String?,
      itemId: map['item_id'] as String?,
      foodName: map['food_name'],
      notes: map['notes'] as String?,
      amount: map['amount'] as String?,
    );
  }
}
