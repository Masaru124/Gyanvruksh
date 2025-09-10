import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class ParticleBackground extends StatefulWidget {
  final int particleCount;
  final double maxParticleSize;
  final Duration animationDuration;
  final Color? particleColor;

  const ParticleBackground({
    super.key,
    this.particleCount = 50,
    this.maxParticleSize = 4.0,
    this.animationDuration = const Duration(seconds: 20),
    this.particleColor,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with TickerProviderStateMixin {
  late List<Particle> _particles;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(
      widget.particleCount,
      (index) => Particle.random(
        maxSize: widget.maxParticleSize,
        color: widget.particleColor ?? FuturisticColors.primary,
      ),
    );

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
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
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            animationValue: _animation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double opacity;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.opacity,
  });

  factory Particle.random({
    required double maxSize,
    required Color color,
  }) {
    final random = Random();
    return Particle(
      position: Offset(
        random.nextDouble() * 400,
        random.nextDouble() * 800,
      ),
      velocity: Offset(
        (random.nextDouble() - 0.5) * 2,
        (random.nextDouble() - 0.5) * 2,
      ),
      size: random.nextDouble() * maxSize + 1,
      color: color.withOpacity(random.nextDouble() * 0.8 + 0.2),
      opacity: random.nextDouble() * 0.8 + 0.2,
    );
  }

  void update(double deltaTime) {
    position += velocity * deltaTime;

    // Wrap around screen edges
    if (position.dx < -size) position = Offset(400 + size, position.dy);
    if (position.dx > 400 + size) position = Offset(-size, position.dy);
    if (position.dy < -size) position = Offset(position.dx, 800 + size);
    if (position.dy > 800 + size) position = Offset(position.dx, -size);
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      particle.update(0.016); // Approximate 60fps delta time

      paint.color = particle.color.withOpacity(particle.opacity);

      // Add subtle glow effect
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(particle.position, particle.size * 2, glowPaint);
      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
