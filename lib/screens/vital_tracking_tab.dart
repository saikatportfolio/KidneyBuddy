import 'package:flutter/material.dart';
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/widgets/vital_tabs/bp_records_tab.dart';
import 'package:myapp/widgets/vital_tabs/creatinine_records_tab.dart';
import 'package:myapp/widgets/vital_tabs/weight_records_tab.dart';

class VitalTrackingTab extends StatelessWidget {
  final String vitalType;
  final String userId;
  final PatientDetails? patientDetails;

  const VitalTrackingTab({
    super.key,
    required this.vitalType,
    required this.userId,
    this.patientDetails,
  });

  @override
  Widget build(BuildContext context) {
    switch (vitalType) {
      case 'BP':
        return BpRecordsTab(userId: userId, patientDetails: patientDetails);
      case 'Creatinine':
        return CreatinineRecordsTab(userId: userId, patientDetails: patientDetails);
      case 'Weight':
        return WeightRecordsTab(userId: userId, patientDetails: patientDetails);
      default:
        return const Center(child: Text('No data available'));
    }
  }
}
