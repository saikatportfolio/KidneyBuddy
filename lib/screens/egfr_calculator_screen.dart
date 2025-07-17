import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter
import 'dart:math'; // For pow, min, max

class EgfrCalculatorScreen extends StatefulWidget {
  const EgfrCalculatorScreen({super.key});

  @override
  State<EgfrCalculatorScreen> createState() => _EgfrCalculatorScreenState();
}

class _EgfrCalculatorScreenState extends State<EgfrCalculatorScreen> {
  final TextEditingController _serumCreatinineController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender; // Nullable to indicate no selection initially
  String? _egfrResult; // To store the calculated eGFR result
  String? _ckdStageInterpretation; // To store the CKD stage and interpretation

  @override
  void dispose() {
    _serumCreatinineController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // eGFR calculation function based on user-provided logic
  double _calculateEGFR(String sex, int age, double scrMgDl) {
    final k = sex == 'Female' ? 0.7 : 0.9;
    final alpha = sex == 'Female' ? -0.241 : -0.302;
    final minRatio = min(scrMgDl / k, 1.0);
    final maxRatio = max(scrMgDl / k, 1.0);
    final femaleFactor = sex == 'Female' ? 1.012 : 1.0;

    final egfr = 142 *
        pow(minRatio, alpha) *
        pow(maxRatio, -1.2) *
        pow(0.9938, age) *
        femaleFactor;

    return egfr; // in mL/min/1.73 m²
  }

  String _getCKDStageAndInterpretation(double egfr) {
    if (egfr >= 90) {
      return 'CKD Stage: G1';
    } else if (egfr >= 60) {
      return 'CKD Stage: G2';
    } else if (egfr >= 45) {
      return 'CKD Stage: G3a';
    } else if (egfr >= 30) {
      return 'CKD Stage: G3b';
    } else if (egfr >= 15) {
      return 'CKD Stage: G4';
    } else {
      return 'CKD Stage: G5';
    }
  }

  void _performCalculation() {
    final String scrText = _serumCreatinineController.text;
    final String ageText = _ageController.text;

    if (scrText.isEmpty || ageText.isEmpty || _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all values and select a gender.')),
      );
      setState(() {
        _egfrResult = null; // Clear previous result if inputs are incomplete
      });
      return;
    }

    try {
      final double scr = double.parse(scrText);
      final int age = int.parse(ageText);

      if (scr <= 0 || age <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Serum Creatinine and Age must be positive values.')),
        );
        setState(() {
          _egfrResult = null;
        });
        return;
      }

      final double egfr = _calculateEGFR(_selectedGender!, age, scr);

      setState(() {
        _egfrResult = 'eGFR: ${egfr.toStringAsFixed(2)} mL/min/1.73 m²';
        _ckdStageInterpretation = _getCKDStageAndInterpretation(egfr); // Set the interpretation
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid input. Please enter valid numbers.')),
      );
      setState(() {
        _egfrResult = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eGFR Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Serum Creatinine Input
            TextFormField(
              controller: _serumCreatinineController,
              decoration: const InputDecoration(
                labelText: 'Serum Creatinine Value (mg/dL)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // Allow numbers and up to 2 decimal places
              ],
            ),
            const SizedBox(height: 16.0),

            // Age Input
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age (Years)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Allow only digits
              ],
            ),
            const SizedBox(height: 16.0),

            // Gender Dropdown
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Select Gender')),
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
            ),
            const SizedBox(height: 24.0),

            // Calculate Button
            ElevatedButton(
              onPressed: _performCalculation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 18.0),
              ),
              child: const Text('Calculate eGFR'),
            ),
            const SizedBox(height: 16.0),

            // eGFR Result Display
            if (_egfrResult != null)
              Text(
                _egfrResult!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            if (_ckdStageInterpretation != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0), // Add some spacing
                child: Text(
                  _ckdStageInterpretation!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent, // A distinct color for emphasis
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
