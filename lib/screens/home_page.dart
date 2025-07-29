import 'package:flutter/material.dart';
import 'package:myapp/screens/feedback_page.dart';
import 'package:myapp/screens/dietician_list_page.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/screens/settings_page.dart';
import 'package:myapp/screens/notification_page.dart'; // Import NotificationPage
import 'package:provider/provider.dart';
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/screens/egfr_calculator_screen.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/screens/vital_tracking_page.dart';
import 'package:myapp/screens/your_meals_screen.dart';
import 'package:myapp/utils/logger_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/models/blood_pressure.dart'; // Import BloodPressure model
import 'package:myapp/models/creatine.dart'; // Import Creatine model
import 'package:myapp/models/weight.dart'; // Import Weight model

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _tipOfTheDay = 'Loading tip...';
  List<String> _allTips = [];
  bool _isLoadingContent = true;
  String? _googleName;
  String? _googlePhotoUrl;

  BloodPressure? _lastBpRecord;
  Creatine? _lastCreatineRecord;
  Weight? _lastWeightRecord;

  @override
  void initState() {
    super.initState();
    logger.d('HomePage: initState called');
    _loadDynamicContent();
    _loadGoogleNameAndPhoto();
    _fetchLastVitals(); // Fetch last vital records
  }

  Future<void> _loadDynamicContent() async {
    setState(() {
      _isLoadingContent = true;
    });
    try {
      final supabaseService = SupabaseService();
      final welcomeMsg = await supabaseService.getMessageByKey(
        'welcome_message',
      );
      final tips = await supabaseService.getAllTips();

      setState(() {
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
        _tipOfTheDay = 'Error loading tip.';
      });
    } finally {
      setState(() {
        _isLoadingContent = false;
      });
    }
  }

  Future<void> _fetchLastVitals() async {
    try {
      final supabaseService = SupabaseService();
      final bpReadings = await supabaseService.getBloodPressureReadings();
      final creatineReadings = await supabaseService.getCreatineReadings();
      final weightReadings = await supabaseService.getWeightReadings();

      setState(() {
        _lastBpRecord = bpReadings.isNotEmpty ? bpReadings.first : null;
        _lastCreatineRecord = creatineReadings.isNotEmpty ? creatineReadings.first : null;
        _lastWeightRecord = weightReadings.isNotEmpty ? weightReadings.first : null;
      });
    } catch (e) {
      logger.e('Error fetching last vital records: $e');
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
    final patientName =
        _googleName ?? patientDetailsProvider.patientDetails?.name ?? 'User';
    final ckdStage =
        patientDetailsProvider.patientDetails?.ckdStage ?? 'Not Set';

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
                              logger.d(
                                'HomePage: _googlePhotoUrl before CircleAvatar: $_googlePhotoUrl',
                              );
                              return CircleAvatar(
                                radius: 25,
                                backgroundImage: _googlePhotoUrl != null
                                    ? NetworkImage(_googlePhotoUrl!)
                                    : null,
                                backgroundColor: _googlePhotoUrl == null
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.2)
                                    : Colors.transparent,
                                child: _googlePhotoUrl == null
                                    ? Text(
                                        patientName.isNotEmpty
                                            ? patientName[0].toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      )
                                    : null,
                              );
                            },
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, $patientName!',
                                style: const TextStyle(
                                  fontSize: 20.0,
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
                      // Notification Icon
                      Row(
                        children: [
                          // Notification Icon
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.notifications_none,
                                size: 28.0,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const NotificationPage(),
                                  ), // Navigate to NotificationPage
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10), // Spacing between icons
                          // Settings Icon
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.settings, size: 28.0),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsPage(),
                                  ), // Navigate to SettingsPage
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tip of the Day Section
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
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
                              Icon(
                                Icons.lightbulb_outline,
                                size: 24.0,
                                color: Theme.of(context).colorScheme.primary,
                              ),
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

                  // Your Health Board Section
                  Text(
                    localizations.yourHealthBoard,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: const EdgeInsets.only(bottom: 24.0),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildVitalSection(
                                  context,
                                  localizations.bpTab,
                                  Icons.monitor_heart,
                                  _lastBpRecord != null
                                      ? '${_lastBpRecord!.systolic}/${_lastBpRecord!.diastolic} mmHg'
                                      : null,
                                  _lastBpRecord?.timestamp,
                                  localizations.noDataAvailableForBp,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildVitalSection(
                                  context,
                                  localizations.creatinineTab,
                                  Icons.science,
                                  _lastCreatineRecord != null
                                      ? '${_lastCreatineRecord!.value} mg/dL'
                                      : null,
                                  _lastCreatineRecord?.timestamp,
                                  localizations.noDataAvailableForCreatinine,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildVitalSection(
                            context,
                            localizations.weight,
                            Icons.scale,
                            _lastWeightRecord != null
                                ? '${_lastWeightRecord!.value} kg'
                                : null,
                            _lastWeightRecord?.timestamp,
                            localizations.noDataAvailableForWeight,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const VitalTrackingPage(),
                                  ),
                                );
                                _fetchLastVitals(); // Refresh data when returning
                              },
                              icon: const Icon(Icons.track_changes),
                              label: Text(localizations.goToVitalMonitoring),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Original GridView of features
                  GridView.count(
                    shrinkWrap: true, // Important for nested scroll views
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                    crossAxisCount:
                        2, // Changed to 2 items per row as per image
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio:
                        1.0, // Adjusted for square-like cards with text below
                    children: [
                      // Food Recommendations (Working)
                      // _buildFeatureItem(
                      //   context,
                      //   'Food Recommendations',
                      //   'assets/images/onboarding1.png', // Placeholder image
                      //   const FoodListPage(),
                      // ),
                      // Contact Dietician (Working)
                      _buildFeatureItem(
                        context,
                        localizations.vitalMonitoringCard,
                        'assets/images/vital.png', // Placeholder image
                        const VitalTrackingPage(),
                      ),
                      _buildFeatureItem(
                        context,
                        "Your meals",
                        'assets/images/your_meal.jpg', // Placeholder image
                        const YourMealsScreen(),
                      ),
                      _buildFeatureItem(
                        context,
                        localizations.contactDieticianCard,
                        'assets/images/dietician.jpg', // Placeholder image
                        const DieticianListPage(),
                      ),
                      _buildFeatureItem(
                        context,
                        localizations.eGFRCalculatorCard,
                        'assets/images/gfr.png', // Placeholder image
                        const EgfrCalculatorScreen(), // Navigate to the new screen
                      ),
                      // Give Your Feedback (Working)
                      _buildFeatureItem(
                        context,
                        localizations.giveYourFeedbackCard,
                        'assets/images/feedback.jpg', // Placeholder image
                        const FeedbackPage(),
                      ),

                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildVitalSection(
    BuildContext context,
    String title,
    IconData icon,
    String? value,
    DateTime? date,
    String noDataMessage,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column( // Changed from Row to Column
        crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
        children: [
          Icon(icon, size: 30.0, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8), // Spacing between icon and title
          Text(
            title,
            textAlign: TextAlign.center, // Center the title text
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4), // Spacing between title and value
          if (value != null && date != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Center value and date
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Date: ${date.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            )
          else
            Text(
              noDataMessage,
              textAlign: TextAlign.center, // Center no data message
              style: TextStyle(
                fontSize: 14.0,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  // New widget to build each feature item (card + text below)
  Widget _buildFeatureItem(
    BuildContext context,
    String title,
    String imagePath,
    Widget? destinationPage,
  ) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      clipBehavior: Clip.antiAlias, // Ensures image respects rounded corners
      child: InkWell(
        onTap: () async {
          if (destinationPage != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destinationPage),
            );
            if (destinationPage is VitalTrackingPage) {
              _fetchLastVitals(); // Refresh data when returning from VitalTrackingPage
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.notYetImplemented(title))),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3, // Image takes more space
              child: SizedBox(
                width: double.infinity,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover, // Cover the available space
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1, // Text and icon take less space
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors
                            .grey[200], // Light grey background for the arrow icon
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16.0,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary, // Primary color for the arrow
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
