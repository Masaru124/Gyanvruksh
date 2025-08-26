import 'package:flutter/material.dart';
import 'package:educonnect/services/api.dart';
import 'package:educonnect/screens/teacher_dashboard.dart';
import 'package:educonnect/screens/student_dashboard.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? me;

  @override
  void initState() {
    super.initState();
    me = ApiService().me();
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = me != null && me!['is_teacher'] == true;
    return isTeacher ? const TeacherDashboard() : const StudentDashboard();
  }
}
