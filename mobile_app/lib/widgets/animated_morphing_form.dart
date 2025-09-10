import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/futuristic_theme.dart';

class AnimatedMorphingForm extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final Duration animationDuration;

  const AnimatedMorphingForm({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedMorphingForm> createState() => _AnimatedMorphingFormState();
}

class _AnimatedMorphingFormState extends State<AnimatedMorphingForm>
    with TickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() => _isFocused = hasFocus);
    if (hasFocus) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }
  }

  void _handleTextChange(String value) {
    widget.onChanged?.call(value);
    // Trigger subtle animation on text change
    if (value.isNotEmpty && !_isFocused) {
      _focusController.forward().then((_) => _focusController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _focusController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  FuturisticColors.surface.withOpacity(0.8),
                  FuturisticColors.surface.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isFocused
                      ? FuturisticColors.primary.withOpacity(_glowAnimation.value * 0.3)
                      : FuturisticColors.primary.withOpacity(0.1),
                  blurRadius: 8 + (_glowAnimation.value * 12),
                  spreadRadius: _glowAnimation.value * 2,
                ),
                BoxShadow(
                  color: _hasError
                      ? FuturisticColors.error.withOpacity(0.2)
                      : Colors.transparent,
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
              border: Border.all(
                color: _isFocused
                    ? FuturisticColors.primary.withOpacity(_glowAnimation.value)
                    : _hasError
                        ? FuturisticColors.error
                        : FuturisticColors.textSecondary.withOpacity(0.3),
                width: 1 + (_glowAnimation.value * 2),
              ),
            ),
            child: Focus(
              onFocusChange: _handleFocusChange,
              child: TextFormField(
                controller: widget.controller,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                validator: (value) {
                  final error = widget.validator?.call(value);
                  setState(() => _hasError = error != null);
                  return error;
                },
                onChanged: _handleTextChange,
                style: FuturisticFonts.bodyLarge.copyWith(
                  color: FuturisticColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: widget.label,
                  hintText: widget.hint,
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _isFocused
                              ? FuturisticColors.primary
                              : FuturisticColors.textSecondary,
                        ).animate(
                          target: _isFocused ? 1 : 0,
                        ).scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          duration: widget.animationDuration,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  labelStyle: FuturisticFonts.bodyMedium.copyWith(
                    color: _isFocused
                        ? FuturisticColors.primary
                        : FuturisticColors.textSecondary,
                  ),
                  hintStyle: FuturisticFonts.bodyMedium.copyWith(
                    color: FuturisticColors.textSecondary.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).animate(
      target: _isFocused ? 1 : 0,
    ).shimmer(
      duration: const Duration(seconds: 2),
      color: FuturisticColors.primary.withOpacity(0.1),
    );
  }
}
