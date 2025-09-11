import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/screens/bp_explanation_screen.dart';
import 'package:myapp/utils/logger_config.dart';

class BpConfirmationScreen extends StatelessWidget {
  final int systolic;
  final int diastolic;
  final DateTime timestamp;

  const BpConfirmationScreen({
    super.key,
    required this.systolic,
    required this.diastolic,
    required this.timestamp,
  });

  Map<String, String> _getBloodPressureStatus(int systolic, int diastolic) {
    String status;
    String action;

    logger.d('systolic: $systolic, diastolic: $diastolic');
    if (systolic >= 140 || diastolic >= 90) {
      status = "Uncontrolled Hypertension";
      action =
          "Your BP is in the uncontrolled range. Consult your Doctor immediately. This requires urgent review.";
    } else if (systolic > 130 || diastolic > 80) {
      status = "Above Optimal Target";
      action =
          "Your BP is above the optimal target. Discuss with your Doctor if treatment needs to be intensified.";
    } else if (systolic <= 130 && diastolic <= 80) {
      status = "At Optimal Target";
      action =
          "Excellent! Your BP is within the optimal target range. Continue with your current medication and lifestyle plan as prescribed.";
    } else {
      status = "Normal BP";
      action = "Your blood pressure is in a normal range.";
    }

    return {'status': status, 'action': action};
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> bpStatus =
        _getBloodPressureStatus(systolic, diastolic);
    final String formattedDate =
        DateFormat('MMMM d, yyyy at h:mm a').format(timestamp);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BP Confirmation'),
        centerTitle: true,
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/bp_confirmation.gif',
                            width: 100,
                            height: 100,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '$systolic/$diastolic mmHg',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            bpStatus['status']!,
                            style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            bpStatus['action']!,
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                margin: const EdgeInsets.only(bottom: 30.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Navigate to Vital Tracking Page
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 18.0),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.blue, width: 2),
                    foregroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
