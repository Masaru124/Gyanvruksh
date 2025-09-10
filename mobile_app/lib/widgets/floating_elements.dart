import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class FloatingElements extends StatefulWidget {
  final int elementCount;
  final double maxElementSize;
  final Duration animationDuration;
  final List<IconData> icons;

  const FloatingElements({
    super.key,
    this.elementCount = 8,
    this.maxElementSize = 60,
    this.animationDuration = const Duration(seconds: 15),
    this.icons = const [
      Icons.school,
      Icons.book,
      Icons.lightbulb,
      Icons.psychology,
      Icons.computer,
      Icons.science,
      Icons.calculate,
      Icons.language,
    ],
  });

  @override
  State<FloatingElements> createState() => _FloatingElementsState();
}

class _FloatingElementsState extends State<FloatingElements>
    with TickerProviderStateMixin {
  late List<FloatingElement> _elements;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _elements = List.generate(
      widget.elementCount,
      (index) => FloatingElement.random(
        maxSize: widget.maxElementSize,
        icon: widget.icons[index % widget.icons.length],
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
        return Stack(
          children: _elements.map((element) {
            element.update(_animation.value);
            return Positioned(
              left: element.position.dx,
              top: element.position.dy,
              child: Transform.rotate(
                angle: element.rotation,
                child: Container(
                  width: element.size,
                  height: element.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        element.color.withOpacity(element.opacity),
                        element.color.withOpacity(element.opacity * 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: element.color.withOpacity(element.opacity * 0.4),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    element.icon,
                    color: Colors.white.withOpacity(element.opacity),
                    size: element.size * 0.6,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class FloatingElement {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double opacity;
  double rotation;
  IconData icon;
  double rotationSpeed;

  FloatingElement({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.opacity,
    required this.rotation,
    required this.icon,
    required this.rotationSpeed,
  });

  factory FloatingElement.random({
    required double maxSize,
    required IconData icon,
  }) {
    final random = Random();
    final colors = [
      FuturisticColors.primary,
      FuturisticColors.secondary,
      FuturisticColors.accent,
      FuturisticColors.accent,
    ];

    return FloatingElement(
      position: Offset(
        random.nextDouble() * 350,
        random.nextDouble() * 700,
      ),
      velocity: Offset(
        (random.nextDouble() - 0.5) * 0.5,
        (random.nextDouble() - 0.5) * 0.5,
      ),
      size: random.nextDouble() * maxSize + 40,
      color: colors[random.nextInt(colors.length)],
      opacity: random.nextDouble() * 0.6 + 0.4,
      rotation: random.nextDouble() * 2 * pi,
      icon: icon,
      rotationSpeed: (random.nextDouble() - 0.5) * 0.02,
    );
  }

  void update(double animationValue) {
    // Update position with floating motion
    position += velocity;

    // Add sine wave motion for more organic movement
    position = Offset(
      position.dx,
      position.dy + sin(animationValue * 2 * pi + position.dx * 0.01) * 0.5,
    );

    // Update rotation
    rotation += rotationSpeed;

    // Wrap around screen edges
    if (position.dx < -size) position = Offset(400 + size, position.dy);
    if (position.dx > 400 + size) position = Offset(-size, position.dy);
    if (position.dy < -size) position = Offset(position.dx, 800 + size);
    if (position.dy > 800 + size) position = Offset(position.dx, -size);

    // Pulsing opacity effect
    opacity = 0.4 + 0.3 * sin(animationValue * 2 * pi + position.dx * 0.005);
  }
}
