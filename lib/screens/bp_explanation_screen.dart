import 'package:flutter/material.dart';
import 'package:myapp/services/anomaly_detection_service.dart'; // Import AnomalyDetectionService
import 'package:myapp/models/blood_pressure.dart'; // Import BloodPressure model

class BpExplanationScreen extends StatefulWidget {
  final int systolic;
  final int diastolic;

  const BpExplanationScreen({
    Key? key,
    required this.systolic,
    required this.diastolic,
  }) : super(key: key);

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

  String _removeMarkdown(String text) {
    return text.replaceAll(RegExp(r'\*\*'), '').replaceAll(RegExp(r'\*'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BP Explanation'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Systolic: ${widget.systolic}, Diastolic: ${widget.diastolic}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              FutureBuilder<Map<String, dynamic>>(
                future: _explanationFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return Expanded(
                      child: Column(
                        children: [
                          Text(
                            _removeMarkdown(snapshot.data!['explanation'] ??
                                'No explanation available.'),
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Recommendations:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: (snapshot.data!['recommendations'] as List<dynamic>).length,
                              itemBuilder: (context, index) {
                                final recommendation = (snapshot.data!['recommendations'] as List<dynamic>)[index];
                                return SizedBox(
                                  child: Text(
                                    _removeMarkdown(recommendation),
                                    style: const TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Text('No data available.');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
