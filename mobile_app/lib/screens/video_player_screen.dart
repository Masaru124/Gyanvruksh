import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:gyanvruksh/services/enhanced_api_service.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final int courseId;
  final String courseTitle;

  const VideoPlayerScreen({
    Key? key,
    required this.courseId,
    required this.courseTitle,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  List<dynamic> videos = [];
  bool isLoading = true;
  String? error;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;
  bool _isYoutube = false;

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

      // Get lessons for this course and filter for video content
      final lessonsResult = await ApiService.getLessons(courseId: widget.courseId);
      final allLessons = lessonsResult.isSuccess ? (lessonsResult.data as List<dynamic>?) ?? [] : [];
      final videoLessons = allLessons
          .where((lesson) =>
              lesson['content_type'] == 'video' &&
              lesson['url'] != null)
          .toList();
      setState(() {
        videos = videoLessons;
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
      _chewieController = null;
    }
    if (_videoPlayerController != null) {
      await _videoPlayerController!.dispose();
      _videoPlayerController = null;
    }
    if (_youtubeController != null) {
      _youtubeController!.dispose();
      _youtubeController = null;
    }

    _isYoutube = false;
    String processedUrl = videoUrl;

    if (videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be')) {
      if (defaultTargetPlatform == TargetPlatform.windows) {
        setState(() {
          error =
              'YouTube playback is not supported on Windows platform. Please use a different video URL or test on Android/iOS.';
        });
        return;
      }
      _isYoutube = true;
      String? videoId = YoutubePlayer.convertUrlToId(videoUrl);
      if (videoId == null) {
        setState(() {
          error = 'Invalid YouTube URL';
        });
        return;
      }
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
      _youtubeController!.addListener(() {
        if (!_youtubeController!.value.isReady) {
          print('YouTube controller not ready yet');
        } else if (_youtubeController!.value.isPlaying) {
          print('YouTube video is playing');
        } else {
          print('YouTube video is not playing');
        }
      });
      setState(() {
        error = null;
      });
      return;
    }

    if (videoUrl.contains('drive.google.com')) {
      // Detect if URL is a folder URL and show error
      if (videoUrl.contains('/drive/folders/')) {
        setState(() {
          error =
              'Google Drive folder URLs cannot be streamed. Please provide a direct video file URL.';
        });
        return;
      }
      // Handle Google Drive file URLs - convert to direct download link
      String fileId = '';
      if (videoUrl.contains('/file/d/')) {
        fileId = videoUrl.split('/file/d/')[1].split('/')[0];
      } else if (videoUrl.contains('id=')) {
        fileId = videoUrl.split('id=')[1].split('&')[0];
      }
      if (fileId.isNotEmpty) {
        processedUrl = 'https://drive.google.com/uc?export=download&id=$fileId';
      }
      print('Processed Google Drive URL: $processedUrl');
    }

    if (defaultTargetPlatform == TargetPlatform.windows) {
      setState(() {
        error = 'Video playback is not supported on Windows platform yet.';
      });
      return;
    }

    try {
      print('Initializing video player with URL: $processedUrl');
      _videoPlayerController =
          VideoPlayerController.network(processedUrl);
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        autoPlay: true,
        looping: false,
        allowPlaybackSpeedChanging: true,
        allowedScreenSleep: false,
        autoInitialize: true,
        showControlsOnInitialize: true,
      );

      setState(() {
        error = null;
      });
    } catch (e) {
      setState(() {
        error = 'Video player initialization failed: $e';
      });
    }
  }

  // Method to test playing a sample public video URL
  void _playSampleVideo() {
    const sampleUrl =
        'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4';
    _initializeVideo(sampleUrl);
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Building VideoPlayerScreen with ${videos.length} videos, isLoading=$isLoading, error=$error');
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
                          Icon(Icons.video_library,
                              size: 64, color: Colors.grey),
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
                        if (_isYoutube && _youtubeController != null)
                          SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: YoutubePlayer(
                              controller: _youtubeController!,
                              showVideoProgressIndicator: true,
                              onReady: () {
                                print('YouTube player is ready');
                              },
                              onEnded: (metaData) {
                                print('YouTube video ended: $metaData');
                              },
                              // onPlayerStateChange: (state) {
                              //   print('YouTube player state changed: $state');
                              // },
                              // onPlayerError: (error) {
                              //   print('YouTube player error: $error');
                              // },
                            ),
                          )
                        else if (_chewieController != null &&
                            _videoPlayerController != null &&
                            _videoPlayerController!.value.isInitialized)
                          AspectRatio(
                            aspectRatio:
                                _videoPlayerController!.value.aspectRatio,
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
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    child: const Icon(Icons.play_circle_fill,
                                        color: Colors.white),
                                  ),
                                  title: Text(
                                    video['title'] ?? 'Untitled Video',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (video['description'] != null &&
                                          video['description'].isNotEmpty)
                                        Text(
                                          video['description'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      Text(
                                        'Uploaded: ${video['uploaded_at'] ?? 'Unknown'}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    print(
                                        'Initializing video: ${video['url']}');
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
