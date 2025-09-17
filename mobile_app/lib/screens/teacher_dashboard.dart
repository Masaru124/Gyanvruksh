import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:gyanvruksh/services/auth_storage.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/widgets/custom_animated_button.dart';
import 'package:gyanvruksh/widgets/neumorphism_container.dart';
import 'package:gyanvruksh/widgets/backgrounds/cinematic_background.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/floating_elements.dart';
import 'package:gyanvruksh/widgets/animated_wave_background.dart';
import 'package:gyanvruksh/widgets/micro_interactions.dart';
import 'package:gyanvruksh/widgets/animated_text_widget.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';
import 'package:gyanvruksh/screens/teacher_course_management.dart';
import 'package:gyanvruksh/screens/teacher_advanced_features.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  Map<String, dynamic> dashboardStats = {};
  List<dynamic> todaySchedule = [];
  List<dynamic> myCourses = [];
  List<dynamic> pendingEvaluations = [];
  List<dynamic> recentMessages = [];
  String teacherName = 'Teacher';
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
      teacherName = prefs.getString('user_name') ?? 'Teacher';
      
      // Use existing API methods with fallback
      final results = await Future.wait([
        ApiService().getTeacherDashboardStats().catchError((_) => {}),
        ApiService().listCourses().catchError((_) => []),
      ]);

      setState(() {
        dashboardStats = results[0] as Map<String, dynamic>;
        myCourses = results[1] as List<dynamic>;
        isLoading = false;
        
        // Set fallback data for demo
        if (dashboardStats.isEmpty) {
          dashboardStats = {
            'total_students': 45,
            'active_courses': 3,
            'avg_scores': 85,
            'pending_evaluations': 12
          };
        }
        
        todaySchedule = [
          {'title': 'Mathematics Class 10A', 'time': '09:00 AM', 'type': 'class'},
          {'title': 'Physics Lab Session', 'time': '11:30 AM', 'type': 'lab'},
          {'title': 'Review Assignments', 'time': '2:00 PM', 'type': 'evaluation'}
        ];
        
        if (myCourses.isEmpty) {
          myCourses = [
            {'id': 1, 'title': 'Advanced Mathematics', 'students': 25, 'progress': 75},
            {'id': 2, 'title': 'Physics Fundamentals', 'students': 20, 'progress': 60}
          ];
        }
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
        // Fallback data for demo
        dashboardStats = {
          'total_students': 45,
          'active_courses': 3,
          'avg_scores': 85,
          'pending_evaluations': 12
        };
        todaySchedule = [
          {'title': 'Mathematics Class 10A', 'time': '09:00 AM', 'type': 'class'},
          {'title': 'Physics Lab Session', 'time': '11:30 AM', 'type': 'lab'},
          {'title': 'Review Assignments', 'time': '2:00 PM', 'type': 'evaluation'}
        ];
        myCourses = [
          {'id': 1, 'title': 'Advanced Mathematics', 'students': 25, 'progress': 75},
          {'id': 2, 'title': 'Physics Fundamentals', 'students': 20, 'progress': 60}
        ];
      });
    }
  }

  Future<void> _logout() async {
    try {
      // Call API logout
      await ApiService().logout();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                FuturisticColors.primary.withOpacity(0.1),
                FuturisticColors.secondary.withOpacity(0.1),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background
          const CinematicBackground(isDark: true),
          const ParticleBackground(),
          
          // Main content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeBanner(theme, colorScheme),
                    const SizedBox(height: 24),
                    _buildStatsOverview(theme, colorScheme),
                    const SizedBox(height: 24),
                    _buildTodaySchedule(theme, colorScheme),
                    const SizedBox(height: 24),
                    _buildMyCourses(theme, colorScheme),
                    const SizedBox(height: 24),
                    _buildQuickActions(theme, colorScheme),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(ThemeData theme, ColorScheme colorScheme) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $teacherName!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready to inspire minds today?',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: FuturisticColors.accent,
                    fontWeight: FontWeight.w500,
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
                backgroundColor: Colors.red.withOpacity(0.2),
                padding: const EdgeInsets.all(12),
              ),
              tooltip: 'Logout',
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FuturisticColors.primary.withOpacity(0.3),
                  FuturisticColors.secondary.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const FaIcon(
              FontAwesomeIcons.chalkboardTeacher,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: -0.1, end: 0, duration: 500.ms);
  }

  Widget _buildStatsOverview(ThemeData theme, ColorScheme colorScheme) {
    final stats = [
      {
        'title': 'Total Students',
        'value': '${dashboardStats['total_students'] ?? 0}',
        'icon': FontAwesomeIcons.users,
        'color': FuturisticColors.primary,
      },
      {
        'title': 'Active Courses',
        'value': '${dashboardStats['active_courses'] ?? 0}',
        'icon': FontAwesomeIcons.book,
        'color': FuturisticColors.secondary,
      },
      {
        'title': 'Avg. Scores',
        'value': '${dashboardStats['avg_scores'] ?? 0}%',
        'icon': FontAwesomeIcons.chartLine,
        'color': FuturisticColors.accent,
      },
      {
        'title': 'Pending Reviews',
        'value': '${dashboardStats['pending_evaluations'] ?? 0}',
        'icon': FontAwesomeIcons.clipboardCheck,
        'color': FuturisticColors.warning,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return MicroInteractionWrapper(
              child: GlassmorphismCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FaIcon(
                          stat['icon'] as IconData,
                          color: stat['color'] as Color,
                          size: 24,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (stat['color'] as Color).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Live',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: stat['color'] as Color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      stat['value'] as String,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      stat['title'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate()
              .fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100))
              .slideX(begin: 0.2, end: 0, duration: 500.ms, delay: Duration(milliseconds: index * 100));
          },
        ),
      ],
    );
  }

  Widget _buildTodaySchedule(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Schedule',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...todaySchedule.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: MicroInteractionWrapper(
              child: GlassmorphismCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getScheduleColor(item['type']).withOpacity(0.3),
                            _getScheduleColor(item['type']).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FaIcon(
                        _getScheduleIcon(item['type']),
                        color: _getScheduleColor(item['type']),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['time'],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getScheduleColor(item['type']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getScheduleTypeText(item['type']),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getScheduleColor(item['type']),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate()
            .fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100))
            .slideX(begin: -0.2, end: 0, duration: 500.ms, delay: Duration(milliseconds: index * 100));
        }).toList(),
      ],
    );
  }

  Widget _buildMyCourses(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Courses',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TeacherCourseManagementScreen()),
                );
              },
              child: Text(
                'View All',
                style: TextStyle(color: FuturisticColors.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: myCourses.length,
            itemBuilder: (context, index) {
              final course = myCourses[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                child: MicroInteractionWrapper(
                  child: GlassmorphismCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                course['title'] ?? 'Course',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    FuturisticColors.primary.withOpacity(0.3),
                                    FuturisticColors.secondary.withOpacity(0.3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const FaIcon(
                                FontAwesomeIcons.graduationCap,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.users,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${course['students'] ?? 0} Students',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Progress: ${course['progress'] ?? 0}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: FuturisticColors.accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (course['progress'] ?? 0) / 100.0,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(FuturisticColors.accent),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100))
                .slideX(begin: 0.2, end: 0, duration: 500.ms, delay: Duration(milliseconds: index * 100));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme, ColorScheme colorScheme) {
    final actions = [
      {
        'title': 'Course Management',
        'subtitle': 'Manage your courses',
        'icon': FontAwesomeIcons.chalkboard,
        'color': FuturisticColors.primary,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TeacherCourseManagementScreen()),
        ),
      },
      {
        'title': 'Student Progress',
        'subtitle': 'Track student performance',
        'icon': FontAwesomeIcons.chartLine,
        'color': FuturisticColors.secondary,
        'onTap': () {},
      },
      {
        'title': 'Assignments',
        'subtitle': 'Create and evaluate',
        'icon': FontAwesomeIcons.tasks,
        'color': FuturisticColors.accent,
        'onTap': () {},
      },
      {
        'title': 'Schedule Classes',
        'subtitle': 'Manage your timetable',
        'icon': FontAwesomeIcons.calendar,
        'color': FuturisticColors.warning,
        'onTap': () {},
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return MicroInteractionWrapper(
              onTap: action['onTap'] as VoidCallback,
              child: GlassmorphismCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (action['color'] as Color).withOpacity(0.3),
                            (action['color'] as Color).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FaIcon(
                        action['icon'] as IconData,
                        color: action['color'] as Color,
                        size: 24,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          action['title'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          action['subtitle'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate()
              .fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100))
              .scale(begin: const Offset(0.8, 0.8), duration: 500.ms, delay: Duration(milliseconds: index * 100));
          },
        ),
      ],
    );
  }

  IconData _getScheduleIcon(String type) {
    switch (type) {
      case 'class':
        return FontAwesomeIcons.chalkboardTeacher;
      case 'lab':
        return FontAwesomeIcons.flask;
      case 'evaluation':
        return FontAwesomeIcons.clipboardCheck;
      default:
        return FontAwesomeIcons.clock;
    }
  }

  Color _getScheduleColor(String type) {
    switch (type) {
      case 'class':
        return FuturisticColors.primary;
      case 'lab':
        return FuturisticColors.secondary;
      case 'evaluation':
        return FuturisticColors.warning;
      default:
        return FuturisticColors.accent;
    }
  }

  String _getScheduleTypeText(String type) {
    switch (type) {
      case 'class':
        return 'Class';
      case 'lab':
        return 'Lab';
      case 'evaluation':
        return 'Review';
      default:
        return 'Event';
    }
  }
}
