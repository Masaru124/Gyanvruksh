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
    print("📚 Course creation started");
    print("📝 Title: ${titleCtrl.text}");
    print("📝 Description: ${descCtrl.text}");

    setState(() {
      loading = true;
      error = null;
    });

    if (titleCtrl.text.isEmpty || descCtrl.text.isEmpty) {
      print("⚠️ Validation failed: Empty fields");
      setState(() {
        error = "Please fill all required fields";
        loading = false;
      });
      return;
    }

    try {
      print("📡 Calling ApiService().createCourse()");
      final ok = await ApiService().createCourse(titleCtrl.text, descCtrl.text);
      print("📡 Create course API response: $ok");

      if (ok) {
        print("✅ Course created successfully");
        if (!mounted) {
          print("⚠️ Widget not mounted after course creation");
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
        print("🔄 Waiting 1 second before navigation");
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          print("🚀 Navigating back with success result");
          Navigator.of(context).pop(true); // Pass true to indicate success
        } else {
          print("⚠️ Widget not mounted during navigation");
        }
      } else {
        print("❌ Course creation failed");
        setState(() {
          error = "Failed to create course";
        });
      }
    } catch (e) {
      print("💥 Course creation error: $e");
      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        print("🔄 Setting loading to false");
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
