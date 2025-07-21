import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/models/feedback_model.dart';
import 'package:myapp/services/database_helper.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/screens/home_page.dart';
import 'package:uuid/uuid.dart'; // Import uuid package
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'package:myapp/utils/logger_config.dart'; // Import the logger
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(); // New controller for name
  final TextEditingController _phoneNumberController = TextEditingController(); // New controller for phone number
  String? _selectedCategory; // New state variable for selected category
  String _patientName = ''; // To store patient's name from provider or input
  String _patientPhoneNumber = ''; // To store patient's phone number from provider or input
  bool _patientDetailsLoaded = false; // New state variable to track if patient details are loaded


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

  _loadPatientDetails() async {
    // Using WidgetsBinding.instance.addPostFrameCallback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final patientDetailsProvider = Provider.of<PatientDetailsProvider>(context, listen: false);
      PatientDetails? details = patientDetailsProvider.patientDetails;

      if (details != null) {
        setState(() {
          _patientDetailsLoaded = true;
          _patientName = details.name;
          _patientPhoneNumber = details.phoneNumber;
          _nameController.text = details.name; // Initialize controller even if not shown
          _phoneNumberController.text = details.phoneNumber; // Initialize controller even if not shown
        });
        logger.i('Patient details loaded for feedback submission: ${details.name}');
      } else {
        // Patient details not available, try to get Google name from SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? googleUserName = prefs.getString('google_user_name');
        
        setState(() {
          _patientDetailsLoaded = false;
          _nameController.text = googleUserName ?? ''; // Pre-fill with Google name if available
          _phoneNumberController.text = ''; // Leave phone number empty for user input
        });
        logger.w('Patient details not available. Google name pre-filled: $googleUserName');
      }
    });
  }

  void _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a feedback category.')),
        );
        return;
      }

      String nameToSubmit;
      String phoneNumberToSubmit;

      if (_patientDetailsLoaded) {
        nameToSubmit = _patientName;
        phoneNumberToSubmit = _patientPhoneNumber;
      } else {
        nameToSubmit = _nameController.text;
        phoneNumberToSubmit = _phoneNumberController.text;
      }

      final feedback = FeedbackModel(
        id: const Uuid().v4(), // Generate a new UUID for the feedback
        name: nameToSubmit, // Use name from controller or fetched details
        phoneNumber: phoneNumberToSubmit, // Use phone number from controller or fetched details
        feedbackText: _feedbackController.text,
        category: _selectedCategory!, // Use the selected category
        timestamp: DateTime.now(),
      );

      // Conditional Save Logic for Feedback
      if (!kIsWeb) {
        // Save to SQLite for mobile
        await DatabaseHelper().insertFeedback(feedback);
      }
      
      // Always sync to Supabase
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
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
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
                    'Give Your Feedback',
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Dropdown for Feedback Category
                    DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Feedback Category',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select a category'),
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
              const SizedBox(height: 16),
              // Conditionally display Name and Phone Number fields
              if (!_patientDetailsLoaded) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                    hintText: 'Enter your name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Your Phone Number',
                    hintText: 'Enter your phone number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              // Feedback Text Field
              TextFormField(
                controller: _feedbackController,
                decoration: const InputDecoration(
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitFeedback,
                child: const Text('Submit Feedback'),
              ),
            ],
          ),
        ),
            ),
          ),
        ],
      ),
    );
  }
}
