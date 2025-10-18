import 'package:flutter/material.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:gyanvruksh/widgets/app_card.dart';
import 'package:gyanvruksh/theme/app_theme.dart';

class StudentProgressReportScreen extends StatefulWidget {
  const StudentProgressReportScreen({super.key});

  @override
  State<StudentProgressReportScreen> createState() => _StudentProgressReportScreenState();
}

class _StudentProgressReportScreenState extends State<StudentProgressReportScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _students = [];
  Map<String, dynamic> _progressData = {};

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // For teachers, we'd need an endpoint to get all students' progress
      // For now, use available endpoints and adapt
      final results = await Future.wait([
        ApiService().getStudentProgressReport(),
        ApiService().listCourses(),
      ]);
      
      final progressReport = results[0] as Map<String, dynamic>;
      final courses = results[1] as List<dynamic>;
      
      setState(() {
        _progressData = progressReport;
        _students = [
          // Mock student data since we don't have a teacher-specific endpoint yet
          {
            'id': 1,
            'name': 'John Doe',
            'email': 'john@example.com',
            'overall_progress': 85,
            'courses_completed': 3,
            'total_courses': 5,
          },
          {
            'id': 2,
            'name': 'Jane Smith',
            'email': 'jane@example.com',
            'overall_progress': 92,
            'courses_completed': 4,
            'total_courses': 5,
          },
        ];
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Progress Reports'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProgressData,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _students.isEmpty
                    ? const Center(child: Text('No student data available'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.screenPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AppText.h6('Class Overview'),
                                  const SizedBox(height: AppSpacing.md),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard('Total Students', '${_students.length}', Icons.people),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: _buildStatCard('Avg Progress', '${_calculateAverageProgress()}%', Icons.trending_up),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sectionSpacing),
                            const AppText.h6('Individual Progress'),
                            const SizedBox(height: AppSpacing.md),
                            ..._students.map((student) {
                              final s = student as Map<String, dynamic>;
                              return AppCard(
                                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(s['name'] ?? 'Student', style: const TextStyle(fontWeight: FontWeight.w600)),
                                              const SizedBox(height: 4),
                                              AppText.bodySmall(s['email'] ?? ''),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: _getProgressColor(s['overall_progress'] ?? 0).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                                          ),
                                          child: AppText.bodySmall('${s['overall_progress'] ?? 0}%', 
                                            color: _getProgressColor(s['overall_progress'] ?? 0)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    LinearProgressIndicator(
                                      value: (s['overall_progress'] ?? 0) / 100.0,
                                      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                                      valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(s['overall_progress'] ?? 0)),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Row(
                                      children: [
                                        AppText.bodySmall('Courses: ${s['courses_completed']}/${s['total_courses']}'),
                                        const Spacer(),
                                        TextButton(
                                          onPressed: () {
                                            // Navigate to detailed student report
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Detailed report for ${s['name']}')),
                                            );
                                          },
                                          child: const AppText.bodySmall('View Details'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: AppSpacing.xs),
              AppText.bodySmall(title),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText.h5(value),
        ],
      ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress >= 80) return Colors.green;
    if (progress >= 60) return Colors.orange;
    return Colors.red;
  }

  int _calculateAverageProgress() {
    if (_students.isEmpty) return 0;
    final total = _students.fold<int>(0, (sum, student) => sum + ((student as Map<String, dynamic>)['overall_progress'] as int? ?? 0));
    return (total / _students.length).round();
  }
}
