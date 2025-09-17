import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyanvruksh/viewmodels/lesson_viewmodel.dart';
import 'package:gyanvruksh/viewmodels/progress_viewmodel.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/widgets/custom_animated_button.dart';
import 'package:gyanvruksh/widgets/neumorphism_container.dart';
import 'package:gyanvruksh/widgets/backgrounds/cinematic_background.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/floating_elements.dart';
import 'package:gyanvruksh/widgets/animated_wave_background.dart';
import 'package:gyanvruksh/widgets/micro_interactions.dart';
import 'package:gyanvruksh/widgets/animated_text_widget.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class LessonScreen extends StatefulWidget {
  final int lessonId;

  const LessonScreen({super.key, required this.lessonId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonViewModel>().loadLesson(widget.lessonId);
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _initializeVideo(String videoUrl) {
    if (_videoController != null) return;

    _videoController = VideoPlayerController.network(videoUrl);
    _videoController!.initialize().then((_) {
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: false,
          looping: false,
          aspectRatio: _videoController!.value.aspectRatio,
          placeholder: Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorBuilder: (context, errorMessage) {
            return Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        );
        _isVideoInitialized = true;
      });
    });
  }

  void _markLessonComplete() {
    final lesson = context.read<LessonViewModel>().currentLesson;
    if (lesson != null) {
      context.read<ProgressViewModel>().updateLessonProgress(
        lesson['course_id'],
        lesson['id'],
        100.0,
        completed: true,
        timeSpentMinutes: lesson['duration_minutes'] ?? 0,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson completed!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Cinematic Background
          CinematicBackground(isDark: false),

          // Enhanced Particle Background
          ParticleBackground(
            particleCount: 25,
            maxParticleSize: 3.0,
            particleColor: FuturisticColors.primary,
          ),

          // Floating Elements
          FloatingElements(
            elementCount: 8,
            maxElementSize: 40,
            icons: const [
              Icons.play_circle,
              Icons.book,
              Icons.lightbulb,
              Icons.check_circle,
            ],
          ),

          // Animated Wave Background
          AnimatedWaveBackground(
            color: FuturisticColors.neonBlue.withOpacity(0.05),
            height: MediaQuery.of(context).size.height,
          ),

          SafeArea(
            child: Consumer<LessonViewModel>(
              builder: (context, lessonVM, child) {
                if (lessonVM.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (lessonVM.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: colorScheme.error),
                        const SizedBox(height: 16),
                        Text('Error loading lesson', style: theme.textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        Text(lessonVM.error!, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 24),
                        CustomAnimatedButton(
                          onPressed: () => lessonVM.loadLesson(widget.lessonId),
                          text: 'Retry',
                          backgroundColor: colorScheme.primary,
                          textColor: colorScheme.onPrimary,
                        ),
                      ],
                    ),
                  );
                }

                final lesson = lessonVM.currentLesson;
                if (lesson == null) {
                  return const Center(child: Text('Lesson not found'));
                }

                // Initialize video if it's a video lesson
                if (lesson['content_type'] == 'video' && lesson['content_url'] != null && !_isVideoInitialized) {
                  _initializeVideo(lesson['content_url']);
                }

                return Column(
                  children: [
                    // Header
                    GlassmorphismCard(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      blurStrength: 15,
                      opacity: 0.1,
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        children: [
                          MicroInteractionWrapper(
                            child: NeumorphismContainer(
                              padding: const EdgeInsets.all(12),
                              borderRadius: BorderRadius.circular(16),
                              child: Icon(
                                _getContentTypeIcon(lesson['content_type']),
                                color: colorScheme.primary,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedTextWidget(
                                  text: lesson['title'] ?? 'Lesson',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  animationType: AnimationType.fade,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${lesson['duration_minutes'] ?? 0} minutes',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: colorScheme.onSurface),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Video Player
                            if (lesson['content_type'] == 'video' && _chewieController != null)
                              GlassmorphismCard(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                blurStrength: 10,
                                opacity: 0.1,
                                borderRadius: BorderRadius.circular(20),
                                child: AspectRatio(
                                  aspectRatio: _videoController!.value.aspectRatio,
                                  child: Chewie(controller: _chewieController!),
                                ),
                              ),

                            // Text Content
                            if (lesson['content_type'] == 'text' && lesson['content_text'] != null)
                              GlassmorphismCard(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(20),
                                blurStrength: 10,
                                opacity: 0.1,
                                borderRadius: BorderRadius.circular(20),
                                child: Text(
                                  lesson['content_text'],
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                    height: 1.6,
                                  ),
                                ),
                              ),

                            // Audio Content (placeholder)
                            if (lesson['content_type'] == 'audio')
                              GlassmorphismCard(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(20),
                                blurStrength: 10,
                                opacity: 0.1,
                                borderRadius: BorderRadius.circular(20),
                                child: Row(
                                  children: [
                                    NeumorphismContainer(
                                      padding: const EdgeInsets.all(16),
                                      borderRadius: BorderRadius.circular(50),
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: colorScheme.primary,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        'Audio Lesson',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Interactive Content (placeholder)
                            if (lesson['content_type'] == 'interactive')
                              GlassmorphismCard(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(20),
                                blurStrength: 10,
                                opacity: 0.1,
                                borderRadius: BorderRadius.circular(20),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.touch_app,
                                      color: colorScheme.primary,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Interactive Content',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'This lesson contains interactive elements',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),

                            // Description
                            if (lesson['description'] != null)
                              GlassmorphismCard(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(20),
                                blurStrength: 10,
                                opacity: 0.1,
                                borderRadius: BorderRadius.circular(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Description',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      lesson['description'],
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Complete Button
                            Center(
                              child: CustomAnimatedButton(
                                onPressed: _markLessonComplete,
                                text: 'Mark as Complete',
                                backgroundColor: colorScheme.primary,
                                textColor: colorScheme.onPrimary,
                                width: 200,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getContentTypeIcon(String? contentType) {
    switch (contentType) {
      case 'video':
        return Icons.play_circle;
      case 'audio':
        return Icons.audiotrack;
      case 'text':
        return Icons.article;
      case 'interactive':
        return Icons.touch_app;
      default:
        return Icons.book;
    }
  }
}
