import 'package:flutter/material.dart';
import 'package:myapp/models/dietician.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb; // Import for platform and web detection
import 'package:myapp/models/review.dart'; // Import Review model
import 'package:myapp/services/supabase_service.dart'; // Import SupabaseService
import 'package:myapp/utils/logger_config.dart'; // Import the logger
import 'package:myapp/services/analytics_service.dart';

class DieticianDetailsPage extends StatefulWidget {
  final Dietician dietician;

  const DieticianDetailsPage({super.key, required this.dietician});

  @override
  State<DieticianDetailsPage> createState() => _DieticianDetailsPageState();
}

class _DieticianDetailsPageState extends State<DieticianDetailsPage> {
  List<Review> _reviews = [];
  bool _isLoadingReviews = true;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    AnalyticsService().trackScreen('diatician detail page');
    logger.d('DieticianDetailsPage: initState called for dietician ID: ${widget.dietician.id}');
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    logger.d('DieticianDetailsPage: _fetchReviews started for dietician ID: ${widget.dietician.id}');
    try {
      final fetchedReviews = await _supabaseService.getReviewsForDietician(widget.dietician.id);
      setState(() {
        _reviews = fetchedReviews;
        _isLoadingReviews = false;
      });
      logger.d('DieticianDetailsPage: Fetched ${fetchedReviews.length} reviews. Is loading: $_isLoadingReviews');
    } catch (e) {
      logger.e('DieticianDetailsPage: Error fetching reviews: $e');
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _launchWhatsApp(BuildContext context, String whatsappNumber) async {
    // Clean the phone number: remove non-numeric characters
    final String cleanedNumber = whatsappNumber.replaceAll(RegExp(r'[^\d]'), '');

    Uri whatsappUri;
    if (kIsWeb) {
      // For web browsers (including mobile web browsers like iPhone Chrome, Android Chrome)
      whatsappUri = Uri.parse('https://wa.me/$cleanedNumber');
    } else if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      // For native mobile apps (Android and iOS)
      whatsappUri = Uri.parse('whatsapp://send?phone=$cleanedNumber');
    } else {
      // Fallback for other desktop platforms if needed, though wa.me is generally preferred
      whatsappUri = Uri.parse('https://wa.me/$cleanedNumber');
    }

    if (await canLaunchUrl(whatsappUri)) {
      // Use externalApplication mode for web to ensure it opens in a new tab/window.
      // For native apps, platformDefault is usually sufficient.
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Could not launch WhatsApp. Please check if WhatsApp is installed, you are logged into WhatsApp Web, or if your browser is blocking pop-ups.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 16.0,
            left: 16.0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 16.0,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Dietician Details',
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Info Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(widget.dietician.imageUrl),
                            onBackgroundImageError: (exception, stackTrace) {
                              logger.e('Error loading image: $exception');
                            },
                            child: widget.dietician.imageUrl.isEmpty
                                ? const Icon(Icons.person, size: 80)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.dietician.name,
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.dietician.education,
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Experience',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.dietician.experience,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'Fees',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${widget.dietician.fees}',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // About and Known Languages Section
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'About',
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Speciality in ${widget.dietician.specialty}',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Known Languages',
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.dietician.languages,
                            style: const TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Contact Section
                  const Text(
                    'Contact',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.phone, color: Colors.green),
                            title: Text('+91 ${widget.dietician.whatsappNumber}'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Availability Section
                  const Text(
                    'Availability',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: Text('Available Days: ${widget.dietician.availableDay}'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.access_time),
                            title: Text('Available Hours: ${widget.dietician.availableHour}'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Reviews Section
                  const SizedBox(height: 16),
                  const Text(
                    'Reviews',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _isLoadingReviews
                      ? const Center(child: CircularProgressIndicator())
                      : _reviews.isEmpty
                          ? const Center(child: Text('No reviews yet.'))
                          : ListView.builder(
                              shrinkWrap: true, // Important for nested list views
                              physics: const NeverScrollableScrollPhysics(), // Disable scrolling for nested list
                              itemCount: _reviews.length,
                              itemBuilder: (context, index) {
                                final review = _reviews[index];
                                final colors = [Colors.blue[50], Colors.green[50], Colors.orange[50]];
                                final color = colors[index % colors.length];
                                return Card(
                                  color: color,
                                  elevation: 0,
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review.patientName,
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          review.patientDetails,
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          review.comment,
                                          style: const TextStyle(fontSize: 15.0),
                                        ),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                                            style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
