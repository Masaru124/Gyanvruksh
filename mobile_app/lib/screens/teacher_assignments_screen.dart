import 'package:flutter/material.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:gyanvruksh/widgets/app_card.dart';
import 'package:gyanvruksh/widgets/app_text_field.dart';
import 'package:gyanvruksh/widgets/app_button.dart';
import 'package:gyanvruksh/theme/app_theme.dart';

class TeacherAssignmentsScreen extends StatefulWidget {
  const TeacherAssignmentsScreen({super.key});

  @override
  State<TeacherAssignmentsScreen> createState() => _TeacherAssignmentsScreenState();
}

class _TeacherAssignmentsScreenState extends State<TeacherAssignmentsScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _assignments = [];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ApiService().getStudentAssignments(); // returns teacher's assignments when teacher is logged in
      setState(() {
        _assignments = list;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openCreateAssignmentDialog() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final courseIdCtrl = TextEditingController();
    final lessonIdCtrl = TextEditingController();
    final dueDateCtrl = TextEditingController();
    final maxScoreCtrl = TextEditingController(text: '100');
    final instructionsCtrl = TextEditingController();
    final attachmentUrlCtrl = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(controller: titleCtrl, label: 'Title', required: true),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(controller: descCtrl, label: 'Description', type: AppTextFieldType.multiline, maxLines: 3),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(controller: courseIdCtrl, label: 'Course ID', type: AppTextFieldType.number, required: true),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(controller: lessonIdCtrl, label: 'Lesson ID (optional)', type: AppTextFieldType.number),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(controller: dueDateCtrl, label: 'Due Date (YYYY-MM-DD)', required: true),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(controller: maxScoreCtrl, label: 'Max Score', type: AppTextFieldType.number),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(controller: instructionsCtrl, label: 'Instructions'),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(controller: attachmentUrlCtrl, label: 'Attachment URL'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final desc = descCtrl.text.trim();
                final courseId = int.tryParse(courseIdCtrl.text.trim());
                final lessonId = int.tryParse(lessonIdCtrl.text.trim());
                final maxScore = int.tryParse(maxScoreCtrl.text.trim()) ?? 100;
                final dueDateText = dueDateCtrl.text.trim();
                if (title.isEmpty || courseId == null || dueDateText.isEmpty) return;
                try {
                  final dueDate = DateTime.parse(dueDateText);
                  final res = await ApiService().createAssignment(
                    title: title,
                    description: desc,
                    courseId: courseId,
                    lessonId: lessonId,
                    dueDate: dueDate,
                    maxScore: maxScore,
                    instructions: instructionsCtrl.text.trim().isEmpty ? null : instructionsCtrl.text.trim(),
                    attachmentUrl: attachmentUrlCtrl.text.trim().isEmpty ? null : attachmentUrlCtrl.text.trim(),
                  );
                  if (res != null) {
                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  }
                } catch (_) {}
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (created == true) {
      _loadAssignments();
    }
  }

  Future<void> _openGradeDialog(Map<String, dynamic> assignment) async {
    final studentIdCtrl = TextEditingController();
    final scoreCtrl = TextEditingController();
    final feedbackCtrl = TextEditingController();

    final graded = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Grade Assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(controller: studentIdCtrl, label: 'Student ID', type: AppTextFieldType.number, required: true),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(controller: scoreCtrl, label: 'Score', type: AppTextFieldType.number, required: true),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(controller: feedbackCtrl, label: 'Feedback'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final studentId = int.tryParse(studentIdCtrl.text.trim());
                final score = int.tryParse(scoreCtrl.text.trim());
                if (studentId == null || score == null) return;
                final courseId = assignment['course_id'] as int? ?? assignment['courseId'] as int? ?? 0;
                final feedback = feedbackCtrl.text.trim();
                await ApiService().gradeAssignment(
                  studentId,
                  courseId,
                  assignment['id'] as int,
                  score.toDouble(),
                  feedback,
                );
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (graded == true) {
      // No list change needed; optional toast/snack
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Grade submitted')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          IconButton(
            onPressed: _openCreateAssignmentDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Create Assignment',
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAssignments,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _assignments.isEmpty
                    ? const Center(child: Text('No assignments yet'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.screenPadding),
                        itemCount: _assignments.length,
                        itemBuilder: (context, index) {
                          final a = _assignments[index] as Map<String, dynamic>;
                          return AppCard(
                            margin: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(a['title'] ?? 'Assignment', style: const TextStyle(fontWeight: FontWeight.w600))),
                                    Text((a['due_date'] ?? a['dueDate'] ?? '').toString(), style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(a['description'] ?? ''),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    AppButton(
                                      text: 'Grade',
                                      onPressed: () => _openGradeDialog(a),
                                      size: AppButtonSize.small,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
