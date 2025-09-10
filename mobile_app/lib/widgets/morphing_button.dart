import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MorphingButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final Duration morphDuration;
  final bool enableMorphing;

  const MorphingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.morphDuration = const Duration(milliseconds: 600),
    this.enableMorphing = true,
  });

  @override
  State<MorphingButton> createState() => _MorphingButtonState();
}

class _MorphingButtonState extends State<MorphingButton>
    with TickerProviderStateMixin {
  late AnimationController _morphController;
  late AnimationController _scaleController;
  late Animation<double> _morphAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _borderRadiusAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    if (widget.enableMorphing) {
      _morphController = AnimationController(
        duration: widget.morphDuration,
        vsync: this,
      );

      _morphAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _morphController, curve: Curves.elasticOut),
      );

      _borderRadiusAnimation = Tween<double>(begin: 12.0, end: 25.0).animate(
        CurvedAnimation(parent: _morphController, curve: Curves.easeInOut),
      );
    }

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    if (widget.enableMorphing) _morphController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
    if (widget.enableMorphing && !_morphController.isAnimating) {
      _morphController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
    if (widget.enableMorphing) {
      _morphController.reverse();
    }
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (widget.enableMorphing) {
      if (isHovered) {
        _morphController.forward();
      } else {
        _morphController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = widget.backgroundColor ?? colorScheme.primary;
    final textColor = widget.textColor ?? colorScheme.onPrimary;

    Widget button = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            if (widget.enableMorphing) _morphController,
            _scaleController,
          ]),
          builder: (context, child) {
            final morphValue = widget.enableMorphing ? _morphAnimation.value : 0.0;
            final scaleValue = _scaleAnimation.value;
            final borderRadius = widget.enableMorphing
                ? _borderRadiusAnimation.value
                : 12.0;

            // Create morphing shape
            final width = widget.width ?? 200.0;
            final height = widget.height ?? 50.0;

            // Calculate morphed dimensions
            final morphedWidth = width + (morphValue * 20);
            final morphedHeight = height + (morphValue * 10);

            return Transform.scale(
              scale: scaleValue,
              child: Container(
                width: morphedWidth,
                height: morphedHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      backgroundColor,
                      Color.lerp(backgroundColor, colorScheme.secondary, morphValue * 0.3)!,
                      Color.lerp(backgroundColor, colorScheme.tertiary, morphValue * 0.2)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [
                      0.0,
                      0.5 + morphValue * 0.2,
                      1.0,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: 0.3),
                      blurRadius: 15 + morphValue * 10,
                      spreadRadius: 2 + morphValue * 3,
                      offset: Offset(0, 4 + morphValue * 2),
                    ),
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.1 + morphValue * 0.1),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.1 + morphValue * 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(textColor),
                              ),
                            )
                          : Text(
                              widget.text,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16 + morphValue * 2,
                                letterSpacing: 0.5 + morphValue * 0.5,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    return button
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          curve: Curves.elasticOut,
        );
  }
}

class LiquidButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  const LiquidButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
  });

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton>
    with TickerProviderStateMixin {
  late AnimationController _liquidController;
  late Animation<double> _liquidAnimation;

  @override
  void initState() {
    super.initState();
    _liquidController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _liquidAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _liquidController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _liquidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = widget.backgroundColor ?? colorScheme.primary;
    final textColor = widget.textColor ?? colorScheme.onPrimary;

    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _liquidAnimation,
        builder: (context, child) {
          return Container(
            width: widget.width ?? 200,
            height: widget.height ?? 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [
                  backgroundColor,
                  Color.lerp(backgroundColor, colorScheme.secondary, 0.3)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Stack(
                children: [
                  // Liquid effect
                  Positioned.fill(
                    child: CustomPaint(
                      painter: LiquidPainter(
                        animation: _liquidAnimation.value,
                        color: backgroundColor.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  // Content
                  Center(
                    child: widget.isLoading
                        ? CircularProgressIndicator(color: textColor)
                        : Text(
                            widget.text,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          curve: Curves.elasticOut,
        );
  }
}

class LiquidPainter extends CustomPainter {
  final double animation;
  final Color color;

  LiquidPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create liquid-like wave effect
    final waveHeight = size.height * 0.1;
    final frequency = 2 * pi * 2; // 2 waves

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height - waveHeight * sin((x / size.width) * frequency + animation * 2 * pi);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LiquidPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
