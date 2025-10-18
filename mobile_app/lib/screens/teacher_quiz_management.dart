import 'package:flutter/material.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:gyanvruksh/widgets/app_card.dart';
import 'package:gyanvruksh/widgets/app_button.dart';
import 'package:gyanvruksh/widgets/app_text_field.dart';
import 'package:gyanvruksh/theme/app_theme.dart';

class TeacherQuizManagementScreen extends StatefulWidget {
  const TeacherQuizManagementScreen({super.key});

  @override
  State<TeacherQuizManagementScreen> createState() => _TeacherQuizManagementScreenState();
}

class _TeacherQuizManagementScreenState extends State<TeacherQuizManagementScreen> {
  List<dynamic> _quizzes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final quizzes = await ApiService().getTeacherQuizzes();
      setState(() {
        _quizzes = quizzes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load quizzes: $e';
        _isLoading = false;
        // Fallback data for testing
        _quizzes = [];
      });
    }
  }

  Future<void> _createQuiz() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const CreateQuizDialog(),
    );

    if (result != null) {
      try {
        await ApiService().createQuiz(
          title: result['title'],
          description: result['description'],
          courseId: result['courseId'],
          timeLimit: result['timeLimit'],
          questions: result['questions'],
        );
        
        _loadQuizzes(); // Refresh list
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quiz created successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create quiz: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Management'),
        actions: [
          IconButton(
            onPressed: _createQuiz,
            icon: const Icon(Icons.add),
            tooltip: 'Create Quiz',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadQuizzes,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red[300]),
                        const SizedBox(height: AppSpacing.md),
                        Text(_error!),
                        const SizedBox(height: AppSpacing.md),
                        AppButton(
                          text: 'Retry',
                          onPressed: _loadQuizzes,
                        ),
                      ],
                    ),
                  )
                : _quizzes.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.quiz, size: 64, color: Colors.grey),
                            SizedBox(height: AppSpacing.md),
                            Text('No quizzes created yet'),
                            SizedBox(height: AppSpacing.sm),
                            Text('Tap + to create your first quiz'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.screenPadding),
                        itemCount: _quizzes.length,
                        itemBuilder: (context, index) {
                          final quiz = _quizzes[index];
                          return _buildQuizCard(quiz);
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createQuiz,
        child: const Icon(Icons.add),
        tooltip: 'Create Quiz',
      ),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz['title'] ?? 'Untitled Quiz',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      quiz['description'] ?? 'No description',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: quiz['is_published'] == true 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Text(
                  quiz['is_published'] == true ? 'Published' : 'Draft',
                  style: TextStyle(
                    color: quiz['is_published'] == true ? Colors.green : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.timer, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${quiz['time_limit'] ?? 30} minutes',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(Icons.quiz, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${quiz['question_count'] ?? 0} questions',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Edit',
                  onPressed: () => _editQuiz(quiz),
                  type: AppButtonType.secondary,
                  size: AppButtonSize.small,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  text: quiz['is_published'] == true ? 'Unpublish' : 'Publish',
                  onPressed: () => _togglePublish(quiz),
                  type: AppButtonType.primary,
                  size: AppButtonSize.small,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editQuiz(Map<String, dynamic> quiz) {
    // Navigate to quiz editing screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quiz editing feature coming soon')),
    );
  }

  Future<void> _togglePublish(Map<String, dynamic> quiz) async {
    try {
      final newStatus = !(quiz['is_published'] ?? false);
      await ApiService().updateQuizStatus(quiz['id'], newStatus);
      
      setState(() {
        quiz['is_published'] = newStatus;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus ? 'Quiz published!' : 'Quiz unpublished!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update quiz: $e')),
        );
      }
    }
  }
}

class CreateQuizDialog extends StatefulWidget {
  const CreateQuizDialog({super.key});

  @override
  State<CreateQuizDialog> createState() => _CreateQuizDialogState();
}

class _CreateQuizDialogState extends State<CreateQuizDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _courseIdController = TextEditingController();
  final _timeLimitController = TextEditingController(text: '30');
  final List<Map<String, dynamic>> _questions = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Quiz'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _titleController,
              label: 'Quiz Title',
              required: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _descriptionController,
              label: 'Description',
              type: AppTextFieldType.multiline,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _courseIdController,
              label: 'Course ID',
              type: AppTextFieldType.number,
              required: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _timeLimitController,
              label: 'Time Limit (minutes)',
              type: AppTextFieldType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createQuiz,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createQuiz() {
    if (_titleController.text.trim().isEmpty || _courseIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields')),
      );
      return;
    }

    Navigator.pop(context, {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'courseId': int.tryParse(_courseIdController.text.trim()) ?? 0,
      'timeLimit': int.tryParse(_timeLimitController.text.trim()) ?? 30,
      'questions': _questions,
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _courseIdController.dispose();
    _timeLimitController.dispose();
    super.dispose();
  }
}
