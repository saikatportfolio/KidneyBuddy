import 'package:flutter/material.dart';
import 'package:myapp/screens/vital_tracking_page.dart';
import 'package:myapp/screens/your_meals_screen.dart';
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/services/database_helper.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/utils/logger_config.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class PatientDetailsPage extends StatefulWidget {
  final String? source;

  const PatientDetailsPage({Key? key, this.source}) : super(key: key);

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
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadInitialData(); // New method to handle loading from SharedPreferences and existing details
  }

  void _loadInitialData() async {
    // Load from SharedPreferences first (for Google Sign-in pre-fill)
    final prefs = await SharedPreferences.getInstance();
    final String? googleUserName = prefs.getString('google_user_name');
    final String? googleUserEmail = prefs.getString('google_user_email');

    logger.d('Patient detailas: Retrieved Google Email1: $googleUserEmail');
    logger.d('Patient detailas: Retrieved Google Name: $googleUserName');

    if (googleUserName != null) {
      _nameController.text = googleUserName;
    }
    if (googleUserEmail != null) {
      _email = googleUserEmail;
    }

    // Then load existing patient details (this will overwrite if there are existing details)
    _loadPatientDetails();
  }

  void _loadPatientDetails() async {
    PatientDetails? loadedDetails;
    if (kIsWeb) {
      loadedDetails = await SupabaseService().getPatientDetails();
    } else {
      loadedDetails = await DatabaseHelper().getPatientDetails();
    }

    if (loadedDetails != null) {
      setState(() {
        _nameController.text = loadedDetails!.name;
        _phoneController.text = loadedDetails.phoneNumber;
        _weightController.text = loadedDetails.weight.toString();
        _heightController.text = loadedDetails.height.toString();
        _ckdStage = loadedDetails.ckdStage;
      });
      // Update provider with loaded details
      if (!mounted) return;
      Provider.of<PatientDetailsProvider>(context, listen: false).setPatientDetails(loadedDetails);
    }
  }

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
      // Get existing patient details from provider if available
      final existingDetails = Provider.of<PatientDetailsProvider>(context, listen: false).patientDetails;

      final patientDetails = PatientDetails(
        id: existingDetails?.id ?? Uuid().v4(), // Use existing ID or generate new UUID
        userId: existingDetails?.userId, // Preserve existing userId if available
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        ckdStage: _ckdStage!,
        email: _email,
      );

      // Conditional Save Logic
      if (!kIsWeb) {
        // Save to SQLite for mobile
        final dbHelper = DatabaseHelper();
        await dbHelper.insertPatientDetails(patientDetails);
      }

      // Always sync to Supabase
      await SupabaseService().upsertPatientDetails(patientDetails);

      // Update provider (using the local patientDetails object)
      // Ensure context is still valid before updating provider and navigating
      if (!mounted) return;
      Provider.of<PatientDetailsProvider>(context, listen: false).setPatientDetails(patientDetails);

      // Navigate to correct page based on source
      if (!mounted) return;
      if (widget.source == "your_meals") {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const YourMealsScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => VitalTrackingPage()),
        );
      }
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
