import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/screens/language_selection_screen.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/screens/auth_screen.dart';
import 'package:myapp/utils/logger_config.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await SupabaseService().signOut();
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
      appBar: AppBar(
        title: Text(localizations.settingsTitle),
      ),
      body: _isLoading
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
                  onTap: _signOut,
                ),
              ],
            ),
    );
  }
}
