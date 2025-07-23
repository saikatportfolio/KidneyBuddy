import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/screens/language_selection_screen.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/screens/auth_screen.dart';
import 'package:myapp/utils/logger_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;

  Future<void> _showSignOutConfirmationDialog() async {
    final localizations = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.signOutButton),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(localizations.signOutConfirmation),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.noButton),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(localizations.yesButton),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _signOut(); // Proceed with sign out
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await SupabaseService().signOut();

      // Clear SharedPreferences data related to Google Sign-in
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('google_user_name');
      await prefs.remove('google_user_email');
      logger.d('SettingsPage: Cleared Google user data from SharedPreferences on sign out.');

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      logger.e('Error signing out: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Text(
                      localizations.settingsTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // To balance the back button
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: [
                        ListTile(
                          title: Text(localizations.languageSetting),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LanguageSelectionScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          title: Text(localizations.signOutButton),
                          leading: const Icon(Icons.logout),
                          onTap: _showSignOutConfirmationDialog,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
