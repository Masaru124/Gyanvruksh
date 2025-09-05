import 'package:flutter/material.dart';
import 'package:educonnect/screens/admin_dashboard.dart';
import 'package:educonnect/screens/dashboard.dart';
import 'package:educonnect/screens/teacher_dashboard.dart';
import 'package:educonnect/screens/create_course.dart';
import 'package:educonnect/screens/create_admin.dart';
import 'package:educonnect/screens/manage_users.dart';
import 'package:educonnect/screens/courses_screen.dart';

class NavigationScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const NavigationScreen({super.key, required this.user});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _studentPages;
  late final List<Widget> _adminPages;

  @override
  void initState() {
    super.initState();
    _studentPages = <Widget>[
      const DashboardScreen(),
      const CoursesScreen(), // Added CoursesScreen to student pages
      // Add other student pages here
    ];
    _adminPages = <Widget>[
      const AdminDashboardScreen(),
      const CreateCourseScreen(),
      const CreateAdminScreen(),
      const ManageUsersScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rawRole = widget.user['role'] ?? '';
    final role = rawRole.toString().trim().toLowerCase();
    final isAdmin = role == 'admin';
    final isTeacher = role == 'service_provider' || widget.user['is_teacher'] == true;

    // If teacher, show teacher dashboard directly
    if (isTeacher) {
      return const TeacherDashboard();
    }

    final pages = isAdmin ? _adminPages : _studentPages;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Admin Navigation' : 'User Navigation'),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 30,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        items: isAdmin
            ? const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Create Course'),
                BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Create Admin'),
                BottomNavigationBarItem(icon: Icon(Icons.manage_accounts), label: 'Manage Users'),
              ]
            : const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Courses'),
                // Add other student navigation items here
              ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
