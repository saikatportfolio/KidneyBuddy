import 'package:flutter/material.dart';
import 'package:myapp/screens/onboarding_screen.dart'; // Import OnboardingScreen
import 'package:myapp/screens/home_page.dart';
import 'package:myapp/screens/auth_screen.dart'; // Import AuthScreen
// Import PatientDetailsPage
import 'package:firebase_core/firebase_core.dart'; // Keep Firebase Core for Crashlytics/Analytics
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // Import Crashlytics
import 'package:provider/provider.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart'; // Import Mixpanel
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/models/feedback_model.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Re-add for conditional logic
import 'dart:async'; // Import for runZonedGuarded
import 'dart:ui'; // Import for PlatformDispatcher
import 'package:myapp/l10n/app_localizations.dart'; // Import generated localizations
import 'package:myapp/services/database_helper.dart'; // Import DatabaseHelper
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'firebase_options.dart'; // Import generated Firebase options
import 'package:myapp/utils/logger_config.dart'; // Import the logger

late Mixpanel mixpanel; // Declare the Mixpanel instance

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  logger.d('main: WidgetsFlutterBinding initialized');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  logger.d('main: Firebase initialized');

  // Initialize Mixpanel
  mixpanel = await Mixpanel.init(
    "b2452b2a059dab674a0de04ea4ab3e94", // Replace with your actual Mixpanel Project Token
    trackAutomaticEvents: true, // Set to true to track common events automatically
  );
  logger.d('main: Mixpanel initialized');

  // Initialize Supabase here, before any service tries to use it
  await SupabaseService.initialize();
  logger.d('main: Supabase initialized');

  // Initialize Crashlytics
  if (!kIsWeb) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }
  // Explicitly enable Crashlytics collection
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Load patient details conditionally on app startup
  PatientDetails? patientDetails;
  if (kIsWeb) {
    patientDetails = await SupabaseService().getPatientDetails();
    logger.d(
      'main: Loaded patient details from Supabase (Web): $patientDetails',
    );
  } else {
    patientDetails = await DatabaseHelper().getPatientDetails();
    logger.d(
      'main: Loaded patient details from SQLite (Mobile): $patientDetails',
    );
  }

  runZonedGuarded(
    () {
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => PatientDetailsProvider(patientDetails),
            ), // Initialize with loaded data
            ChangeNotifierProvider(create: (_) => FeedbackProvider()),
          ],
          child: MyApp(),
        ),
      );
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    if (state != null) {
      state.setLocale(newLocale);
    }
  }
}

