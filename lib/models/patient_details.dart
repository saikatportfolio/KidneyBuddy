import 'package:flutter/foundation.dart';

class PatientDetails {
  int? id;
  String name;
  String phoneNumber;
  double weight;
  double height;
  String ckdStage;

  PatientDetails({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.weight,
    required this.height,
    required this.ckdStage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'weight': weight,
      'height': height,
      'ckd_stage': ckdStage,
    };
  }

  factory PatientDetails.fromMap(Map<String, dynamic> map) {
    return PatientDetails(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phone_number'],
      weight: map['weight'],
      height: map['height'],
      ckdStage: map['ckd_stage'],
    );
  }
}

class PatientDetailsProvider with ChangeNotifier {
  PatientDetails? _patientDetails;

  PatientDetails? get patientDetails => _patientDetails;

  void setPatientDetails(PatientDetails details) {
    _patientDetails = details;
    notifyListeners();
  }

  void clearPatientDetails() {
    _patientDetails = null;
    notifyListeners();
  }
}
