import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/utils/localization_helper.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/screens/home_page.dart' as home_page;
import 'package:myapp/screens/patient_details_page.dart';
import 'package:myapp/utils/logger_config.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    logger.d('AuthScreen: Google Sign-In button pressed.');
    try {
      await SupabaseService().signInWithGoogle();
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && mounted) {
        final patientDetails = await SupabaseService().getPatientDetails();
        if (mounted) {
          if (patientDetails == null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PatientDetailsPage(), // No longer passing name/email directly
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const home_page.HomePage()),
            );
          }
          _showSnackBar(LocalizationHelper.translateKey(context, 'loginSuccessMessage'));
        }
      } else if (mounted) {
       // _showSnackBar(LocalizationHelper.translateKey(context, 'authErrorMessage').replaceFirst('{error}', 'Sign-in failed.'));
      }
    } on AuthException catch (e) {
      logger.e('Google Auth Error: ${e.message}');
      _showSnackBar(LocalizationHelper.translateKey(context, 'authErrorMessage').replaceFirst('{error}', e.message));
    } catch (e) {
      logger.e('Google General Error: $e');
      _showSnackBar(LocalizationHelper.translateKey(context, 'authErrorMessage').replaceFirst('{error}', e.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image Section
          Positioned.fill(
            child: Image.asset(
              'assets/images/auth_image.png', // Using onboarding1.png as placeholder
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey, child: const Center(child: Icon(Icons.error, size: 100, color: Colors.white)));
              },
            ),
          ),
          // Content Section (Bottom Half with rounded corners)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5, // Adjust height as needed
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, // Align content to start
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      localizations.authScreenNewTitle,
                      style: const TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      localizations.authScreenNewDescription,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40), // Increased spacing
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _signInWithGoogle,
                          icon: Image.asset(
                            'assets/images/google_logo.png',
                            height: 24.0,
                          ),
                          label: Text(
                            localizations.signInWithGoogleButton,
                            style: const TextStyle(fontSize: 18),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87, // Text color
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Theme.of(context).colorScheme.primary), // Primary color border
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
