import 'dart:ui';
import 'package:flutter/material.dart';

// Define the FuturisticColors class since it's imported but not defined
class FuturisticColors {
  static const Color primary = Color(0xFF00E5FF);
  static const Color secondary = Color(0xFF651FFF);
  static const Color cardBackground = Color(0xFF1A1A2E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
}

class FuturisticChart extends StatefulWidget {
  final List<double> data;
  final List<String> labels;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? backgroundColor;
  final double height;
  final bool showGrid;
  final bool showAnimation;
  final Duration animationDuration;
  final String title;
  final TextStyle? titleStyle;
  final bool enableGlow;

  const FuturisticChart({
    Key? key,
    required this.data,
    required this.labels,
    this.primaryColor,
    this.secondaryColor,
    this.backgroundColor,
    this.height = 300,
    this.showGrid = true,
    this.showAnimation = true,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.title = '',
    this.titleStyle,
    this.enableGlow = true,
  }) : super(key: key);

  @override
  State<FuturisticChart> createState() => _FuturisticChartState();
}

class _FuturisticChartState extends State<FuturisticChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    if (widget.showAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? FuturisticColors.primary;
    final secondaryColor = widget.secondaryColor ?? FuturisticColors.secondary;
    final backgroundColor =
        widget.backgroundColor ?? FuturisticColors.cardBackground;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor.withOpacity(0.9),
            backgroundColor.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: widget.enableGlow
            ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title.isNotEmpty) ...[
                  Text(
                    widget.title,
                    style: widget.titleStyle ??
                        const TextStyle(
                          color: FuturisticColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 20),
                ],
                Expanded(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: FuturisticChartPainter(
                          data: widget.data,
                          labels: widget.labels,
                          primaryColor: primaryColor,
                          secondaryColor: secondaryColor,
                          animationValue: _animation.value,
                          showGrid: widget.showGrid,
                          enableGlow: widget.enableGlow,
                        ),
                        child: Container(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FuturisticChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color primaryColor;
  final Color secondaryColor;
  final double animationValue;
  final bool showGrid;
  final bool enableGlow;

  FuturisticChartPainter({
    required this.data,
    required this.labels,
    required this.primaryColor,
    required this.secondaryColor,
    required this.animationValue,
    required this.showGrid,
    required this.enableGlow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Explicitly convert num to double to fix type errors
    final double maxValue = data.reduce((a, b) => a > b ? a : b).toDouble();
    final double minValue = data.reduce((a, b) => a < b ? a : b).toDouble();
    final double range = maxValue - minValue;
    final double effectiveRange = range == 0.0 ? 1.0 : range;

    final chartWidth = size.width - 60; // Leave space for labels
    final chartHeight = size.height - 60; // Leave space for labels
    final chartLeft = 40.0;
    final chartTop = 20.0;

    // Draw grid
    if (showGrid) {
      _drawGrid(canvas, size, chartLeft, chartTop, chartWidth, chartHeight);
    }

    // Draw axes
    _drawAxes(canvas, size, chartLeft, chartTop, chartWidth, chartHeight);

    // Draw data points and lines
    _drawData(
      canvas,
      size,
      chartLeft,
      chartTop,
      chartWidth,
      chartHeight,
      maxValue,
      minValue,
      effectiveRange,
    );

    // Draw labels
    _drawLabels(canvas, size, chartLeft, chartTop, chartWidth, chartHeight);
  }

  void _drawGrid(Canvas canvas, Size size, double left, double top,
      double width, double height) {
    final gridPaint = Paint()
      ..color = FuturisticColors.textSecondary.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Vertical grid lines
    for (int i = 0; i <= 5; i++) {
      final x = left + (width * i / 5);
      canvas.drawLine(
        Offset(x, top),
        Offset(x, top + height),
        gridPaint,
      );
    }

    // Horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = top + (height * i / 4);
      canvas.drawLine(
        Offset(left, y),
        Offset(left + width, y),
        gridPaint,
      );
    }
  }

  void _drawAxes(Canvas canvas, Size size, double left, double top,
      double width, double height) {
    final axisPaint = Paint()
      ..color = FuturisticColors.textSecondary.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // X-axis
    canvas.drawLine(
      Offset(left, top + height),
      Offset(left + width, top + height),
      axisPaint,
    );

    // Y-axis
    canvas.drawLine(
      Offset(left, top),
      Offset(left, top + height),
      axisPaint,
    );
  }

  void _drawData(
    Canvas canvas,
    Size size,
    double left,
    double top,
    double width,
    double height,
    double maxValue,
    double minValue,
    double effectiveRange,
  ) {
    if (data.length < 2) return;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = left + (width * i / (data.length - 1));
      final normalizedValue = (data[i] - minValue) / effectiveRange;
      final y = top + height - (height * normalizedValue * animationValue);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, top + height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Draw data point
      if (animationValue > 0.8) {
        final pointPaint = Paint()
          ..color = primaryColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), 4, pointPaint);

        if (enableGlow) {
          final glowPaint = Paint()
            ..color = primaryColor.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

          canvas.drawCircle(Offset(x, y), 6, glowPaint);
        }
      }
    }

    // Complete fill path
    fillPath.lineTo(left + width, top + height);
    fillPath.close();

    // Draw fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.3 * animationValue),
          primaryColor.withOpacity(0.1 * animationValue),
        ],
      ).createShader(Rect.fromLTWH(left, top, width, height));

    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Draw glow effect on line
    if (enableGlow) {
      final glowLinePaint = Paint()
        ..color = primaryColor.withOpacity(0.5)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawPath(path, glowLinePaint);
    }
  }

  void _drawLabels(Canvas canvas, Size size, double left, double top,
      double width, double height) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // X-axis labels
    for (int i = 0; i < labels.length; i++) {
      final int labelsLength = labels.length;
      final int step = (labelsLength / 5).ceil();
      final int actualStep = step > 1 ? step : 1;

      if (i % actualStep == 0) {
        final double x = left + (width * i / (labels.length - 1));
        textPainter.text = TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: FuturisticColors.textSecondary,
            fontSize: 10,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, top + height + 10),
        );
      }
    }

    // Y-axis labels - Fix the type error here too
    final double maxValue = data.reduce((a, b) => a > b ? a : b).toDouble();
    final double minValue = data.reduce((a, b) => a < b ? a : b).toDouble();

    for (int i = 0; i <= 4; i++) {
      final double value = minValue + (maxValue - minValue) * i / 4;
      final y = top + height - (height * i / 4);

      textPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: const TextStyle(
          color: FuturisticColors.textSecondary,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(left - textPainter.width - 5, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(FuturisticChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.data != data ||
        oldDelegate.labels != labels;
  }
}
