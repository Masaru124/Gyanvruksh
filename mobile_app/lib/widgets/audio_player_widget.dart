import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final String title;
  final String? description;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    required this.title,
    this.description,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  bool _isPlaying = false;
  Duration _duration = const Duration(minutes: 5, seconds: 30);
  Duration _position = Duration.zero;

  void _playPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    // TODO: Implement actual audio playback when packages are available
  }

  void _seekTo(Duration position) {
    setState(() {
      _position = position;
    });
    // TODO: Implement actual seeking when packages are available
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FuturisticColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FuturisticColors.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: FuturisticColors.primary.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (widget.description != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Progress Bar (Custom implementation)
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _position.inSeconds / _duration.inSeconds,
              child: Container(
                decoration: BoxDecoration(
                  color: FuturisticColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Time display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rewind 10 seconds
              IconButton(
                onPressed: () {
                  final newPosition = _position - const Duration(seconds: 10);
                  _seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
                },
                icon: Icon(
                  Icons.replay_10,
                  color: theme.colorScheme.onSurface,
                  size: 32,
                ),
              ),

              const SizedBox(width: 16),

              // Play/Pause
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      FuturisticColors.primary,
                      FuturisticColors.secondary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: FuturisticColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _playPause,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Forward 10 seconds
              IconButton(
                onPressed: () {
                  final newPosition = _position + const Duration(seconds: 10);
                  _seekTo(newPosition > _duration ? _duration : newPosition);
                },
                icon: Icon(
                  Icons.forward_10,
                  color: theme.colorScheme.onSurface,
                  size: 32,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Audio URL display (for debugging)
          Text(
            'Audio URL: ${widget.audioUrl}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 8),

          // Note about implementation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Note: Audio playback implementation pending. This is a UI mockup.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
