import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';

class LoadingStates {
  // Full screen loading overlay
  static Widget fullScreenLoading(BuildContext context, {String? message}) {
    return Container(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FuturisticLoadingIndicator(),
            if (message != null) ...[
              const SizedBox(height: 24),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Inline loading for buttons/cards
  static Widget inlineLoading({double size = 24, Color? color}) {
    return SizedBox(
      width: size,
      height: size,
      child: _FuturisticLoadingIndicator(color: color),
    );
  }

  // Loading button
  static Widget loadingButton({
    required String text,
    required bool isLoading,
    required VoidCallback? onPressed,
    double? width,
    double? height,
  }) {
    return SizedBox(
      width: width,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading
              ? FuturisticColors.neonBlue.withOpacity(0.3)
              : FuturisticColors.neonBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isLoading ? 0 : 4,
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  inlineLoading(size: 20, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Loading...'),
                ],
              )
            : Text(text),
      ),
    );
  }

  // Skeleton loading for content
  static Widget skeletonLoader({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: FuturisticColors.neonBlue.withOpacity(0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1500.ms,
          color: FuturisticColors.neonBlue.withOpacity(0.2),
        );
  }

  // Error state widget
  static Widget errorState({
    required String title,
    required String message,
    required VoidCallback onRetry,
    IconData? icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: FuturisticColors.error,
            )
                .animate()
                .scale(duration: 300.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: FuturisticColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: FuturisticColors.neonBlue.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FuturisticColors.neonBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms)
                .slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  // Empty state widget
  static Widget emptyState({
    required String title,
    required String message,
    IconData? icon,
    Widget? actionButton,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox,
              size: 64,
              color: FuturisticColors.neonBlue.withOpacity(0.5),
            )
                .animate()
                .scale(duration: 300.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: FuturisticColors.neonBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: FuturisticColors.neonBlue.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 24),
              actionButton
                  .animate()
                  .fadeIn(delay: 500.ms)
                  .slideY(begin: 0.2, end: 0),
            ],
          ],
        ),
      ),
    );
  }
}

class _FuturisticLoadingIndicator extends StatefulWidget {
  final Color? color;

  const _FuturisticLoadingIndicator({this.color});

  @override
  State<_FuturisticLoadingIndicator> createState() => _FuturisticLoadingIndicatorState();
}

class _FuturisticLoadingIndicatorState extends State<_FuturisticLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? FuturisticColors.neonBlue;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 3,
                ),
              ),
            ),
            // Rotating arc
            Transform.rotate(
              angle: _animation.value * 2 * 3.14159,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.transparent,
                    width: 3,
                  ),
                ),
                child: CircularProgressIndicator(
                  value: 0.75,
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            // Inner glow
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
