import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/models/feedback_model.dart';
import 'package:myapp/services/database_helper.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/screens/home_page.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();
  String _name = '';
  String _phoneNumber = '';

  @override
  void initState() {
    super.initState();
    _loadPatientDetails();
  }

  _loadPatientDetails() async {
    final patientDetailsProvider = Provider.of<PatientDetailsProvider>(context, listen: false);
    PatientDetails? details = patientDetailsProvider.patientDetails;

    if (details == null) {
      // Try to load from database if not in provider
      details = await DatabaseHelper().getPatientDetails();
      if (details != null) {
        patientDetailsProvider.setPatientDetails(details);
      }
    }

    if (details != null) {
      setState(() {
        _name = details!.name;
        _phoneNumber = details.phoneNumber;
      });
    }
  }

  void _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      final feedback = FeedbackModel(
        name: _name,
        phoneNumber: _phoneNumber,
        feedbackText: _feedbackController.text,
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
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Your Name'),
                readOnly: true, // Name should be pre-filled and not editable
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _phoneNumber,
                decoration: InputDecoration(labelText: 'Your Phone Number'),
                readOnly: true, // Phone number should be pre-filled and not editable
              ),
              SizedBox(height: 16),
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
