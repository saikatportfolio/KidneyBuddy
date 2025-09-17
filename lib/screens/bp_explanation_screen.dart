import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:myapp/services/anomaly_detection_service.dart';
import 'package:myapp/models/blood_pressure.dart';

class BpExplanationScreen extends StatefulWidget {
  final int systolic;
  final int diastolic;

  const BpExplanationScreen({
    super.key,
    required this.systolic,
    required this.diastolic,
  });

  @override
  State<BpExplanationScreen> createState() => _BpExplanationScreenState();
}

class _BpExplanationScreenState extends State<BpExplanationScreen> {
  final AnomalyDetectionService _anomalyDetectionService =
      AnomalyDetectionService();
  late Future<Map<String, dynamic>> _explanationFuture;

  @override
  void initState() {
    super.initState();
    _explanationFuture = _anomalyDetectionService.detectVitalAnomaly(
      bloodPressure: BloodPressure(
        systolic: widget.systolic,
        diastolic: widget.diastolic,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Blood Pressure Explanation")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _explanationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available.'));
          } else {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  "Systolic: ${widget.systolic}, Diastolic: ${widget.diastolic}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Markdown(
                  data: snapshot.data!['explanation'] ?? '',
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
                const SizedBox(height: 20),
                ...List.generate(
                  (snapshot.data!['recommendations'] as List<dynamic>).length,
                  (index) {
                    final rec = (snapshot.data!['recommendations']
                        as List<dynamic>)[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Markdown(
                        data: rec,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      ),
                    );
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
