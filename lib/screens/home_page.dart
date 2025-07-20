import 'package:flutter/material.dart';
import 'package:myapp/screens/feedback_page.dart';
import 'package:myapp/screens/dietician_list_page.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/screens/settings_page.dart';
import 'package:myapp/screens/food_list_page.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/screens/egfr_calculator_screen.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/screens/vital_tracking_page.dart';
import 'package:myapp/screens/your_meals_screen.dart';
import 'package:myapp/utils/logger_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _welcomeMessage = 'Stay informed and healthy on your journey.';
  String _tipOfTheDay = 'Loading tip...';
  List<String> _allTips = [];
  bool _isLoadingContent = true;
  String? _googleName;
  String? _googlePhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadDynamicContent();
    _loadGoogleNameAndPhoto();
  }

  Future<void> _loadDynamicContent() async {
    setState(() {
      _isLoadingContent = true;
    });
    try {
      final supabaseService = SupabaseService();
      final welcomeMsg = await supabaseService.getMessageByKey('welcome_message');
      final tips = await supabaseService.getAllTips();

      setState(() {
        _welcomeMessage = welcomeMsg ?? 'Stay informed and healthy on your journey.';
        _allTips = tips;
        if (_allTips.isNotEmpty) {
          _tipOfTheDay = _allTips[DateTime.now().day % _allTips.length];
        } else {
          _tipOfTheDay = 'No tips available at the moment.';
        }
      });
    } catch (e) {
      logger.e('Error loading dynamic content: $e');
      setState(() {
        _welcomeMessage = 'Error loading message.';
        _tipOfTheDay = 'Error loading tip.';
      });
    } finally {
      setState(() {
        _isLoadingContent = false;
      });
    }
  }

  Future<void> _loadGoogleNameAndPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _googleName = prefs.getString('google_user_name');
      _googlePhotoUrl = prefs.getString('google_user_photo_url');
      logger.i('Home page _googleName $_googleName');
      logger.i('Home page _googlePhotoUrl $_googlePhotoUrl');
    });
  }

  @override
  Widget build(BuildContext context) {
    logger.d('HomePage: build called');
    final localizations = AppLocalizations.of(context)!;
    final patientDetailsProvider = Provider.of<PatientDetailsProvider>(context);
    final patientName = _googleName ?? patientDetailsProvider.patientDetails?.name ?? 'User';
    final ckdStage = patientDetailsProvider.patientDetails?.ckdStage ?? 'Not Set';

    return Scaffold(
      body: _isLoadingContent
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Debugging: Log the photo URL right before using it
                          Builder(
                            builder: (context) {
                              logger.d('HomePage: _googlePhotoUrl before CircleAvatar: $_googlePhotoUrl');
                              return CircleAvatar(
                                radius: 25,
                                backgroundImage: _googlePhotoUrl != null
                                    ? NetworkImage(_googlePhotoUrl!)
                                    : null,
                                backgroundColor: _googlePhotoUrl == null
                                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                                    : Colors.transparent,
                                child: _googlePhotoUrl == null
                                    ? Text(
                                        patientName.isNotEmpty ? patientName[0].toUpperCase() : 'U',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      )
                                    : null,
                              );
                            }
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, $patientName!',
                                style: const TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your CKD Stage: $ckdStage',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_none, size: 28.0),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _welcomeMessage, // Dynamic welcome message
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tip of the Day Section
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                    margin: const EdgeInsets.only(bottom: 24.0),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tip of the Day',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lightbulb_outline, size: 24.0, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _tipOfTheDay,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Original GridView of features
                  GridView.count(
                    shrinkWrap: true, // Important for nested scroll views
                    physics: const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                    crossAxisCount: 3, // Changed to 3 items per row as per image
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.9, // Adjusted for square-like cards with text below
                    children: [
                      // Food Recommendations (Working)
                      _buildFeatureItem(
                        context,
                        'Food Recommendations',
                        'Get personalized food recommendations based on your CKD stage.',
                        Icons.restaurant_menu,
                        const FoodListPage(),
                      ),
                      // Contact Dietician (Working)
                      _buildFeatureItem(
                        context,
                        localizations.contactDieticianCard,
                        localizations.contactDieticianDescription,
                        Icons.person_pin,
                        const DieticianListPage(),
                      ),
                      // Give Your Feedback (Working)
                      _buildFeatureItem(
                        context,
                        localizations.giveYourFeedbackCard,
                        localizations.giveYourFeedbackDescription,
                        Icons.feedback,
                        const FeedbackPage(),
                      ),
                      _buildFeatureItem(
                        context,
                        "Your meals",
                        localizations.dietManagementDescription,
                        Icons.food_bank,
                        const YourMealsScreen(),
                      ),
                      _buildFeatureItem(
                        context,
                        localizations.vitalMonitoringCard,
                        localizations.vitalMonitoringDescription,
                        Icons.monitor_heart,
                        const VitalTrackingPage(),
                      ),
                      _buildFeatureItem(
                        context,
                        localizations.eGFRCalculatorCard,
                        localizations.eGFRCalculatorDescription,
                        Icons.calculate,
                        const EgfrCalculatorScreen(), // Navigate to the new screen
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // New widget to build each feature item (card + text below)
  Widget _buildFeatureItem(BuildContext context, String title, String description, IconData icon, Widget? destinationPage) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      children: [
        Expanded(
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            color: Theme.of(context).colorScheme.primary, // Fill card with primary color
            child: InkWell(
              onTap: () {
                if (destinationPage != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => destinationPage),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.notYetImplemented(title))),
                  );
                }
              },
              child: Center(
                child: Icon(icon, size: 50.0, color: Colors.white), // Large white icon
              ),
            ),
          ),
        ),
        const SizedBox(height: 8.0), // Space between card and text
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold), // Smaller font for text below
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}
