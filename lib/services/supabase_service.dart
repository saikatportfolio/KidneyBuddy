import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/models/feedback_model.dart';
import 'package:myapp/models/dietician.dart'; // Import Dietician model
import 'package:myapp/models/review.dart'; // Import Review model
import 'package:myapp/models/blood_pressure.dart'; // Import BloodPressure model
import 'package:google_sign_in/google_sign_in.dart'; // Import google_sign_in
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'package:myapp/utils/logger_config.dart'; // Import the logger

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- Authentication Methods ---
  Future<void> signUp(String email, String password) async {
    await _supabase.auth.signUp(email: email, password: password);
  }

  Future<void> signInWithPassword(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> signInWithGoogle() async {
    // For web, Supabase handles the redirect. For mobile, google_sign_in handles the native flow.
    // This example focuses on the general approach.
    // You might need platform-specific logic for GoogleSignIn.

    if (kIsWeb) {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://ukhmymbgfzbpulwsfmrd.supabase.co/auth/v1/callback', // Use actual Supabase URL
      );
      // For web, the navigation happens via redirect, so no direct AuthResponse is returned here.
      // The auth state listener in main.dart will handle the session.
    } else {
      // Mobile implementation using google_sign_in
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: '998282656789-og31pr3bvcdi7b49p1emo5bsuc9s5t5m.apps.googleusercontent.com', // IMPORTANT: Replace with your Web client ID
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleAuth != null) {
        if (googleAuth.accessToken != null && googleAuth.idToken != null) {
          await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: googleAuth.idToken!,
          accessToken: googleAuth.accessToken!,
        );
        } else {
          throw AuthException('Google Sign-In: Access token or ID token not found.');
        }
      } else {
        throw AuthException('Google Sign-In aborted or authentication object is null.');
      }
    }
  }

  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  // --- End Authentication Methods ---

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
      final user = _supabase.auth.currentUser;
      if (user == null) {
        logger.w('upsertPatientDetails: No authenticated user found. Cannot upsert patient details.');
        return;
      }
      details.userId = user.id; // Assign the current user's ID
      final data = details.toMap();
      // Supabase will automatically handle insert/update based on primary key
      await _supabase.from('patient_details').upsert(data);
      logger.i('Patient details upserted to Supabase: ${details.name} for user ${user.id}');
    } catch (e) {
      logger.e('Error upserting patient details to Supabase: $e');
      // TODO: Implement retry mechanism or error logging
    }
  }

  Future<PatientDetails?> getPatientDetails() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        logger.w('getPatientDetails: No authenticated user found. Cannot fetch patient details.');
        return null;
      }

      final response = await _supabase
          .from('patient_details')
          .select()
          .eq('user_id', user.id) // Filter by user_id
          .limit(1); // Assuming only one patient's details are stored per user

      if (response.isNotEmpty) {
        return PatientDetails.fromMap(response.first);
      }
      return null;
    } catch (e) {
      logger.e('Error fetching patient details from Supabase: $e');
      return null;
    }
  }

  // Feedback Operations
  Future<void> insertFeedback(FeedbackModel feedback) async {
    try {
      final data = feedback.toMap();
      await _supabase.from('feedback').insert(data);
      logger.i('Feedback inserted to Supabase: ${feedback.feedbackText}');
    } catch (e) {
      logger.e('Error inserting feedback to Supabase: $e');
      // TODO: Implement retry mechanism or error logging
    }
  }

  // Dietician Operations
  Future<List<Dietician>> getDieticians() async {
    try {
      final response = await _supabase
          .from('dieticians')
          .select('id, name, experience, specialty, image_url, whatsapp_number, education, available_day, available_hour, fees, languages');
      logger.d('Supabase raw response for dieticians: $response'); // Debugging line
      
      if ((response.isEmpty)) {
        logger.i('No data or empty response from Supabase for dieticians.');
        return [];
      }

      final List<Dietician> dieticians = (response as List).map((map) => Dietician.fromMap(map)).toList();
      logger.d('Parsed dieticians: $dieticians'); // Debugging line
      return dieticians;
    } catch (e) {
      logger.e('Error fetching dieticians from Supabase: $e');
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
        logger.i('No reviews found for dietician ID: $dieticianId');
        return [];
      }

      final List<Review> reviews = (response as List).map((map) => Review.fromMap(map)).toList();
      logger.d('Fetched reviews for dietician $dieticianId: $reviews');
      return reviews;
    } catch (e) {
      logger.e('Error fetching reviews for dietician $dieticianId from Supabase: $e');
      return []; // Return empty list on error
    }
  }

  // Blood Pressure Operations
  Future<void> insertBloodPressure(BloodPressure bp) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        logger.w('insertBloodPressure: No authenticated user found. Cannot insert blood pressure reading.');
        return;
      }
      bp.userId = user.id; // Assign the current user's ID
      final data = bp.toMap();
      await _supabase.from('blood_pressure_readings').insert(data);
      logger.i('Blood pressure reading inserted to Supabase: ${bp.systolic}/${bp.diastolic} for user ${user.id}');
    } catch (e) {
      logger.e('Error inserting blood pressure reading to Supabase: $e');
      // TODO: Implement retry mechanism or error logging
    }
  }

  Future<List<BloodPressure>> getBloodPressureReadings() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        logger.w('getBloodPressureReadings: No authenticated user found. Cannot fetch blood pressure readings.');
        return [];
      }

      final response = await _supabase
          .from('blood_pressure_readings')
          .select()
          .eq('user_id', user.id) // Filter by user_id
          .order('timestamp', ascending: false); // Order by newest first

      if (response.isEmpty) {
        logger.i('No blood pressure readings found for user ${user.id}.');
        return [];
      }

      final List<BloodPressure> readings = (response as List).map((map) => BloodPressure.fromMap(map)).toList();
      logger.d('Fetched ${readings.length} blood pressure readings for user ${user.id}.');
      return readings;
    } catch (e) {
      logger.e('Error fetching blood pressure readings from Supabase: $e');
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
      logger.e('Error fetching message by key "$key" from Supabase: $e');
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
        logger.i('No tips found in Supabase.');
        return [];
      }

      return (response as List).map((map) => map['message_text'] as String).toList();
    } catch (e) {
      logger.e('Error fetching all tips from Supabase: $e');
      return [];
    }
  }
}
