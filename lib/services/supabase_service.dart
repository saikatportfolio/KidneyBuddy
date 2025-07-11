import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/models/feedback_model.dart';
import 'package:myapp/models/dietician.dart'; // Import Dietician model
import 'package:myapp/models/review.dart'; // Import Review model

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Initialize Supabase (call this in main.dart)
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://ukhmymbgfzbpulwsfmrd.supabase.co', // Replace with your Supabase URL
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVraG15bWJnZnpicHVsd3NmbXJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE3OTMxNTIsImV4cCI6MjA2NzM2OTE1Mn0.WcimbbltoqdRewLh7Wnh3DP7f-BMgRuQ8115oZoGpjo', // Replace with your Supabase Anon Key
    );
  }

  // Patient Details Operations
  Future<void> upsertPatientDetails(PatientDetails details) async {
    try {
      final data = details.toMap();
      // Supabase will automatically handle insert/update based on primary key
      await _supabase.from('patient_details').upsert(data);
      print('Patient details upserted to Supabase: ${details.name}');
    } catch (e) {
      print('Error upserting patient details to Supabase: $e');
      // TODO: Implement retry mechanism or error logging
    }
  }

  Future<PatientDetails?> getPatientDetails() async {
    try {
      final response = await _supabase
          .from('patient_details')
          .select()
          .limit(1); // Assuming only one patient's details are stored

      if (response.isNotEmpty) {
        return PatientDetails.fromMap(response.first);
      }
      return null;
    } catch (e) {
      print('Error fetching patient details from Supabase: $e');
      return null;
    }
  }

  // Feedback Operations
  Future<void> insertFeedback(FeedbackModel feedback) async {
    try {
      final data = feedback.toMap();
      await _supabase.from('feedback').insert(data);
      print('Feedback inserted to Supabase: ${feedback.feedbackText}');
    } catch (e) {
      print('Error inserting feedback to Supabase: $e');
      // TODO: Implement retry mechanism or error logging
    }
  }

  // Dietician Operations
  Future<List<Dietician>> getDieticians() async {
    try {
      final response = await _supabase
          .from('dieticians')
          .select('id, name, experience, specialty, image_url, whatsapp_number, education, available_day, available_hour');
      print('Supabase raw response for dieticians: $response'); // Debugging line
      
      if ((response.isEmpty)) {
        print('No data or empty response from Supabase for dieticians.');
        return [];
      }

      final List<Dietician> dieticians = (response as List).map((map) => Dietician.fromMap(map)).toList();
      print('Parsed dieticians: $dieticians'); // Debugging line
      return dieticians;
    } catch (e) {
      print('Error fetching dieticians from Supabase: $e');
      return []; // Return empty list on error
    }
  }

  // Review Operations
  Future<List<Review>> getReviewsForDietician(String dieticianId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('id, dietician_id, patient_name, patient_details, comment, created_at')
          .eq('dietician_id', dieticianId) // Changed to camelCase
          .order('created_at', ascending: false); // Order by newest first

      if (response.isEmpty) {
        print('No reviews found for dietician ID: $dieticianId');
        return [];
      }

      final List<Review> reviews = (response as List).map((map) => Review.fromMap(map)).toList();
      print('Fetched reviews for dietician $dieticianId: $reviews');
      return reviews;
    } catch (e) {
      print('Error fetching reviews for dietician $dieticianId from Supabase: $e');
      return []; // Return empty list on error
    }
  }

  // App Messages Operations
  Future<String?> getMessageByKey(String key) async {
    try {
      final response = await _supabase
          .from('app_messages')
          .select('message_text')
          .eq('message_key', key)
          .limit(1);

      if (response.isNotEmpty) {
        return response.first['message_text'] as String;
      }
      return null;
    } catch (e) {
      print('Error fetching message by key "$key" from Supabase: $e');
      return null;
    }
  }

  Future<List<String>> getAllTips() async {
    try {
      final response = await _supabase
          .from('app_messages')
          .select('message_text')
          .like('message_key', 'tip_%') // Assuming tips are keyed as 'tip_1', 'tip_2', etc.
          .order('message_key', ascending: true); // Order to ensure consistent rotation

      if (response.isEmpty) {
        print('No tips found in Supabase.');
        return [];
      }

      return (response as List).map((map) => map['message_text'] as String).toList();
    } catch (e) {
      print('Error fetching all tips from Supabase: $e');
      return [];
    }
  }
}
