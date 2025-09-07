import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/widgets/neumorphism_container.dart';
import 'package:gyanvruksh/utils/responsive_utils.dart';
import 'package:gyanvruksh/widgets/custom_animated_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = ColorTween(
      begin: const Color(0xFF667EEA),
      end: const Color(0xFF764BA2),
    ).animate(_backgroundController);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required int index,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GlassmorphismCard(
      width: double.infinity,
      height: 140,
      blurStrength: 20,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NeumorphismContainer(
                width: 60,
                height: 60,
                borderRadius: BorderRadius.circular(30),
                backgroundColor: color.withOpacity(0.1),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 600.ms,
          delay: Duration(milliseconds: index * 100),
        )
        .slideY(
          begin: 0.2,
          end: 0,
          duration: 500.ms,
          delay: Duration(milliseconds: index * 100),
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          delay: Duration(milliseconds: index * 100),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    // School-themed color palette
    final liveClassesColor = const Color(0xFF3C6EFA);
    final assignmentsColor = const Color(0xFFA58DF5);
    final clubsColor = const Color(0xFF26A69A);
    final progressTrackerColor = const Color(0xFFFF6B6B);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _backgroundAnimation.value ?? colorScheme.primary,
                  colorScheme.secondary,
                  colorScheme.tertiary,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      children: [
                        NeumorphismContainer(
                          width: 50,
                          height: 50,
                          borderRadius: BorderRadius.circular(25),
                          child: Icon(
                            FontAwesomeIcons.graduationCap,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back!',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Continue your learning journey',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onPrimary.withOpacity(0.8),
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

                  // Dashboard Grid
                  Expanded(
                    child: ResponsiveBuilder(
                      builder: (context, isMobile, isTablet, isDesktop) {
                        final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
                        final spacing = isMobile ? 16.0 : 20.0;

                        return Padding(
                          padding: EdgeInsets.all(spacing),
                          child: GridView.count(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                            children: [
                              _buildDashboardCard(
                                title: 'Live Classes',
                                icon: Icons.live_tv,
                                color: liveClassesColor,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Live Classes coming soon!'),
                                      backgroundColor: liveClassesColor,
                                    ),
                                  );
                                },
                                index: 0,
                              ),
                              _buildDashboardCard(
                                title: 'Assignments',
                                icon: Icons.assignment,
                                color: assignmentsColor,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Assignments coming soon!'),
                                      backgroundColor: assignmentsColor,
                                    ),
                                  );
                                },
                                index: 1,
                              ),
                              _buildDashboardCard(
                                title: 'Study Clubs',
                                icon: Icons.group,
                                color: clubsColor,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Study Clubs coming soon!'),
                                      backgroundColor: clubsColor,
                                    ),
                                  );
                                },
                                index: 2,
                              ),
                              _buildDashboardCard(
                                title: 'Progress',
                                icon: Icons.show_chart,
                                color: progressTrackerColor,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Progress Tracker coming soon!'),
                                      backgroundColor: progressTrackerColor,
                                    ),
                                  );
                                },
                                index: 3,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
