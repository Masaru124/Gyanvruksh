import 'package:flutter/material.dart';

/// Optimized container that uses const constructors where possible
class OptimizedContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final Widget? child;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;

  const OptimizedContainer({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.decoration,
    this.child,
    this.alignment,
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      alignment: alignment,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

/// Optimized text widget with performance considerations
class OptimizedText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const OptimizedText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}

/// Optimized icon widget
class OptimizedIcon extends StatelessWidget {
  final IconData? icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final TextDirection? textDirection;

  const OptimizedIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
    );
  }
}

/// Optimized padding widget
class OptimizedPadding extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget? child;

  const OptimizedPadding({
    super.key,
    required this.padding,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Optimized sized box
class OptimizedSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const OptimizedSizedBox({
    super.key,
    this.width,
    this.height,
    this.child,
  }) : assert(width == null || width >= 0),
       assert(height == null || height >= 0);

  const OptimizedSizedBox.shrink({super.key})
    : width = 0,
      height = 0,
      child = null;

  const OptimizedSizedBox.expand({super.key, this.child})
    : width = double.infinity,
      height = double.infinity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }
}

/// Performance-optimized animated container
class OptimizedAnimatedContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final Widget? child;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;
  final Duration duration;
  final Curve curve;

  const OptimizedAnimatedContainer({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.decoration,
    this.child,
    this.alignment,
    this.clipBehavior = Clip.none,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.linear,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      alignment: alignment,
      clipBehavior: clipBehavior,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}
