import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class AnimatedTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final bool repeat;
  final AnimationType animationType;
  final List<Color>? colors;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;

  const AnimatedTextWidget({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(seconds: 2),
    this.repeat = true,
    this.animationType = AnimationType.fade,
    this.colors,
    this.fontSize,
    this.fontWeight,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = style ??
        theme.textTheme.headlineMedium?.copyWith(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.bold,
          color: color ?? theme.colorScheme.onSurface,
        );

    switch (animationType) {
      case AnimationType.fade:
        return AnimatedTextKit(
          animatedTexts: [
            FadeAnimatedText(
              text,
              textStyle: defaultStyle!,
              duration: duration,
            ),
          ],
          repeatForever: repeat,
          pause: const Duration(milliseconds: 500),
        );

      case AnimationType.typewriter:
        return AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              text,
              textStyle: defaultStyle!,
              speed: const Duration(milliseconds: 100),
              cursor: '|',
            ),
          ],
          repeatForever: repeat,
          pause: const Duration(milliseconds: 1000),
        );

      case AnimationType.scale:
        return AnimatedTextKit(
          animatedTexts: [
            ScaleAnimatedText(
              text,
              textStyle: defaultStyle!,
              duration: duration,
              scalingFactor: 0.5,
            ),
          ],
          repeatForever: repeat,
          pause: const Duration(milliseconds: 500),
        );

      case AnimationType.colorize:
        return AnimatedTextKit(
          animatedTexts: [
            ColorizeAnimatedText(
              text,
              textStyle: defaultStyle!,
              colors: colors ??
                  [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                    theme.colorScheme.tertiary,
                    theme.colorScheme.primary,
                  ],
            ),
          ],
          repeatForever: repeat,
          pause: const Duration(milliseconds: 500),
        );

      case AnimationType.wavy:
        return AnimatedTextKit(
          animatedTexts: [
            WavyAnimatedText(
              text,
              textStyle: defaultStyle!,
              speed: const Duration(milliseconds: 300),
            ),
          ],
          repeatForever: repeat,
          pause: const Duration(milliseconds: 1000),
        );

      case AnimationType.flicker:
        return AnimatedTextKit(
          animatedTexts: [
            FlickerAnimatedText(
              text,
              textStyle: defaultStyle!,
              speed: const Duration(milliseconds: 500),
            ),
          ],
          repeatForever: repeat,
          pause: const Duration(milliseconds: 500),
        );

      default:
        return Text(text, style: defaultStyle);
    }
  }
}

enum AnimationType {
  fade,
  typewriter,
  scale,
  colorize,
  wavy,
  flicker,
}

class MultiTextAnimation extends StatelessWidget {
  final List<String> texts;
  final TextStyle? style;
  final Duration duration;
  final bool repeat;
  final AnimationType animationType;
  final List<Color>? colors;

  const MultiTextAnimation({
    super.key,
    required this.texts,
    this.style,
    this.duration = const Duration(seconds: 2),
    this.repeat = true,
    this.animationType = AnimationType.fade,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = style ?? theme.textTheme.headlineMedium;

    switch (animationType) {
      case AnimationType.fade:
        return AnimatedTextKit(
          animatedTexts: texts
              .map((text) => FadeAnimatedText(
                    text,
                    textStyle: defaultStyle!,
                    duration: duration,
                  ))
              .toList(),
          repeatForever: repeat,
          pause: const Duration(milliseconds: 500),
        );

      case AnimationType.scale:
        return AnimatedTextKit(
          animatedTexts: texts
              .map((text) => ScaleAnimatedText(
                    text,
                    textStyle: defaultStyle!,
                    duration: duration,
                  ))
              .toList(),
          repeatForever: repeat,
          pause: const Duration(milliseconds: 500),
        );

      case AnimationType.colorize:
        return AnimatedTextKit(
          animatedTexts: texts
              .map((text) => ColorizeAnimatedText(
                    text,
                    textStyle: defaultStyle!,
                    colors: colors ??
                        [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                          theme.colorScheme.tertiary,
                        ],
                  ))
              .toList(),
          repeatForever: repeat,
          pause: const Duration(milliseconds: 500),
        );

      default:
        return AnimatedTextKit(
          animatedTexts: texts
              .map((text) => FadeAnimatedText(
                    text,
                    textStyle: defaultStyle!,
                    duration: duration,
                  ))
              .toList(),
          repeatForever: repeat,
          pause: const Duration(milliseconds: 500),
        );
    }
  }
}

class TypingText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;
  final String cursor;
  final bool repeat;

  const TypingText({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 100),
    this.cursor = '|',
    this.repeat = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = style ?? theme.textTheme.bodyLarge;

    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          text,
          textStyle: defaultStyle!,
          speed: speed,
          cursor: cursor,
        ),
      ],
      repeatForever: repeat,
      pause: const Duration(milliseconds: 1000),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final List<Color> colors;
  final Duration duration;
  final bool animate;

  const GradientText({
    super.key,
    required this.text,
    this.style,
    required this.colors,
    this.duration = const Duration(seconds: 3),
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = style ?? theme.textTheme.headlineMedium;

    if (!animate) {
      return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: Text(
          text,
          style: defaultStyle?.copyWith(color: Colors.white),
        ),
      );
    }

    return AnimatedTextKit(
      animatedTexts: [
        ColorizeAnimatedText(
          text,
          textStyle: defaultStyle!.copyWith(color: Colors.white),
          colors: colors,
        ),
      ],
      repeatForever: true,
      pause: const Duration(milliseconds: 500),
    );
  }
}

class PulsingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final double scale;

  const PulsingText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(seconds: 2),
    this.scale = 1.2,
  });

  @override
  State<PulsingText> createState() => _PulsingTextState();
}

class _PulsingTextState extends State<PulsingText>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = widget.style ?? theme.textTheme.headlineMedium;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Text(
            widget.text,
            style: defaultStyle,
          ),
        );
      },
    );
  }
}
