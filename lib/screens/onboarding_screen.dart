import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:myapp/screens/auth_screen.dart';
// Import HomePage
import 'package:myapp/l10n/app_localizations.dart'; // Import generated localizations
// Import LanguageSelectionScreen
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
      "titleKey": "vitalTrackingOnboardingTitle",
      "descriptionKey": "vitalTrackingOnboardingDescription",
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
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE0F7FA), // Light blue
                  Colors.white,
                ],
              ),
            ),
          ),
          PageView.builder(
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
              return SingleChildScrollView( // Wrap with SingleChildScrollView
                child: Column(
                  children: [
                    // Image Section (Top Half)
                    SizedBox( // Use SizedBox instead of Expanded with fixed height
                      height: MediaQuery.of(context).size.height * 0.6, // Adjust height as needed
                      child: Container(
                        alignment: Alignment.center,
                        child: Image.asset(
                          item["image"]!,
                          fit: BoxFit.cover, // Cover the available space
                          width: double.infinity,
                        ),
                      ),
                    ),
                    // Content Section (Bottom Half with rounded corners)
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40.0),
                          topRight: Radius.circular(40.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getLocalizedText(context, item["titleKey"]!),
                              style: const TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 15),
                            Text(
                              _getLocalizedText(context, item["descriptionKey"]!),
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            SmoothPageIndicator(
                              controller: _pageController,
                              count: onboardingData.length,
                              effect: WormEffect(
                                dotHeight: 10.0,
                                dotWidth: 10.0,
                                activeDotColor: Theme.of(context).colorScheme.primary,
                                dotColor: Colors.grey.shade300,
                              ),
                              onDotClicked: (index) {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              },
                            ),
                            const SizedBox(height: 30),
                            _currentPage == onboardingData.length - 1
                                ? SizedBox(
width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => _onIntroEnd(context),
style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF16C2D5),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      child: Text(AppLocalizations.of(context)!.getStartedButton, style: const TextStyle(fontSize: 18)),
                                    ),
                                  )
                                : SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _pageController.nextPage(
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.ease,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF16C2D5),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      child: Text(AppLocalizations.of(context)!.nextButton, style: const TextStyle(fontSize: 18)),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
      case "vitalTrackingOnboardingTitle": return localizations.vitalTrackingOnboardingTitle;
      case "vitalTrackingOnboardingDescription": return localizations.vitalTrackingOnboardingDescription;
      case "connectDieticiansTitle": return localizations.connectDieticiansTitle;
      case "connectDieticiansDescription": return localizations.connectDieticiansDescription;
      default: return ''; // Fallback
    }
  }
}
