import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AppCardType { elevated, outlined, filled }

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardType type;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final double? elevation;
  final VoidCallback? onTap;
  final bool showShadow;

  const AppCard({
    super.key,
    required this.child,
    this.type = AppCardType.elevated,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.elevation,
    this.onTap,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget card = _buildCard(context, theme);
    
    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? AppBorderRadius.md),
        child: card,
      );
    }
    
    return Container(
      margin: margin ?? const EdgeInsets.all(AppSpacing.sm),
      child: card,
    );
  }

  Widget _buildCard(BuildContext context, ThemeData theme) {
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.cardPadding);
    final effectiveBorderRadius = borderRadius ?? AppBorderRadius.md;
    
    switch (type) {
      case AppCardType.elevated:
        return Card(
          elevation: elevation ?? (showShadow ? AppElevation.sm : 0),
          color: backgroundColor ?? theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
          ),
          child: Padding(
            padding: effectivePadding,
            child: child,
          ),
        );
        
      case AppCardType.outlined:
        return Container(
          padding: effectivePadding,
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.cardColor,
            border: Border.all(
              color: borderColor ?? theme.dividerColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: child,
        );
        
      case AppCardType.filled:
        return Container(
          padding: effectivePadding,
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: child,
        );
    }
  }
}

class AppContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final double borderWidth;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const AppContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.borderWidth = 1.0,
    this.gradient,
    this.boxShadow,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? theme.cardColor) : null,
        gradient: gradient,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        borderRadius: BorderRadius.circular(borderRadius ?? AppBorderRadius.md),
        boxShadow: boxShadow,
      ),
      child: child,
    );
    
    if (onTap != null) {
      container = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? AppBorderRadius.md),
        child: container,
      );
    }
    
    return container;
  }
}

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool selectable;

  const AppText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.selectable = false,
  });

  // Named constructors for common text styles
  const AppText.h1(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.selectable = false,
  }) : style = AppTextStyles.h1,
       fontSize = null,
       fontWeight = null;

  const AppText.h2(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.selectable = false,
  }) : style = AppTextStyles.h2,
       fontSize = null,
       fontWeight = null;

  const AppText.h3(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.selectable = false,
  }) : style = AppTextStyles.h3,
       fontSize = null,
       fontWeight = null;

  const AppText.h4(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.selectable = false,
  }) : style = AppTextStyles.h4,
       fontSize = null,
       fontWeight = null;

  const AppText.h5(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.selectable = false,
  }) : style = AppTextStyles.h5,
       fontSize = null,
       fontWeight = null;

  const AppText.h6(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.selectable = false,
  }) : style = AppTextStyles.h6,
       fontSize = null,
       fontWeight = null;

  const AppText.bodyLarge(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.selectable = false,
  }) : style = AppTextStyles.bodyLarge,
       fontSize = null,
       fontWeight = null;

  const AppText.bodyMedium(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.selectable = false,
  }) : style = AppTextStyles.bodyMedium,
       fontSize = null,
       fontWeight = null;

  const AppText.bodySmall(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.selectable = false,
  }) : style = AppTextStyles.bodySmall,
       fontSize = null,
       fontWeight = null;

  const AppText.label(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.selectable = false,
  }) : style = AppTextStyles.labelMedium,
       fontSize = null,
       fontWeight = null;

  const AppText.caption(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.selectable = false,
  }) : style = AppTextStyles.caption,
       fontSize = null,
       fontWeight = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    TextStyle effectiveStyle = style ?? theme.textTheme.bodyMedium!;
    
    if (color != null) {
      effectiveStyle = effectiveStyle.copyWith(color: color);
    }
    
    if (fontSize != null) {
      effectiveStyle = effectiveStyle.copyWith(fontSize: fontSize);
    }
    
    if (fontWeight != null) {
      effectiveStyle = effectiveStyle.copyWith(fontWeight: fontWeight);
    }

    if (selectable) {
      return SelectableText(
        text,
        style: effectiveStyle,
        textAlign: textAlign,
        maxLines: maxLines,
      );
    }

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
