import 'package:flutter/material.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:gyanvruksh/widgets/app_card.dart';
import 'package:gyanvruksh/widgets/app_button.dart';
import 'package:gyanvruksh/theme/app_theme.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> assignment;
  const AssignmentDetailScreen({super.key, required this.assignment});

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  bool _loading = false;
  String? _error;
  List<dynamic> _grades = [];

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ApiService().getAssignmentGrades(widget.assignment['id'] as int);
      setState(() {
        _grades = list;
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
    final a = widget.assignment;

    return Scaffold(
      appBar: AppBar(
        title: const AppText.h5('Assignment Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.h6(a['title'] ?? 'Assignment'),
                  const SizedBox(height: AppSpacing.md),
                  AppText.bodyMedium(a['description'] ?? 'No description provided'),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const AppText.label('Course: '),
                      AppText.bodyMedium(a['course_title'] ?? a['subject'] ?? 'Course'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const AppText.label('Due: '),
                      AppText.bodyMedium((a['due_date'] ?? a['dueDate'] ?? '').toString()),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionSpacing),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText.h6('Grades'),
                  const SizedBox(height: AppSpacing.md),
                  if (_loading) const Center(child: CircularProgressIndicator()),
                  if (_error != null) AppText.bodyMedium(_error!, color: Theme.of(context).colorScheme.error),
                  if (!_loading && _error == null)
                    if (_grades.isEmpty)
                      const AppText.bodyMedium('No grades yet')
                    else
                      ..._grades.map((g) {
                        final m = g as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(AppBorderRadius.md),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText.bodyMedium('Student ID: ${m['student_id']}'),
                                    const SizedBox(height: 4),
                                    AppText.bodySmall(m['feedback'] ?? 'No feedback'),
                                  ],
                                ),
                              ),
                              AppText.bodyMedium('${m['score'] ?? 0}/${widget.assignment['max_score'] ?? 100}'),
                            ],
                          ),
                        );
                      }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionSpacing),
            AppButton(
              text: 'Refresh',
              onPressed: _loadGrades,
              type: AppButtonType.secondary,
            )
          ],
        ),
      ),
    );
  }
}
