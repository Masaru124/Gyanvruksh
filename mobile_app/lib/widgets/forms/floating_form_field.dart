import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

/// A futuristic floating form field with animated borders, particles, and morphing effects
/// Completely replaces standard TextField with a unique, trademark-level design
class FloatingFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool enabled;
  final int maxLines;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;

  const FloatingFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.maxLines = 1,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<FloatingFormField> createState() => _FloatingFormFieldState();
}

class _FloatingFormFieldState extends State<FloatingFormField>
    with TickerProviderStateMixin {
  late AnimationController _borderController;
  late AnimationController _particleController;
  late AnimationController _glowController;
  late Animation<double> _borderAnimation;
  late Animation<double> _glowAnimation;

  final List<FloatingParticle> _particles = [];
  final Random _random = Random();
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();

    _borderController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _borderAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _borderController,
      curve: Curves.elasticOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _generateParticles();
  }

  void _generateParticles() {
    for (int i = 0; i < 8; i++) {
      _particles.add(FloatingParticle(
        position: Offset(_random.nextDouble(), _random.nextDouble()),
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 0.02,
          (_random.nextDouble() - 0.5) * 0.02,
        ),
        size: _random.nextDouble() * 2 + 1,
        opacity: _random.nextDouble() * 0.4 + 0.2,
      ));
    }
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() => _isFocused = hasFocus);
    if (hasFocus) {
      _borderController.forward();
      _glowController.forward();
    } else {
      _borderController.reverse();
      _glowController.reverse();
    }
  }

  void _validateField(String value) {
    if (widget.validator != null) {
      final error = widget.validator!(value);
      setState(() {
        _hasError = error != null;
        _errorText = error;
      });
    }
  }

  @override
  void dispose() {
    _borderController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    final primaryColor = _hasError
        ? Colors.red
        : _isFocused
            ? colorScheme.primary
            : colorScheme.onSurface.withOpacity(0.6);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _borderController,
        _particleController,
        _glowController,
      ]),
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: Stack(
            children: [
              // Animated border with morphing effect
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                // Remove fixed height to allow dynamic height based on content
                // height: 60 + (_hasError ? 20 : 0),
                padding: EdgeInsets.only(bottom: _hasError ? 20 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12 + _borderAnimation.value * 4),
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.15 + _glowAnimation.value * 0.3),
                      primaryColor.withOpacity(0.05 + _glowAnimation.value * 0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(_glowAnimation.value * 0.1),
                      blurRadius: 1 + _glowAnimation.value * 1.5,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10 + _borderAnimation.value * 4),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3 + _borderAnimation.value * 0.4),
                      width: 1 + _borderAnimation.value * 1,
                    ),
                  ),
                ),
              ),

              // Floating particles around the border
              // Removed particle positioning to avoid overlap with input content
              // ..._particles.map((particle) {
              //   final animatedPosition = particle.position +
              //       particle.velocity * _particleController.value * 10;

              //   return Positioned(
              //     left: animatedPosition.dx * (size.width - 32) + 16,
              //     top: animatedPosition.dy * 70 + 8,
              //     child: Container(
              //       width: particle.size,
              //       height: particle.size,
              //       decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         color: primaryColor.withOpacity(particle.opacity * _glowAnimation.value),
              //       ),
              //     ),
              //   );
              // }),

              // Main content
              Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label with floating animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.only(
                        left: 16,
                        top: _isFocused || widget.controller.text.isNotEmpty ? 8 : 20,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.icon,
                            size: 20,
                            color: primaryColor,
                          )
                              .animate(target: _isFocused ? 1 : 0)
                              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2))
                              .then()
                              .scale(begin: const Offset(1.2, 1.2), end: const Offset(1.0, 1.0)),
                          const SizedBox(width: 8),
                          Text(
                            widget.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: _isFocused || widget.controller.text.isNotEmpty ? 12 : 14,
                            ),
                          )
                              .animate(target: _isFocused ? 1 : 0)
                              .fadeIn(duration: 200.ms)
                              .slideY(begin: -0.2, end: 0),
                        ],
                      ),
                    ),

                    // Text field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        obscureText: widget.obscureText,
                        keyboardType: widget.keyboardType,
                        maxLines: widget.maxLines,
                        enabled: widget.enabled,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: theme.cardColor.withOpacity(0.15),
                          hintText: widget.hint,
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                        ),
                        onChanged: (value) {
                          widget.onChanged?.call(value);
                          _validateField(value);
                        },
                        onSubmitted: widget.onSubmitted,
                        onTap: () => _handleFocusChange(true),
                        onEditingComplete: () => _handleFocusChange(false),
                      ),
                    ),

                    // Error message
                    if (_hasError && _errorText != null)
                      Container(
                        margin: const EdgeInsets.only(left: 16, right: 16, top: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorText!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 200.ms)
                          .slideY(begin: -0.2, end: 0),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Particle data class for floating elements around form fields
class FloatingParticle {
  Offset position;
  Offset velocity;
  double size;
  double opacity;

  FloatingParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
  });
}
