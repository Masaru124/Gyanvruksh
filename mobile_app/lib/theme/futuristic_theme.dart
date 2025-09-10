import 'package:flutter/material.dart';

/// Futuristic color palette with neon accents and modern gradients
class FuturisticColors {
  // Primary colors - Electric and vibrant
  static const Color primary = Color(0xFF6366F1); // Electric indigo
  static const Color primaryLight = Color(0xFFA5B4FC); // Light electric blue
  static const Color primaryDark = Color(0xFF312E81); // Dark indigo

  // Secondary colors - Neon and bright
  static const Color secondary = Color(0xFF8B5CF6); // Vibrant purple
  static const Color secondaryLight = Color(0xFFC4B5FD); // Light neon purple
  static const Color secondaryDark = Color(0xFF581C87); // Dark purple

  // Accent colors - Electric variants
  static const Color accent = Color(0xFF06B6D4); // Cyan accent
  static const Color accentLight = Color(0xFF67E8F9); // Electric cyan
  static const Color accentDark = Color(0xFF164E63); // Dark cyan

  // Background colors - Deep and rich
  static const Color background = Color(0xFF0F0F23); // Deep dark blue
  static const Color backgroundLight = Color(0xFF1E1B4B); // Light dark blue
  static const Color surface = Color(0xFF1A1A2E); // Surface dark
  static const Color surfaceLight = Color(0xFF16213E); // Light surface
  static const Color cardBackground = Color(0xFF1A1A2E); // Card background

  // Text colors
  static const Color textPrimary = Color(0xFFF1F5F9); // Light text
  static const Color textSecondary = Color(0xFF94A3B8); // Muted text
  static const Color textAccent = Color(0xFFE879F9); // Neon pink accent

  // Status colors
  static const Color success = Color(0xFF10B981); // Electric green
  static const Color warning = Color(0xFFF59E0B); // Electric orange
  static const Color error = Color(0xFFEF4444); // Electric red
  static const Color info = Color(0xFF3B82F6); // Electric blue

  // Neon colors (for backward compatibility)
  static const Color neonBlue = Color(0xFF6366F1);
  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color neonGreen = Color(0xFF10B981);
  static const Color neonPink = Color(0xFFE879F9);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, accent],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundLight],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surface, surfaceLight],
  );

  // Glow effects
  static BoxShadow primaryGlow = BoxShadow(
    color: primary.withOpacity(0.3),
    blurRadius: 20,
    spreadRadius: 5,
  );

  static BoxShadow secondaryGlow = BoxShadow(
    color: secondary.withOpacity(0.3),
    blurRadius: 20,
    spreadRadius: 5,
  );

  static BoxShadow accentGlow = BoxShadow(
    color: accent.withOpacity(0.3),
    blurRadius: 20,
    spreadRadius: 5,
  );
}

/// Futuristic fonts with custom font families and weights
class FuturisticFonts {
  static const String fontFamily = 'Inter'; // Default font family

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );
}

/// Futuristic text styles with custom fonts and effects
class FuturisticTextStyles {
  static const TextStyle headline1 = TextStyle(
    color: FuturisticColors.textPrimary,
    fontWeight: FontWeight.w300,
    fontSize: 32,
    letterSpacing: -1.5,
    shadows: [
      Shadow(
        color: FuturisticColors.primary,
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ],
  );

  static const TextStyle headline2 = TextStyle(
    color: FuturisticColors.textPrimary,
    fontWeight: FontWeight.w300,
    fontSize: 28,
    letterSpacing: -0.5,
    shadows: [
      Shadow(
        color: FuturisticColors.secondary,
        blurRadius: 8,
        offset: Offset(0, 1),
      ),
    ],
  );

  static const TextStyle headline3 = TextStyle(
    color: FuturisticColors.textPrimary,
    fontWeight: FontWeight.w400,
    fontSize: 24,
    letterSpacing: 0,
  );

  static const TextStyle body1 = TextStyle(
    color: FuturisticColors.textPrimary,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: 0.5,
  );

  static const TextStyle body2 = TextStyle(
    color: FuturisticColors.textSecondary,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.25,
  );

  static const TextStyle button = TextStyle(
    color: FuturisticColors.textPrimary,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 1.25,
  );

  static const TextStyle caption = TextStyle(
    color: FuturisticColors.textSecondary,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.4,
  );
}

/// Futuristic theme data
class FuturisticTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: FuturisticColors.primary,
      scaffoldBackgroundColor: FuturisticColors.background,

      colorScheme: const ColorScheme.dark(
        primary: FuturisticColors.primary,
        secondary: FuturisticColors.secondary,
        tertiary: FuturisticColors.accent,
        surface: FuturisticColors.surface,
        error: FuturisticColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: FuturisticColors.textPrimary,
        onError: Colors.white,
      ),

      textTheme: TextTheme(
        displayLarge: FuturisticTextStyles.headline1,
        displayMedium: FuturisticTextStyles.headline2,
        displaySmall: FuturisticTextStyles.headline3,
        bodyLarge: FuturisticTextStyles.body1,
        bodyMedium: FuturisticTextStyles.body2,
        labelLarge: FuturisticTextStyles.button,
        bodySmall: FuturisticTextStyles.caption,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FuturisticColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      cardTheme: CardThemeData(
        color: FuturisticColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.transparent,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FuturisticColors.surfaceLight.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: FuturisticColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      primaryColor: FuturisticColors.primaryLight,
      scaffoldBackgroundColor: Colors.white,

      colorScheme: const ColorScheme.light(
        primary: FuturisticColors.primary,
        secondary: FuturisticColors.secondary,
        tertiary: FuturisticColors.accent,
        surface: Colors.white,
        error: FuturisticColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onError: Colors.white,
      ),

      textTheme: TextTheme(
        displayLarge: FuturisticTextStyles.headline1,
        displayMedium: FuturisticTextStyles.headline2,
        displaySmall: FuturisticTextStyles.headline3,
        bodyLarge: FuturisticTextStyles.body1,
        bodyMedium: FuturisticTextStyles.body2,
        labelLarge: FuturisticTextStyles.button,
        bodySmall: FuturisticTextStyles.caption,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FuturisticColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: FuturisticColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}
