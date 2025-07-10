import 'package:flutter/material.dart';
import 'package:myapp/screens/home_page.dart';
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/services/database_helper.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart'; // Import uuid package

class PatientDetailsPage extends StatefulWidget {
  const PatientDetailsPage({super.key});

  @override
  _PatientDetailsPageState createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String? _ckdStage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _savePatientDetails() async {
    if (_formKey.currentState!.validate()) {
      final patientDetails = PatientDetails(
        id: Uuid().v4(), // Generate a new UUID for the patient
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        ckdStage: _ckdStage!,
      );

      // Save to SQLite (will insert or update based on ID)
      final dbHelper = DatabaseHelper();
      // insertPatientDetails now returns String, and patientDetails already has the UUID
      await dbHelper.insertPatientDetails(patientDetails);

      // Sync to Supabase (patientDetails already has the UUID)
      await SupabaseService().upsertPatientDetails(patientDetails);

      // Update provider (using the local patientDetails object)
      // Ensure context is still valid before updating provider and navigating
      if (!mounted) return;
      Provider.of<PatientDetailsProvider>(context, listen: false).setPatientDetails(patientDetails);

      // Set onboarding seen status
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);

      // Navigate to Home Page
      if (!mounted) return; // Check mounted again before navigation
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _ckdStage,
                decoration: InputDecoration(labelText: 'CKD Stage'),
                items: <String>['Stage 1', 'Stage 2', 'Stage 3', 'Stage 4', 'Stage 5']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _ckdStage = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your CKD stage';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _savePatientDetails,
                child: Text('Save Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
