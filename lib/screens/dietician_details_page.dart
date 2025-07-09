import 'package:flutter/material.dart';
import 'package:myapp/models/dietician.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/models/review.dart'; // Import Review model
import 'package:myapp/services/supabase_service.dart'; // Import SupabaseService

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
    print('DieticianDetailsPage: initState called for dietician ID: ${widget.dietician.id}');
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    print('DieticianDetailsPage: _fetchReviews started for dietician ID: ${widget.dietician.id}');
    try {
      final fetchedReviews = await _supabaseService.getReviewsForDietician(widget.dietician.id);
      setState(() {
        _reviews = fetchedReviews;
        _isLoadingReviews = false;
      });
      print('DieticianDetailsPage: Fetched ${fetchedReviews.length} reviews. Is loading: $_isLoadingReviews');
    } catch (e) {
      print('DieticianDetailsPage: Error fetching reviews: $e');
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _launchWhatsApp(BuildContext context, String whatsappNumber) async {
    final Uri whatsappUri = Uri.parse('whatsapp://send?phone=$whatsappNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      // Fallback for when WhatsApp is not installed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp. Make sure it is installed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dietician Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Info Card
            Card(
              elevation: 4.0,
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
                        print('Error loading image: $exception');
                      },
                      child: widget.dietician.imageUrl.isEmpty
                          ? const Icon(Icons.person, size: 80)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.dietician.name,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Education: ${widget.dietician.education}',
                      style: const TextStyle(fontSize: 16.0, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Experience: ${widget.dietician.experience}',
                      style: const TextStyle(fontSize: 16.0, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Specialty: ${widget.dietician.specialty}',
                      style: const TextStyle(fontSize: 16.0, color: Colors.black),
                      textAlign: TextAlign.center,
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
              elevation: 4.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.message, color: Colors.green),
                      title: Text(widget.dietician.whatsappNumber),
                      trailing: ElevatedButton(
                        onPressed: () => _launchWhatsApp(context, widget.dietician.whatsappNumber),
                        child: const Text('WhatsApp'),
                      ),
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
              elevation: 4.0,
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
                          return Card(
                            elevation: 2.0,
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
    );
  }
}
