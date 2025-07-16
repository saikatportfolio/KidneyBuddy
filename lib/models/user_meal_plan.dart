import 'package:flutter/foundation.dart';

class UserMealPlan {
  String? planId;
  String? userId;
  String planName;
  String? description;
  DateTime? startDate;
  DateTime? endDate;

  UserMealPlan({
    this.planId,
    required this.userId,
    required this.planName,
    this.description,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'plan_id': planId,
      'user_id': userId,
      'plan_name': planName,
      'description': description,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }

  factory UserMealPlan.fromMap(Map<String, dynamic> map) {
    return UserMealPlan(
      planId: map['plan_id'] as String?,
      userId: map['user_id'] as String?,
      planName: map['plan_name'],
      description: map['description'] as String?,
      startDate: map['start_date'] != null ? DateTime.parse(map['start_date']) : null,
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
    );
  }
}
