import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class EnhancedFuturisticCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool enableGlow;
  final bool enableHover;
  final Duration animationDuration;
  final double borderRadius;
  final Color? glowColor;
  final double glowIntensity;

  const EnhancedFuturisticCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.onTap,
    this.enableGlow = true,
    this.enableHover = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.borderRadius = 20,
    this.glowColor,
    this.glowIntensity = 0.5,
  }) : super(key: key);

  @override
  _EnhancedFuturisticCardState createState() => _EnhancedFuturisticCardState();
}

class _EnhancedFuturisticCardState extends State<EnhancedFuturisticCard>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _hoverController;
  late Animation<double> _glowAnimation;
  late Animation<double> _hoverAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _hoverController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: widget.glowIntensity,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _glowController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (widget.enableHover) {
      setState(() => _isHovered = isHovered);
      if (isHovered) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _hoverAnimation]),
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => _handleHover(true),
          onExit: (_) => _handleHover(false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: widget.width,
              height: widget.height,
              margin: widget.margin,
              child: Stack(
                children: [
                  // Glow effect
                  if (widget.enableGlow)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: (widget.glowColor ?? FuturisticColors.neonBlue)
                                  .withValues(alpha: _glowAnimation.value),
                              blurRadius: 20 + (_hoverAnimation.value * 10),
                              spreadRadius: 5 + (_hoverAnimation.value * 5),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Main card
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          FuturisticColors.cardBackground.withValues(alpha: 0.9),
                          FuturisticColors.cardBackground.withValues(alpha: 0.7),
                        ],
                      ),
                      border: Border.all(
                        color: FuturisticColors.neonBlue.withValues(
                          alpha: 0.3 + (_hoverAnimation.value * 0.4),
                        ),
                        width: 1 + (_hoverAnimation.value * 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: Offset(0, 5 + (_hoverAnimation.value * 2)),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.borderRadius - 1),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: widget.padding,
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
                          child: Transform.scale(
                            scale: 1.0 + (_hoverAnimation.value * 0.02),
                            child: widget.child,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Hover overlay
                  if (_isHovered)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              FuturisticColors.neonBlue.withValues(alpha: 0.1),
                              FuturisticColors.neonPurple.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
