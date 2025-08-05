import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/models/education_video.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EducationItemScreen extends StatefulWidget {
  final String categoryId;

  const EducationItemScreen({Key? key, required this.categoryId}) : super(key: key);

  @override
  _EducationItemScreenState createState() => _EducationItemScreenState();
}

class _EducationItemScreenState extends State<EducationItemScreen> {
  late Future<List<EducationVideo>> _educationVideosFuture;

  @override
  void initState() {
    super.initState();
    _educationVideosFuture = _fetchEducationVideos();
  }

  Future<List<EducationVideo>> _fetchEducationVideos() async {
    final supabaseService = SupabaseService();
    final videos = await supabaseService.getEducationVideos(int.parse(widget.categoryId));
    for (var video in videos) {
      print('Video Image URL in _fetchEducationVideos: ${video.videoImageURL}');
    }
    return videos;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational Videos'),
      ),
      body: FutureBuilder<List<EducationVideo>>(
        future: _educationVideosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No videos available.'));
          } else {
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final video = snapshot.data![index];
                return _buildVideoItem(context, video);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildVideoItem(BuildContext context, EducationVideo video) {
    print('Video Image URL: ${video.videoImageURL}');
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final Uri url = Uri.parse(video.videoUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch \$url')),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                width: double.infinity,
                child: video.videoImageURL == null
                    ? const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      )
                    : Image.network(
                        video.videoImageURL!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Text(
                  video.videoName,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
