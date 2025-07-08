import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:myapp/screens/patient_details_page.dart';

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
      "title": "Welcome to KidneyBuddy",
      "description": "This app is designed to simplify life for CKD patients by helping them manage their condition and prevent further Progression",
      "image": "assets/images/onboarding1.png", // Placeholder
    },
    {
      "title": "Renal Diet Management",
      "description": "Maintain a proper renal diet with personalized guidance and easy-to-follow meal plans tailored to your CKD stage.",
      "image": "assets/images/onboarding2.png", // Placeholder
    },
    {
      "title": "Connect with Dieticians",
      "description": "Easily connect with the best dieticians for personalized consultations and expert advice to support your kidney health journey.",
      "image": "assets/images/onboarding3.png", // Placeholder
    },
  ];

  _onIntroEnd(context) async {
    print('OnboardingScreen: _onIntroEnd started');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PatientDetailsPage()),
    );
    print('OnboardingScreen: Navigated to PatientDetailsPage');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('OnboardingScreen: build called. Current page: $_currentPage');
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
                print('OnboardingScreen: Page changed to $index');
              },
              itemBuilder: (context, index) {
                final item = onboardingData[index];
                print('OnboardingScreen: Building page $index');
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        item["image"]!,
                        height: 200,
                      ),
                      SizedBox(height: 30),
                      Text(
                        item["title"]!,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Text(
                        item["description"]!,
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
                      child: Text("Get Started"),
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
                      child: Text("Next"),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
