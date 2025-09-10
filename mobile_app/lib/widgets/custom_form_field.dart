import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final int? maxLines;
  final bool enabled;
  final Color? fillColor;
  final BorderRadius? borderRadius;

  const CustomFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.maxLines = 1,
    this.enabled = true,
    this.fillColor,
    this.borderRadius,
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField>
    with TickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _focusAnimation;
  late FocusNode _internalFocusNode;
  bool _hasError = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeInOut),
    );

    _internalFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    _focusController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_internalFocusNode.hasFocus) {
      _focusController.forward();
    } else {
      _focusController.reverse();
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _focusAnimation,
          builder: (context, child) {
            final borderColor = _hasError
                ? Colors.red
                : Color.lerp(
                    colorScheme.outline,
                    colorScheme.primary,
                    _focusAnimation.value,
                  )!;

            return Container(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _internalFocusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                maxLines: widget.maxLines,
                enabled: widget.enabled,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  hintText: widget.hintText,
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _internalFocusNode.hasFocus
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                        )
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? Icon(
                          widget.suffixIcon,
                          color: _internalFocusNode.hasFocus
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                        )
                      : null,
                  filled: true,
                          fillColor: widget.fillColor ??
                      colorScheme.surface.withValues(alpha: 0.8),
                  border: OutlineInputBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: borderColor,
                      width: _internalFocusNode.hasFocus ? 2 : 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _hasError ? Colors.red : colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _hasError ? Colors.red : colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  widget.onChanged?.call(value);
                  _validateField(value);
                },
                onFieldSubmitted: widget.onSubmitted,
                validator: widget.validator,
              ),
            );
          },
        )
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOut),
        if (_hasError && _errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              _errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .slideY(begin: -0.2, end: 0, duration: 200.ms),
          ),
      ],
    );
  }
}
