import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/utils/localization_helper.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/screens/home_page.dart';
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
              MaterialPageRoute(builder: (context) => const HomePage()),
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
      appBar: AppBar(
        title: Text(localizations.loginTitle),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Placeholder for the promotional image
              Image.asset(
                'assets/images/auth_image.png', // Replace with your actual image asset
                height: 250,
                errorBuilder: (context, error, stackTrace) {
                  // This shows a placeholder if the image is not found
                  return const Icon(Icons.lock_person, size: 150, color: Colors.green);
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'CKDBuddy',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(height: 40),
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
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
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
