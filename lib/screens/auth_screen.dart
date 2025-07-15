import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/utils/localization_helper.dart';
import 'package:myapp/services/supabase_service.dart'; // Assuming you have this service
import 'package:myapp/screens/patient_details_page.dart'; // Import PatientDetailsPage
import 'package:myapp/utils/logger_config.dart'; // Import the logger

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoginMode = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseService = SupabaseService();
      if (_isLoginMode) {
        await supabaseService.signInWithPassword(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        await supabaseService.signUp(
          _emailController.text,
          _passwordController.text,
        );
      }
      // On successful auth, navigate to PatientDetailsPage
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        logger.d('AuthScreen: mounted is true, scheduling navigation to PatientDetailsPage');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          logger.d('AuthScreen: Executing navigation to PatientDetailsPage');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PatientDetailsPage()),
          );
          _showSnackBar(LocalizationHelper.translateKey(context, _isLoginMode ? 'loginSuccessMessage' : 'signupSuccessMessage'));
        });
      } else {
        logger.w('AuthScreen: mounted is false, cannot navigate after auth.');
      }
    } on AuthException catch (e) {
      logger.e('Auth Error: ${e.message}'); // Print full error message
      _showSnackBar(LocalizationHelper.translateKey(context, 'authErrorMessage').replaceFirst('{error}', e.message));
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      logger.e('General Error: $e'); // Print full error object
      _showSnackBar(LocalizationHelper.translateKey(context, 'authErrorMessage').replaceFirst('{error}', e.toString()));
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationHelper.translateKey(context, _isLoginMode ? 'loginTitle' : 'signupTitle')),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: LocalizationHelper.translateKey(context, 'emailLabel'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: LocalizationHelper.translateKey(context, 'passwordLabel'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                if (!_isLoginMode) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: LocalizationHelper.translateKey(context, 'confirmPasswordLabel'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleAuth,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            LocalizationHelper.translateKey(context, _isLoginMode ? 'signInButton' : 'signUpButton'),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLoginMode = !_isLoginMode;
                      _formKey.currentState?.reset(); // Clear form fields on mode switch
                      _emailController.clear(); // Clear email field too
                      _passwordController.clear();
                      _confirmPasswordController.clear();
                    });
                  },
                  child: Text(
                    LocalizationHelper.translateKey(context, _isLoginMode ? 'noAccountPrompt' : 'haveAccountPrompt'),
                  ),
                ),
                const SizedBox(height: 24), // Space before Google button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () async {
                      setState(() {
                        _isLoading = true;
                      });
                      logger.d('AuthScreen: Google Sign-In button pressed. _isLoading set to true.');
                      try {
                        await SupabaseService().signInWithGoogle();
                        logger.d('AuthScreen: SupabaseService().signInWithGoogle() completed.');
                        // Navigation handled by main.dart listener or by the deep link
                        // For mobile, it will navigate to PatientDetailsPage as per previous logic
                        // For web, it will redirect and main.dart will handle.
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                          logger.d('AuthScreen: Google Sign-In successful. _isLoading set to false. Navigation will be handled by main.dart listener.');
                          _showSnackBar(LocalizationHelper.translateKey(context, 'loginSuccessMessage'));
                        } else {
                          logger.w('AuthScreen: mounted is false after Google Sign-In, cannot update UI.');
                        }
                      } on AuthException catch (e) {
                        logger.e('Google Auth Error: ${e.message}');
                        _showSnackBar(LocalizationHelper.translateKey(context, 'authErrorMessage').replaceFirst('{error}', e.message));
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      } catch (e) {
                        logger.e('Google General Error: $e');
                        _showSnackBar(LocalizationHelper.translateKey(context, 'authErrorMessage').replaceFirst('{error}', e.toString()));
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    icon: Image.asset(
                      'assets/images/google_logo.png', // You'll need to add a Google logo asset
                      height: 24.0,
                    ),
                    label: Text(
                      LocalizationHelper.translateKey(context, 'signInWithGoogleButton'),
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
      ),
    );
  }
}
