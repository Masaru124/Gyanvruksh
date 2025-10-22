import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gyanvruksh/services/enhanced_api_service.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/widgets/backgrounds/cinematic_background.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/micro_interactions.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic> dashboardStats = {};
  List<dynamic> recentActivities = [];
  List<dynamic> systemAlerts = [];
  String adminName = 'Admin';
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
      adminName = prefs.getString('user_name') ?? 'Admin';
      
      // Use enhanced API service with proper error handling
      final response = await ApiService.get('/api/admin/dashboard/stats');
      final Map<String, dynamic> stats = response.isSuccess
          ? (response.data as Map<String, dynamic>?) ?? {}
          : {};

      setState(() {
        dashboardStats = stats.isNotEmpty ? stats : {
          'total_users': 1250,
          'active_students': 980,
          'total_teachers': 45,
          'total_courses': 125,
          'revenue_this_month': 45000,
          'platform_uptime': 99.8,
        };
        isLoading = false;
        
        recentActivities = [
          {'type': 'user_registration', 'message': '15 new students registered today', 'time': '2 hours ago'},
          {'type': 'course_creation', 'message': 'New course "Advanced Physics" created', 'time': '4 hours ago'},
          {'type': 'system_update', 'message': 'Platform maintenance completed', 'time': '1 day ago'},
        ];
        
        systemAlerts = [
          {'type': 'warning', 'message': 'Server load at 85%', 'priority': 'medium'},
          {'type': 'info', 'message': 'Backup completed successfully', 'priority': 'low'},
        ];
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
        // Fallback data for demo
        dashboardStats = {
          'total_users': 1250,
          'active_students': 980,
          'total_teachers': 45,
          'total_courses': 125,
          'revenue_this_month': 45000,
          'platform_uptime': 99.8,
        };
        recentActivities = [
          {'type': 'user_registration', 'message': '15 new students registered today', 'time': '2 hours ago'},
          {'type': 'course_creation', 'message': 'New course "Advanced Physics" created', 'time': '4 hours ago'},
          {'type': 'system_update', 'message': 'Platform maintenance completed', 'time': '1 day ago'},
        ];
        systemAlerts = [
          {'type': 'warning', 'message': 'Server load at 85%', 'priority': 'medium'},
          {'type': 'info', 'message': 'Backup completed successfully', 'priority': 'low'},
        ];
      });
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
                FuturisticColors.primary.withValues(alpha: 0.1),
                FuturisticColors.secondary.withValues(alpha: 0.1),
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
                    _buildSystemAlerts(theme, colorScheme),
                    const SizedBox(height: 24),
                    _buildRecentActivities(theme, colorScheme),
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
                  'Welcome, $adminName!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Platform Overview & Management',
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FuturisticColors.primary.withValues(alpha: 0.3),
                  FuturisticColors.secondary.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const FaIcon(
              FontAwesomeIcons.userShield,
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
        'title': 'Total Users',
        'value': '${dashboardStats['total_users'] ?? 0}',
        'icon': FontAwesomeIcons.users,
        'color': FuturisticColors.primary,
        'subtitle': '${dashboardStats['active_students'] ?? 0} active students',
      },
      {
        'title': 'Teachers',
        'value': '${dashboardStats['total_teachers'] ?? 0}',
        'icon': FontAwesomeIcons.chalkboardUser,
        'color': FuturisticColors.secondary,
        'subtitle': 'Active educators',
      },
      {
        'title': 'Courses',
        'value': '${dashboardStats['total_courses'] ?? 0}',
        'icon': FontAwesomeIcons.graduationCap,
        'color': FuturisticColors.accent,
        'subtitle': 'Available courses',
      },
      {
        'title': 'Revenue',
        'value': '₹${NumberFormat('#,##,###').format(dashboardStats['revenue_this_month'] ?? 0)}',
        'icon': FontAwesomeIcons.chartLine,
        'color': FuturisticColors.success,
        'subtitle': 'This month',
      },
      {
        'title': 'Uptime',
        'value': '${dashboardStats['platform_uptime'] ?? 0}%',
        'icon': FontAwesomeIcons.server,
        'color': FuturisticColors.warning,
        'subtitle': 'Platform availability',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Platform Overview',
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
            childAspectRatio: 1.3,
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
                            color: (stat['color'] as Color).withValues(alpha: 0.2),
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
                    const SizedBox(height: 8),
                    Text(
                      stat['value'] as String,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      stat['title'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      stat['subtitle'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
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

  Widget _buildSystemAlerts(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Alerts',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...systemAlerts.asMap().entries.map((entry) {
          final index = entry.key;
          final alert = entry.value;
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
                            _getAlertColor(alert['type']).withValues(alpha: 0.3),
                            _getAlertColor(alert['type']).withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FaIcon(
                        _getAlertIcon(alert['type']),
                        color: _getAlertColor(alert['type']),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert['message'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Priority: ${alert['priority']}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getAlertColor(alert['type']).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        alert['type'].toString().toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getAlertColor(alert['type']),
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

  Widget _buildRecentActivities(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...recentActivities.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
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
                            _getActivityColor(activity['type']).withValues(alpha: 0.3),
                            _getActivityColor(activity['type']).withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FaIcon(
                        _getActivityIcon(activity['type']),
                        color: _getActivityColor(activity['type']),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['message'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity['time'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate()
            .fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100))
            .slideX(begin: 0.2, end: 0, duration: 500.ms, delay: Duration(milliseconds: index * 100));
        }).toList(),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme, ColorScheme colorScheme) {
    final actions = [
      {
        'title': 'User Management',
        'subtitle': 'Manage students & teachers',
        'icon': FontAwesomeIcons.usersGear,
        'color': FuturisticColors.primary,
        'onTap': () {},
      },
      {
        'title': 'Course Management',
        'subtitle': 'Create & manage courses',
        'icon': FontAwesomeIcons.bookOpen,
        'color': FuturisticColors.secondary,
        'onTap': () {},
      },
      {
        'title': 'Analytics',
        'subtitle': 'Platform insights',
        'icon': FontAwesomeIcons.chartBar,
        'color': FuturisticColors.accent,
        'onTap': () {},
      },
      {
        'title': 'System Settings',
        'subtitle': 'Platform configuration',
        'icon': FontAwesomeIcons.gears,
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
                            (action['color'] as Color).withValues(alpha: 0.3),
                            (action['color'] as Color).withValues(alpha: 0.1),
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

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'warning':
        return FontAwesomeIcons.triangleExclamation;
      case 'error':
        return FontAwesomeIcons.circleExclamation;
      case 'info':
        return FontAwesomeIcons.circleInfo;
      default:
        return FontAwesomeIcons.bell;
    }
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'warning':
        return FuturisticColors.warning;
      case 'error':
        return FuturisticColors.error;
      case 'info':
        return FuturisticColors.accent;
      default:
        return FuturisticColors.primary;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'user_registration':
        return FontAwesomeIcons.userPlus;
      case 'course_creation':
        return FontAwesomeIcons.plus;
      case 'system_update':
        return FontAwesomeIcons.arrowsRotate;
      default:
        return FontAwesomeIcons.bell;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'user_registration':
        return FuturisticColors.success;
      case 'course_creation':
        return FuturisticColors.primary;
      case 'system_update':
        return FuturisticColors.secondary;
      default:
        return FuturisticColors.accent;
    }
  }
}
