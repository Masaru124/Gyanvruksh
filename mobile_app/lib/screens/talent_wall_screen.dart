import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gyanvruksh/services/enhanced_api_service.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/widgets/backgrounds/cinematic_background.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/micro_interactions.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';

class TalentWallScreen extends StatefulWidget {
  const TalentWallScreen({super.key});

  @override
  State<TalentWallScreen> createState() => _TalentWallScreenState();
}

class _TalentWallScreenState extends State<TalentWallScreen> {
  List<dynamic> topPerformers = [];
  List<dynamic> achievements = [];
  List<dynamic> leaderboard = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTalentData();
  }

  Future<void> _loadTalentData() async {
    setState(() => isLoading = true);

    try {
      final results = await Future.wait([
        ApiService.getLeaderboard().catchError((_) => []),
        ApiService.getStudentAchievements().catchError((_) => []),
      ]);

      setState(() {
        leaderboard = results[0] as List<dynamic>;
        achievements = results[1] as List<dynamic>;
        isLoading = false;

        // Fallback data
        if (leaderboard.isEmpty) {
          leaderboard = [
            {
              'rank': 1,
              'name': 'Arjun Sharma',
              'points': 2450,
              'avatar': '🏆',
              'subject': 'Mathematics'
            },
            {
              'rank': 2,
              'name': 'Priya Patel',
              'points': 2380,
              'avatar': '🥈',
              'subject': 'Physics'
            },
            {
              'rank': 3,
              'name': 'Rahul Kumar',
              'points': 2320,
              'avatar': '🥉',
              'subject': 'Chemistry'
            },
            {
              'rank': 4,
              'name': 'Sneha Gupta',
              'points': 2280,
              'avatar': '⭐',
              'subject': 'Biology'
            },
            {
              'rank': 5,
              'name': 'Vikram Singh',
              'points': 2250,
              'avatar': '🌟',
              'subject': 'Computer Science'
            },
          ];
        }

        topPerformers = leaderboard.take(3).toList();

        if (achievements.isEmpty) {
          achievements = [
            {
              'title': 'Perfect Score',
              'description': 'Scored 100% in Mathematics Quiz',
              'student': 'Arjun Sharma',
              'date': '2024-01-15',
              'badge': '🏆'
            },
            {
              'title': 'Speed Demon',
              'description': 'Completed Physics assignment in record time',
              'student': 'Priya Patel',
              'date': '2024-01-14',
              'badge': '⚡'
            },
            {
              'title': 'Streak Master',
              'description': '30-day learning streak achieved',
              'student': 'Rahul Kumar',
              'date': '2024-01-13',
              'badge': '🔥'
            },
            {
              'title': 'Helper',
              'description': 'Helped 10+ students with doubts',
              'student': 'Sneha Gupta',
              'date': '2024-01-12',
              'badge': '🤝'
            },
          ];
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        leaderboard = [
          {
            'rank': 1,
            'name': 'Arjun Sharma',
            'points': 2450,
            'avatar': '🏆',
            'subject': 'Mathematics'
          },
          {
            'rank': 2,
            'name': 'Priya Patel',
            'points': 2380,
            'avatar': '🥈',
            'subject': 'Physics'
          },
          {
            'rank': 3,
            'name': 'Rahul Kumar',
            'points': 2320,
            'avatar': '🥉',
            'subject': 'Chemistry'
          },
        ];
        topPerformers = leaderboard.take(3).toList();
        achievements = [
          {
            'title': 'Perfect Score',
            'description': 'Scored 100% in Mathematics Quiz',
            'student': 'Arjun Sharma',
            'date': '2024-01-15',
            'badge': '🏆'
          },
          {
            'title': 'Speed Demon',
            'description': 'Completed Physics assignment in record time',
            'student': 'Priya Patel',
            'date': '2024-01-14',
            'badge': '⚡'
          },
        ];
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
                              _buildTopPerformers(theme),
                              const SizedBox(height: 24),
                              _buildRecentAchievements(theme),
                              const SizedBox(height: 24),
                              _buildLeaderboard(theme),
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
            'Talent Wall',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FuturisticColors.primary.withOpacity(0.3),
                  FuturisticColors.secondary.withOpacity(0.3)
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const FaIcon(FontAwesomeIcons.trophy,
                color: Colors.white, size: 24),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildTopPerformers(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Performers',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: topPerformers.length,
            itemBuilder: (context, index) {
              final performer = topPerformers[index];
              final isFirst = index == 0;
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                child: MicroInteractionWrapper(
                  child: GlassmorphismCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isFirst
                                  ? [FuturisticColors.warning, Colors.amber]
                                  : [
                                      FuturisticColors.primary,
                                      FuturisticColors.secondary
                                    ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              performer['avatar'],
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          performer['name'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${performer['points']} pts',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: FuturisticColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          performer['subject'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
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
                      delay: Duration(milliseconds: index * 200))
                  .slideY(begin: 0.2, end: 0, duration: 500.ms);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAchievements(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Achievements',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...achievements.take(4).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final achievement = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: MicroInteractionWrapper(
              child: GlassmorphismCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            FuturisticColors.accent.withOpacity(0.3),
                            FuturisticColors.primary.withOpacity(0.3)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          achievement['badge'],
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement['title'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            achievement['description'],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'By ${achievement['student']}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: FuturisticColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '• ${achievement['date']}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(
                  duration: 600.ms, delay: Duration(milliseconds: index * 100))
              .slideX(begin: -0.2, end: 0, duration: 500.ms);
        }).toList(),
      ],
    );
  }

  Widget _buildLeaderboard(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leaderboard',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...leaderboard.asMap().entries.map((entry) {
          final index = entry.key;
          final student = entry.value;
          final isTopThree = student['rank'] <= 3;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: MicroInteractionWrapper(
              child: GlassmorphismCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: isTopThree
                            ? LinearGradient(
                                colors: [
                                  FuturisticColors.warning,
                                  Colors.amber
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  FuturisticColors.primary.withOpacity(0.3),
                                  FuturisticColors.secondary.withOpacity(0.3)
                                ],
                              ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          '#${student['rank']}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student['name'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            student['subject'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${student['points']}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: FuturisticColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'points',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
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
                  duration: 600.ms, delay: Duration(milliseconds: index * 50))
              .slideX(begin: 0.2, end: 0, duration: 500.ms);
        }).toList(),
      ],
    );
  }
}
