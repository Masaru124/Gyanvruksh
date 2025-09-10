import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../theme/futuristic_theme.dart';

class CinematicIntro extends StatefulWidget {
  final VoidCallback? onIntroComplete;
  final Duration introDuration;
  final String title;
  final String subtitle;

  const CinematicIntro({
    super.key,
    this.onIntroComplete,
    this.introDuration = const Duration(seconds: 4),
    this.title = 'Gyanvruksh',
    this.subtitle = 'Tree of Knowledge',
  });

  @override
  State<CinematicIntro> createState() => _CinematicIntroState();
}

class _CinematicIntroState extends State<CinematicIntro>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _textController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    _startIntroSequence();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _startIntroSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _fadeController.forward();

    await Future.delayed(const Duration(seconds: 1));
    _scaleController.forward();

    await Future.delayed(const Duration(seconds: 1));
    _textController.forward();

    await Future.delayed(widget.introDuration);
    widget.onIntroComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FuturisticColors.background,
            FuturisticColors.surface,
            FuturisticColors.primary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Animated background particles
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    FuturisticColors.primary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  center: Alignment.center,
                  radius: 1.5,
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon with cinematic effect
                AnimatedBuilder(
                  animation: Listenable.merge([_fadeController, _scaleController]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                FuturisticColors.primary,
                                FuturisticColors.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: FuturisticColors.primary.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.school,
                            size: 60,
                          color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ).animate().shimmer(
                  duration: const Duration(seconds: 3),
                  color: FuturisticColors.primary.withOpacity(0.3),
                ),

                const SizedBox(height: 40),

                // Animated title text
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value,
                      child: Column(
                        children: [
                          Text(
                            widget.title,
                            style: FuturisticFonts.displayLarge.copyWith(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: FuturisticColors.primary,
                            ),
                          ).animate().fadeIn(
                            duration: const Duration(seconds: 1),
                            delay: const Duration(milliseconds: 500),
                          ),

                          const SizedBox(height: 16),

                          // Animated subtitle with typewriter effect
                          SizedBox(
                            height: 50,
                            child: DefaultTextStyle(
                              style: FuturisticFonts.headlineMedium.copyWith(
                                color: FuturisticColors.textPrimary,
                                fontSize: 24,
                              ),
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    widget.subtitle,
                                    speed: const Duration(milliseconds: 100),
                                    cursor: '|',
                                  ),
                                ],
                                isRepeatingAnimation: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                // Loading indicator
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FuturisticColors.primary,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Bottom fade effect
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    FuturisticColors.background.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
