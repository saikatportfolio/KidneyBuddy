import 'package:flutter/material.dart';

class BpExplanationScreen extends StatelessWidget {
  final int systolic;
  final int diastolic;

  const BpExplanationScreen({
    Key? key,
    required this.systolic,
    required this.diastolic,
  }) : super(key: key);

  @override
  Future<String> _getGeminiExplanation(int systolic, int diastolic) async {
    // Replace this with actual Gemini API call
    await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
    return 'This is a dummy explanation for systolic: $systolic and diastolic: $diastolic. Please consult with your doctor for accurate information.';
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
                'Systolic: $systolic, Diastolic: $diastolic',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              const Text(
                'Explanation from Gemini API will be displayed here.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FutureBuilder<String>(
                future: _getGeminiExplanation(systolic, diastolic),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Text(
                      snapshot.data ?? 'No explanation available.',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    );
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
