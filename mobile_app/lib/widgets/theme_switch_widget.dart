import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ThemeSwitchWidget extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged;
  final Duration animationDuration;

  const ThemeSwitchWidget({
    super.key,
    required this.isDark,
    required this.onChanged,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  State<ThemeSwitchWidget> createState() => _ThemeSwitchWidgetState();
}

class _ThemeSwitchWidgetState extends State<ThemeSwitchWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _backgroundAnimation;
  late Animation<Color?> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _backgroundAnimation = ColorTween(
      begin: Colors.blue.shade400,
      end: Colors.purple.shade600,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _iconAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.amber.shade300,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isDark) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ThemeSwitchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDark != widget.isDark) {
      if (widget.isDark) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    widget.onChanged(!widget.isDark);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleTheme,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: 70,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17.5),
              gradient: LinearGradient(
                colors: [
                  _backgroundAnimation.value ?? Colors.blue.shade400,
                  (_backgroundAnimation.value ?? Colors.blue.shade400).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_backgroundAnimation.value ?? Colors.blue.shade400).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Animated background particles
                Positioned.fill(
                  child: CustomPaint(
                    painter: ParticlePainter(
                      animation: _controller.value,
                      color: (_backgroundAnimation.value ?? Colors.blue.shade400).withOpacity(0.2),
                    ),
                  ),
                ),

                // Switch thumb
                Positioned(
                  left: _controller.value * 35,
                  top: 2.5,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Transform.rotate(
                          angle: _rotationAnimation.value * 3.14159,
                          child: Icon(
                            widget.isDark ? Icons.nightlight_round : Icons.wb_sunny,
                            size: 18,
                            color: _iconAnimation.value,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Glow effect
                Positioned(
                  left: _controller.value * 35 - 5,
                  top: -2.5,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (_backgroundAnimation.value ?? Colors.blue.shade400).withOpacity(0.3),
                    ),
                  ),
                ),
              ],
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

class ParticlePainter extends CustomPainter {
  final double animation;
  final Color color;

  ParticlePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw animated particles
    for (int i = 0; i < 5; i++) {
      final x = (i * 14.0 + animation * 20) % size.width;
      final y = size.height / 2 + (i % 2 == 0 ? 5 : -5) * (animation * 2 - 1);
      final radius = 1.5 + (i % 3) * 0.5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) =>
      oldDelegate.animation != animation;
}

class AnimatedThemeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const AnimatedThemeToggle({
    super.key,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
      ),
      child: ThemeSwitchWidget(
        isDark: isDark,
        onChanged: onChanged,
      ),
    );
  }
}
