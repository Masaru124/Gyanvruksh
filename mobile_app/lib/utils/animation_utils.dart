import 'dart:math';
import 'package:flutter/material.dart';

/// Custom sine wave curve for organic animations
class _SineWaveCurve extends Curve {
  final double frequency;

  const _SineWaveCurve(this.frequency);

  @override
  double transform(double t) {
    return sin(t * 2 * pi * frequency);
  }
}

/// Custom breathing curve for smooth pulsing effects
class _BreathingCurve extends Curve {
  @override
  double transform(double t) {
    return 0.5 + 0.5 * sin(t * 2 * pi - pi / 2);
  }
}

/// Custom pulse curve for heartbeat-like effects
class _PulseCurve extends Curve {
  @override
  double transform(double t) {
    if (t < 0.5) {
      return 0.5 + 0.5 * sin(t * 4 * pi);
    } else {
      return 1.0 - 0.5 * sin((t - 0.5) * 4 * pi);
    }
  }
}

/// Advanced animation utilities for futuristic UI effects
class AnimationUtils {
  /// Creates a smooth elastic animation curve
  static const Curve elasticInOut = Curves.elasticInOut;

  /// Creates a bouncy animation curve
  static const Curve bounceOut = Curves.bounceOut;

  /// Creates a smooth ease-in-out curve
  static const Curve easeInOut = Curves.easeInOut;

  /// Creates a custom sine wave curve for organic motion
  static Curve sineWave(double frequency) {
    return _SineWaveCurve(frequency);
  }

  /// Creates a breathing animation curve
  static _BreathingCurve get breathing => _BreathingCurve();

  /// Creates a custom pulse curve
  static _PulseCurve get pulse => _PulseCurve();

  /// Creates a staggered animation delay
  static Duration staggeredDelay(int index, Duration baseDelay) {
    return Duration(milliseconds: baseDelay.inMilliseconds + (index * 100));
  }

  /// Creates a random delay within a range
  static Duration randomDelay(Duration min, Duration max) {
    final random = Random();
    final minMs = min.inMilliseconds;
    final maxMs = max.inMilliseconds;
    final randomMs = minMs + random.nextInt(maxMs - minMs);
    return Duration(milliseconds: randomMs);
  }

  /// Creates a fade-in animation with slide effect
  static Widget fadeInSlide({
    required Widget child,
    required Duration delay,
    Duration duration = const Duration(milliseconds: 600),
    double slideOffset = 0.2,
    Curve curve = Curves.easeOutCubic,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * slideOffset * 100),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Creates a scale-in animation
  static Widget scaleIn({
    required Widget child,
    required Duration delay,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.elasticOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Creates a rotation animation
  static Widget rotateIn({
    required Widget child,
    required Duration delay,
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.elasticOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: (1 - value) * 2 * pi,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Creates a shimmer effect animation
  static Widget shimmerEffect({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
    Color shimmerColor = Colors.white,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            Colors.transparent,
            shimmerColor.withOpacity(0.4),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds);
      },
      child: child,
    );
  }

  /// Creates a breathing glow effect
  static Widget breathingGlow({
    required Widget child,
    Color glowColor = Colors.blue,
    Duration duration = const Duration(seconds: 2),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.5, end: 1.0),
      duration: duration,
      curve: breathing,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(value * 0.6),
                blurRadius: value * 20,
                spreadRadius: value * 5,
              ),
            ],
          ),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Creates a floating animation
  static Widget floatingAnimation({
    required Widget child,
    Duration duration = const Duration(seconds: 3),
    double amplitude = 10.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: sineWave(1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, sin(value * 2 * pi) * amplitude),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Creates a morphing shape animation
  static Widget morphingShape({
    required Widget child,
    Duration duration = const Duration(seconds: 4),
    double morphFactor = 0.2,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: sineWave(0.5),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + (sin(value * 2 * pi) * morphFactor),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Creates a particle-like floating effect
  static Widget particleFloat({
    required Widget child,
    Duration duration = const Duration(seconds: 5),
    double amplitude = 15.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: sineWave(0.7),
      builder: (context, value, child) {
        final xOffset = sin(value * 2 * pi) * amplitude * 0.5;
        final yOffset = cos(value * 2 * pi) * amplitude;
        return Transform.translate(
          offset: Offset(xOffset, yOffset),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Creates a holographic flicker effect
  static Widget holographicFlicker({
    required Widget child,
    Duration duration = const Duration(milliseconds: 100),
    double intensity = 0.1,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.linear,
      builder: (context, value, child) {
        return Opacity(
          opacity: 1.0 - (Random().nextDouble() * intensity),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Creates a wave animation for backgrounds
  static Widget waveAnimation({
    required Widget child,
    Duration duration = const Duration(seconds: 8),
    double amplitude = 20.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: sineWave(0.3),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(sin(value * 2 * pi) * amplitude, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Creates a staggered animation for lists
  static List<Widget> staggeredAnimation({
    required List<Widget> children,
    Duration baseDelay = const Duration(milliseconds: 100),
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.elasticOut,
  }) {
    return children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;
      final delay = Duration(
        milliseconds: baseDelay.inMilliseconds + (index * 150),
      );

      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: duration,
        curve: curve,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 50),
              child: child,
            ),
          );
        },
        child: child,
      );
    }).toList();
  }

  /// Creates a ripple effect animation
  static Widget rippleEffect({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
    Color rippleColor = Colors.blue,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: rippleColor.withOpacity((1 - value) * 0.5),
                blurRadius: value * 100,
                spreadRadius: value * 50,
              ),
            ],
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Animation presets for common use cases
class AnimationPresets {
  /// Fast entrance animation
  static const Duration fastEntrance = Duration(milliseconds: 300);

  /// Normal entrance animation
  static const Duration normalEntrance = Duration(milliseconds: 500);

  /// Slow entrance animation
  static const Duration slowEntrance = Duration(milliseconds: 800);

  /// Page transition duration
  static const Duration pageTransition = Duration(milliseconds: 400);

  /// Dialog animation duration
  static const Duration dialogAnimation = Duration(milliseconds: 250);

  /// Micro-interaction duration
  static const Duration microInteraction = Duration(milliseconds: 150);

  /// Loading animation duration
  static const Duration loadingAnimation = Duration(seconds: 1);
}

/// Animation sequences for complex multi-step animations
class AnimationSequence {
  final List<AnimationStep> steps;

  const AnimationSequence(this.steps);

  /// Creates a fade-in sequence
  static AnimationSequence fadeInSequence(int count) {
    return AnimationSequence(
      List.generate(count, (index) {
        return AnimationStep(
          delay: Duration(milliseconds: index * 100),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 30),
                child: child,
              ),
            );
          },
        );
      }),
    );
  }

  /// Creates a scale-in sequence
  static AnimationSequence scaleInSequence(int count) {
    return AnimationSequence(
      List.generate(count, (index) {
        return AnimationStep(
          delay: Duration(milliseconds: index * 150),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
        );
      }),
    );
  }
}

/// Individual animation step for sequences
class AnimationStep {
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Widget Function(BuildContext, double, Widget?) builder;

  const AnimationStep({
    required this.delay,
    required this.duration,
    required this.curve,
    required this.builder,
  });
}
