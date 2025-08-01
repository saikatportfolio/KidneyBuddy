import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class EducationalContentScreen extends StatefulWidget {
  final String videoUrl;

  const EducationalContentScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<EducationalContentScreen> createState() => _EducationalContentScreenState();
}

class _EducationalContentScreenState extends State<EducationalContentScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational Content'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Article Title',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Image.asset('assets/images/auth_image.png'), // Or Image.network
            const SizedBox(height: 16.0),
            const Text(
              'Article Text...',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Subheading',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'More Article Text...',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
                : const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
