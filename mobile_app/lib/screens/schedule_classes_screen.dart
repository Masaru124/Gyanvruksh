import 'package:flutter/material.dart';
import 'package:gyanvruksh/services/enhanced_api_service.dart';
import 'package:gyanvruksh/widgets/app_card.dart';
import 'package:gyanvruksh/widgets/app_text_field.dart';
import 'package:gyanvruksh/widgets/app_button.dart';
import 'package:gyanvruksh/theme/app_theme.dart';

class ScheduleClassesScreen extends StatefulWidget {
  const ScheduleClassesScreen({super.key});

  @override
  State<ScheduleClassesScreen> createState() => _ScheduleClassesScreenState();
}

class _ScheduleClassesScreenState extends State<ScheduleClassesScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _classes = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Use teacher's upcoming schedule endpoint
      final response = await ApiService.getTodaySchedule();
      if (response.isSuccess) {
        setState(() {
          _classes = response.data as List<dynamic>;
        });
      } else {
        setState(() {
          _error = response.userMessage;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openCreateClassDialog() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final courseIdCtrl = TextEditingController();
    final dateTimeCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '60');

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Schedule Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(controller: titleCtrl, label: 'Class Title', required: true),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(controller: descCtrl, label: 'Description'),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(controller: courseIdCtrl, label: 'Course ID', type: AppTextFieldType.number, required: true),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(controller: dateTimeCtrl, label: 'Date & Time (YYYY-MM-DD HH:MM)', required: true),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(controller: durationCtrl, label: 'Duration (minutes)', type: AppTextFieldType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final courseId = int.tryParse(courseIdCtrl.text.trim());
                final dateTimeText = dateTimeCtrl.text.trim();
                final duration = int.tryParse(durationCtrl.text.trim()) ?? 60;
                
                if (title.isEmpty || courseId == null || dateTimeText.isEmpty) return;
                
                try {
                  // This would need a backend endpoint for scheduling classes
                  // For now, just show success and close dialog
                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                } catch (_) {}
              },
              child: const Text('Schedule'),
            ),
          ],
        );
      },
    );

    if (created == true) {
      _loadClasses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Classes'),
        actions: [
          IconButton(
            onPressed: _openCreateClassDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Schedule Class',
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadClasses,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _classes.isEmpty
                    ? const Center(child: Text('No scheduled classes'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.screenPadding),
                        itemCount: _classes.length,
                        itemBuilder: (context, index) {
                          final c = _classes[index] as Map<String, dynamic>;
                          return AppCard(
                            margin: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(c['title'] ?? 'Class', style: const TextStyle(fontWeight: FontWeight.w600))),
                                    Text((c['time'] ?? c['date'] ?? '').toString(), style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(c['description'] ?? c['type'] ?? ''),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    AppButton(
                                      text: 'Join',
                                      onPressed: () {
                                        // Navigate to class/video call
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Joining class...')),
                                        );
                                      },
                                      size: AppButtonSize.small,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    AppButton(
                                      text: 'Edit',
                                      onPressed: () {
                                        // Edit class details
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Edit functionality coming soon')),
                                        );
                                      },
                                      type: AppButtonType.secondary,
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
