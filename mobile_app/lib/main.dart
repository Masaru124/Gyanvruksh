import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gyanvruksh/screens/splash_screen.dart';
import 'package:gyanvruksh/blocs/theme_bloc.dart';
import 'package:gyanvruksh/viewmodels/personalization_viewmodel.dart';
import 'package:gyanvruksh/viewmodels/progress_viewmodel.dart';
import 'package:gyanvruksh/utils/responsive_utils.dart';
import 'package:gyanvruksh/theme/app_theme.dart';
import 'package:gyanvruksh/theme/theme_provider.dart';
// Import all screen widgets
import 'package:gyanvruksh/screens/login.dart';
import 'package:gyanvruksh/screens/onboarding_screen.dart';
import 'package:gyanvruksh/screens/dashboard.dart';
import 'package:gyanvruksh/screens/role_selection.dart';
import 'package:gyanvruksh/screens/admin_dashboard.dart';
import 'package:gyanvruksh/screens/student_dashboard.dart';
import 'package:gyanvruksh/screens/teacher_dashboard.dart';
import 'package:gyanvruksh/screens/courses_screen.dart';
import 'package:gyanvruksh/screens/profile_screen.dart';
import 'package:gyanvruksh/screens/chatroom_screen.dart';
import 'package:gyanvruksh/screens/leaderboard_screen.dart';
import 'package:gyanvruksh/screens/messages_screen.dart';
import 'package:gyanvruksh/screens/create_course.dart';
import 'package:gyanvruksh/screens/manage_courses.dart';
import 'package:gyanvruksh/screens/manage_users.dart';
import 'package:gyanvruksh/screens/create_admin.dart';
import 'package:gyanvruksh/screens/skill_tree_screen.dart';
import 'package:gyanvruksh/screens/progress_dashboard_screen.dart';
import 'package:gyanvruksh/screens/lesson_screen.dart';
import 'package:gyanvruksh/screens/register.dart';
import 'package:gyanvruksh/screens/sub_role_selection.dart';
import 'package:gyanvruksh/screens/video_player_screen.dart';
import 'package:gyanvruksh/screens/navigation.dart';
import 'package:gyanvruksh/screens/student_features.dart';
import 'package:gyanvruksh/screens/teacher_advanced_features.dart';
import 'package:gyanvruksh/screens/teacher_course_management.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PersonalizationViewModel()),
        ChangeNotifierProvider(create: (_) => ProgressViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        BlocProvider(create: (_) => ThemeBloc()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Update system UI overlay based on theme
          final brightness = themeProvider.isDarkMode ? Brightness.light : Brightness.dark;
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
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/dashboard': (context) => const DashboardScreen(),

              '/role_selection': (context) => const RoleSelectionScreen(),
              '/admin_dashboard': (context) => const AdminDashboard(),
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

              // New screens added
              '/skill_tree': (context) => const SkillTreeScreen(),
              '/progress_dashboard': (context) => const ProgressDashboardScreen(),
              '/lesson': (context) => LessonScreen(lessonId: 0),
              '/register': (context) => RegisterScreen(role: '', subRole: ''),
              '/sub_role_selection': (context) => SubRoleSelectionScreen(selectedRole: ''),
              '/video_player': (context) => VideoPlayerScreen(courseId: 0, courseTitle: ''),
              '/navigation': (context) => NavigationScreen(user: {}),
              '/student_features': (context) => const StudentFeaturesScreen(),
              '/teacher_advanced_features': (context) => const TeacherAdvancedFeaturesScreen(),
              '/teacher_course_management': (context) => const TeacherCourseManagementScreen(),
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

}
