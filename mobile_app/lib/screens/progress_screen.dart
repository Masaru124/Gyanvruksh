import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:gyanvruksh/viewmodels/progress_viewmodel.dart';
import 'package:gyanvruksh/widgets/enhanced_futuristic_card.dart';
import 'package:gyanvruksh/widgets/loading_states.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';
import 'package:gyanvruksh/widgets/backgrounds/cinematic_background.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/floating_elements.dart';
import 'package:gyanvruksh/widgets/animated_wave_background.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = ColorTween(
      begin: FuturisticColors.primary,
      end: FuturisticColors.secondary,
    ).animate(_backgroundController);

    // Load progress data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressViewModel>().initialize();
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Cinematic Background
          CinematicBackground(isDark: false),

          // Particle Background
          ParticleBackground(
            particleCount: 30,
            maxParticleSize: 5.0,
            particleColor: FuturisticColors.neonPink,
          ),

          // Floating Elements
          FloatingElements(
            elementCount: 8,
            maxElementSize: 60,
            icons: [
              Icons.show_chart,
              Icons.trending_up,
              Icons.star,
              Icons.emoji_events,
              Icons.timeline,
              Icons.bar_chart,
              Icons.pie_chart,
              Icons.analytics,
            ],
          ),

          // Animated Wave Background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedWaveBackground(
              color: FuturisticColors.neonPink.withOpacity(0.2),
              height: 120,
              speed: 1.0,
              waveHeight: 12,
            ),
          ),

          SafeArea(
            child: Consumer<ProgressViewModel>(
              builder: (context, progressVM, child) {
                if (progressVM.isLoading && progressVM.overallProgress == 0.0) {
                  return Center(
                    child: LoadingStates.fullScreenLoading(
                      context,
                      message: 'Loading your progress...',
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(context, progressVM),

                      const SizedBox(height: 24),

                      // Overall Progress Card
                      _buildOverallProgressCard(context, progressVM),

                      const SizedBox(height: 24),

                      // Skills Progress
                      _buildSkillsProgressSection(context, progressVM),

                      const SizedBox(height: 24),

                      // Recent Activity
                      _buildRecentActivitySection(context, progressVM),

                      const SizedBox(height: 24),

                      // Weekly Stats
                      _buildWeeklyStatsCard(context, progressVM),

                      const SizedBox(height: 24),

                      // Gamification Section
                      _buildGamificationSection(context, progressVM),

                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProgressViewModel progressVM) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                FuturisticColors.neonPink,
                FuturisticColors.neonPurple,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: FuturisticColors.neonPink.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: const Icon(
            Icons.show_chart,
            color: Colors.white,
            size: 24,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: 500.ms,
            ),

        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Progress',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${progressVM.completionRate.toStringAsFixed(1)}% Complete',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => progressVM.initialize(),
          icon: const Icon(Icons.refresh),
          color: FuturisticColors.neonPink,
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.2, end: 0, duration: 500.ms);
  }

  Widget _buildOverallProgressCard(BuildContext context, ProgressViewModel progressVM) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return EnhancedFuturisticCard(
      width: double.infinity,
      height: 180,
      enableGlow: true,
      glowColor: FuturisticColors.neonPink,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Progress',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: FuturisticColors.neonPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: FuturisticColors.neonPink.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${progressVM.overallProgress.toStringAsFixed(1)}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: FuturisticColors.neonPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progressVM.overallProgress / 100,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(FuturisticColors.neonPink),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  icon: Icons.book,
                  value: '${progressVM.totalLessonsCompleted}',
                  label: 'Completed',
                  color: FuturisticColors.neonBlue,
                ),
                _buildStatItem(
                  context,
                  icon: Icons.access_time,
                  value: progressVM.formattedTimeSpent,
                  label: 'Time Spent',
                  color: FuturisticColors.neonGreen,
                ),
                _buildStatItem(
                  context,
                  icon: Icons.local_fire_department,
                  value: '${progressVM.currentStreak}',
                  label: 'Day Streak',
                  color: FuturisticColors.neonOrange,
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .slideY(begin: 0.2, end: 0, duration: 500.ms);
  }

  Widget _buildStatItem(BuildContext context,
      {required IconData icon, required String value, required String label, required Color color}) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsProgressSection(BuildContext context, ProgressViewModel progressVM) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills Progress',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: progressVM.skillProgress.length,
            itemBuilder: (context, index) {
              final skill = progressVM.skillProgress[index];
              return _buildSkillProgressCard(context, skill, index);
            },
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 400.ms)
        .slideX(begin: 0.2, end: 0, duration: 500.ms);
  }

  Widget _buildSkillProgressCard(BuildContext context, Map<String, dynamic> skill, int index) {
    final theme = Theme.of(context);
    final progress = skill['progress'] ?? 0.0;
    final color = _getSkillColor(skill['name'] as String? ?? '');

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: EnhancedFuturisticCard(
        width: double.infinity,
        height: 120,
        enableGlow: true,
        glowColor: color,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                skill['name'] ?? 'Unknown',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              const SizedBox(height: 4),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: index * 100 + 600),
        )
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
          delay: Duration(milliseconds: index * 100 + 600),
        );
  }

  Widget _buildRecentActivitySection(BuildContext context, ProgressViewModel progressVM) {
    final theme = Theme.of(context);
    final recentLessons = progressVM.getRecentLessons(limit: 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (recentLessons.isEmpty)
          EnhancedFuturisticCard(
            width: double.infinity,
            height: 80,
            child: Center(
              child: Text(
                'No recent activity',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentLessons.length,
            itemBuilder: (context, index) {
              final lesson = recentLessons[index];
              return _buildRecentLessonItem(context, lesson, index);
            },
          ),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 800.ms)
        .slideY(begin: 0.2, end: 0, duration: 500.ms);
  }

  Widget _buildRecentLessonItem(BuildContext context, Map<String, dynamic> lesson, int index) {
    final theme = Theme.of(context);
    final progress = lesson['progress_percentage'] ?? 0.0;
    final isCompleted = lesson['completed'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: EnhancedFuturisticCard(
        width: double.infinity,
        height: 70,
        enableGlow: isCompleted,
        glowColor: FuturisticColors.neonGreen,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? FuturisticColors.neonGreen.withOpacity(0.1)
                      : FuturisticColors.neonBlue.withOpacity(0.1),
                  border: Border.all(
                    color: isCompleted
                        ? FuturisticColors.neonGreen
                        : FuturisticColors.neonBlue,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.play_arrow,
                  color: isCompleted
                      ? FuturisticColors.neonGreen
                      : FuturisticColors.neonBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lesson['lesson_title'] ?? 'Unknown Lesson',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      lesson['course_title'] ?? 'Unknown Course',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: FuturisticColors.neonPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isCompleted ? 'Completed' : 'In Progress',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isCompleted
                          ? FuturisticColors.neonGreen
                          : FuturisticColors.neonBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: index * 100 + 1000),
        )
        .slideX(begin: 0.1, end: 0, duration: 300.ms);
  }

  Widget _buildWeeklyStatsCard(BuildContext context, ProgressViewModel progressVM) {
    final theme = Theme.of(context);
    final weeklyStats = progressVM.getWeeklyStats();

    return EnhancedFuturisticCard(
      width: double.infinity,
      height: 120,
      enableGlow: true,
      glowColor: FuturisticColors.neonPurple,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeeklyStatItem(
                  context,
                  icon: Icons.book,
                  value: '${weeklyStats['lessons_completed'] ?? 0}',
                  label: 'Lessons',
                  color: FuturisticColors.neonBlue,
                ),
                _buildWeeklyStatItem(
                  context,
                  icon: Icons.access_time,
                  value: '${(weeklyStats['time_spent'] ?? 0)}m',
                  label: 'Time',
                  color: FuturisticColors.neonGreen,
                ),
                _buildWeeklyStatItem(
                  context,
                  icon: Icons.local_fire_department,
                  value: weeklyStats['streak_maintained'] == true ? 'Yes' : 'No',
                  label: 'Streak',
                  color: FuturisticColors.neonOrange,
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 1200.ms)
        .slideY(begin: 0.2, end: 0, duration: 500.ms);
  }

  Widget _buildWeeklyStatItem(BuildContext context,
      {required IconData icon, required String value, required String label, required Color color}) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildGamificationSection(BuildContext context, ProgressViewModel progressVM) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAchievementItem(
              context,
              icon: Icons.local_fire_department,
              value: '${progressVM.currentStreak}',
              label: 'Current Streak',
              color: FuturisticColors.neonOrange,
            ),
            _buildAchievementItem(
              context,
              icon: Icons.emoji_events,
              value: '${progressVM.totalPoints}',
              label: 'Points',
              color: FuturisticColors.neonGold,
            ),
            _buildAchievementItem(
              context,
              icon: Icons.military_tech,
              value: '${progressVM.totalBadges}',
              label: 'Badges',
              color: FuturisticColors.neonPurple,
            ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 1400.ms)
        .slideY(begin: 0.2, end: 0, duration: 500.ms);
  }

  Widget _buildAchievementItem(BuildContext context,
      {required IconData icon, required String value, required String label, required Color color}) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
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
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Color _getSkillColor(String skillName) {
    final colors = [
      FuturisticColors.neonBlue,
      FuturisticColors.neonGreen,
      FuturisticColors.neonPurple,
      FuturisticColors.neonPink,
      FuturisticColors.neonOrange,
      FuturisticColors.neonGold,
    ];

    // Simple hash function to get consistent colors
    int hash = 0;
    for (int i = 0; i < skillName.length; i++) {
      hash = skillName.codeUnitAt(i) + ((hash << 5) - hash);
    }

    return colors[hash.abs() % colors.length];
  }
}
