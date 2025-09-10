import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

class AccessibilityHelper {
  // Add semantic labels and hints to widgets
  static Widget accessible({
    required Widget child,
    required String label,
    String? hint,
    bool? excludeSemantics,
    VoidCallback? onTapHint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      excludeSemantics: excludeSemantics ?? false,
      onTapHint: onTapHint != null ? 'Tap to $hint' : null,
      child: child,
    );
  }

  // Create accessible buttons
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback onPressed,
    required String label,
    String? hint,
    bool enabled = true,
  }) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: hint,
      onTap: enabled ? onPressed : null,
      child: child,
    );
  }

  // Create accessible text fields
  static Widget accessibleTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? errorText,
    bool obscureText = false,
    TextInputType? keyboardType,
    int? maxLength,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
  }) {
    return Semantics(
      textField: true,
      label: label,
      hint: hint,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // Announce content changes to screen readers
  static void announce(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  // Create focusable widgets with proper focus management
  static Widget focusable({
    required Widget child,
    required FocusNode focusNode,
    VoidCallback? onFocusChange,
  }) {
    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasFocus) {
        if (onFocusChange != null) {
          onFocusChange();
        }
      },
      child: child,
    );
  }

  // Merge semantics for complex widgets
  static Widget mergeSemantics({
    required List<Widget> children,
    required String label,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      container: true,
      child: Stack(
        children: children,
      ),
    );
  }

  // Exclude decorative elements from accessibility
  static Widget decorative(Widget child) {
    return Semantics(
      container: false,
      child: ExcludeSemantics(
        child: child,
      ),
    );
  }

  // Create accessible images
  static Widget accessibleImage({
    required String imagePath,
    required String label,
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return Semantics(
      image: true,
      label: label,
      child: Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }

  // Create accessible icons
  static Widget accessibleIcon({
    required IconData icon,
    required String label,
    double? size,
    Color? color,
  }) {
    return Semantics(
      label: label,
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }

  // Handle keyboard navigation
  static Widget keyboardNavigable({
    required Widget child,
    required FocusNode focusNode,
    VoidCallback? onEnter,
    VoidCallback? onEscape,
  }) {
    return RawKeyboardListener(
      focusNode: focusNode,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) && onEnter != null) {
          onEnter();
        } else if (event.isKeyPressed(LogicalKeyboardKey.escape) && onEscape != null) {
          onEscape();
        }
      },
      child: child,
    );
  }

  // Create accessible switches
  static Widget accessibleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String label,
    String? hint,
    bool enabled = true,
  }) {
    return Semantics(
      toggled: value,
      enabled: enabled,
      label: label,
      hint: hint,
      onTap: enabled ? () => onChanged(!value) : null,
      child: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  // Create accessible checkboxes
  static Widget accessibleCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
    String? hint,
    bool enabled = true,
  }) {
    return Semantics(
      checked: value,
      enabled: enabled,
      label: label,
      hint: hint,
      onTap: enabled ? () => onChanged(!value) : null,
      child: Checkbox(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  // Create accessible radio buttons
  static Widget accessibleRadio<T>({
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
    required String label,
    String? hint,
    bool enabled = true,
  }) {
    return Semantics(
      checked: value == groupValue,
      enabled: enabled,
      label: label,
      hint: hint,
      inMutuallyExclusiveGroup: true,
      onTap: enabled ? () => onChanged(value) : null,
      child: Radio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  // Create accessible sliders
  static Widget accessibleSlider({
    required double value,
    required ValueChanged<double> onChanged,
    required String label,
    String? hint,
    double? min,
    double? max,
    int? divisions,
    bool enabled = true,
  }) {
    return Semantics(
      slider: true,
      enabled: enabled,
      label: label,
      hint: hint,
      value: value.toStringAsFixed(1),
      increasedValue: ((value + 1) > (max ?? 100) ? (max ?? 100) : value + 1).toStringAsFixed(1),
      decreasedValue: ((value - 1) < (min ?? 0) ? (min ?? 0) : value - 1).toStringAsFixed(1),
      onIncrease: enabled ? () => onChanged(value + 1) : null,
      onDecrease: enabled ? () => onChanged(value - 1) : null,
      child: Slider(
        value: value,
        onChanged: enabled ? onChanged : null,
        min: min ?? 0,
        max: max ?? 100,
        divisions: divisions,
      ),
    );
  }
}

// Extension methods for easier accessibility implementation
extension AccessibilityExtensions on Widget {
  Widget accessible({
    required String label,
    String? hint,
    bool? excludeSemantics,
    VoidCallback? onTapHint,
  }) {
    return AccessibilityHelper.accessible(
      child: this,
      label: label,
      hint: hint,
      excludeSemantics: excludeSemantics,
      onTapHint: onTapHint,
    );
  }

  Widget decorative() {
    return AccessibilityHelper.decorative(this);
  }
}
