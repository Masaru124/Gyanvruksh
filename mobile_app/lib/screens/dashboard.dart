import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ShimmerEffect;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gyanvruksh/widgets/enhanced_futuristic_card.dart';
import 'package:gyanvruksh/widgets/animated_text_widget.dart';
import 'package:gyanvruksh/widgets/particle_effect.dart';
import 'package:gyanvruksh/widgets/theme_switch_widget.dart';
import 'package:gyanvruksh/widgets/backgrounds/cinematic_background.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/floating_elements.dart';
import 'package:gyanvruksh/widgets/glowing_button.dart';
import 'package:gyanvruksh/widgets/animated_wave_background.dart';
import 'package:gyanvruksh/widgets/micro_interactions.dart';
import 'package:gyanvruksh/blocs/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gyanvruksh/utils/responsive_utils.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';

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

    return MicroInteractionWrapper(
      onTap: onTap,
      glowColor: color,
      child: HoverEffectWrapper(
        hoverColor: color,
        child: EnhancedFuturisticCard(
          width: double.infinity,
          height: 140,
          onTap: null, // Remove onTap since we handle it in MicroInteractionWrapper
          enableGlow: true,
          enableHover: true,
          glowColor: color,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BreathingEffect(
                  duration: const Duration(seconds: 3),
                  minOpacity: 0.8,
                  maxOpacity: 1.0,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 300.ms,
                      delay: Duration(milliseconds: index * 100 + 200),
                    )
                    .rotate(
                      begin: -0.2,
                      end: 0,
                      duration: 400.ms,
                      delay: Duration(milliseconds: index * 100 + 200),
                    ),
                const SizedBox(height: 12),
                ShimmerEffect(
                  duration: const Duration(seconds: 4),
                  shimmerColor: color,
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
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

    // Enhanced color palette with neon accents
    final liveClassesColor = FuturisticColors.neonBlue;
    final assignmentsColor = FuturisticColors.neonPurple;
    final clubsColor = FuturisticColors.neonGreen;
    final progressTrackerColor = FuturisticColors.neonPink;

    return Scaffold(
      body: Stack(
        children: [
          // Cinematic Background
          CinematicBackground(isDark: false),

          // Enhanced Particle Background
          ParticleBackground(
            particleCount: 40,
            maxParticleSize: 6.0,
            particleColor: FuturisticColors.primary,
          ),

          // Floating Elements
          FloatingElements(
            elementCount: 12,
            maxElementSize: 80,
            icons: const [
              Icons.school,
              Icons.book,
              Icons.lightbulb,
              Icons.psychology,
              Icons.computer,
              Icons.science,
              Icons.calculate,
              Icons.language,
              Icons.assignment,
              Icons.group,
              Icons.show_chart,
              Icons.live_tv,
            ],
          ),

          // Animated Wave Background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedWaveBackground(
              color: FuturisticColors.primary.withOpacity(0.3),
              height: 150,
              speed: 0.8,
              waveHeight: 15,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Enhanced Header Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    children: [
                      // Enhanced futuristic icon container
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              FuturisticColors.primary,
                              FuturisticColors.secondary,
                              FuturisticColors.accent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: FuturisticColors.primary.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: FuturisticColors.neonBlue.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          FontAwesomeIcons.graduationCap,
                          color: Colors.white,
                          size: 28,
                        ),
                      )
                          .animate()
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.0, 1.0),
                            duration: 500.ms,
                          )
                          .rotate(begin: -0.2, end: 0, duration: 600.ms),

                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back!',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: FuturisticColors.primary.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Continue your learning journey',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Enhanced Theme switch
                      BlocBuilder<ThemeBloc, ThemeState>(
                        builder: (context, state) {
                          return ThemeSwitchWidget(
                            isDark: state.isDark,
                            onChanged: (isDark) {
                              context.read<ThemeBloc>().add(ToggleTheme());
                            },
                          );
                        },
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2, end: 0, duration: 500.ms),

                // Enhanced Dashboard Grid
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

                // Quick Actions Bar with Glowing Buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildGlowingQuickActionButton(
                        icon: Icons.notifications,
                        label: 'Alerts',
                        color: FuturisticColors.neonBlue,
                        onTap: () {},
                      ),
                      _buildGlowingQuickActionButton(
                        icon: Icons.calendar_today,
                        label: 'Schedule',
                        color: FuturisticColors.neonPurple,
                        onTap: () {},
                      ),
                      _buildGlowingQuickActionButton(
                        icon: Icons.message,
                        label: 'Messages',
                        color: FuturisticColors.neonGreen,
                        onTap: () {},
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 800.ms)
                    .slideY(begin: 0.2, end: 0, duration: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
        );
  }

  Widget _buildGlowingQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlowingButton(
          onPressed: onTap,
          width: 60,
          height: 60,
          borderRadius: BorderRadius.circular(30),
          child: Icon(
            icon,
            color: colorScheme.onSurface,
            size: 28,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
