import 'package:flutter/material.dart';
import 'package:gyanvruksh/services/enhanced_api_service.dart';
import 'package:gyanvruksh/widgets/app_button.dart';
import 'package:gyanvruksh/widgets/app_text_field.dart';
import 'package:gyanvruksh/widgets/app_card.dart';
import 'package:gyanvruksh/theme/app_theme.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final totalHoursCtrl = TextEditingController();
  final thumbnailUrlCtrl = TextEditingController();
  bool loading = false;
  String? error;
  String selectedDifficulty = 'beginner';
  bool isPublished = false;
  
  final List<String> difficultyLevels = ['beginner', 'intermediate', 'advanced'];

  void _createCourse() async {
    setState(() {
      loading = true;
      error = null;
    });

    if (titleCtrl.text.isEmpty || descCtrl.text.isEmpty || totalHoursCtrl.text.isEmpty) {
      setState(() {
        error = "Please fill all required fields";
        loading = false;
      });
      return;
    }

    try {
      final totalHours = int.tryParse(totalHoursCtrl.text.trim());
      final response = await ApiService.post('/api/courses/create', {
        'title': titleCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'total_hours': totalHours,
        'difficulty': selectedDifficulty,
        'thumbnail_url': thumbnailUrlCtrl.text.trim().isEmpty ? null : thumbnailUrlCtrl.text.trim(),
        'is_published': isPublished,
      });

      if (response.isSuccess) {
        // Clear form and navigate back
        titleCtrl.clear();
        descCtrl.clear();
        totalHoursCtrl.clear();
        thumbnailUrlCtrl.clear();
        setState(() {
          selectedDifficulty = 'beginner';
          isPublished = false;
          loading = false;
        });

        Navigator.pop(context, true);
      } else {
        setState(() {
          error = response.userMessage;
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText.h5('Create Course'),
        backgroundColor: Theme.of(context).colorScheme.surface,
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
                    controller: titleCtrl,
                    label: 'Course Title',
                    hint: 'Enter course title',
                    required: true,
                    type: AppTextFieldType.text,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  AppTextField(
                    controller: descCtrl,
                    label: 'Course Description',
                    hint: 'Enter detailed course description',
                    required: true,
                    type: AppTextFieldType.multiline,
                    maxLines: 4,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  AppTextField(
                    controller: totalHoursCtrl,
                    label: 'Total Hours',
                    hint: 'Enter estimated course duration in hours',
                    required: true,
                    type: AppTextFieldType.number,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  AppTextField(
                    controller: thumbnailUrlCtrl,
                    label: 'Thumbnail URL',
                    hint: 'Enter course thumbnail image URL (optional)',
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
                    value: selectedDifficulty,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: difficultyLevels.map((String difficulty) {
                      return DropdownMenuItem<String>(
                        value: difficulty,
                        child: AppText.bodyMedium(
                          difficulty[0].toUpperCase() + difficulty.substring(1),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedDifficulty = newValue;
                        });
                      }
                    },
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  Row(
                    children: [
                      Checkbox(
                        value: isPublished,
                        onChanged: (bool? value) {
                          setState(() {
                            isPublished = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Expanded(
                        child: AppText.bodyMedium(
                          'Publish course immediately (students can enroll)',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.sectionSpacing),
            
            if (error != null) ...[
              AppContainer(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                borderColor: Theme.of(context).colorScheme.error,
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppText.bodyMedium(
                        error!,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            
            AppButton(
              text: 'Create Course',
              onPressed: loading ? null : _createCourse,
              isLoading: loading,
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
