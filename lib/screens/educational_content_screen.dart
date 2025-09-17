import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:video_player/video_player.dart';

class EducationalContentScreen extends StatefulWidget {
  final String videoUrl;
  final String categoryName;

  const EducationalContentScreen({
    super.key,
    required this.videoUrl,
    required this.categoryName,
  });

  @override
  State<EducationalContentScreen> createState() =>
      _EducationalContentScreenState();
}

class _EducationalContentScreenState extends State<EducationalContentScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoInitialize: true,
      looping: false,
      showControls: true,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );

    _videoPlayerController.initialize().then((_) {
      setState(() {
        _isLoading = false;
        _chewieController!.play();
        
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
    _chewieController?.dispose();
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
                    widget.categoryName,
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
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isLoading)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text("Loading. Please wait..."),
                              SizedBox(height: 16),
                              SpinKitWave(color: Colors.blue, size: 40.0),
                            ],
                          )
                        else if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized)
                          AspectRatio(
                            aspectRatio: _videoPlayerController.value.aspectRatio,
                            child: Chewie(controller: _chewieController!),
                          )
                        else
                          const Center(
                            child: SpinKitWave(color: Colors.blue, size: 40.0),
                          ),
                        if (!_isLoading)
                          FloatingActionButton(
                            backgroundColor: Colors.blue.withValues(alpha: 0.5),
                            onPressed: () {
                              setState(() {
                                if (_chewieController!.isPlaying) {
                                  _chewieController!.pause();
                                } else {
                                  _chewieController!.play();
                                }
                              });
                            },
                            child: Icon(
                              _chewieController!.isPlaying
                                  ? Icons.pause
                                  : Icons.play_circle_filled_rounded,
                            ),
                          ),
                      ],
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
