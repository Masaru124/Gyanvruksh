import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class HolographicButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Duration animationDuration;
  final bool enableHologram;
  final bool enablePulse;
  final double borderRadius;
  final TextStyle? textStyle;
  final IconData? icon;
  final bool isLoading;

  const HolographicButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.width,
    this.height,
    this.primaryColor,
    this.secondaryColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.enableHologram = true,
    this.enablePulse = true,
    this.borderRadius = 25,
    this.textStyle,
    this.icon,
    this.isLoading = false,
  }) : super(key: key);

  @override
  _HolographicButtonState createState() => _HolographicButtonState();
}

class _HolographicButtonState extends State<HolographicButton>
    with TickerProviderStateMixin {
  late AnimationController _hologramController;
  late AnimationController _pulseController;
  late AnimationController _pressController;
  late Animation<double> _hologramAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _pressAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _hologramController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _hologramAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_hologramController);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _hologramController.dispose();
    _pulseController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _pressController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _pressController.reverse();
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _pressController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? FuturisticColors.primary;
    final secondaryColor = widget.secondaryColor ?? FuturisticColors.secondary;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _hologramAnimation,
        _pulseAnimation,
        _pressAnimation,
      ]),
      builder: (context, child) {
        return GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: Container(
            width: widget.width,
            height: widget.height ?? 50,
            child: Stack(
              children: [
                // Holographic effect background
                if (widget.enableHologram)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: HolographicPainter(
                        primaryColor: primaryColor,
                        secondaryColor: secondaryColor,
                        animationValue: _hologramAnimation.value,
                        borderRadius: widget.borderRadius,
                      ),
                    ),
                  ),

                // Main button
                Transform.scale(
                  scale: widget.enablePulse ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: widget.width,
                    height: widget.height ?? 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor.withValues(alpha: 0.8),
                          secondaryColor.withValues(alpha: 0.6),
                        ],
                      ),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.8),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 15 + (_pressAnimation.value * 5),
                          spreadRadius: 2 + (_pressAnimation.value * 2),
                        ),
                        BoxShadow(
                          color: secondaryColor.withValues(alpha: 0.2),
                          blurRadius: 25,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.borderRadius - 2),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.1),
                                Colors.white.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                          child: Center(
                            child: widget.isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white.withValues(alpha: 0.8),
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (widget.icon != null) ...[
                                        Icon(
                                          widget.icon,
                                          color: Colors.white.withValues(alpha: 0.9),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Text(
                                        widget.text,
                                        style: widget.textStyle ??
                                            FuturisticFonts.labelLarge.copyWith(
                                              color: Colors.white.withValues(alpha: 0.9),
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Press effect overlay
                if (_isPressed)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HolographicPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double animationValue;
  final double borderRadius;

  HolographicPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.animationValue,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Create holographic gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor.withValues(alpha: 0.3),
        secondaryColor.withValues(alpha: 0.3),
        primaryColor.withValues(alpha: 0.1),
        secondaryColor.withValues(alpha: 0.2),
      ],
      stops: [
        0.0,
        0.3 + animationValue * 0.4,
        0.7 + animationValue * 0.3,
        1.0,
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rrect, paint);

    // Add shimmer effect
    final shimmerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final shimmerPath = Path()
      ..moveTo(0, size.height * (0.2 + animationValue * 0.6))
      ..lineTo(size.width, size.height * (0.8 - animationValue * 0.4));

    canvas.drawPath(shimmerPath, shimmerPaint);
  }

  @override
  bool shouldRepaint(HolographicPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
