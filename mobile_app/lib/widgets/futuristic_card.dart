import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FuturisticCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blurStrength;
  final double opacity;
  final Color? tintColor;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;
  final Duration animationDuration;
  final bool enableParticles;
  final bool enableMorphing;

  const FuturisticCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurStrength = 20.0,
    this.opacity = 0.1,
    this.tintColor,
    this.gradientColors,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 500),
    this.enableParticles = true,
    this.enableMorphing = true,
  });

  @override
  State<FuturisticCard> createState() => _FuturisticCardState();
}

class _FuturisticCardState extends State<FuturisticCard>
    with TickerProviderStateMixin {
  late AnimationController _morphController;
  late AnimationController _particleController;
  late Animation<double> _morphAnimation;
  late Animation<double> _glowAnimation;

  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    if (widget.enableMorphing) {
      _morphController = AnimationController(
        duration: const Duration(seconds: 4),
        vsync: this,
      )..repeat(reverse: true);

      _morphAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _morphController, curve: Curves.easeInOut),
      );
    }

    if (widget.enableParticles) {
      _particleController = AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      )..repeat();

      _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
      );

      // Initialize particles
      for (int i = 0; i < 8; i++) {
        _particles.add(Particle.random());
      }
    }
  }

  @override
  void dispose() {
    if (widget.enableMorphing) _morphController.dispose();
    if (widget.enableParticles) _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final defaultGradientColors = [
      colorScheme.primary.withOpacity(0.3),
      colorScheme.secondary.withOpacity(0.3),
      colorScheme.tertiary.withOpacity(0.3),
    ];

    final gradientColors = widget.gradientColors ?? defaultGradientColors;

    Widget card = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: widget.enableMorphing ? _morphAnimation : AlwaysStoppedAnimation(0),
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [
                      _morphAnimation.value * 0.3,
                      0.5 + _morphAnimation.value * 0.3,
                      1.0 - _morphAnimation.value * 0.3,
                    ],
                  ),
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                ),
              );
            },
          ),

          // Glassmorphism effect
          ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blurStrength,
                sigmaY: widget.blurStrength,
              ),
              child: Container(
                padding: widget.padding ?? const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (widget.tintColor ?? colorScheme.surface).withValues(alpha: widget.opacity),
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: gradientColors[0].withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: -5,
                      offset: const Offset(-5, -5),
                    ),
                  ],
                ),
                child: widget.child,
              ),
            ),
          ),

          // Particles effect
          if (widget.enableParticles)
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    particles: _particles,
                    animation: _particleController.value,
                    glowIntensity: _glowAnimation.value,
                    color: gradientColors[0],
                  ),
                );
              },
            ),

          // Morphing border effect
          if (widget.enableMorphing)
            AnimatedBuilder(
              animation: _morphAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                    border: Border.all(
                      color: Color.lerp(
                        gradientColors[0],
                        gradientColors[1],
                        _morphAnimation.value,
                      )!.withValues(alpha: 0.6),
                      width: 2 + sin(_morphAnimation.value * 2 * pi) * 0.5,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );

    if (widget.onTap != null) {
      card = GestureDetector(
        onTap: widget.onTap,
        child: card
            .animate()
            .fadeIn(duration: widget.animationDuration)
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              duration: widget.animationDuration,
              curve: Curves.elasticOut,
            )
            .shimmer(duration: 2.seconds, color: gradientColors[0].withValues(alpha: 0.1)),
      );
    } else {
      card = card
          .animate()
          .fadeIn(duration: widget.animationDuration)
          .scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
            duration: widget.animationDuration,
            curve: Curves.elasticOut,
          )
          .shimmer(duration: 2.seconds, color: gradientColors[0].withValues(alpha: 0.1));
    }

    return card;
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double life;

  Particle(this.x, this.y, this.vx, this.vy, this.size, this.life);

  factory Particle.random() {
    return Particle(
      Random().nextDouble() * 200,
      Random().nextDouble() * 200,
      (Random().nextDouble() - 0.5) * 2,
      (Random().nextDouble() - 0.5) * 2,
      Random().nextDouble() * 3 + 1,
      Random().nextDouble(),
    );
  }

  void update(double deltaTime) {
    x += vx * deltaTime;
    y += vy * deltaTime;

    // Wrap around
    if (x < 0) x = 200;
    if (x > 200) x = 0;
    if (y < 0) y = 200;
    if (y > 200) y = 0;

    life += deltaTime * 0.1;
    if (life > 1) life = 0;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;
  final double glowIntensity;
  final Color color;

  ParticlePainter({
    required this.particles,
    required this.animation,
    required this.glowIntensity,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: glowIntensity * 0.3)
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      particle.update(0.016); // ~60fps

      final opacity = (sin(particle.life * 2 * pi) + 1) / 2;
      paint.color = color.withValues(alpha: opacity * glowIntensity * 0.5);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
