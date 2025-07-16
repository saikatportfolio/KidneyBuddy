class Meal {
  String? mealId;
  String? planId;
  String mealType;
  String timing;
  String? notes;
  String? dayOfWeek;

  Meal({
    this.mealId,
    required this.planId,
    required this.mealType,
    required this.timing,
    this.notes,
    this.dayOfWeek,
  });

  Map<String, dynamic> toMap() {
    return {
      'meal_id': mealId,
      'plan_id': planId,
      'meal_type': mealType,
      'timing': timing,
      'notes': notes,
      'day_of_week': dayOfWeek,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      mealId: map['meal_id'] as String?,
      planId: map['plan_id'] as String?,
      mealType: map['meal_type'],
      timing: map['timing'],
      notes: map['notes'] as String?,
      dayOfWeek: map['day_of_week'] as String?,
    );
  }
}
