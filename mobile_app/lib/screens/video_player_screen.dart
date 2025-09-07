import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class VideoPlayerScreen extends StatefulWidget {
  final int courseId;
  final String courseTitle;

  const VideoPlayerScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  List<dynamic> videos = [];
  bool isLoading = true;
  String? error;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final videosData = await ApiService().getCourseVideos(widget.courseId);
      setState(() {
        videos = videosData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _initializeVideo(String videoUrl) async {
    if (_chewieController != null) {
      _chewieController!.dispose();
    }
    if (_videoPlayerController != null) {
      await _videoPlayerController!.dispose();
    }

    String processedUrl = videoUrl;

    if (videoUrl.contains('drive.google.com')) {
      // Handle Google Drive URLs - convert to direct download link
      String fileId = '';
      if (videoUrl.contains('/file/d/')) {
        fileId = videoUrl.split('/file/d/')[1].split('/')[0];
      } else if (videoUrl.contains('id=')) {
        fileId = videoUrl.split('id=')[1].split('&')[0];
      }
      if (fileId.isNotEmpty) {
        processedUrl = 'https://drive.google.com/uc?export=download&id=$fileId';
      }
    }

    if (defaultTargetPlatform == TargetPlatform.windows) {
      setState(() {
        error = 'Video playback is not supported on Windows platform yet.';
      });
      return;
    }

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(processedUrl));
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        autoPlay: true,
        looping: false,
      );

      setState(() {});
    } catch (e) {
      setState(() {
        error = 'Video player initialization failed: $e';
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.courseTitle} - Videos'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadVideos,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : videos.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.video_library, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No videos available',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Videos will be added by your teacher',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        if (_chewieController != null && _videoPlayerController != null && _videoPlayerController!.value.isInitialized)
                          AspectRatio(
                            aspectRatio: _videoPlayerController!.value.aspectRatio,
                            child: Chewie(controller: _chewieController!),
                          ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: videos.length,
                            itemBuilder: (context, index) {
                              final video = videos[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    child: const Icon(Icons.play_circle_fill, color: Colors.white),
                                  ),
                                  title: Text(
                                    video['title'] ?? 'Untitled Video',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (video['description'] != null && video['description'].isNotEmpty)
                                        Text(
                                          video['description'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      Text(
                                        'Uploaded: ${video['uploaded_at'] ?? 'Unknown'}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    _initializeVideo(video['url']);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}
