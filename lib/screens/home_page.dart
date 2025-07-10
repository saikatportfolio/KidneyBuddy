import 'package:flutter/material.dart';
import 'package:myapp/screens/feedback_page.dart';
import 'package:myapp/screens/dietician_list_page.dart';
import 'package:myapp/l10n/app_localizations.dart'; // Import generated localizations
import 'package:myapp/screens/settings_page.dart'; // Import SettingsPage
import 'package:myapp/screens/food_list_page.dart'; // Import the new food list page

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    print('HomePage: build called'); // Keep the print statement
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.homePageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.7, // Adjust this value as needed
          children: [
            _buildFeatureCard(
              context,
              localizations.dietManagementCard,
              localizations.dietManagementDescription, // Assuming this will be added to localizations
              Icons.food_bank,
              null, // No specific page for this yet
            ),
            _buildFeatureCard(
              context,
              localizations.bloodPressureMonitoringCard,
              localizations.bloodPressureMonitoringDescription, // Assuming this will be added
              Icons.monitor_heart,
              null,
            ),
            _buildFeatureCard(
              context,
              localizations.eGFRCalculatorCard,
              localizations.eGFRCalculatorDescription, // Assuming this will be added
              Icons.calculate,
              null,
            ),
            _buildFeatureCard(
              context,
              localizations.contactDieticianCard,
              localizations.contactDieticianDescription, // Assuming this will be added
              Icons.person_pin,
              const DieticianListPage(),
            ),
            _buildFeatureCard(
              context,
              localizations.giveYourFeedbackCard,
              localizations.giveYourFeedbackDescription, // Assuming this will be added
              Icons.feedback,
              const FeedbackPage(),
            ),
            _buildFeatureCard(
              context,
              'Food Recommendations', // Hardcoded for now, can be localized
              'Get personalized food recommendations based on your CKD stage.',
              Icons.restaurant_menu,
              const FoodListPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String description, IconData icon, Widget? destinationPage) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: () {
          if (destinationPage != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destinationPage),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.notYetImplemented(title))),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50.0, color: Theme.of(context).primaryColor),
            const SizedBox(height: 10.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Expanded( // Wrap description in Expanded
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  maxLines: 3, // Limit to 3 lines
                  overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                  style: TextStyle(fontSize: 10.0, color: Colors.grey[600]), // Reduced font size
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
