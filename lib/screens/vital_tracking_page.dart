import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/screens/vital_tracking_tab.dart'; // Import the new VitalTrackingTab
import 'package:myapp/utils/localization_helper.dart'; // Import LocalizationHelper
import 'package:myapp/screens/add_bp_page.dart'; // Import AddBpPage
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:provider/provider.dart'; // Import Provider
import 'package:myapp/models/patient_details.dart'; // Import PatientDetails
import 'package:myapp/screens/auth_screen.dart'; // Import AuthScreen
import 'package:myapp/screens/patient_details_page.dart'; // Import PatientDetailsPage
import 'package:myapp/utils/logger_config.dart'; // Import the logger
import 'package:myapp/utils/pdf_generator.dart'; // Import PdfGenerator
import 'package:myapp/models/blood_pressure.dart'; // Import BloodPressure model
import 'package:myapp/services/database_helper.dart'; // Import DatabaseHelper
import 'package:printing/printing.dart'; // Import printing for PDF sharing
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'package:myapp/services/supabase_service.dart'; // Ensure SupabaseService is imported

class VitalTrackingPage extends StatefulWidget {
  const VitalTrackingPage({super.key});

  @override
  State<VitalTrackingPage> createState() => _VitalTrackingPageState();
}

class _VitalTrackingPageState extends State<VitalTrackingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCategoryIndex = 0;
  final SupabaseService _supabaseService = SupabaseService(); // Explicitly create an instance

  final List<Map<String, dynamic>> _categoryCards = [
    {'nameKey': 'bpTab', 'icon': Icons.monitor_heart, 'vitalType': 'BP'},
    {'nameKey': 'creatinineTab', 'icon': Icons.science, 'vitalType': 'Creatinine'},
    {'nameKey': 'potassiumTab', 'icon': Icons.bloodtype, 'vitalType': 'Potassium'},
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthAndPatientDetails();
    _tabController = TabController(length: _categoryCards.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategoryIndex = _tabController.index;
      });
    });
  }

  Future<void> _checkAuthAndPatientDetails() async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;

    logger.d('VitalTrackingPage: _checkAuthAndPatientDetails called.');
    logger.d('VitalTrackingPage: currentUser: $currentUser');

    if (currentUser == null) {
      logger.i('VitalTrackingPage: User not logged in. Navigating to AuthScreen.');
      // User not logged in, navigate to AuthScreen
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AuthScreen()),
          );
        });
      }
      return;
    }

    // User is logged in, check for patient details
    final patientDetailsProvider = Provider.of<PatientDetailsProvider>(context, listen: false);
    logger.d('VitalTrackingPage: patientDetailsProvider.patientDetails: ${patientDetailsProvider.patientDetails}');

    if (patientDetailsProvider.patientDetails == null) {
      logger.i('VitalTrackingPage: Patient details not found. Navigating to PatientDetailsPage.');
      // Patient details not found, navigate to PatientDetailsPage
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PatientDetailsPage()),
          );
        });
      }
      return;
    }

    // User is logged in and patient details exist. Now, check for BP data sync on mobile.
    if (!kIsWeb) {
      logger.d('VitalTrackingPage: On mobile, checking for BP data sync.');
      try {
        final List<BloodPressure> supabaseBpReadings = await _supabaseService.getBloodPressureReadings();
        final List<BloodPressure> localBpReadings = await DatabaseHelper().getBloodPressureReadings(currentUser.id); // currentUser is guaranteed non-null here

        if (supabaseBpReadings.length > localBpReadings.length) {
          logger.i('VitalTrackingPage: Supabase has more BP readings than local SQLite. Syncing...');
          // For simplicity, clear local and re-insert from Supabase.
          // In a real app, you'd compare and insert only missing ones.
          await DatabaseHelper().clearBloodPressureReadings();
          for (var bp in supabaseBpReadings) {
            await DatabaseHelper().insertBloodPressure(bp);
          }
          logger.i('VitalTrackingPage: BP readings synced from Supabase to SQLite.');
        } else {
          logger.d('VitalTrackingPage: Local SQLite BP readings are up-to-date or newer. No sync needed.');
        }
      } catch (e) {
        logger.e('VitalTrackingPage: Error during BP data sync: $e');
      }
    }
    logger.i('VitalTrackingPage: User logged in and patient details exist. Proceeding to VitalTrackingPage content.');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.vitalTrackingPageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              logger.i('Attempting to generate PDF report...');
              try {
                final patientDetailsProvider = Provider.of<PatientDetailsProvider>(context, listen: false);
                final patientDetails = patientDetailsProvider.patientDetails;

                if (patientDetails == null) {
                  logger.w('Patient details not available for PDF generation.');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.pdfGenerationErrorNoPatientDetails)),
                  );
                  return;
                }

                // Fetch BP readings from SupabaseService for PDF generation
                final List<BloodPressure> bpReadings = await _supabaseService.getBloodPressureReadings();
                
                // The userId check is now implicitly handled by SupabaseService().getBloodPressureReadings()
                // which returns an empty list if no user is authenticated.
                // However, if patientDetails is null, it implies no user or no patient details,
                // so the earlier check for patientDetails should cover the user authentication.
                
                if (bpReadings.isEmpty) {
                  logger.w('No blood pressure readings available for PDF generation.');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.pdfGenerationErrorNoReadings)),
                  );
                  return;
                }

                final pdfBytes = await PdfGenerator.generateBpReport(patientDetails, bpReadings);
                await Printing.sharePdf(bytes: pdfBytes, filename: 'blood_pressure_report.pdf');
                logger.i('PDF report shared successfully.');
              } catch (e, stack) {
                logger.e('Error generating or sharing PDF: $e', error: e, stackTrace: stack);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(localizations.pdfGenerationError(e.toString()))),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Cards at the top, similar to FoodListPage
          SizedBox(
            height: 120, // Adjust height as needed for the category cards
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _categoryCards.length,
              itemBuilder: (context, index) {
                final category = _categoryCards[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                      _tabController.animateTo(index); // Switch tab on card tap
                    });
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: _selectedCategoryIndex == index
                            ? Theme.of(context).primaryColor // Highlight selected card
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                    child: Container(
                      width: 100, // Fixed width for each card
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'],
                            size: 40,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            LocalizationHelper.translateKey(context, category['nameKey']), // Use LocalizationHelper
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // TabBarView to display content for each tab
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categoryCards.map((category) {
                final String? userId = Supabase.instance.client.auth.currentUser?.id;
                if (userId == null) {
                  // Handle case where user is not logged in, perhaps show a message or redirect
                  return Center(child: Text(localizations.userNotLoggedIn)); // Assuming you have this localization key
                }
                return VitalTrackingTab(vitalType: category['vitalType'], userId: userId);
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final currentVitalType = _categoryCards[_selectedCategoryIndex]['vitalType'];
          if (currentVitalType == 'BP') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddBpPage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.notYetImplemented(LocalizationHelper.translateKey(context, 'add${currentVitalType}Button')))),
            );
          }
        },
        label: Text(LocalizationHelper.translateKey(context, 'add${_categoryCards[_selectedCategoryIndex]['vitalType']}Button')),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
