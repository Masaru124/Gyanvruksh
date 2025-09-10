import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final List<Alignment> alignments;
  final Duration duration;
  final Curve curve;
  final bool enableAnimation;
  final double opacity;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    required this.colors,
    this.alignments = const [
      Alignment.topLeft,
      Alignment.topRight,
      Alignment.bottomLeft,
      Alignment.bottomRight,
    ],
    this.duration = const Duration(seconds: 8),
    this.curve = Curves.linear,
    this.enableAnimation = true,
    this.opacity = 1.0,
  });

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (widget.enableAnimation) {
      _controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      )..repeat();

      _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: widget.curve),
      );
    }
  }

  @override
  void dispose() {
    if (widget.enableAnimation) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableAnimation) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.colors.map((color) => color.withValues(alpha: widget.opacity)).toList(),
            begin: widget.alignments[0],
            end: widget.alignments[1],
          ),
        ),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value;

        // Create dynamic gradient based on animation value
        final colors = widget.colors.map((color) => color.withValues(alpha: widget.opacity)).toList();

        // Interpolate between different gradient configurations
        final begin = Alignment.lerp(widget.alignments[0], widget.alignments[2], t)!;
        final end = Alignment.lerp(widget.alignments[1], widget.alignments[3], t)!;

        // Add color shifting effect
        final shiftedColors = colors.map((color) {
          final hue = HSVColor.fromColor(color).hue;
          final newHue = (hue + t * 30) % 360; // Shift hue by up to 30 degrees
          return HSVColor.fromAHSV(color.a, newHue, HSVColor.fromColor(color).saturation, HSVColor.fromColor(color).value).toColor();
        }).toList();

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: shiftedColors,
              begin: begin,
              end: end,
              stops: [
                t * 0.3,
                0.5 + t * 0.3,
                1.0 - t * 0.3,
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class RadialGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;
  final double radius;
  final bool enableAnimation;
  final double opacity;

  const RadialGradientBackground({
    super.key,
    required this.child,
    required this.colors,
    this.duration = const Duration(seconds: 6),
    this.radius = 1.5,
    this.enableAnimation = true,
    this.opacity = 1.0,
  });

  @override
  State<RadialGradientBackground> createState() => _RadialGradientBackgroundState();
}

class _RadialGradientBackgroundState extends State<RadialGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (widget.enableAnimation) {
      _controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      )..repeat(reverse: true);

      _animation = Tween<double>(begin: 0.8, end: widget.radius).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    if (widget.enableAnimation) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableAnimation) {
      return Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: widget.colors.map((color) => color.withValues(alpha: widget.opacity)).toList(),
            radius: widget.radius,
          ),
        ),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final colors = widget.colors.map((color) => color.withValues(alpha: widget.opacity)).toList();

        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: colors,
              radius: _animation.value,
              center: Alignment.center,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class MeshGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;
  final bool enableAnimation;
  final double opacity;

  const MeshGradientBackground({
    super.key,
    required this.child,
    required this.colors,
    this.duration = const Duration(seconds: 10),
    this.enableAnimation = true,
    this.opacity = 1.0,
  });

  @override
  State<MeshGradientBackground> createState() => _MeshGradientBackgroundState();
}

class _MeshGradientBackgroundState extends State<MeshGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (widget.enableAnimation) {
      _controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      )..repeat();

      _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.linear),
      );
    }
  }

  @override
  void dispose() {
    if (widget.enableAnimation) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableAnimation) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.colors.map((color) => color.withValues(alpha: widget.opacity)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value;
        final colors = widget.colors.map((color) => color.withValues(alpha: widget.opacity)).toList();

        // Create mesh-like effect by layering multiple gradients
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors[0], colors[1]],
                  begin: Alignment(sin(t * 2 * 3.14159) * 0.5, cos(t * 2 * 3.14159) * 0.5),
                  end: Alignment(-sin(t * 2 * 3.14159) * 0.5, -cos(t * 2 * 3.14159) * 0.5),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors[1], colors[2 % colors.length]],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [t * 0.5, 1.0 - t * 0.5],
                ),
              ),
            ),
            Opacity(
              opacity: 0.3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Colors.transparent, colors[0].withValues(alpha: 0.5)],
                    radius: 1.0 + sin(t * 4 * 3.14159) * 0.2,
                  ),
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}
