import 'package:flutter/material.dart';
import 'package:myapp/screens/onboarding_screen.dart';
import 'package:myapp/screens/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // Import Crashlytics
import 'package:provider/provider.dart';
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/models/feedback_model.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Re-add for conditional logic
import 'dart:async'; // Import for runZonedGuarded
import 'dart:ui'; // Import for PlatformDispatcher
import 'package:myapp/l10n/app_localizations.dart'; // Import generated localizations

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('main: WidgetsFlutterBinding initialized');
  await Firebase.initializeApp();
  print('main: Firebase initialized');

  // Initialize Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await SupabaseService.initialize(); // Initialize Supabase
  print('main: Supabase initialized');

  runZonedGuarded(() {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PatientDetailsProvider()),
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

  @override
  void initState() {
    super.initState();
    print('MyAppState: initState called');
    _loadPreferencesAndSetLocale();
  }

  _loadPreferencesAndSetLocale() async {
    print('MyAppState: _loadPreferencesAndSetLocale started');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSeenOnboarding = (prefs.getBool('hasSeenOnboarding') ?? false);
      String? langCode = prefs.getString('languageCode');
      _locale = langCode != null ? Locale(langCode) : null;
          _isLoading = false;
    });
    print('MyAppState: _loadPreferencesAndSetLocale completed. hasSeenOnboarding: $_hasSeenOnboarding, locale: $_locale');
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
        primarySwatch: Colors.blue,
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
}
