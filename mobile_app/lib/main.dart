import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gyanvruksh/screens/splash_screen.dart';
import 'package:gyanvruksh/blocs/theme_bloc.dart';
import 'package:gyanvruksh/utils/responsive_utils.dart';

// Import all screen widgets
import 'package:gyanvruksh/screens/login.dart';
import 'package:gyanvruksh/screens/onboarding_screen.dart';
import 'package:gyanvruksh/screens/dashboard.dart';
import 'package:gyanvruksh/screens/navigation.dart';
import 'package:gyanvruksh/screens/register.dart';
import 'package:gyanvruksh/screens/role_selection.dart';
import 'package:gyanvruksh/screens/admin_dashboard.dart';
import 'package:gyanvruksh/screens/student_dashboard.dart';
import 'package:gyanvruksh/screens/teacher_dashboard.dart';
import 'package:gyanvruksh/screens/courses_screen.dart';
import 'package:gyanvruksh/screens/profile_screen.dart';
import 'package:gyanvruksh/screens/chatroom_screen.dart';
import 'package:gyanvruksh/screens/leaderboard_screen.dart';
import 'package:gyanvruksh/screens/messages_screen.dart';
import 'package:gyanvruksh/screens/video_player_screen.dart';
import 'package:gyanvruksh/screens/create_course.dart';
import 'package:gyanvruksh/screens/manage_courses.dart';
import 'package:gyanvruksh/screens/manage_users.dart';
import 'package:gyanvruksh/screens/create_admin.dart';
import 'package:gyanvruksh/screens/sub_role_selection.dart';

void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const GyanvrukshApp());
}

class GyanvrukshApp extends StatelessWidget {
  const GyanvrukshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          // Update system UI overlay based on theme
          final brightness = state.isDark ? Brightness.light : Brightness.dark;
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: brightness,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: brightness,
            ),
          );

          return MaterialApp(
            title: 'Gyanvruksh',
            debugShowCheckedModeBanner: false,
            theme: state.isDark ? _buildDarkTheme() : _buildLightTheme(),
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/dashboard': (context) => const DashboardScreen(),

              '/role_selection': (context) => const RoleSelectionScreen(),
              '/admin_dashboard': (context) => const AdminDashboardScreen(),
              '/student_dashboard': (context) => const StudentDashboard(),
              '/teacher_dashboard': (context) => const TeacherDashboard(),
              '/courses': (context) => const CoursesScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/chatroom': (context) => const ChatroomScreen(),
              '/leaderboard': (context) => const LeaderboardScreen(),
              '/messages': (context) => const MessagesScreen(),
              '/create_course': (context) => const CreateCourseScreen(),
              '/manage_courses': (context) => const ManageCoursesScreen(),
              '/manage_users': (context) => const ManageUsersScreen(),
              '/create_admin': (context) => const CreateAdminScreen(),
            },
            builder: (context, child) {
              return ResponsiveBuilder(
                builder: (context, isMobile, isTablet, isDesktop) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(ResponsiveUtils.getResponsiveValue(
                        context: context,
                        mobile: 1.0,
                        tablet: 1.1,
                        desktop: 1.2,
                      )),
                    ),
                    child: child!,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    final base = ThemeData.light(useMaterial3: true);

    // Futuristic color palette with vibrant gradients and modern aesthetics
    final colorScheme = const ColorScheme.light(
      primary: Color(0xFF6366F1), // Electric indigo
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE0E7FF),
      onPrimaryContainer: Color(0xFF312E81),

      secondary: Color(0xFF8B5CF6), // Vibrant purple
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFF3E8FF),
      onSecondaryContainer: Color(0xFF581C87),

      tertiary: Color(0xFF06B6D4), // Cyan accent
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFECFEFF),
      onTertiaryContainer: Color(0xFF164E63),

      error: Color(0xFFEF4444),
      onError: Colors.white,
      errorContainer: Color(0xFFFEE2E2),
      onErrorContainer: Color(0xFF991B1B),

      surface: Color(0xFFFEFEFE),
      onSurface: Color(0xFF0F172A),
      surfaceContainerHighest: Color(0xFFF8FAFC),
      onSurfaceVariant: Color(0xFF475569),

      outline: Color(0xFFCBD5E1),
      outlineVariant: Color(0xFFE2E8F0),

      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),

      inverseSurface: Color(0xFF0F172A),
      onInverseSurface: Color(0xFFF8FAFC),
      inversePrimary: Color(0xFFA5B4FC),

      surfaceTint: Color(0xFF6366F1),
    );

    return base.copyWith(
      colorScheme: colorScheme,

      // Modern typography with Google Fonts
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          height: 1.12,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.16,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.22,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.25,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.29,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.33,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.27,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.33,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.45,
        ),
      ),

      // Modern card design
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.surface,
        shadowColor: colorScheme.shadow.withOpacity(0.08),
      ),

      // Modern button styles
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),

      // Modern input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Modern app bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // Modern bottom navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Modern floating action button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData.dark(useMaterial3: true);

    // Futuristic dark theme color palette with neon accents
    final colorScheme = const ColorScheme.dark(
      primary: Color(0xFFA5B4FC), // Electric blue
      onPrimary: Color(0xFF1E1B4B),
      primaryContainer: Color(0xFF6366F1),
      onPrimaryContainer: Color(0xFFE0E7FF),

      secondary: Color(0xFFC4B5FD), // Neon purple
      onSecondary: Color(0xFF581C87),
      secondaryContainer: Color(0xFF8B5CF6),
      onSecondaryContainer: Color(0xFFF3E8FF),

      tertiary: Color(0xFF67E8F9), // Electric cyan
      onTertiary: Color(0xFF164E63),
      tertiaryContainer: Color(0xFF06B6D4),
      onTertiaryContainer: Color(0xFFECFEFF),

      error: Color(0xFFFCA5A5),
      onError: Color(0xFF991B1B),
      errorContainer: Color(0xFFEF4444),
      onErrorContainer: Color(0xFFFEE2E2),

      surface: Color(0xFF0F0F23),
      onSurface: Color(0xFFF1F5F9),
      surfaceContainerHighest: Color(0xFF1E1B4B),
      onSurfaceVariant: Color(0xFF94A3B8),

      outline: Color(0xFF475569),
      outlineVariant: Color(0xFF334155),

      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),

      inverseSurface: Color(0xFFF8FAFC),
      onInverseSurface: Color(0xFF0F0F23),
      inversePrimary: Color(0xFF6366F1),

      surfaceTint: Color(0xFFA5B4FC),
    );

    return base.copyWith(
      colorScheme: colorScheme,

      // Same typography for dark theme
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          height: 1.12,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.16,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.22,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.25,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.29,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.33,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.27,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.33,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.45,
        ),
      ),

      // Modern card design for dark theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.surface,
        shadowColor: colorScheme.shadow.withOpacity(0.12),
      ),

      // Modern button styles for dark theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),

      // Modern input decoration for dark theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Modern app bar for dark theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // Modern bottom navigation for dark theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Modern floating action button for dark theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
