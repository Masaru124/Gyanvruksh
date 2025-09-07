import 'package:flutter/material.dart';
import 'package:gyanvruksh/services/api.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  bool loading = false;
  String? error;

  void _createCourse() async {
    setState(() {
      loading = true;
      error = null;
    });

    if (titleCtrl.text.isEmpty || descCtrl.text.isEmpty) {
      setState(() {
        error = "Please fill all required fields";
        loading = false;
      });
      return;
    }

    try {
      final ok = await ApiService().createCourse(titleCtrl.text, descCtrl.text);

      if (ok) {
        if (!mounted) {
          return;
        }

        // Clear the form
        titleCtrl.clear();
        descCtrl.clear();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course created successfully')),
        );

        // Navigate back after showing the message
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop(true); // Pass true to indicate success
        }
      } else {
        setState(() {
          error = "Failed to create course";
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
      appBar: AppBar(title: const Text('Create Course')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Course Title *'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Course Description *'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: loading ? null : _createCourse,
              child: loading ? const CircularProgressIndicator() : const Text('Create Course'),
            ),
          ],
        ),
      ),
    );
  }
}
