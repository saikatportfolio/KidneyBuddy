import 'package:flutter/material.dart';
import 'package:myapp/models/dietician.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/screens/dietician_details_page.dart';
import 'package:myapp/utils/logger_config.dart'; // Import the logger

class DieticianListPage extends StatefulWidget {
  const DieticianListPage({super.key});

  @override
  State<DieticianListPage> createState() => _DieticianListPageState();
}

class _DieticianListPageState extends State<DieticianListPage> {
  late Future<List<Dietician>> _dieticiansFuture;

  @override
  void initState() {
    super.initState();
    _dieticiansFuture = SupabaseService().getDieticians();
  }

  Future<void> _launchWhatsApp(String whatsappNumber) async {
    final Uri whatsappUri = Uri.parse('whatsapp://send?phone=$whatsappNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp. Make sure it is installed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contact Dietician',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: FutureBuilder<List<Dietician>>(
        future: _dieticiansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.black),
            ));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text(
              'No dieticians found.',
              style: TextStyle(color: Colors.black),
            ));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final dietician = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  child: InkWell(
                    // Make the whole card tappable
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DieticianDetailsPage(dietician: dietician),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(dietician.imageUrl),
                                onBackgroundImageError: (exception, stackTrace) {
                                  // Fallback to a default icon if image fails to load
                                  logger.e('Error loading image: $exception');
                                },
                                child: dietician.imageUrl.isEmpty ? const Icon(Icons.person, size: 50) : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dietician.name,
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        text: 'Experience: ',
                                        style: const TextStyle(
                                            fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: dietician.experience,
                                            style: const TextStyle(fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        text: 'Specialty: ',
                                        style: const TextStyle(
                                            fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: dietician.specialty,
                                            style: const TextStyle(fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        text: 'Education: ',
                                        style: const TextStyle(
                                            fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: dietician.education,
                                            style: const TextStyle(fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        text: 'Language Known: ',
                                        style: const TextStyle(
                                            fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: dietician.languages,
                                            style: const TextStyle(fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        text: 'Consultation Charge: ',
                                        style: const TextStyle(
                                            fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: dietician.fees,
                                            style: const TextStyle(fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton.icon(
                              onPressed: () => _launchWhatsApp(dietician.whatsappNumber),
                              icon: const Icon(Icons.message), // Changed to a generic message icon
                              label: const Text('Contact via WhatsApp'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
