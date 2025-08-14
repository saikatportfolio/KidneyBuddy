import 'package:flutter/foundation.dart';

class PatientDetails {
  String? id; // Changed to String for UUID
  String? userId; // New field for Supabase user ID
  String name;
  String? email;
  String phoneNumber;
  double? weight;
  double? height;
  String? ckdStage;
  String? gender;
  int? age;

  PatientDetails({
    this.id,
    this.userId, // Initialize new field
    required this.name,
    this.email,
    required this.phoneNumber,
    this.weight,
    this.height,
    this.ckdStage,
    this.gender,
    this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId, // Add to map
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'weight': weight,
      'height': height,
      'ckd_stage': ckdStage,
      'gender': gender,
      'age': age,
    };
  }

  factory PatientDetails.fromMap(Map<String, dynamic> map) {
    return PatientDetails(
      id: map['id'] as String?, // Cast to String?
      userId: map['user_id'] as String?, // Cast to String?
      name: map['name'],
      email: map['email'] as String?,
      phoneNumber: map['phone_number'],
      weight: map['weight'],
      height: map['height'],
      ckdStage: map['ckd_stage'] as String?,
      gender: map['gender'] as String?,
      age: map['age'] as int?,
    );
  }
}

class PatientDetailsProvider with ChangeNotifier {
  PatientDetails? _patientDetails;

  PatientDetailsProvider(PatientDetails? initialDetails) {
    _patientDetails = initialDetails;
  }

  PatientDetails? get patientDetails => _patientDetails;

  void setPatientDetails(PatientDetails? details) {
    _patientDetails = details;
    notifyListeners();
  }

  void clearPatientDetails() {
    _patientDetails = null;
    notifyListeners();
  }
}
