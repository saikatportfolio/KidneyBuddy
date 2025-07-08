import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/l10n/app_localizations.dart'; // Ensure this import is correct
import 'package:myapp/main.dart'; // Import MyApp to trigger rebuild

class LanguageSelectionScreen extends StatefulWidget {
  final bool fromOnboarding;

  const LanguageSelectionScreen({super.key, this.fromOnboarding = false});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  Locale? _selectedLocale;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString('languageCode');
    if (langCode != null && AppLocalizations.supportedLocales.any((element) => element.languageCode == langCode)) {
      setState(() {
        _selectedLocale = Locale(langCode);
      });
    }
  }

  _setLanguage(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    setState(() {
      _selectedLocale = locale;
    });

    // Rebuild the entire app to apply the new locale
    if (mounted) {
      MyApp.setLocale(context, locale);
    }

    if (widget.fromOnboarding) {
      // If coming from onboarding, navigate back to the onboarding screen
      // or to the next screen in the onboarding flow (e.g., PatientDetailsPage)
      // For now, let's just pop if it's a simple flow, or navigate to the next step.
      // Assuming we want to go back to the onboarding screen to continue.
      Navigator.of(context).pop();
    } else {
      // If coming from settings, just pop the screen
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.selectLanguageTitle),
        leading: widget.fromOnboarding
            ? null // No back button if from onboarding
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              localizations.chooseYourLanguage,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _buildLanguageButton(localizations.english, const Locale('en')),
            _buildLanguageButton(localizations.hindi, const Locale('hi')),
            _buildLanguageButton(localizations.bengali, const Locale('bn')),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(String languageName, Locale locale) {
    final isSelected = _selectedLocale == locale;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40.0),
      child: ElevatedButton(
        onPressed: () => _setLanguage(locale),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
          foregroundColor: isSelected ? Colors.white : Colors.black,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          languageName,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
