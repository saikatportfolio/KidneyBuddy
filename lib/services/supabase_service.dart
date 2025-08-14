import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/models/feedback_model.dart';
import 'package:myapp/models/dietician.dart';
import 'package:myapp/models/review.dart';
import 'package:myapp/models/blood_pressure.dart';
import 'package:myapp/models/creatine.dart';
import 'package:myapp/models/weight.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:typed_data';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:myapp/models/user_file.dart';
import 'package:myapp/models/nutrition_restriction.dart';
import 'package:myapp/utils/logger_config.dart';
import 'package:uuid/uuid.dart';
import 'package:myapp/config/app_config.dart';

import 'package:myapp/models/education_category.dart';
import 'package:myapp/models/education_video.dart';

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
        redirectTo: AppConfig.googleAuthRedirectUrl, // Use global URL
      );
    } else {
      // Mobile implementation using google_sign_in
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: AppConfig.googleSignInWebClientId, // Use global client ID
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

  Future<List<EducationVideo>> getEducationVideos(int categoryId) async {
    try {
      final response = await _supabase
          .from('educational_videos')
          .select('videoId, categoryId, videoName, videoImageURL, videoUrl')
          .eq('categoryId', categoryId);

      if (response.isEmpty) {
        print('No education videos found for category ID: \$categoryId');
        return [];
      }

      return (response as List).map((map) => EducationVideo.fromJson(map)).toList();
    } catch (e) {
      print('Error fetching education videos for category ID $categoryId from Supabase: $e');
      return [];
    }
  }

  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  // --- End Authentication Methods ---

  // Initialize Supabase (call this in main.dart)
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl, // Use global URL
      anonKey: AppConfig.supabaseAnonKey, // Use global Anon Key
    );
  }

  // Patient Details Operations
  Future<void> upsertPatientDetails(PatientDetails details) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        logger.i('upsertPatientDetails: No authenticated user found. Cannot upsert patient details.');
        return;
      }
      details.userId = user.id; // Assign the current user's ID
      final data = details.toMap();
      // Supabase will automatically handle insert/update based on primary key
      await _supabase.from('patient_details').upsert(data);
      logger.i('Patient details upserted to Supabase: ${details.name} for user ${user.id}');
    } catch (e) {
      logger.e('Error upserting patient details to Supabase: $e');
    }
  }

  Future<PatientDetails?> getPatientDetails() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('getPatientDetails: No authenticated user found. Cannot fetch patient details.');
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

    Future<List<EducationCategory>> getEducationCategories() async {
    try {
      final response = await _supabase
          .from('educationcategory')
          .select('categoryId, categoryName, categoryImage');

      if (response.isEmpty) {
        print('No education categories found in Supabase.');
        return [];
      }

      return (response as List).map((map) => EducationCategory.fromJson(map)).toList();
    } catch (e) {
      print('Error fetching education categories from Supabase: \$e');
      return [];
    }
  }

  // Feedback Operations
  Future<void> insertFeedback(FeedbackModel feedback) async {
    try {
      final data = feedback.toMap();
      await _supabase.from('feedback').insert(data);
      print('Feedback inserted to Supabase: \${feedback.feedbackText}');
    } catch (e) {
      print('Error inserting feedback to Supabase: \$e');
    }
  }

  // Dietician Operations
  Future<List<Dietician>> getDieticians() async {
    try {
      final response = await _supabase
          .from('dieticians')
          .select('id, name, experience, specialty, image_url, whatsapp_number, education, available_day, available_hour, fees, languages');
      print('Supabase raw response for dieticians: \$response');
      
      if ((response.isEmpty)) {
        print('No data or empty response from Supabase for dieticians.');
        return [];
      }

      final List<Dietician> dieticians = (response as List).map((map) => Dietician.fromMap(map)).toList();
      print('Parsed dieticians: \$dieticians');
      return dieticians;
    } catch (e) {
      print('Error fetching dieticians from Supabase: \$e');
      return []; // Return empty list on error
    }
  }

  Future<void> deleteBloodPressureReading(String id) async {
    try {
      await _supabase.from('blood_pressure_readings').delete().eq('id', id);
      print('Blood pressure reading with ID \$id deleted from Supabase.');
    } catch (e) {
      print('Error deleting blood pressure reading from Supabase: \$e');
      rethrow;
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
        print('No reviews found for dietician ID: \$dieticianId');
        return [];
      }

      final List<Review> reviews = (response as List).map((map) => Review.fromMap(map)).toList();
      print('Fetched reviews for dietician \$dieticianId: \$reviews');
      return reviews;
    } catch (e) {
      print('Error fetching reviews for dietician \$dieticianId from Supabase: \$e');
      return []; // Return empty list on error
    }
  }

  // Blood Pressure Operations
  Future<void> insertBloodPressure(BloodPressure bp) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('insertBloodPressure: No authenticated user found. Cannot insert blood pressure reading.');
        return;
      }
      bp.userId = user.id; // Assign the current user's ID
      final data = bp.toMap();
      await _supabase.from('blood_pressure_readings').insert(data);
      print('Blood pressure reading inserted to Supabase: \${bp.systolic}/\${bp.diastolic} for user \${user.id}');
    } catch (e) {
      print('Error inserting blood pressure reading to Supabase: \$e');
    }
  }

  Future<List<BloodPressure>> getBloodPressureReadings({DateTime? startDate}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('getBloodPressureReadings: No authenticated user found. Cannot fetch blood pressure readings.');
        return [];
      }

      var query = _supabase
          .from('blood_pressure_readings')
          .select()
          .eq('user_id', user.id);

      if (startDate != null) {
        query = query.gte('timestamp', startDate.toIso8601String());
      }

      final response = await query.order('timestamp', ascending: false);

      if (response.isEmpty) {
        print('No blood pressure readings found for user \${user.id} with filter starting from \$startDate.');
        return [];
      }

      final List<BloodPressure> readings = (response as List).map((map) => BloodPressure.fromMap(map)).toList();
      print('Fetched \${readings.length} blood pressure readings for user \${user.id} with filter starting from \$startDate.');
      return readings;
    } catch (e) {
      print('Error fetching blood pressure readings from Supabase: \$e');
      return [];
    }
  }

  Future<BloodPressure?> getLatestBloodPressureReading() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('getLatestBloodPressureReading: No authenticated user found. Cannot fetch latest blood pressure reading.');
        return null;
      }

      final response = await _supabase
          .from('blood_pressure_readings')
          .select()
          .eq('user_id', user.id)
          .order('timestamp', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        return BloodPressure.fromMap(response.first);
      }
      return null;
    } catch (e) {
      print('Error fetching latest blood pressure reading from Supabase: \$e');
      return null;
    }
  }

  // Creatine Operations
  Future<void> insertCreatine(Creatine creatine) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('insertCreatine: No authenticated user found. Cannot insert creatine reading.');
        return;
      }
      final data = {
        'user_id': user.id,
        'value': creatine.value,
        'timestamp': creatine.timestamp.toIso8601String(),
        'comment': creatine.comment,
      };
      await _supabase.from('creatine_readings').insert(data);
      print('Creatine reading inserted to Supabase: \${creatine.value} for user \${user.id}');
    } catch (e) {
      print('Error inserting creatine reading to Supabase: \$e');
    }
  }

  Future<List<Creatine>> getCreatineReadings({DateTime? startDate}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('getCreatineReadings: No authenticated user found. Cannot fetch creatine readings.');
        return [];
      }

      var query = _supabase
          .from('creatine_readings')
          .select()
          .eq('user_id', user.id);

      if (startDate != null) {
        query = query.gte('timestamp', startDate.toIso8601String());
      }

      final response = await query.order('timestamp', ascending: false);

      if (response.isEmpty) {
        print('No creatine readings found for user \${user.id} with filter starting from \$startDate.');
        return [];
      }

      final List<Creatine> readings = (response as List).map((map) => Creatine.fromMap(map)).toList();
      print('Fetched \${readings.length} creatine readings for user \${user.id} with filter starting from \$startDate.');
      return readings;
    } catch (e) {
      print('Error fetching creatine readings from Supabase: \$e');
      return [];
    }
  }

  Future<Creatine?> getLatestCreatineReading() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('getLatestCreatineReading: No authenticated user found. Cannot fetch latest creatine reading.');
        return null;
      }

      final response = await _supabase
          .from('creatine_readings')
          .select()
          .eq('user_id', user.id)
          .order('timestamp', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        return Creatine.fromMap(response.first);
      }
      return null;
    } catch (e) {
      print('Error fetching latest creatine reading from Supabase: \$e');
      return null;
    }
  }

  Future<void> deleteCreatine(String id) async {
    try {
      await _supabase.from('creatine_readings').delete().eq('id', id);
      print('Creatine reading with ID \$id deleted from Supabase.');
    } catch (e) {
      print('Error deleting creatine reading from Supabase: \$e');
      rethrow;
    }
  }

  // Weight Operations
  Future<void> insertWeight(Weight weight) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('insertWeight: No authenticated user found. Cannot insert weight reading.');
        return;
      }
      final data = {
        'user_id': user.id,
        'value': weight.value,
        'timestamp': weight.timestamp.toIso8601String(),
        'comment': weight.comment,
      };
      await _supabase.from('weight_readings').insert(data);
      print('Weight reading inserted to Supabase: \${weight.value} for user \${user.id}');
    } catch (e) {
      print('Error inserting weight reading to Supabase: \$e');
    }
  }

  Future<List<Weight>> getWeightReadings({DateTime? startDate}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('getWeightReadings: No authenticated user found. Cannot fetch weight readings.');
        return [];
      }

      var query = _supabase
          .from('weight_readings')
          .select()
          .eq('user_id', user.id);

      if (startDate != null) {
        query = query.gte('timestamp', startDate.toIso8601String());
      }

      final response = await query.order('timestamp', ascending: false);

      if (response.isEmpty) {
        print('No weight readings found for user \${user.id} with filter starting from \$startDate.');
        return [];
      }

      final List<Weight> readings = (response as List).map((map) => Weight.fromMap(map)).toList();
      print('Fetched \${readings.length} weight readings for user \${user.id} with filter starting from \$startDate.');
      return readings;
    } catch (e) {
      print('Error fetching weight readings from Supabase: \$e');
      return [];
    }
  }

  Future<Weight?> getLatestWeightReading() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('getLatestWeightReading: No authenticated user found. Cannot fetch latest weight reading.');
        return null;
      }

      final response = await _supabase
          .from('weight_readings')
          .select()
          .eq('user_id', user.id)
          .order('timestamp', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        return Weight.fromMap(response.first);
      }
      return null;
    } catch (e) {
      print('Error fetching latest weight reading from Supabase: \$e');
      return null;
    }
  }

  Future<void> deleteWeight(String id) async {
    try {
      await _supabase.from('weight_readings').delete().eq('id', id);
      print('Weight reading with ID \$id deleted from Supabase.');
    } catch (e) {
      print('Error deleting weight reading from Supabase: \$e');
      rethrow;
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
          .like('message_key', 'tip_%')
          .order('message_key', ascending: true);

      if (response.isEmpty) {
        print('No tips found in Supabase.');
        return [];
      }

      return (response as List).map((map) => map['message_text'] as String).toList();
    } catch (e) {
      print('Error fetching all tips from Supabase: \$e');
      return [];
    }
  }

  // Meal Plan Operations
  Future<Map<String, dynamic>> getMealPlan() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('getMealPlan: No authenticated user found. Cannot fetch meal plan.');
        return {};
      }

      final userMealPlanResponse = await _supabase
          .from('usermealplans')
          .select()
          .eq('user_id', user.id)
          .limit(1);

      if (userMealPlanResponse.isEmpty) {
        print('No meal plan found for user \${user.id}.');
        return {};
      }

      final userMealPlan = userMealPlanResponse.first;
      final planId = userMealPlan['plan_id'];

      final mealsResponse = await _supabase
          .from('meals')
          .select('*, sequence') // Select all columns including sequence
          .eq('plan_id', planId)
          .order('sequence', ascending: true); // Order by sequence

      final mealItemsResponse = await _supabase
          .from('mealitems')
          .select()
          .filter('meal_id', 'in', mealsResponse.map((meal) => meal['meal_id']).toList())
          .order('sequence', ascending: true);

      final mealItemOptionsResponse = await _supabase
          .from('mealitemoptions')
          .select('*, amount')
          .filter('item_id', 'in', mealItemsResponse.map((item) => item['item_id']).toList());

      return {
        'userMealPlan': userMealPlan,
        'meals': mealsResponse,
        'mealItems': mealItemsResponse,
        'mealItemOptions': mealItemOptionsResponse,
      };
    } catch (e) {
      print('Error fetching meal plan from Supabase: \$e');
      return {};
    }
  }

  // File Upload Operations
  Future<String> uploadFile(Uint8List fileBytes, String fileName) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthException('No authenticated user found. Cannot upload file.');
      }
      final newFileName = '\${user.id}/\${DateTime.now().millisecondsSinceEpoch}_\$fileName';
      final contentType = lookupMimeType(fileName);
      await _supabase.storage.from('user-files').uploadBinary(
            newFileName,
            fileBytes,
            fileOptions: FileOptions(contentType: contentType),
          );
      return _supabase.storage.from('user-files').getPublicUrl(newFileName);
    } catch (e) {
      print('Error uploading file to Supabase: \$e');
      rethrow;
    }
  }

  Future<void> insertUserFile(String fileUrl, String fileName) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthException('No authenticated user found. Cannot insert user file.');
      }
      final userFile = UserFile(
        fileId: Uuid().v4(),
        userId: user.id,
        fileName: fileName,
        fileUrl: fileUrl,
      );
      await _supabase.from('userfiles').insert(userFile.toMap());
    } catch (e) {
      print('Error inserting user file to Supabase: \$e');
      rethrow;
    }
  }

  // Nutrition Restriction Operations
  Future<List<NutritionRestriction>> getNutritionRestrictions() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('getNutritionRestrictions: No authenticated user found. Cannot fetch nutrition restrictions.');
        return [];
      }

      final response = await _supabase
          .from('nutrition_restriction')
          .select()
          .eq('userId', user.id)
          .order('sequence', ascending: true);

      if (response.isEmpty) {
        print('No nutrition restrictions found for user \${user.id}.');
        return [];
      }

      final List<NutritionRestriction> restrictions = (response as List)
          .map((map) => NutritionRestriction.fromMap(map))
          .toList();
      print('Fetched \${restrictions.length} nutrition restrictions for user \${user.id}.');
      return restrictions;
    } catch (e) {
      print('Error fetching nutrition restrictions from Supabase: \$e');
      return [];
    }
  }
}
