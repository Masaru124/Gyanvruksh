import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gyanvruksh/services/enhanced_api_service.dart';
import 'package:gyanvruksh/services/auth_storage.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/widgets/backgrounds/cinematic_background.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/floating_elements.dart';
import 'package:gyanvruksh/widgets/animated_wave_background.dart';
import 'package:gyanvruksh/widgets/micro_interactions.dart';
import 'package:gyanvruksh/widgets/animated_text_widget.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';
import 'package:gyanvruksh/screens/courses_screen.dart';
import 'package:gyanvruksh/screens/assignments_quizzes_screen.dart';
import 'package:gyanvruksh/screens/progress_tracker_screen.dart';
import 'package:gyanvruksh/screens/talent_wall_screen.dart';
import 'package:gyanvruksh/screens/notifications_screen.dart';
import 'package:gyanvruksh/screens/settings_profile_screen.dart';
import 'package:intl/intl.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Map<String, dynamic> dashboardData = {};
  List<dynamic> todaySchedule = [];
  List<dynamic> courses = [];
  List<dynamic> assignments = [];
  Map<String, dynamic> learningStreak = {};
  String userName = 'Student';
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      userName = prefs.getString('user_name') ?? 'Student';
      
      final results = await Future.wait([
        ApiService.getStudentDashboard(),
        ApiService.get('/api/student/schedule/today'),
        ApiService.listCourses(),
        ApiService.get('/api/student/assignments'),
        ApiService.get('/api/gamification/streak'),
      ]);

      setState(() {
        dashboardData = results[0].isSuccess ? (results[0].data as Map<String, dynamic>?) ?? {} : {};
        todaySchedule = results[1].isSuccess ? (results[1].data as List<dynamic>?) ?? [] : [];
        courses = results[2].isSuccess ? (results[2].data as List<dynamic>?) ?? [] : [];
        assignments = results[3].isSuccess ? (results[3].data as List<dynamic>?) ?? [] : [];
        learningStreak = results[4].isSuccess ? (results[4].data as Map<String, dynamic>?) ?? {} : {};
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
        // Fallback data for demo
        dashboardData = {
          'enrolled_courses': 5,
          'completed_courses': 2,
          'total_study_hours': 45,
          'current_streak': 7
        };
        todaySchedule = [
          {'title': 'Mathematics Class', 'time': '10:00 AM', 'type': 'live_class'},
          {'title': 'Physics Assignment', 'time': '2:00 PM', 'type': 'assignment'},
          {'title': 'Code Practice', 'time': '4:00 PM', 'type': 'practice'}
        ];
        learningStreak = {'current_streak': 7, 'longest_streak': 15};
      });
    }
  }

  Future<void> _logout() async {
    try {
      // Call API logout
      await ApiService.logout();
      // Clear local auth data
      await AuthStorage.clearAuthData();
      
      // Navigate to login screen and clear navigation stack
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Even if API call fails, clear local data and logout
      await AuthStorage.clearAuthData();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  void _navigateToScreen(String route) {
    switch (route) {
      case 'courses':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CoursesScreen()),
        );
        break;
      case 'assignments':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AssignmentsQuizzesScreen()),
        );
        break;
      case 'progress':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProgressTrackerScreen()),
        );
        break;
      case 'talent_wall':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TalentWallScreen()),
        );
        break;
      case 'notifications':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationsScreen()),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Cinematic Background
          CinematicBackground(isDark: false),

          // Enhanced Particle Background
          ParticleBackground(
            particleCount: 30,
            maxParticleSize: 4.0,
            particleColor: FuturisticColors.primary,
          ),

          // Floating Elements
          FloatingElements(
            elementCount: 8,
            maxElementSize: 45,
            icons: const [
              Icons.school,
              Icons.people,
              Icons.assignment,
              Icons.grade,
              Icons.class_,
              Icons.question_answer,
              Icons.calendar_today,
              Icons.trending_up,
            ],
          ),

          // Animated Wave Background
          AnimatedWaveBackground(
            color: FuturisticColors.neonBlue.withValues(alpha: 0.04),
            height: MediaQuery.of(context).size.height,
          ),

          SafeArea(
            child: Column(
              children: [
                // Welcome Banner
                _buildWelcomeBanner(),
                const SizedBox(height: 20),

                // Main Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadDashboardData,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Today's Schedule
                          _buildTodaySchedule(),
                          const SizedBox(height: 20),
                          
                          // Learning Streak
                          _buildLearningStreak(),
                          const SizedBox(height: 20),
                          
                          // Course Progress
                          _buildCourseProgress(),
                          const SizedBox(height: 20),
                          
                          // Quick Access Buttons
                          _buildQuickAccess(),
                          const SizedBox(height: 20),
                          
                          // Recent Activity
                          _buildRecentActivity(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),

                // Quick Navigation Bar
                _buildQuickNavigationBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Good Morning' : now.hour < 17 ? 'Good Afternoon' : 'Good Evening';
    
    return GlassmorphismCard(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [FuturisticColors.primary, FuturisticColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.waving_hand, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $userName!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ready to continue your learning journey?',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Logout Button
              MicroInteractionWrapper(
                child: IconButton(
                  onPressed: _logout,
                  icon: const Icon(
                    FontAwesomeIcons.rightFromBracket,
                    color: Colors.white,
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.2),
                    padding: const EdgeInsets.all(12),
                  ),
                  tooltip: 'Logout',
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0, duration: 500.ms);
  }

  Widget _buildTodaySchedule() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.today, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              const Text(
                "Today's Schedule",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM dd').format(DateTime.now()),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (todaySchedule.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No classes scheduled for today',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            ...todaySchedule.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    width: 4,
                    color: _getScheduleColor(item['type']),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getScheduleIcon(item['type']),
                    color: _getScheduleColor(item['type']),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] ?? 'Unknown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          item['time'] ?? '',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getScheduleColor(item['type']).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getScheduleLabel(item['type']),
                      style: TextStyle(
                        color: _getScheduleColor(item['type']),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildLearningStreak() {
    final currentStreak = learningStreak['current_streak'] ?? 0;
    final longestStreak = learningStreak['longest_streak'] ?? 0;
    
    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FuturisticColors.neonGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: FuturisticColors.neonGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Learning Streak',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$currentStreak',
                        style: TextStyle(
                          color: FuturisticColors.neonGreen,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Current Streak',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$longestStreak',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Best Streak',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStreakCalendar(),
        ],
      ),
    );
  }

  Widget _buildCourseProgress() {
    final enrolledCourses = dashboardData['enrolled_courses'] ?? courses.length;
    final completedCourses = dashboardData['completed_courses'] ?? 0;
    final totalStudyHours = dashboardData['total_study_hours'] ?? 0;
    
    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Course Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  'Enrolled',
                  '$enrolledCourses',
                  Icons.book_outlined,
                  FuturisticColors.neonBlue,
                ),
              ),
              Expanded(
                child: _buildProgressItem(
                  'Completed',
                  '$completedCourses',
                  Icons.check_circle_outline,
                  FuturisticColors.neonGreen,
                ),
              ),
              Expanded(
                child: _buildProgressItem(
                  'Study Hours',
                  '${totalStudyHours}h',
                  Icons.access_time,
                  FuturisticColors.neonPurple,
                ),
              ),
            ],
          ),
          if (courses.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Recent Courses',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...courses.take(2).map((course) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: FuturisticColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.play_circle_outline,
                      color: FuturisticColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course['title'] ?? 'Unknown Course',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Progress: ${course['progress'] ?? 0}%',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 16,
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickAccess() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Quick Access',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessButton(
                  'Join Live Class',
                  Icons.video_call,
                  FuturisticColors.neonBlue,
                  () => _navigateToScreen('courses'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessButton(
                  'Continue Course',
                  Icons.play_circle_filled,
                  FuturisticColors.neonGreen,
                  () => _navigateToScreen('courses'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessButton(
                  'Revise',
                  Icons.refresh,
                  FuturisticColors.neonPurple,
                  () => _navigateToScreen('progress'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessButton(
                  'Assignments',
                  Icons.assignment,
                  FuturisticColors.neonPink,
                  () => _navigateToScreen('assignments'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.history, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _navigateToScreen('progress'),
                child: const Text(
                  'View All',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (assignments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No recent activity',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            ...assignments.take(3).map((activity) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getActivityColor(activity['type']).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getActivityIcon(activity['type']),
                      color: _getActivityColor(activity['type']),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'] ?? 'Unknown Activity',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          activity['description'] ?? 'No description',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    activity['time'] ?? '',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildQuickNavigationBar() {
    return GlassmorphismCard(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.school, 'Courses', () => _navigateToScreen('courses')),
          _buildNavItem(Icons.assignment, 'Assignments', () => _navigateToScreen('assignments')),
          _buildNavItem(Icons.trending_up, 'Progress', () => _navigateToScreen('progress')),
          _buildNavItem(Icons.star, 'Talent Wall', () => _navigateToScreen('talent_wall')),
          _buildNavItem(Icons.notifications, 'Alerts', () => _navigateToScreen('notifications')),
          _buildNavItem(Icons.settings, 'Settings', () => _navigateToScreen('settings')),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2, end: 0, duration: 500.ms);
  }

  // Helper methods
  Widget _buildProgressItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return MicroInteractionWrapper(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap) {
    return MicroInteractionWrapper(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCalendar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            'This Week',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final isActive = index < (learningStreak['current_streak'] ?? 0);
              return Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isActive ? FuturisticColors.neonGreen : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Helper methods for schedule items
  Color _getScheduleColor(String? type) {
    switch (type) {
      case 'live_class': return FuturisticColors.neonBlue;
      case 'assignment': return FuturisticColors.neonPink;
      case 'practice': return FuturisticColors.neonGreen;
      default: return FuturisticColors.neonPurple;
    }
  }

  IconData _getScheduleIcon(String? type) {
    switch (type) {
      case 'live_class': return Icons.video_call;
      case 'assignment': return Icons.assignment;
      case 'practice': return Icons.code;
      default: return Icons.book;
    }
  }

  String _getScheduleLabel(String? type) {
    switch (type) {
      case 'live_class': return 'LIVE';
      case 'assignment': return 'DUE';
      case 'practice': return 'PRACTICE';
      default: return 'STUDY';
    }
  }

  // Helper methods for activity items
  Color _getActivityColor(String? type) {
    switch (type) {
      case 'completed': return FuturisticColors.neonGreen;
      case 'assignment': return FuturisticColors.neonPink;
      case 'quiz': return FuturisticColors.neonBlue;
      default: return FuturisticColors.neonPurple;
    }
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'completed': return Icons.check_circle;
      case 'assignment': return Icons.assignment_turned_in;
      case 'quiz': return Icons.quiz;
      default: return Icons.book;
    }
  }
}
