import 'package:flutter/material.dart';
import 'package:myapp/screens/feedback_page.dart';
import 'package:myapp/screens/dietician_list_page.dart';
import 'package:myapp/l10n/app_localizations.dart'; // Import generated localizations
import 'package:myapp/screens/settings_page.dart'; // Import SettingsPage
import 'package:myapp/screens/food_list_page.dart'; // Import the new food list page
import 'package:provider/provider.dart'; // Import provider
import 'package:myapp/models/patient_details.dart'; // Import PatientDetailsProvider

import 'package:myapp/screens/dietician_list_page.dart';
import 'package:myapp/l10n/app_localizations.dart'; // Import generated localizations
import 'package:myapp/screens/settings_page.dart'; // Import SettingsPage
import 'package:myapp/screens/food_list_page.dart'; // Import the new food list page
import 'package:provider/provider.dart'; // Import provider
import 'package:myapp/models/patient_details.dart'; // Import PatientDetailsProvider
import 'package:myapp/services/supabase_service.dart'; // Import SupabaseService

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

  @override
  void initState() {
    super.initState();
    _loadDynamicContent();
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
      print('Error loading dynamic content: $e');
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

  @override
  Widget build(BuildContext context) {
    print('HomePage: build called'); // Keep the print statement
    final localizations = AppLocalizations.of(context)!;
    final patientDetailsProvider = Provider.of<PatientDetailsProvider>(context);
    final patientName = patientDetailsProvider.patientDetails?.name ?? 'User';
    final ckdStage = patientDetailsProvider.patientDetails?.ckdStage ?? 'Not Set';

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.homePageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoadingContent
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personalized Greeting Section
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, size: 30.0, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 10),
                              Text(
                                'Hello, $patientName!',
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your CKD Stage: $ckdStage',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _welcomeMessage, // Dynamic welcome message
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tip of the Day Section
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                    margin: const EdgeInsets.only(bottom: 24.0),
                    color: Colors.white, // Set background color to white
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
                              color: Theme.of(context).colorScheme.primary, // Use primary color for heading
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
                                  _tipOfTheDay, // Dynamic tip of the day
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
                      // Remaining features (Not yet working)
                      _buildFeatureItem(
                        context,
                        localizations.dietManagementCard,
                        localizations.dietManagementDescription,
                        Icons.food_bank,
                        null,
                      ),
                      _buildFeatureItem(
                        context,
                        localizations.bloodPressureMonitoringCard,
                        localizations.bloodPressureMonitoringDescription,
                        Icons.monitor_heart,
                        null,
                      ),
                      _buildFeatureItem(
                        context,
                        localizations.eGFRCalculatorCard,
                        localizations.eGFRCalculatorDescription,
                        Icons.calculate,
                        null,
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
}
