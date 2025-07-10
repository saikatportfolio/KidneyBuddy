import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/models/feedback_model.dart';
import 'package:myapp/services/database_helper.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/screens/home_page.dart';
import 'package:uuid/uuid.dart'; // Import uuid package

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();
  String? _selectedCategory; // New state variable for selected category
  String _patientName = ''; // To store patient's name from provider
  String _patientPhoneNumber = ''; // To store patient's phone number from provider

  final List<String> _feedbackCategories = [
    'App Experience',
    'Feature Request',
    'Bug Report',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadPatientDetails();
  }

  _loadPatientDetails() {
    // Using WidgetsBinding.instance.addPostFrameCallback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patientDetailsProvider = Provider.of<PatientDetailsProvider>(context, listen: false);
      PatientDetails? details = patientDetailsProvider.patientDetails;

      if (details != null) {
        setState(() {
          _patientName = details.name;
          _patientPhoneNumber = details.phoneNumber;
        });
      } else {
        // Handle case where patient details are not available (e.g., show a message or disable feedback)
        print('Patient details not available for feedback submission.');
      }
    });
  }

  void _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a feedback category.')),
        );
        return;
      }

      final feedback = FeedbackModel(
        id: Uuid().v4(), // Generate a new UUID for the feedback
        name: _patientName, // Use patient's name from provider
        phoneNumber: _patientPhoneNumber, // Use patient's phone number from provider
        feedbackText: _feedbackController.text,
        category: _selectedCategory!, // Use the selected category
        timestamp: DateTime.now(),
      );

      // Save to SQLite
      await DatabaseHelper().insertFeedback(feedback);

      // Sync to Supabase
      await SupabaseService().insertFeedback(feedback);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback submitted successfully!')),
      );

      _feedbackController.clear();
      setState(() {
        _selectedCategory = null; // Clear selected category after submission
      });

      // Navigate to Home Page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Give Your Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Dropdown for Feedback Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Feedback Category',
                  border: OutlineInputBorder(),
                ),
                hint: Text('Select a category'),
                items: _feedbackCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Feedback Text Field
              TextFormField(
                controller: _feedbackController,
                decoration: InputDecoration(
                  labelText: 'Your Feedback',
                  hintText: 'Write your feedback here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your feedback';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitFeedback,
                child: Text('Submit Feedback'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
