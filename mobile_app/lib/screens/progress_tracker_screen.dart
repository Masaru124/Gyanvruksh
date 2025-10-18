import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/widgets/backgrounds/cinematic_background.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/micro_interactions.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';

class ProgressTrackerScreen extends StatefulWidget {
  const ProgressTrackerScreen({super.key});

  @override
  State<ProgressTrackerScreen> createState() => _ProgressTrackerScreenState();
}

class _ProgressTrackerScreenState extends State<ProgressTrackerScreen> {
  Map<String, dynamic> overallProgress = {};
  List<dynamic> courseProgress = [];
  List<dynamic> skillProgress = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    setState(() => isLoading = true);
    
    try {
      final report = await ApiService().getStudentProgressReport();

      // Map backend report to current UI structures
      final summary = report['summary'] as Map<String, dynamic>? ?? {};
      final courseList = report['course_progress'] as List<dynamic>? ?? [];

      overallProgress = {
        'totalCourses': summary['total_courses'] ?? 0,
        'completedCourses': summary['completed_courses'] ?? 0,
        'totalHours': report['total_study_hours'] ?? 0,
        'completedHours': (report['total_study_hours'] ?? 0) * 0.6, // estimate if not provided
        'averageScore': (summary['overall_progress'] ?? 0).round(),
        'streak': report['study_streak'] ?? 0,
      };

      courseProgress = courseList.map((c) {
        final m = c as Map<String, dynamic>;
        return {
          'name': m['course_title'] ?? 'Course',
          'progress': (m['progress'] ?? 0).round(),
          'totalLessons': 0,
          'completedLessons': 0,
          'score': ((m['progress'] ?? 0) as num).round(),
        };
      }).toList();

      // Skills not yet provided by backend; keep empty for now
      skillProgress = [];

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        overallProgress = {};
        courseProgress = [];
        skillProgress = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const CinematicBackground(isDark: true),
          const ParticleBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(theme),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildOverallProgress(theme),
                              const SizedBox(height: 24),
                              _buildCourseProgress(theme),
                              const SizedBox(height: 24),
                              _buildSkillProgress(theme),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Text(
            'Progress Tracker',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildOverallProgress(ThemeData theme) {
    final stats = [
      {
        'title': 'Courses',
        'value': '${overallProgress['completedCourses']}/${overallProgress['totalCourses']}',
        'progress': (overallProgress['completedCourses'] / overallProgress['totalCourses']),
        'icon': FontAwesomeIcons.graduationCap,
        'color': FuturisticColors.primary,
      },
      {
        'title': 'Study Hours',
        'value': '${overallProgress['completedHours']}/${overallProgress['totalHours']}',
        'progress': (overallProgress['completedHours'] / overallProgress['totalHours']),
        'icon': FontAwesomeIcons.clock,
        'color': FuturisticColors.secondary,
      },
      {
        'title': 'Avg Score',
        'value': '${overallProgress['averageScore']}%',
        'progress': (overallProgress['averageScore'] / 100.0),
        'icon': FontAwesomeIcons.chartLine,
        'color': FuturisticColors.accent,
      },
      {
        'title': 'Streak',
        'value': '${overallProgress['streak']} days',
        'progress': (overallProgress['streak'] / 30.0).clamp(0.0, 1.0),
        'icon': FontAwesomeIcons.fire,
        'color': FuturisticColors.warning,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Progress',
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
                        Text(
                          '${((stat['progress'] as double) * 100).round()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: stat['color'] as Color,
                            fontWeight: FontWeight.bold,
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
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: stat['progress'] as double,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(stat['color'] as Color),
                    ),
                  ],
                ),
              ),
            ).animate()
              .fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100))
              .slideX(begin: 0.2, end: 0, duration: 500.ms);
          },
        ),
      ],
    );
  }

  Widget _buildCourseProgress(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Progress',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...courseProgress.asMap().entries.map((entry) {
          final index = entry.key;
          final course = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
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
                            course['name'],
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: FuturisticColors.accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${course['progress']}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: FuturisticColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.bookOpen,
                          color: FuturisticColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${course['completedLessons']}/${course['totalLessons']} Lessons',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(width: 24),
                        FaIcon(
                          FontAwesomeIcons.star,
                          color: FuturisticColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Score: ${course['score']}%',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: course['progress'] / 100.0,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(FuturisticColors.accent),
                    ),
                  ],
                ),
              ),
            ),
          ).animate()
            .fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100))
            .slideX(begin: -0.2, end: 0, duration: 500.ms);
        }).toList(),
      ],
    );
  }

  Widget _buildSkillProgress(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skill Development',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...skillProgress.asMap().entries.map((entry) {
          final index = entry.key;
          final skill = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: MicroInteractionWrapper(
              child: GlassmorphismCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          skill['skill'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Level ${skill['level']}/${skill['maxLevel']}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: FuturisticColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(skill['maxLevel'], (levelIndex) {
                        final isActive = levelIndex < skill['level'];
                        return Container(
                          margin: const EdgeInsets.only(right: 4),
                          width: 20,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive 
                                ? FuturisticColors.success 
                                : Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: skill['progress'] / 100.0,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(FuturisticColors.success),
                    ),
                  ],
                ),
              ),
            ),
          ).animate()
            .fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100))
            .slideX(begin: 0.2, end: 0, duration: 500.ms);
        }).toList(),
      ],
    );
  }
}
