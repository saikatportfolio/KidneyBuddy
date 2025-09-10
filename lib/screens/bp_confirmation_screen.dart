import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/screens/bp_explanation_screen.dart';

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

  String _getBloodPressureStatus(int systolic, int diastolic) {
    if (systolic >= 180 || diastolic >= 120) {
      return "Hypertensive Crisis – Emergency (Seek immediate care)";
    } else if (systolic >= 140 || diastolic >= 90) {
      return "Stage 2 Hypertension (Very high BP; not at goal for CKD)";
    } else if (systolic >= 130 || diastolic >= 80) {
      return "Stage 1 Hypertension (Above recommended target for CKD)";
    } else if (systolic >= 120 && diastolic < 80) {
      return "Elevated BP (Slightly above normal)";
    } else {
      return "Normal BP (Ideal range for CKD)";
    }
  }

  @override
  Widget build(BuildContext context) {
    final String bpStatus = _getBloodPressureStatus(systolic, diastolic);
    final String formattedDate = DateFormat('MMMM d, yyyy at h:mm a').format(timestamp);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 40,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '$systolic/$diastolic mmHg',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      bpStatus,
                      style: const TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BpExplanationScreen(
                            systolic: systolic,
                            diastolic: diastolic,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'See Explanation',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Navigate to Vital Tracking Page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.blue, width: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
