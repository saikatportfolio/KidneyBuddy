import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter
import 'dart:math'; // For pow, min, max
import 'package:numberpicker/numberpicker.dart'; // For NumberPicker

class EgfrCalculatorScreen extends StatefulWidget {
  const EgfrCalculatorScreen({super.key});

  @override
  State<EgfrCalculatorScreen> createState() => _EgfrCalculatorScreenState();
}

class _EgfrCalculatorScreenState extends State<EgfrCalculatorScreen> {
  final TextEditingController _serumCreatinineController = TextEditingController();
  int _currentAge = 40; // Default age
  String? _selectedGender = 'Male'; // Nullable to indicate no selection initially
  String? _egfrResult; // To store the calculated eGFR result
  String? _ckdStageInterpretation; // To store the CKD stage and interpretation

  @override
  void dispose() {
    _serumCreatinineController.dispose();
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

    if (scrText.isEmpty || _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter all values and select a gender.')),
      );
      setState(() {
        _egfrResult = null; // Clear previous result if inputs are incomplete
      });
      return;
    }

    try {
      final double scr = double.parse(scrText);

      if (scr <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Serum Creatinine must be positive values.')),
        );
        setState(() {
          _egfrResult = null;
        });
        return;
      }

      final double egfr = _calculateEGFR(_selectedGender!, _currentAge, scr);

      setState(() {
        _egfrResult = 'eGFR: ${egfr.toStringAsFixed(2)} mL/min/1.73 m²';
        _ckdStageInterpretation =
            _getCKDStageAndInterpretation(egfr); // Set the interpretation
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Invalid input. Please enter valid numbers.')),
      );
      setState(() {
        _egfrResult = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Text(
                    'eGFR Calculator',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 48), // To balance the back button
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
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
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNumberPickerColumn(
                            label: 'Age (Years)',
                            value: _currentAge,
                            minValue: 1,
                            maxValue: 120,
                            onChanged: (value) => setState(() => _currentAge = value),
                            width: 100,
                          ),
                          const SizedBox(width: 8.0),
                          Column(
                            children: [
                              const Text(
                                "I'm a",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedGender = 'Male';
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _selectedGender == 'Male' ? Colors.lightBlue : Colors.grey[300],
                                      foregroundColor: _selectedGender == 'Male' ? Colors.black : Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('Male'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedGender = 'Female';
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _selectedGender == 'Female' ? Colors.lightBlue : Colors.grey[300],
                                      foregroundColor: _selectedGender == 'Female' ? Colors.black : Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('Female'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

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
                  color: Colors.blue,
                ),
              ),
            if (_ckdStageInterpretation != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _ckdStageInterpretation!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
          ],
        ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildNumberPickerColumn({
    required String label,
    required int value,
    required int minValue,
    required int maxValue,
    required ValueChanged<int> onChanged,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          NumberPicker(
            value: value,
            minValue: minValue,
            maxValue: maxValue,
            onChanged: onChanged,
            textStyle: TextStyle(color: Colors.grey[400], fontSize: 20),
            selectedTextStyle: const TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
