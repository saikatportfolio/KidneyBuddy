import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/screens/vital_tracking_tab.dart';
import 'package:myapp/utils/localization_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/screens/patient_details_page.dart'; // Corrected import
import 'package:myapp/utils/logger_config.dart';
import 'package:myapp/models/blood_pressure.dart';
import 'package:myapp/models/creatine.dart';
import 'package:myapp/services/database_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:myapp/services/supabase_service.dart';

class VitalTrackingPage extends StatefulWidget {
  const VitalTrackingPage({super.key});

  @override
  State<VitalTrackingPage> createState() => _VitalTrackingPageState();
}

class _VitalTrackingPageState extends State<VitalTrackingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCategoryIndex = 0;
  final SupabaseService _supabaseService = SupabaseService();

  final List<Map<String, dynamic>> _categoryCards = [
    {'nameKey': 'bpTab', 'icon': Icons.monitor_heart, 'vitalType': 'BP'},
    {'nameKey': 'creatinineTab', 'icon': Icons.science, 'vitalType': 'Creatinine'},
    {'nameKey': 'weightTab', 'icon': Icons.monitor_weight, 'vitalType': 'Weight'},
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
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PatientDetailsPage(source: "vital_tracking",)),
          );
        });
      }
      return;
    }

    final patientDetailsProvider = Provider.of<PatientDetailsProvider>(context, listen: false);
    logger.d('VitalTrackingPage: patientDetailsProvider.patientDetails: ${patientDetailsProvider.patientDetails}');

    if (patientDetailsProvider.patientDetails == null) {
      logger.i('VitalTrackingPage: Patient details not found. Navigating to PatientDetailsPage.');
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PatientDetailsPage(source: "vital_tracking")),
          );
        });
      }
      return;
    }

    if (!kIsWeb) {
      logger.d('VitalTrackingPage: On mobile, checking for BP data sync.');
      try {
        final List<BloodPressure> supabaseBpReadings = await _supabaseService.getBloodPressureReadings();
        final List<BloodPressure> localBpReadings = await DatabaseHelper().getBloodPressureReadings(currentUser.id);

        if (supabaseBpReadings.length > localBpReadings.length) {
          logger.i('VitalTrackingPage: Supabase has more BP readings than local SQLite. Syncing...');
          await DatabaseHelper().clearBloodPressureReadings();
          for (var bp in supabaseBpReadings) {
            await DatabaseHelper().insertBloodPressure(bp);
          }
          logger.i('VitalTrackingPage: BP readings synced from Supabase to SQLite.');
        } else {
          logger.d('VitalTrackingPage: Local SQLite BP readings are up-to-date or newer. No sync needed.');
        }

        final List<Creatine> supabaseCreatineReadings = await _supabaseService.getCreatineReadings();
        final List<Creatine> localCreatineReadings = await DatabaseHelper().getCreatineReadings(currentUser.id);

        if (supabaseCreatineReadings.length > localCreatineReadings.length) {
          logger.i('VitalTrackingPage: Supabase has more Creatine readings than local SQLite. Syncing...');
          // await DatabaseHelper().clearCreatineReadings(); //TODO: implement this
          for (var cr in supabaseCreatineReadings) {
            await DatabaseHelper().insertCreatine(cr);
          }
          logger.i('VitalTrackingPage: Creatine readings synced from Supabase to SQLite.');
        } else {
          logger.d('VitalTrackingPage: Local SQLite Creatine readings are up-to-date or newer. No sync needed.');
        }
      } catch (e) {
        logger.e('VitalTrackingPage: Error during data sync: $e');
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
      body: SafeArea(
        child: Consumer<PatientDetailsProvider>(
          builder: (context, patientDetailsProvider, child) {
            final patientDetails = patientDetailsProvider.patientDetails;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context, true); // Pop with a result to indicate a potential change
                        },
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            localizations.vitalTrackingPageTitle,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                  fontSize: 24.0,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
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
                            _tabController.animateTo(index);
                          });
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: _selectedCategoryIndex == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                          child: Container(
                            width: 100,
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
                                  LocalizationHelper.translateKey(context, category['nameKey']),
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
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _categoryCards.map((category) {
                      final String? userId = Supabase.instance.client.auth.currentUser?.id;
                      if (userId == null) {
                        return Center(child: Text(localizations.userNotLoggedIn));
                      }
                      return VitalTrackingTab(
                        vitalType: category['vitalType'],
                        userId: userId,
                        patientDetails: patientDetails,
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
