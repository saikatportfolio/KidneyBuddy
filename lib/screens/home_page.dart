import 'package:flutter/material.dart';
import 'package:myapp/screens/feedback_page.dart';
import 'package:myapp/screens/dietician_list_page.dart';
import 'package:myapp/l10n/app_localizations.dart'; // Import generated localizations
import 'package:myapp/screens/settings_page.dart'; // Import SettingsPage

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
          children: [
            _buildFeatureCard(context, localizations.dietManagementCard, Icons.food_bank),
            _buildFeatureCard(context, localizations.bloodPressureMonitoringCard, Icons.monitor_heart),
            _buildFeatureCard(context, localizations.eGFRCalculatorCard, Icons.calculate),
            _buildFeatureCard(context, localizations.contactDieticianCard, Icons.person_pin),
            _buildFeatureCard(context, localizations.giveYourFeedbackCard, Icons.feedback),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: () {
          if (title == localizations.giveYourFeedbackCard) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FeedbackPage()),
            );
          } else if (title == localizations.contactDieticianCard) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DieticianListPage()),
            );
          }
          else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.notYetImplemented(title))),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50.0, color: Theme.of(context).primaryColor),
            SizedBox(height: 10.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
