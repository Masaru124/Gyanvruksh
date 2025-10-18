import 'package:flutter/material.dart';
import 'package:gyanvruksh/screens/teacher_course_management.dart';
import 'package:gyanvruksh/screens/teacher_assignments_screen.dart';
import 'package:gyanvruksh/screens/schedule_classes_screen.dart';
import 'package:gyanvruksh/screens/student_progress_report_screen.dart';
import 'package:gyanvruksh/widgets/app_card.dart';
import 'package:gyanvruksh/widgets/app_button.dart';
import 'package:gyanvruksh/theme/app_theme.dart';

class TeacherFeaturesScreen extends StatelessWidget {
  const TeacherFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'title': 'Course Management',
        'subtitle': 'Create, edit, and manage your courses',
        'icon': Icons.book,
        'color': Colors.blue,
        'screen': const TeacherCourseManagementScreen(),
      },
      {
        'title': 'Assignments',
        'subtitle': 'Create and grade assignments',
        'icon': Icons.assignment,
        'color': Colors.green,
        'screen': const TeacherAssignmentsScreen(),
      },
      {
        'title': 'Schedule Classes',
        'subtitle': 'Manage your class schedule',
        'icon': Icons.schedule,
        'color': Colors.orange,
        'screen': const ScheduleClassesScreen(),
      },
      {
        'title': 'Student Progress',
        'subtitle': 'Track student performance',
        'icon': Icons.trending_up,
        'color': Colors.purple,
        'screen': const StudentProgressReportScreen(),
      },
      {
        'title': 'Attendance',
        'subtitle': 'Manage student attendance',
        'icon': Icons.how_to_reg,
        'color': Colors.teal,
        'onTap': () => _showAttendanceOptions(context),
      },
      {
        'title': 'Grading',
        'subtitle': 'Grade assignments and exams',
        'icon': Icons.grade,
        'color': Colors.red,
        'onTap': () => _showGradingOptions(context),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Features'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.1,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return AppCard(
              child: InkWell(
                onTap: () {
                  if (feature['onTap'] != null) {
                    (feature['onTap'] as VoidCallback)();
                  } else if (feature['screen'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => feature['screen'] as Widget,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: (feature['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          size: 32,
                          color: feature['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        feature['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        feature['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static void _showAttendanceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Attendance Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              text: 'View All Courses',
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeacherCourseManagementScreen(),
                  ),
                );
              },
              type: AppButtonType.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              text: 'Quick Attendance',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quick attendance feature coming soon')),
                );
              },
              type: AppButtonType.secondary,
            ),
          ],
        ),
      ),
    );
  }

  static void _showGradingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Grading Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              text: 'Grade Assignments',
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeacherAssignmentsScreen(),
                  ),
                );
              },
              type: AppButtonType.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              text: 'View Student Progress',
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentProgressReportScreen(),
                  ),
                );
              },
              type: AppButtonType.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
