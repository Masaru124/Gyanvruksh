import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/widgets/neumorphism_container.dart';
import 'package:gyanvruksh/widgets/backgrounds/cinematic_background.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/floating_elements.dart';
import 'package:gyanvruksh/widgets/animated_wave_background.dart';
import 'package:gyanvruksh/widgets/micro_interactions.dart';
import 'package:gyanvruksh/widgets/glowing_button.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';
import 'package:gyanvruksh/screens/login.dart';
import 'manage_users.dart';
import 'create_course.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundAnimation;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = ColorTween(
      begin: const Color(0xFF667EEA),
      end: const Color(0xFF764BA2),
    ).animate(_backgroundController);

    _loadStats();
  }

  Future<void> _loadStats() async {
    // Mock data for demonstration
    setState(() {
      _stats = {
        'total_users': 1250,
        'active_courses': 45,
        'total_revenue': 15750,
        'new_signups': 23,
      };
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
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
            particleCount: 35,
            maxParticleSize: 5.0,
            particleColor: FuturisticColors.primary,
          ),

          // Floating Elements
          FloatingElements(
            elementCount: 10,
            maxElementSize: 50,
            icons: const [
              Icons.admin_panel_settings,
              Icons.people,
              Icons.school,
              Icons.analytics,
              Icons.settings,
              Icons.security,
              Icons.dashboard,
              Icons.trending_up,
              Icons.notifications,
              Icons.report,
            ],
          ),

          // Animated Wave Background
          AnimatedWaveBackground(
            color: FuturisticColors.neonPurple.withOpacity(0.04),
            height: MediaQuery.of(context).size.height,
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Header with Glassmorphism
                  GlassmorphismCard(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(20),
                    blurStrength: 15,
                    opacity: 0.1,
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      children: [
                        MicroInteractionWrapper(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  FuturisticColors.primary,
                                  FuturisticColors.secondary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: FuturisticColors.primary.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Icon(
                              FontAwesomeIcons.crown,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Admin Dashboard',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: FuturisticColors.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage your learning platform',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.2, end: 0, duration: 500.ms),

                  const SizedBox(height: 32),

                  // Stats Cards
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildStatCard(
                        'Total Users',
                        _stats['total_users']?.toString() ?? '0',
                        FontAwesomeIcons.users,
                        colorScheme.primary,
                      ),
                      _buildStatCard(
                        'Active Courses',
                        _stats['active_courses']?.toString() ?? '0',
                        FontAwesomeIcons.bookOpen,
                        colorScheme.secondary,
                      ),
                      _buildStatCard(
                        'Total Revenue',
                        '\$${_stats['total_revenue']?.toString() ?? '0'}',
                        FontAwesomeIcons.dollarSign,
                        colorScheme.tertiary,
                      ),
                      _buildStatCard(
                        'New Signups',
                        _stats['new_signups']?.toString() ?? '0',
                        FontAwesomeIcons.userPlus,
                        colorScheme.error,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildActionCard(
                        'Create Course',
                        FontAwesomeIcons.plus,
                        colorScheme.primary,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateCourseScreen(),
                          ),
                        ),
                      ),
                      _buildActionCard(
                        'Manage Users',
                        FontAwesomeIcons.usersCog,
                        colorScheme.secondary,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageUsersScreen(),
                          ),
                        ),
                      ),
                      _buildActionCard(
                        'View Reports',
                        FontAwesomeIcons.chartBar,
                        colorScheme.tertiary,
                        () {
                          // Navigate to reports
                        },
                      ),
                      _buildActionCard(
                        'Settings',
                        FontAwesomeIcons.cog,
                        colorScheme.surfaceContainerHighest,
                        () {
                          // Navigate to settings
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Recent Activity
                  GlassmorphismCard(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    blurStrength: 15,
                    opacity: 0.1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Activity',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActivityItem(
                          'New user registered',
                          'John Doe joined the platform',
                          '2 hours ago',
                        ),
                        const SizedBox(height: 12),
                        _buildActivityItem(
                          'Course created',
                          'Advanced Flutter Development course added',
                          '4 hours ago',
                        ),
                        const SizedBox(height: 12),
                        _buildActivityItem(
                          'Payment received',
                          'Payment of \$49.99 from Jane Smith',
                          '6 hours ago',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Logout Button
                  Center(
                    child: GlowingButton(
                      onPressed: () async {
                        final success = await ApiService().logout();
                        if (success) {
                          if (!mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Logout failed')),
                          );
                        }
                      },
                      width: 200,
                      height: 50,
                      child: Text(
                        'Logout',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GlassmorphismCard(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      blurStrength: 10,
      opacity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0, duration: 600.ms);
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return NeumorphismContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      depth: 8,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), duration: 600.ms);
  }

  Widget _buildActivityItem(String title, String subtitle, String time) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
