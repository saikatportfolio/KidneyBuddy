import 'package:flutter/material.dart';
import 'package:myapp/screens/vital_tracking_page.dart';
import 'package:myapp/screens/your_meals_screen.dart';
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/services/database_helper.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/utils/logger_config.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:myapp/services/analytics_service.dart';

class PatientDetailsPage extends StatefulWidget {
  final String? source;

  const PatientDetailsPage({super.key, this.source});

  @override
  _PatientDetailsPageState createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 1;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _ckdStage;
  String? _gender;
  String? _email;

  String? _videoUrl;
  String? _videoThumbnailUrl;
  late VideoPlayerController _videoPlayerController;
  bool _isVideoPlaying = false;
  bool _isThumbnailVisible = true;

  Widget _buildStepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(labelText: 'Phone Number'),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _ckdStage,
          decoration: const InputDecoration(labelText: 'CKD Stage'),
          items: const <String>['Stage 1', 'Stage 2', 'Stage 3', 'Stage 4', 'Stage 5']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _ckdStage = newValue;
            });
          },
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              setState(() {
                _currentStep = 2;
              });
            }
          },
          child: const Text('Next'),
        ),
      ],
    );
  }

  Widget _buildStepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _ageController,
          decoration: const InputDecoration(labelText: 'Age'),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your age';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _gender,
          decoration: const InputDecoration(labelText: 'Gender'),
          items: const <String>['Male', 'Female', 'Other']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _gender = newValue;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your gender';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _savePatientDetails,
          child: const Text('Submit'),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    AnalyticsService().trackScreen('patient_detsils_page');
    _loadInitialData(); // New method to handle loading from SharedPreferences and existing details
    _loadVideoContent();
  }

  void _loadVideoContent() async {
    try {
      final supabaseService = SupabaseService();
      final videoUrlData = await supabaseService.getMessageByKey('patinet_video_url');
      // final videoThumbnailUrlData =
      //     await supabaseService.getMessageByKey('patinet_image_url');

      setState(() {
        _videoUrl = videoUrlData;
        _videoThumbnailUrl = 'assets/images/fill_your_details.png';
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
              _isVideoPlaying = false;
            });
          }
        });
      }
    } catch (e) {
      logger.e('Error loading video content: $e');
      setState(() {});
    }
  }

  void _loadInitialData() async {
    // Load from SharedPreferences first (for Google Sign-in pre-fill)
    final prefs = await SharedPreferences.getInstance();
    final String? googleUserName = prefs.getString('google_user_name');
    final String? googleUserEmail = prefs.getString('google_user_email');

    logger.d('Patient detailas: Retrieved Google Email1: $googleUserEmail');
    logger.d('Patient detailas: Retrieved Google Name: $googleUserName');

    if (googleUserName != null) {
      _nameController.text = googleUserName;
    }
    if (googleUserEmail != null) {
      _email = googleUserEmail;
    }

    // Then load existing patient details (this will overwrite if there are existing details)
    _loadPatientDetails();
  }

  void _loadPatientDetails() async {
    PatientDetails? loadedDetails;
    if (kIsWeb) {
      loadedDetails = await SupabaseService().getPatientDetails();
    } else {
      loadedDetails = await DatabaseHelper().getPatientDetails();
    }

    if (loadedDetails != null) {
      setState(() {
        _nameController.text = loadedDetails!.name;
        _phoneController.text = loadedDetails.phoneNumber;
        _ckdStage = loadedDetails.ckdStage;
      });
      // Update provider with loaded details
      if (!mounted) return;
      Provider.of<PatientDetailsProvider>(context, listen: false).setPatientDetails(loadedDetails);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
    _videoPlayerController.dispose();
  }

  void _savePatientDetails() async {
    if (_formKey.currentState!.validate()) {
      // Get existing patient details from provider if available
      final existingDetails = Provider.of<PatientDetailsProvider>(context, listen: false).patientDetails;

      final patientDetails = PatientDetails(
        id: existingDetails?.id ?? const Uuid().v4(),
        userId: existingDetails?.userId,
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        weight: existingDetails?.weight ?? 0.0,
        height: existingDetails?.height ?? 0.0,
        ckdStage: _ckdStage,
        gender: _gender,
        email: _email,
        age: int.tryParse(_ageController.text) ?? 0,
      );

      // Conditional Save Logic
      if (!kIsWeb) {
        // Save to SQLite for mobile
        final dbHelper = DatabaseHelper();
        await dbHelper.insertPatientDetails(patientDetails);
      }

      // Always sync to Supabase
      await SupabaseService().upsertPatientDetails(patientDetails);

      // Update provider (using the local patientDetails object)
      if (!mounted) return;
      Provider.of<PatientDetailsProvider>(context, listen: false).setPatientDetails(patientDetails);

      // Navigate to correct page based on source
      if (!mounted) return;
      if (widget.source == "your_meals") {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const YourMealsScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => VitalTrackingPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Patient Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isSkipEnabled', true);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => VitalTrackingPage()),
                      );
                    },
                    child: const Text(
                      'SKIP',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
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
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (_isThumbnailVisible)
                                    AspectRatio(
                                      aspectRatio: 15 / 8,
                                      child: _videoThumbnailUrl != null
                                          ? Image.asset(
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
                                      setState(() {
                                        if (_isVideoPlaying) {
                                          _videoPlayerController.pause();
                                          _isVideoPlaying = false;
                                        } else {
                                          _videoPlayerController.play();
                                          _isVideoPlaying = true;
                                          _isThumbnailVisible = false;
                                        }
                                      });
                                    },
                                    child: Icon(
                                      _isVideoPlaying ? Icons.pause : Icons.play_circle_filled_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _currentStep == 1 ? _buildStepOne() : _buildStepTwo(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
