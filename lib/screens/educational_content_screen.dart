import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class EducationalContentScreen extends StatefulWidget {
  final String videoUrl;
  final String categoryName;

  const EducationalContentScreen({Key? key, required this.videoUrl, required this.categoryName}) : super(key: key);

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
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                    Expanded(
                      child: Text(
                        widget.categoryName, // Fixed title as requested
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                              fontSize: 24.0,
                            ),
                      ),
                    ),
              ],
            ),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_controller.value.isInitialized)
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    //const Center(child: CircularProgressIndicator()),
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
            ),
          ],
        ),
      ),
    );
  }
}
