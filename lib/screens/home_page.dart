import 'package:flutter/material.dart';
import 'package:myapp/screens/feedback_page.dart';
import 'package:myapp/screens/dietician_list_page.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/screens/food_list_page.dart';
import 'package:myapp/screens/settings_page.dart';
import 'package:myapp/screens/education_category_screen.dart';
// Import NotificationPage
import 'package:provider/provider.dart';
import 'package:myapp/services/analytics_service.dart';
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
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _allTips = [];
  bool _isLoadingContent = true;
  String? _googleName;
  String? _googlePhotoUrl;
  String? _videoUrl;
  String? _videoThumbnailUrl;
  late VideoPlayerController _videoPlayerController;

  BloodPressure? _lastBpRecord;
  Creatine? _lastCreatineRecord;
  Weight? _lastWeightRecord;
  bool _isVideoPlaying = false;
  bool _isThumbnailVisible = true;

  @override
  void initState() {
    super.initState();
    logger.d('HomePage: initState called');
    _loadDynamicContent();
    _loadGoogleNameAndPhoto();
    _fetchLastVitals(); // Fetch last vital records

    // Initialize with a dummy URL, will be updated in _loadDynamicContent
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(''));

    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.position ==
          _videoPlayerController.value.duration) {
        setState(() {
          logger.d('HomePgae, video finished');
          _isVideoPlaying = false;
        });
      }
    });
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
      final videoUrlData = await supabaseService.getMessageByKey('video_url');
      final videoThumbnailUrlData =
          await supabaseService.getMessageByKey('image_thumbnail');

      setState(() {
        _allTips = tips;
        _videoUrl = videoUrlData;
        _videoThumbnailUrl = videoThumbnailUrlData;
      });

      if (_videoUrl != null) {
        _videoPlayerController =
            VideoPlayerController.networkUrl(Uri.parse(_videoUrl!))
              ..initialize().then((_) {
                setState(() {});
              });

        _videoPlayerController.addListener(() {
          if (_videoPlayerController.value.position ==
              _videoPlayerController.value.duration) {
            setState(() {
              logger.d('HomePgae, video finished');
              _isVideoPlaying = false;
            });
          }
        });
      }
    } catch (e) {
      logger.e('Error loading dynamic content: $e');
      setState(() {
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
      final latestBp = await supabaseService.getLatestBloodPressureReading();
      final latestCreatine = await supabaseService.getLatestCreatineReading();
      final latestWeight = await supabaseService.getLatestWeightReading();

      setState(() {
        _lastBpRecord = latestBp;
        _lastCreatineRecord = latestCreatine;
        _lastWeightRecord = latestWeight;
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
    logger.i('HomePage: _videoUrl = $_videoUrl');
    logger.i('HomePage: imageThumnail = $_videoThumbnailUrl');
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
                                    ? Theme.of(context).colorScheme.primary
                                          .withValues(alpha: 0.2)
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
                          // Container(
                          //   decoration: BoxDecoration(
                          //   shape: BoxShape.circle,
                          //   color: Colors.grey[200],
                          //   ),
                          //   child: IconButton(
                          //   icon: const Icon(
                          //       Icons.notifications_none,
                          //       size: 28.0,
                          //   ),
                          //   onPressed: () {
                          //       Navigator.of(context).push(
                          //         MaterialPageRoute(
                          //           builder: (_) =>
                          //               const NotificationPage(),
                          //         ), // Navigate to NotificationPage
                          //       );
                          //   },
                          //   ),
                          // ),
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
                  // Card(
                  //   elevation: 4.0,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(15.0),
                  //   ),
                  //   margin: const EdgeInsets.only(bottom: 24.0),
                  //   color: Colors.white,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(20.0),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           'Tip of the Day',
                  //           style: TextStyle(
                  //             fontSize: 18.0,
                  //             fontWeight: FontWeight.bold,
                  //             color: Theme.of(context).colorScheme.primary,
                  //           ),
                  //         ),
                  //         const SizedBox(height: 10),
                  //         Row(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Icon(
                  //               Icons.lightbulb_outline,
                  //               size: 24.0,
                  //               color: Theme.of(context).colorScheme.primary,
                  //             ),
                  //             const SizedBox(width: 10),
                  //             Expanded(
                  //               child: Text(
                  //                 _tipOfTheDay,
                  //                 style: const TextStyle(
                  //                   fontSize: 14.0,
                  //                   color: Colors.black87,
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  if (_videoUrl != null)
                    Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: const EdgeInsets.only(bottom: 15.0),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: SizedBox(
                          width: double.infinity,
                          //height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (_isThumbnailVisible)
                                AspectRatio(
                                  aspectRatio: 15 / 8,
                                  child: _videoThumbnailUrl != null
                                      ? Image.network(
                                          _videoThumbnailUrl!,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: Icon(
                                              Icons.image,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                )
                              else if (_videoPlayerController.value.isInitialized)
                                Column(
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 15 / 8,
                                      child: VideoPlayer(
                                        _videoPlayerController,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 2.0,
                                      ),
                                      child: VideoProgressIndicator(
                                        _videoPlayerController,
                                        allowScrubbing: true,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              FloatingActionButton(
                                backgroundColor: Colors.blue.withValues(
                                  alpha: 0.5,
                                ),
                                onPressed: () {
                                  AnalyticsService().pushToGTM(
                                      'video_play_pause_click', {
                                    'user_id': '12345', // Replace with actual user ID
                                    'video_url': _videoUrl ?? '',
                                    'is_playing': _isVideoPlaying,
                                  });
                                  setState(() {
                                    logger.d('Video paused');
                                    if (_isVideoPlaying) {
                                      _videoPlayerController.pause();
                                      _isVideoPlaying = false;
                                    } else {
                                      logger.d('Video played');
                                      _videoPlayerController.play();
                                      _isVideoPlaying = true;
                                      _isThumbnailVisible = false;
                                    }
                                  });
                                },
                                child: Icon(
                                  _isVideoPlaying
                                      ? Icons.pause
                                      : Icons.play_circle_filled_rounded,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 2),
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
                    margin: const EdgeInsets.only(bottom: 18.0),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                buildVitalSection(
                                  context,
                                  localizations.bpTab,
                                  Icons.monitor_heart,
                                  _lastBpRecord != null
                                      ? '${_lastBpRecord!.systolic}/${_lastBpRecord!.diastolic} mmHg'
                                      : null,
                                  _lastBpRecord?.timestamp,
                                  localizations.noDataAvailableForBp,
                                ),
                                const SizedBox(width: 16),
                                buildVitalSection(
                                  context,
                                  localizations.creatinineTab,
                                  Icons.science,
                                  _lastCreatineRecord != null
                                      ? '${_lastCreatineRecord!.value} mg/dL'
                                      : null,
                                  _lastCreatineRecord?.timestamp,
                                  localizations.noDataAvailableForCreatinine,
                                ),
                                const SizedBox(width: 16),
                                buildVitalSection(
                                  context,
                                  localizations.weight,
                                  Icons.scale,
                                  _lastWeightRecord != null
                                      ? '${_lastWeightRecord!.value} kg'
                                      : null,
                                  _lastWeightRecord?.timestamp,
                                  localizations.noDataAvailableForWeight,
                                ),
                              ],
                            ),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
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
                      buildFeatureItem(
                        context,
                        localizations.vitalMonitoringCard,
                        'assets/images/vital.png', // Placeholder image
                        const VitalTrackingPage(),
                      ),
                      buildFeatureItem(
                        context,
                        "Your meals",
                        'assets/images/your_meal.jpg', // Placeholder image
                        const YourMealsScreen(),
                      ),
                      // buildFeatureItem(
                      //   context,
                      //   'Nutritions Info',
                      //   'assets/images/nutrition_guide_ckd.jpeg', // Placeholder image
                      //   const FoodListPage(),
                      // ),
                      buildFeatureItem(
                        context,
                        localizations.contactDieticianCard,
                        'assets/images/dietician.jpg', // Placeholder image
                        const DieticianListPage(),
                      ),
                      buildFeatureItem(
                        context,
                        'Understand CKD',
                        'assets/images/understand_ckd.png', // Placeholder image
                        const EducationCategoryScreen(),
                      ),
                      buildFeatureItem(
                        context,
                        localizations.eGFRCalculatorCard,
                        'assets/images/gfr.png', // Placeholder image
                        const EgfrCalculatorScreen(), // Navigate to the new screen
                      ),
                      // Give Your Feedback (Working)
                      buildFeatureItem(
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

  Widget buildVitalSection(
    BuildContext context,
    String title,
    IconData icon,
    String? value,
    DateTime? date,
    String noDataMessage,
  ) {
    return Container(
      width: 135, // Set a fixed width for each vital section
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 30.0, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          if (value != null && date != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Date: ${DateFormat('dd-MM-yyyy').format(date)}',
                  style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                ),
              ],
            )
          else
            Text(
              noDataMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget buildFeatureItem(
    BuildContext context,
    String title,
    String imagePath,
    Widget? destinationPage,
  ) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      clipBehavior: Clip.antiAlias,
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
              flex: 3,
              child: SizedBox(
                width: double.infinity,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
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
              flex: 1,
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
                        color: Colors.grey[200],
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16.0,
                        color: Theme.of(context).colorScheme.primary,
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
    _videoPlayerController.dispose();
  }
}