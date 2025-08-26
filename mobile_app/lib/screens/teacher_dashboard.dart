import 'package:flutter/material.dart';
import 'package:educonnect/services/api.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});
  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  List<dynamic> courses = [];
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService().myCourses();
    setState(() { courses = data; });
  }

  Future<void> _create() async {
    setState(() { loading = true; });
    final ok = await ApiService().createCourse(titleCtrl.text, descCtrl.text);
    setState(() { loading = false; titleCtrl.clear(); descCtrl.clear(); });
    if (ok) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Course title')),
                    const SizedBox(height: 8),
                    TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Short description')),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: loading ? null : _create, child: loading ? const CircularProgressIndicator() : const Text('Create course'))
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: courses.length,
                itemBuilder: (ctx,i) => ListTile(
                  title: Text(courses[i]['title']),
                  subtitle: Text(courses[i]['description']),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
