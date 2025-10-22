import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

/// A widget that provides subtle micro-interactions for better user experience
class MicroInteractionWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration animationDuration;
  final double scaleFactor;
  final bool enableGlow;
  final Color? glowColor;

  const MicroInteractionWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 150),
    this.scaleFactor = 0.95,
    this.enableGlow = true,
    this.glowColor,
  });

  @override
  State<MicroInteractionWrapper> createState() => _MicroInteractionWrapperState();
}

class _MicroInteractionWrapperState extends State<MicroInteractionWrapper>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
    if (widget.enableGlow) {
      _glowController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    if (widget.enableGlow) {
      _glowController.reverse();
    }
  }

  void _handleTapCancel() {
    _scaleController.reverse();
    if (widget.enableGlow) {
      _glowController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleController, _glowController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: widget.enableGlow
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: (widget.glowColor ?? FuturisticColors.primary)
                              .withOpacity(_glowAnimation.value * 0.3),
                          blurRadius: _glowAnimation.value * 20,
                          spreadRadius: _glowAnimation.value * 5,
                        ),
                      ],
                    )
                  : null,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// A widget that provides hover effects (primarily for web/desktop)
class HoverEffectWrapper extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;
  final double hoverScale;
  final double hoverElevation;
  final Color? hoverColor;
  final VoidCallback? onTap;

  const HoverEffectWrapper({
    super.key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 200),
    this.hoverScale = 1.05,
    this.hoverElevation = 8.0,
    this.hoverColor,
    this.onTap,
  });

  @override
  State<HoverEffectWrapper> createState() => _HoverEffectWrapperState();
}

class _HoverEffectWrapperState extends State<HoverEffectWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: widget.animationDuration,
          transform: Matrix4.identity()..scale(_isHovered ? widget.hoverScale : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: (widget.hoverColor ?? FuturisticColors.primary)
                          .withOpacity(0.2),
                      blurRadius: widget.hoverElevation,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// A widget that provides ripple effect on tap
class RippleEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? rippleColor;
  final Duration animationDuration;

  const RippleEffect({
    super.key,
    required this.child,
    this.onTap,
    this.rippleColor,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _tapPosition = details.localPosition);
    _controller.forward(from: 0.0);
  }

  void _handleTapUp(TapUpDetails details) {
    widget.onTap?.call();
    Future.delayed(widget.animationDuration, () {
      if (mounted) {
        setState(() => _tapPosition = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      child: Stack(
        children: [
          widget.child,
          if (_tapPosition != null)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: RipplePainter(
                      position: _tapPosition!,
                      progress: _animation.value,
                      color: widget.rippleColor ?? FuturisticColors.primary.withValues(alpha: 0.3),
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

class RipplePainter extends CustomPainter {
  final Offset position;
  final double progress;
  final Color color;

  RipplePainter({
    required this.position,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final radius = progress * (size.width + size.height) / 2;
    canvas.drawCircle(position, radius, paint);
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// A widget that provides breathing/pulsing effect
class BreathingEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minOpacity;
  final double maxOpacity;

  const BreathingEffect({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.minOpacity = 0.7,
    this.maxOpacity = 1.0,
  });

  @override
  State<BreathingEffect> createState() => _BreathingEffectState();
}

class _BreathingEffectState extends State<BreathingEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// A widget that provides shimmer effect
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color shimmerColor;
  final double shimmerWidth;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.shimmerColor = Colors.white,
    this.shimmerWidth = 100.0,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -widget.shimmerWidth,
      end: 400.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.transparent,
                widget.shimmerColor.withValues(alpha: 0.4),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              transform: GradientRotation(_animation.value * 0.01),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}
