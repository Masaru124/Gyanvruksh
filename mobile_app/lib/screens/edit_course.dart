import 'package:flutter/material.dart';
import 'package:gyanvruksh/services/enhanced_api_service.dart';
import 'package:gyanvruksh/widgets/app_button.dart';
import 'package:gyanvruksh/widgets/app_text_field.dart';
import 'package:gyanvruksh/widgets/app_card.dart';
import 'package:gyanvruksh/theme/app_theme.dart';

class EditCourseScreen extends StatefulWidget {
  final Map<String, dynamic> course;
  const EditCourseScreen({super.key, required this.course});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _totalHoursCtrl;
  late final TextEditingController _thumbnailUrlCtrl;
  String _difficulty = 'beginner';
  bool _isPublished = false;
  bool _loading = false;
  String? _error;

  final List<String> _difficultyLevels = const ['beginner', 'intermediate', 'advanced'];

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    _titleCtrl = TextEditingController(text: c['title'] ?? '');
    _descCtrl = TextEditingController(text: c['description'] ?? '');
    _totalHoursCtrl = TextEditingController(text: (c['total_hours']?.toString() ?? ''));
    _thumbnailUrlCtrl = TextEditingController(text: c['thumbnail_url'] ?? '');
    _difficulty = (c['difficulty'] ?? 'beginner').toString();
    _isPublished = (c['is_published'] ?? false) == true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _totalHoursCtrl.dispose();
    _thumbnailUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final totalHours = int.tryParse(_totalHoursCtrl.text.trim());
      final response = await ApiService.updateCourseDetails(
        courseId: widget.course['id'] as int,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        totalHours: totalHours,
        difficulty: _difficulty,
        thumbnailUrl: _thumbnailUrlCtrl.text.trim().isEmpty ? null : _thumbnailUrlCtrl.text.trim(),
        isPublished: _isPublished,
      );

      if (!mounted) return;
      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course updated successfully')),
        );
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _error = 'Failed to update course';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _deleteCourse() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text('Are you sure you want to delete this course? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await ApiService.deleteCourse(widget.course['id'] as int);
      if (!mounted) return;
      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course deleted')),
        );
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _error = 'Failed to delete course';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText.h5('Edit Course'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _deleteCourse,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Course',
          ),
        ],
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
                  const AppText.h6('Course Information'),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _titleCtrl,
                    label: 'Course Title',
                    hint: 'Enter course title',
                    required: true,
                    type: AppTextFieldType.text,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _descCtrl,
                    label: 'Course Description',
                    hint: 'Enter course description',
                    type: AppTextFieldType.multiline,
                    maxLines: 4,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _totalHoursCtrl,
                    label: 'Total Hours',
                    hint: 'Enter total hours',
                    type: AppTextFieldType.number,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _thumbnailUrlCtrl,
                    label: 'Thumbnail URL',
                    hint: 'Enter thumbnail URL (optional)',
                    type: AppTextFieldType.text,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionSpacing),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText.h6('Course Settings'),
                  const SizedBox(height: AppSpacing.lg),
                  const AppText.label('Difficulty Level'),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    value: _difficulty,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _difficultyLevels.map((d) => DropdownMenuItem(
                      value: d,
                      child: AppText.bodyMedium(d[0].toUpperCase() + d.substring(1)),
                    )).toList(),
                    onChanged: (v) => setState(() => _difficulty = v ?? _difficulty),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Checkbox(
                        value: _isPublished,
                        onChanged: (v) => setState(() => _isPublished = v ?? false),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Expanded(child: AppText.bodyMedium('Published (students can enroll)')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionSpacing),
            if (_error != null) ...[
              AppContainer(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                borderColor: Theme.of(context).colorScheme.error,
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: AppText.bodyMedium(_error!, color: Theme.of(context).colorScheme.onErrorContainer)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            AppButton(
              text: 'Save Changes',
              onPressed: _loading ? null : _save,
              isLoading: _loading,
              fullWidth: true,
              type: AppButtonType.primary,
              size: AppButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }
}
