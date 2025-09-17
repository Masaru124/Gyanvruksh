import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../viewmodels/progress_viewmodel.dart';
import '../widgets/glassmorphism_card.dart';
import '../widgets/particle_background.dart';
import '../widgets/animated_wave_background.dart';
import '../theme/futuristic_theme.dart';
import 'package:fl_chart/fl_chart.dart';

class SkillTreeScreen extends StatefulWidget {
  const SkillTreeScreen({super.key});

  @override
  State<SkillTreeScreen> createState() => _SkillTreeScreenState();
}

class _SkillTreeScreenState extends State<SkillTreeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Skill Tree',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface.withOpacity(0.8),
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: Stack(
        children: [
          // Animated Wave Background
          AnimatedWaveBackground(
            color: FuturisticColors.neonBlue.withOpacity(0.1),
            height: MediaQuery.of(context).size.height,
          ),

          // Particle Background
          ParticleBackground(
            particleCount: 20,
            particleColor: FuturisticColors.neonPurple,
          ),

          Consumer<ProgressViewModel>(
            builder: (context, progressViewModel, child) {
              if (progressViewModel.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overall Progress Header
                      GlassmorphismCard(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        blurStrength: 15,
                        opacity: 0.1,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Overall Mastery',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: FuturisticColors.neonGreen.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: FuturisticColors.neonGreen,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${progressViewModel.completionRate.toStringAsFixed(1)}%',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: FuturisticColors.neonGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: progressViewModel.completionRate / 100,
                              backgroundColor: colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FuturisticColors.neonGreen,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Skill Categories
                      Text(
                        'Skill Categories',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Skill Tree Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: _skillCategories.length,
                        itemBuilder: (context, index) {
                          final category = _skillCategories[index];
                          final skillProgress = progressViewModel.getProgressForSkill(category.name);

                          return _buildSkillNode(
                            context,
                            category,
                            skillProgress,
                          ).animate().fadeIn(
                            delay: Duration(milliseconds: index * 100),
                            duration: const Duration(milliseconds: 500),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Progress Analytics
                      Text(
                        'Progress Analytics',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      GlassmorphismCard(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        blurStrength: 15,
                        opacity: 0.1,
                        child: Column(
                          children: [
                            Text(
                              'Weekly Progress',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 200,
                              child: LineChart(
                                _buildWeeklyProgressChart(progressViewModel),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Achievement Highlights
                      Text(
                        'Recent Achievements',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildAchievementHighlights(context),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSkillNode(
    BuildContext context,
    SkillCategory category,
    Map<String, dynamic>? progress,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final masteryLevel = progress?['mastery_level'] ?? 1;
    final progressPercent = progress?['progress_percentage'] ?? 0.0;

    return GlassmorphismCard(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      blurStrength: 10,
      opacity: 0.1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  category.color.withOpacity(0.3),
                  category.color.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: category.color,
                width: 2,
              ),
            ),
            child: Icon(
              category.icon,
              color: category.color,
              size: 30,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            category.name,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'Level $masteryLevel',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: progressPercent / 100,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(category.color),
          ),

          const SizedBox(height: 4),

          Text(
            '${progressPercent.toStringAsFixed(0)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: category.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildWeeklyProgressChart(ProgressViewModel progressViewModel) {
    final weeklyData = progressViewModel.weeklyProgress;

    // Create sample data if weeklyData is empty or not in expected format
    final List<FlSpot> spots = [];
    if (weeklyData.containsKey('daily_progress')) {
      final dailyProgress = weeklyData['daily_progress'] as List?;
      if (dailyProgress != null) {
        for (int i = 0; i < dailyProgress.length && i < 7; i++) {
          final dayData = dailyProgress[i];
          if (dayData is Map && dayData.containsKey('minutes')) {
            spots.add(FlSpot(i.toDouble(), (dayData['minutes'] as num).toDouble()));
          } else {
            spots.add(FlSpot(i.toDouble(), 0.0));
          }
        }
      }
    }

    // If no data, create sample data
    if (spots.isEmpty) {
      for (int i = 0; i < 7; i++) {
        spots.add(FlSpot(i.toDouble(), (i * 10.0 + 20))); // Sample data
      }
    }

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              if (value.toInt() < days.length) {
                return Text(
                  days[value.toInt()],
                  style: const TextStyle(fontSize: 12),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 12),
              );
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: FuturisticColors.neonBlue,
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            color: FuturisticColors.neonBlue.withOpacity(0.1),
          ),
          dotData: FlDotData(show: true),
        ),
      ],
    );
  }

  Widget _buildAchievementHighlights(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Mock achievements - in real app, get from ViewModel
    final achievements = [
      AchievementData(
        title: 'First Lesson Completed',
        description: 'Completed your first lesson',
        icon: FontAwesomeIcons.trophy,
        color: FuturisticColors.neonGold,
        date: '2 days ago',
      ),
      AchievementData(
        title: 'Week Warrior',
        description: '7-day learning streak',
        icon: FontAwesomeIcons.fire,
        color: FuturisticColors.neonOrange,
        date: '1 week ago',
      ),
      AchievementData(
        title: 'Quiz Master',
        description: 'Scored 100% on 5 quizzes',
        icon: FontAwesomeIcons.brain,
        color: FuturisticColors.neonPurple,
        date: '3 days ago',
      ),
    ];

    return Column(
      children: achievements.map((achievement) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassmorphismCard(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            blurStrength: 10,
            opacity: 0.1,
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: achievement.color?.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    achievement.icon,
                    color: achievement.color,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.date,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  FontAwesomeIcons.chevronRight,
                  color: colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SkillCategory {
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  const SkillCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}

final List<SkillCategory> _skillCategories = [
  SkillCategory(
    name: 'Mathematics',
    icon: FontAwesomeIcons.calculator,
    color: FuturisticColors.neonBlue,
    description: 'Numbers, algebra, geometry, and calculus',
  ),
  SkillCategory(
    name: 'Science',
    icon: FontAwesomeIcons.microscope,
    color: FuturisticColors.neonGreen,
    description: 'Physics, chemistry, biology, and earth science',
  ),
  SkillCategory(
    name: 'Programming',
    icon: FontAwesomeIcons.code,
    color: FuturisticColors.neonPurple,
    description: 'Coding, algorithms, and software development',
  ),
  SkillCategory(
    name: 'Languages',
    icon: FontAwesomeIcons.language,
    color: FuturisticColors.neonOrange,
    description: 'English, regional languages, and communication',
  ),
  SkillCategory(
    name: 'Arts',
    icon: FontAwesomeIcons.palette,
    color: FuturisticColors.neonPink,
    description: 'Drawing, painting, and visual arts',
  ),
  SkillCategory(
    name: 'Music',
    icon: FontAwesomeIcons.music,
    color: FuturisticColors.neonCyan,
    description: 'Instruments, theory, and musical skills',
  ),
  SkillCategory(
    name: 'Sports',
    icon: FontAwesomeIcons.running,
    color: FuturisticColors.neonRed,
    description: 'Physical fitness and sports training',
  ),
  SkillCategory(
    name: 'Literature',
    icon: FontAwesomeIcons.book,
    color: FuturisticColors.neonGold,
    description: 'Reading, writing, and literary analysis',
  ),
];

class AchievementData {
  final String title;
  final String description;
  final IconData icon;
  final Color? color;
  final String date;

  const AchievementData({
    required this.title,
    required this.description,
    required this.icon,
    this.color,
    required this.date,
  });
}
