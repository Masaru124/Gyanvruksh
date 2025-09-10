import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:math';

/// A cinematic animated background with floating particles, waves, and dynamic gradients
/// Creates a unique, trademark-level visual experience
class CinematicBackground extends StatefulWidget {
  final bool isDark;
  final List<Color> primaryColors;
  final List<Color> accentColors;

  const CinematicBackground({
    super.key,
    required this.isDark,
    this.primaryColors = const [
      Color(0xFF6366F1), // Electric indigo
      Color(0xFF8B5CF6), // Vibrant purple
      Color(0xFF06B6D4), // Cyan accent
    ],
    this.accentColors = const [
      Color(0xFFA5B4FC), // Electric blue
      Color(0xFFC4B5FD), // Neon purple
      Color(0xFF67E8F9), // Electric cyan
    ],
  });

  @override
  State<CinematicBackground> createState() => _CinematicBackgroundState();
}

class _CinematicBackgroundState extends State<CinematicBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _particleController;
  late AnimationController _waveController;
  late Animation<Color?> _primaryColorAnimation;
  late Animation<Color?> _secondaryColorAnimation;
  late Animation<double> _waveAnimation;

  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _waveController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    // Color animations for dynamic gradient shifts
    _primaryColorAnimation = ColorTween(
      begin: widget.primaryColors[0],
      end: widget.primaryColors[1],
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    _secondaryColorAnimation = ColorTween(
      begin: widget.primaryColors[1],
      end: widget.primaryColors[2],
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    // Wave animation
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_waveController);

    // Generate floating particles
    _generateParticles();
  }

  void _generateParticles() {
    for (int i = 0; i < 25; i++) {
      _particles.add(Particle(
        position: Offset(
          _random.nextDouble() * 400,
          _random.nextDouble() * 800,
        ),
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 0.5,
          (_random.nextDouble() - 0.5) * 0.5,
        ),
        size: _random.nextDouble() * 3 + 1,
        opacity: _random.nextDouble() * 0.6 + 0.2,
        color: widget.accentColors[_random.nextInt(widget.accentColors.length)],
      ));
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _gradientController,
        _particleController,
        _waveController,
      ]),
      builder: (context, child) {
        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _primaryColorAnimation.value ?? widget.primaryColors[0],
                _secondaryColorAnimation.value ?? widget.primaryColors[1],
                widget.primaryColors[2].withOpacity(0.8),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Animated wave patterns
              CustomPaint(
                size: size,
                painter: WavePainter(
                  animation: _waveAnimation.value,
                  colors: widget.accentColors,
                  isDark: widget.isDark,
                ),
              ),
              // Floating particles with reduced blur for sharper appearance
              ..._particles.map((particle) {
                final animatedPosition = particle.position +
                    particle.velocity * _particleController.value * 100;

                return Positioned(
                  left: animatedPosition.dx % size.width,
                  top: animatedPosition.dy % size.height,
                  child: Container(
                    width: particle.size,
                    height: particle.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: particle.color.withOpacity(particle.opacity),
                      boxShadow: [
                        BoxShadow(
                          color: particle.color.withOpacity(0.3),
                          blurRadius: particle.size, // Reduced blur radius
                          spreadRadius: particle.size * 0.3, // Reduced spread radius
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Floating particles
              ..._particles.map((particle) {
                final animatedPosition = particle.position +
                    particle.velocity * _particleController.value * 100;

                return Positioned(
                  left: animatedPosition.dx % size.width,
                  top: animatedPosition.dy % size.height,
                  child: Container(
                    width: particle.size,
                    height: particle.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: particle.color.withOpacity(particle.opacity),
                      boxShadow: [
                        BoxShadow(
                          color: particle.color.withOpacity(0.3),
                          blurRadius: particle.size * 2,
                          spreadRadius: particle.size * 0.5,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Subtle noise texture overlay
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      Colors.transparent,
                      widget.isDark
                          ? Colors.black.withOpacity(0.1)
                          : Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Particle data class for floating elements
class Particle {
  Offset position;
  Offset velocity;
  double size;
  double opacity;
  Color color;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.color,
  });
}

/// Custom painter for animated wave patterns
class WavePainter extends CustomPainter {
  final double animation;
  final List<Color> colors;
  final bool isDark;

  WavePainter({
    required this.animation,
    required this.colors,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Draw multiple wave layers
    for (int i = 0; i < 3; i++) {
      final path = Path();
      final waveHeight = 20.0 + i * 10;
      final frequency = 0.02 + i * 0.01;

      path.moveTo(0, size.height * 0.3);

      for (double x = 0; x <= size.width; x += 5) {
        final y = size.height * 0.3 +
            math.sin((x * frequency) + animation + i * math.pi / 3) * waveHeight;
        path.lineTo(x, y);
      }

      paint.color = colors[i % colors.length].withOpacity(0.3 - i * 0.1);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
