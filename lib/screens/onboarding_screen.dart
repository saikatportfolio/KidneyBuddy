import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:myapp/screens/auth_screen.dart';
// Import HomePage
import 'package:myapp/l10n/app_localizations.dart'; // Import generated localizations
import 'package:myapp/screens/language_selection_screen.dart'; // Import LanguageSelectionScreen
import 'package:myapp/utils/logger_config.dart'; // Import the logger

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "titleKey": "welcomeTitle",
      "descriptionKey": "welcomeDescription",
      "image": "assets/images/onboarding1.png", // Placeholder
    },
    {
      "titleKey": "renalDietTitle",
      "descriptionKey": "renalDietDescription",
      "image": "assets/images/onboarding2.png", // Placeholder
    },
    {
      "titleKey": "connectDieticiansTitle",
      "descriptionKey": "connectDieticiansDescription",
      "image": "assets/images/onboarding3.png", // Placeholder
    },
  ];

  _onIntroEnd(context) async {
    logger.d('OnboardingScreen: _onIntroEnd started');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthScreen()), // Navigate to AuthScreen
    );
    logger.i('OnboardingScreen: Navigated to HomePage');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.d('OnboardingScreen: build called. Current page: $_currentPage');
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                logger.d('OnboardingScreen: Page changed to $index');
              },
              itemBuilder: (context, index) {
                final item = onboardingData[index];
                logger.d('OnboardingScreen: Building page $index');
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (index == 0) // Add language selection only on the first page
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const LanguageSelectionScreen(fromOnboarding: true),
                                ),
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context)!.selectLanguageTitle,
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                      Image.asset(
                        item["image"]!,
                        height: 200,
                      ),
                      SizedBox(height: 30),
                      Text(
                        _getLocalizedText(context, item["titleKey"]!),
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Text(
                        _getLocalizedText(context, item["descriptionKey"]!),
                        style: TextStyle(fontSize: 16.0),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: onboardingData.length,
              effect: WormEffect(
                dotHeight: 8.0,
                dotWidth: 8.0,
                activeDotColor: Colors.blue, // Changed for debugging ANR
                dotColor: Colors.grey,
              ),
              onDotClicked: (index) {
                _pageController.animateToPage(
                  index,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              },
            ),
          ),
          SizedBox(height: 20),
          _currentPage == onboardingData.length - 1
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _onIntroEnd(context),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(Color(0xFF00B4D8)),
                        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                      ),
                      child: Text(AppLocalizations.of(context)!.getStartedButton),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(Color(0xFF00B4D8)),
                        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                      ),
                      child: Text(AppLocalizations.of(context)!.nextButton),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  String _getLocalizedText(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context)!;
    switch (key) {
      case "welcomeTitle": return localizations.welcomeTitle;
      case "welcomeDescription": return localizations.welcomeDescription;
      case "renalDietTitle": return localizations.renalDietTitle;
      case "renalDietDescription": return localizations.renalDietDescription;
      case "connectDieticiansTitle": return localizations.connectDieticiansTitle;
      case "connectDieticiansDescription": return localizations.connectDieticiansDescription;
      default: return ''; // Fallback
    }
  }
}