class MyAppState extends State<MyApp> {
  bool _hasSeenOnboarding = false;
  bool _isLoading = true;
  Locale? _locale;
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    logger.d('MyAppState: initState called');
    _initializeAppData(); // Call a new method for async initializations
    _setupAuthStateListener(); // Setup auth state listener
  }

  Future<void> _initializeAppData() async {
    logger.d('MyAppState: _initializeAppData started');
    try {
      // Load preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _hasSeenOnboarding =
          (prefs.getBool('hasSeenOnboarding') ??
          false); // Always show onboarding
      String? langCode = prefs.getString('languageCode');
      _locale = langCode != null ? Locale(langCode) : null;
    } catch (e) {
      logger.e('MyAppState: Error during initialization: $e');
      // Handle error, e.g., show an error screen or retry
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        logger.d(
          'MyAppState: _initializeAppData completed. hasSeenOnboarding: $_hasSeenOnboarding, locale: $_locale',
        );
      }
    }
  }

  void _setupAuthStateListener() {
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) async {
      logger.d('MyAppState: Auth state changed: ${data.event}');
      if (mounted) {
        final patientDetailsProvider = Provider.of<PatientDetailsProvider>(
          context,
          listen: false,
        );
        if (data.event == AuthChangeEvent.signedIn ||
            data.event == AuthChangeEvent.initialSession) {
          logger.d(
            'MyAppState: User signed in or initial session. Attempting to load patient details.',
          );
          final currentUser = Supabase.instance.client.auth.currentUser;
          if (currentUser == null) {
            return;
          }
          if (mounted) {
            final name = currentUser.userMetadata?['full_name'] as String?;
            final email = currentUser.email;
            final photoUrl = currentUser.userMetadata?['picture'] as String?; // Common key for Google profile picture
            logger.d('MyAppState: Retrieved Google Name1: $name');
            logger.d('MyAppState: Retrieved Google Email1: $email');
            logger.d('MyAppState: Retrieved Google Photo URL1: $photoUrl');
            logger.d('MyAppState: Full userMetadata: ${currentUser.userMetadata}'); // Log full metadata for debugging
            SharedPreferences prefs = await SharedPreferences.getInstance();
            if (name != null) {
              await prefs.setString('google_user_name', name);
            }
            if (email != null) {
              await prefs.setString('google_user_email', email);
            }
            if (photoUrl != null) {
              await prefs.setString('google_user_photo_url', photoUrl);
            }
          }
          PatientDetails? fetchedDetails;
          if (kIsWeb) {
            fetchedDetails = await SupabaseService().getPatientDetails();
            logger.d(
              'MyAppState: Fetched patient details from Supabase (Web): $fetchedDetails',
            );
          } else {
            fetchedDetails = await DatabaseHelper().getPatientDetails();
            logger.d(
              'MyAppState: Fetched patient details from SQLite (Mobile): $fetchedDetails',
            );
          }
          patientDetailsProvider.setPatientDetails(fetchedDetails);
          logger.d(
            'MyAppState: PatientDetailsProvider updated with: ${patientDetailsProvider.patientDetails != null ? 'Available' : 'Missing'}',
          );
        } else if (data.event == AuthChangeEvent.signedOut) {
          logger.d('MyAppState: User signed out. Clearing patient details.');
          patientDetailsProvider.setPatientDetails(null);
        }
        setState(() {
          // Trigger rebuild to re-evaluate home screen based on new auth state and patient details
        });
      }
    });
  }

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.d('MyAppState: build called. _isLoading: $_isLoading');

    if (_isLoading) {
      logger.d('MyAppState: Building loading screen');
      return MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    // Determine the actual home screen based on auth and onboarding
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    final patientDetailsProvider = Provider.of<PatientDetailsProvider>(context);

    logger.d(
      'MyAppState: currentUser: ${currentUser?.id != null ? 'Logged In' : 'Logged Out'}',
    );
    logger.d(
      'MyAppState: patientDetailsProvider.patientDetails: ${patientDetailsProvider.patientDetails != null ? 'Available' : 'Missing'}',
    );
    logger.d('MyAppState: _hasSeenOnboarding: $_hasSeenOnboarding');

    Widget homeScreen;
    if (!_hasSeenOnboarding) {
      homeScreen = const OnboardingScreen();
      logger.d('MyAppState: Initial route: OnboardingScreen');
    } else if (currentUser == null) {
      homeScreen = const AuthScreen();
      logger.d('MyAppState: Initial route: AuthScreen (User not logged in)');
    } else {
      homeScreen = const HomePage();
      logger.d('MyAppState: Initial route: HomePage (User logged in)');
    }

    return MaterialApp(
      title: 'PreventO', // This will be replaced by localized string later
      theme: ThemeData(
        primarySwatch: _createMaterialColor(const Color(0xFF59B8F0)),
        primaryColor: const Color(0xFF59B8F0), // Explicitly set primaryColor
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: _createMaterialColor(const Color(0xFF59B8F0)),
        ).copyWith(
          primary: const Color(0xFF59B8F0), // Explicitly set colorScheme.primary
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: false, // Temporarily set to false for debugging ANR
      ),
      locale: _locale, // Apply the selected locale
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: homeScreen, // Directly set the home screen
      navigatorObservers: [
        MixpanelNavigatorObserver(), // Add Mixpanel Navigator Observer
      ],
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
} // End of MyAppState class

// Custom NavigatorObserver for Mixpanel screen tracking
class MixpanelNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      mixpanel.track("Screen Viewed", properties: {"Screen Name": route.settings.name});
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name != null) {
      mixpanel.track("Screen Viewed", properties: {"Screen Name": newRoute?.settings.name});
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (route.settings.name != null) {
      mixpanel.track("Screen Left", properties: {"Screen Name": route.settings.name});
    }
  }
}
