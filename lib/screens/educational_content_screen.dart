import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class EducationalContentScreen extends StatefulWidget {
  final String videoUrl;

  const EducationalContentScreen({super.key, required this.videoUrl});

  @override
  State<EducationalContentScreen> createState() => _EducationalContentScreenState();
}

class _EducationalContentScreenState extends State<EducationalContentScreen> {
  late VideoPlayerController _controller;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isVideoPlaying = true;
          _controller.play();
        });
      });

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        setState(() {
          _isVideoPlaying = false;
        });
      }
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
            SizedBox(
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_controller.value.isInitialized)
                    Column(
                      children: [
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                          ),
                        ),
                      ],
                    )
                  else
                    const Center(child: CircularProgressIndicator()),
                  FloatingActionButton(
                    backgroundColor: Colors.blue.withValues(alpha: 0.5),
                    onPressed: () {
                      setState(() {
                        if (_isVideoPlaying) {
                          _controller.pause();
                          _isVideoPlaying = false;
                        } else {
                          _controller.play();
                          _isVideoPlaying = true;
                        }
                      });
                    },
                    child: Icon(
                      _isVideoPlaying ? Icons.pause : Icons.play_circle_filled_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
