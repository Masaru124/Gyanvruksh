import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/futuristic_theme.dart';

class AnimatedWaveBackground extends StatefulWidget {
  final Color color;
  final double height;
  final double speed;
  final double waveHeight;

  const AnimatedWaveBackground({
    super.key,
    this.color = FuturisticColors.primary,
    this.height = 200,
    this.speed = 1.0,
    this.waveHeight = 20,
  });

  @override
  State<AnimatedWaveBackground> createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: (5000 / widget.speed).round()),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _WavePainter(
              animationValue: _animation.value,
              color: widget.color,
              waveHeight: widget.waveHeight,
            ),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double waveHeight;

  _WavePainter({
    required this.animationValue,
    required this.color,
    required this.waveHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final path = Path();

    final waveLength = size.width / 2;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 +
          math.sin((x / waveLength * 2 * math.pi) + animationValue) * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
