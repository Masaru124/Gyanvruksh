import 'package:flutter/material.dart';
import 'package:educonnect/services/api.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List<dynamic> courses = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService().listCourses();
    setState(() { courses = data; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView.builder(
            itemCount: courses.length,
            itemBuilder: (ctx,i) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(courses[i]['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(courses[i]['description']),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
