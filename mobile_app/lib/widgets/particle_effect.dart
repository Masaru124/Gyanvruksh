import 'dart:math';
import 'package:flutter/material.dart';

class ParticleEffect extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Color? particleColor;
  final double particleSize;
  final Duration animationDuration;
  final bool enableParticles;

  const ParticleEffect({
    super.key,
    required this.child,
    this.particleCount = 20,
    this.particleColor,
    this.particleSize = 2.0,
    this.animationDuration = const Duration(seconds: 3),
    this.enableParticles = true,
  });

  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<ParticleEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    if (widget.enableParticles) {
      _controller = AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      )..repeat();

      _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.linear),
      );

      _particles = List.generate(
        widget.particleCount,
        (index) => Particle.random(),
      );
    }
  }

  @override
  void dispose() {
    if (widget.enableParticles) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableParticles) {
      return widget.child;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final particleColor = widget.particleColor ?? colorScheme.primary.withValues(alpha: 0.6);

    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(
                particles: _particles,
                animation: _animation.value,
                color: particleColor,
                size: widget.particleSize,
              ),
              child: Container(), // Invisible container to take full size
            );
          },
        ),
      ],
    );
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double life;
  double maxLife;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.life,
    required this.maxLife,
    required this.color,
  });

  factory Particle.random() {
    final random = Random();
    return Particle(
      x: random.nextDouble() * 400,
      y: random.nextDouble() * 800,
      vx: (random.nextDouble() - 0.5) * 0.5,
      vy: (random.nextDouble() - 0.5) * 0.5,
      size: random.nextDouble() * 3 + 1,
      life: random.nextDouble(),
      maxLife: random.nextDouble() * 2 + 1,
      color: Colors.white.withValues(alpha: random.nextDouble() * 0.5 + 0.2),
    );
  }

  void update(double deltaTime) {
    x += vx;
    y += vy;

    // Wrap around screen
    if (x < 0) x = 400;
    if (x > 400) x = 0;
    if (y < 0) y = 800;
    if (y > 800) y = 0;

    life += deltaTime;
    if (life > maxLife) {
      life = 0;
      // Reset position occasionally
      if (Random().nextDouble() < 0.1) {
        x = Random().nextDouble() * 400;
        y = Random().nextDouble() * 800;
      }
    }
  }

  double get opacity {
    if (life < maxLife * 0.2) {
      return life / (maxLife * 0.2);
    } else if (life > maxLife * 0.8) {
      return (maxLife - life) / (maxLife * 0.2);
    }
    return 1.0;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;
  final Color color;
  final double size;

  ParticlePainter({
    required this.particles,
    required this.animation,
    required this.color,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      particle.update(0.016); // ~60fps

      final particleColor = color.withValues(alpha: particle.opacity * color.a);
      paint.color = particleColor;

      // Draw particle with glow effect
      final glowPaint = Paint()
        ..color = particleColor.withValues(alpha: particle.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * size * 2,
        glowPaint,
      );

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class FloatingParticles extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final List<Color> colors;
  final double minSize;
  final double maxSize;
  final Duration duration;

  const FloatingParticles({
    super.key,
    required this.child,
    this.particleCount = 15,
    this.colors = const [Colors.white, Colors.blue, Colors.purple],
    this.minSize = 1.0,
    this.maxSize = 4.0,
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<FloatingParticle> _floatingParticles;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _animations = [];
    _floatingParticles = [];

    for (int i = 0; i < widget.particleCount; i++) {
      final controller = AnimationController(
        duration: widget.duration + Duration(milliseconds: Random().nextInt(2000)),
        vsync: this,
      )..repeat(reverse: true);

      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );

      _controllers.add(controller);
      _animations.add(animation);
      _floatingParticles.add(FloatingParticle.random(
        colors: widget.colors,
        minSize: widget.minSize,
        maxSize: widget.maxSize,
      ));
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ...List.generate(
          widget.particleCount,
          (index) => AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              final particle = _floatingParticles[index];
              final t = _animations[index].value;

              final x = particle.startX + (particle.endX - particle.startX) * t;
              final y = particle.startY + (particle.endY - particle.startY) * t;
              final size = particle.size * (0.8 + 0.4 * sin(t * 2 * pi));

              return Positioned(
                left: x,
                top: y,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: particle.color.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: particle.color.withValues(alpha: 0.3),
                        blurRadius: size,
                        spreadRadius: size * 0.5,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FloatingParticle {
  double startX;
  double startY;
  double endX;
  double endY;
  double size;
  Color color;

  FloatingParticle({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.size,
    required this.color,
  });

  factory FloatingParticle.random({
    required List<Color> colors,
    required double minSize,
    required double maxSize,
  }) {
    final random = Random();
    return FloatingParticle(
      startX: random.nextDouble() * 400,
      startY: random.nextDouble() * 800,
      endX: random.nextDouble() * 400,
      endY: random.nextDouble() * 800,
      size: random.nextDouble() * (maxSize - minSize) + minSize,
      color: colors[random.nextInt(colors.length)],
    );
  }
}
