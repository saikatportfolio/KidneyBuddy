import 'package:flutter/material.dart';
import 'package:myapp/screens/onboarding_screen.dart';
import 'package:myapp/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/onboarding_screen.dart';
import 'package:myapp/screens/home_page.dart';
import 'package:firebase_core/firebase_core.dart'; // Keep Firebase Core for Crashlytics/Analytics
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // Import Crashlytics
import 'package:provider/provider.dart';
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/models/feedback_model.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Re-add for conditional logic
import 'dart:async'; // Import for runZonedGuarded
import 'dart:ui'; // Import for PlatformDispatcher
import 'package:myapp/l10n/app_localizations.dart'; // Import generated localizations
import 'package:myapp/services/database_helper.dart'; // Import DatabaseHelper

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('main: WidgetsFlutterBinding initialized');
  await Firebase.initializeApp(); // Keep Firebase Core for Crashlytics
  print('main: Firebase initialized');

  // Initialize Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Load patient details from local database on app startup
  final patientDetails = await DatabaseHelper().getPatientDetails();
  print('main: Loaded patient details from DB: $patientDetails');

  runZonedGuarded(() {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PatientDetailsProvider(patientDetails)), // Initialize with loaded data
          ChangeNotifierProvider(create: (_) => FeedbackProvider()),
        ],
        child: MyApp(),
      ),
    );
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    state?.setLocale(newLocale);
  }
}

class MyAppState extends State<MyApp> {
  bool _hasSeenOnboarding = false;
  bool _isLoading = true;
  Locale? _locale;
  // PatientDetails? _patientDetails; // Removed as it's now passed via provider

  @override
  void initState() {
    super.initState();
    print('MyAppState: initState called');
    _initializeAppData(); // Call a new method for async initializations
  }

  Future<void> _initializeAppData() async {
    print('MyAppState: _initializeAppData started');
    try {
      // Initialize Supabase
      await SupabaseService.initialize();
      print('MyAppState: Supabase initialized');

      // Load preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _hasSeenOnboarding = (prefs.getBool('hasSeenOnboarding') ?? false);
      String? langCode = prefs.getString('languageCode');
      _locale = langCode != null ? Locale(langCode) : null;
    } catch (e) {
      print('MyAppState: Error during initialization: $e');
      // Handle error, e.g., show an error screen or retry
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('MyAppState: _initializeAppData completed. hasSeenOnboarding: $_hasSeenOnboarding, locale: $_locale');
      }
    }
  }

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('MyAppState: build called. _isLoading: $_isLoading');
    if (_isLoading) {
      print('MyAppState: Building loading screen');
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    print('MyAppState: Building main app. Navigating to: ${_hasSeenOnboarding ? 'HomePage' : 'OnboardingScreen'}');
    return MaterialApp(
      title: 'CKD Care App', // This will be replaced by localized string later
      theme: ThemeData(
        primarySwatch: _createMaterialColor(const Color(0xFF16C2D5)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: false, // Temporarily set to false for debugging ANR
      ),
      locale: _locale, // Apply the selected locale
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _hasSeenOnboarding ? HomePage() : OnboardingScreen(),
      // Temporarily removed FirebaseAnalyticsObserver for debugging ANR
      // navigatorObservers: [
      //   FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      // ],
    );
}

MaterialColor _createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
}
