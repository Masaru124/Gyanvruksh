import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/widgets/backgrounds/cinematic_background.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/micro_interactions.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';

class AssignmentsQuizzesScreen extends StatefulWidget {
  const AssignmentsQuizzesScreen({super.key});

  @override
  State<AssignmentsQuizzesScreen> createState() => _AssignmentsQuizzesScreenState();
}

class _AssignmentsQuizzesScreenState extends State<AssignmentsQuizzesScreen> {
  int selectedTab = 0;
  List<dynamic> assignments = [];
  List<dynamic> quizzes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      final results = await Future.wait([
        ApiService().get('/api/assignments').catchError((_) => []),
        ApiService().get('/api/quizzes').catchError((_) => []),
      ]);
      
      setState(() {
        assignments = results[0] as List<dynamic>;
        quizzes = results[1] as List<dynamic>;
        isLoading = false;
        
        // Fallback data
        if (assignments.isEmpty) {
          assignments = [
            {'id': 1, 'title': 'Mathematics Problem Set 1', 'subject': 'Mathematics', 'dueDate': '2024-01-15', 'status': 'pending'},
            {'id': 2, 'title': 'Physics Lab Report', 'subject': 'Physics', 'dueDate': '2024-01-20', 'status': 'submitted'},
            {'id': 3, 'title': 'Chemistry Equations', 'subject': 'Chemistry', 'dueDate': '2024-01-25', 'status': 'overdue'},
          ];
        }
        
        if (quizzes.isEmpty) {
          quizzes = [
            {'id': 1, 'title': 'Algebra Quiz', 'subject': 'Mathematics', 'questions': 15, 'duration': 30, 'status': 'available'},
            {'id': 2, 'title': 'Mechanics Quiz', 'subject': 'Physics', 'questions': 20, 'duration': 45, 'status': 'completed'},
            {'id': 3, 'title': 'Organic Chemistry', 'subject': 'Chemistry', 'questions': 25, 'duration': 60, 'status': 'locked'},
          ];
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        assignments = [
          {'id': 1, 'title': 'Mathematics Problem Set 1', 'subject': 'Mathematics', 'dueDate': '2024-01-15', 'status': 'pending'},
          {'id': 2, 'title': 'Physics Lab Report', 'subject': 'Physics', 'dueDate': '2024-01-20', 'status': 'submitted'},
        ];
        quizzes = [
          {'id': 1, 'title': 'Algebra Quiz', 'subject': 'Mathematics', 'questions': 15, 'duration': 30, 'status': 'available'},
          {'id': 2, 'title': 'Mechanics Quiz', 'subject': 'Physics', 'questions': 20, 'duration': 45, 'status': 'completed'},
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
                _buildTabBar(theme),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : selectedTab == 0
                          ? _buildAssignmentsList(theme)
                          : _buildQuizzesList(theme),
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
            'Assignments & Quizzes',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildTabBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphismCard(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: MicroInteractionWrapper(
                onTap: () => setState(() => selectedTab = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: selectedTab == 0
                        ? LinearGradient(
                            colors: [FuturisticColors.primary, FuturisticColors.secondary],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Assignments',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: MicroInteractionWrapper(
                onTap: () => setState(() => selectedTab = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: selectedTab == 1
                        ? LinearGradient(
                            colors: [FuturisticColors.primary, FuturisticColors.secondary],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Quizzes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms);
  }

  Widget _buildAssignmentsList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
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
                          assignment['title'],
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(assignment['status']).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          assignment['status'].toString().toUpperCase(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(assignment['status']),
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
                        FontAwesomeIcons.book,
                        color: FuturisticColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        assignment['subject'],
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(width: 24),
                      FaIcon(
                        FontAwesomeIcons.calendar,
                        color: FuturisticColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Due: ${assignment['dueDate']}',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ).animate()
          .fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100))
          .slideX(begin: 0.2, end: 0, duration: 500.ms);
      },
    );
  }

  Widget _buildQuizzesList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
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
                          quiz['title'],
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(quiz['status']).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          quiz['status'].toString().toUpperCase(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(quiz['status']),
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
                        FontAwesomeIcons.book,
                        color: FuturisticColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        quiz['subject'],
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(width: 24),
                      FaIcon(
                        FontAwesomeIcons.questionCircle,
                        color: FuturisticColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${quiz['questions']} Questions',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(width: 24),
                      FaIcon(
                        FontAwesomeIcons.clock,
                        color: FuturisticColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${quiz['duration']} min',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ).animate()
          .fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100))
          .slideX(begin: 0.2, end: 0, duration: 500.ms);
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'submitted':
        return FuturisticColors.success;
      case 'pending':
      case 'available':
        return FuturisticColors.warning;
      case 'overdue':
        return FuturisticColors.error;
      case 'locked':
        return Colors.grey;
      default:
        return FuturisticColors.accent;
    }
  }
}
