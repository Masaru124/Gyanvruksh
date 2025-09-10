import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class GlowingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Duration glowDuration;

  const GlowingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width = 160,
    this.height = 48,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.glowDuration = const Duration(seconds: 2),
  });

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: widget.glowDuration,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              gradient: LinearGradient(
                colors: [
                  FuturisticColors.primary,
                  FuturisticColors.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: FuturisticColors.primary.withOpacity(_glowAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: FuturisticColors.secondary.withOpacity(_glowAnimation.value * 0.7),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(child: widget.child),
          ),
        );
      },
    );
  }
}
