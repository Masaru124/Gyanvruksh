import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NeumorphismContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final double depth;
  final bool isPressed;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const NeumorphismContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.depth = 8.0,
    this.isPressed = false,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = backgroundColor ?? colorScheme.surface;
    final lightShadow = isDark
        ? Color.lerp(baseColor, Colors.white, 0.1)!
        : Color.lerp(baseColor, Colors.white, 0.8)!;
    final darkShadow = isDark
        ? Color.lerp(baseColor, Colors.black, 0.3)!
        : Color.lerp(baseColor, Colors.black, 0.2)!;

    final container = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: isPressed
            ? [
                BoxShadow(
                  color: darkShadow,
                  offset: Offset(depth / 2, depth / 2),
                  blurRadius: depth,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: lightShadow,
                  offset: Offset(-depth / 2, -depth / 2),
                  blurRadius: depth,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: lightShadow,
                  offset: Offset(-depth, -depth),
                  blurRadius: depth * 2,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: darkShadow,
                  offset: Offset(depth, depth),
                  blurRadius: depth * 2,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          child: container,
        ),
      )
          .animate()
          .fadeIn(duration: animationDuration)
          .slideY(begin: 0.1, end: 0, duration: animationDuration);
    }

    return container
        .animate()
        .fadeIn(duration: animationDuration)
        .slideY(begin: 0.1, end: 0, duration: animationDuration);
  }
}
