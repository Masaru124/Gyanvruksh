import 'package:flutter/material.dart';
import 'package:educonnect/services/api.dart';
import 'package:educonnect/screens/courses_screen.dart';
import 'package:educonnect/screens/messages_screen.dart';
import 'package:educonnect/screens/profile_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;

  // Data from API
  List<Map<String, dynamic>> availableCourses = [];
  List<Map<String, dynamic>> upcomingClasses = [];
  List<Map<String, dynamic>> studentQueries = [];
  Map<String, dynamic> performanceStats = {};

  // Loading states
  bool isLoadingCourses = true;
  bool isLoadingClasses = true;
  bool isLoadingQueries = true;
  bool isLoadingStats = true;
  bool isSelectingCourse = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadAvailableCourses(),
      _loadUpcomingClasses(),
      _loadStudentQueries(),
      _loadPerformanceStats(),
    ]);
  }

  Future<void> _loadAvailableCourses() async {
    setState(() => isLoadingCourses = true);
    try {
      final data = await ApiService().availableCourses();
      setState(() {
        availableCourses = data.map((course) => course as Map<String, dynamic>).toList();
        isLoadingCourses = false;
      });
    } catch (e) {
      setState(() => isLoadingCourses = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load available courses: $e')),
      );
    }
  }

  Future<void> _loadUpcomingClasses() async {
    setState(() => isLoadingClasses = true);
    try {
      final data = await ApiService().upcomingClasses();
      setState(() {
        upcomingClasses = data.map((classInfo) => classInfo as Map<String, dynamic>).toList();
        isLoadingClasses = false;
      });
    } catch (e) {
      setState(() => isLoadingClasses = false);
      // Use fallback data if API fails
      setState(() {
        upcomingClasses = [
          {'subject': 'Mathematics', 'time': '9:00 AM', 'class': 'Grade 10A'},
          {'subject': 'Physics', 'time': '11:00 AM', 'class': 'Grade 11B'},
          {'subject': 'English', 'time': '2:00 PM', 'class': 'Grade 9C'},
        ];
        isLoadingClasses = false;
      });
    }
  }

  Future<void> _loadStudentQueries() async {
    setState(() => isLoadingQueries = true);
    try {
      final data = await ApiService().studentQueries();
      setState(() {
        studentQueries = data.map((query) => query as Map<String, dynamic>).toList();
        isLoadingQueries = false;
      });
    } catch (e) {
      setState(() => isLoadingQueries = false);
      // Use fallback data if API fails
      setState(() {
        studentQueries = [
          {'student': 'Alice Johnson', 'query': 'Need help with quadratic equations', 'time': '2 hours ago'},
          {'student': 'Bob Smith', 'query': 'Clarification on Newton\'s laws', 'time': '4 hours ago'},
          {'student': 'Carol Davis', 'query': 'Assignment deadline extension', 'time': '1 day ago'},
        ];
        isLoadingQueries = false;
      });
    }
  }

  Future<void> _loadPerformanceStats() async {
    setState(() => isLoadingStats = true);
    try {
      final data = await ApiService().teacherStats();
      setState(() {
        performanceStats = data;
        isLoadingStats = false;
      });
    } catch (e) {
      setState(() => isLoadingStats = false);
      // Use fallback data if API fails
      setState(() {
        performanceStats = {
          'totalStudents': 45,
          'averageAttendance': 92,
          'engagementRate': 87,
          'completedAssignments': 156,
        };
        isLoadingStats = false;
      });
    }
  }

  Future<void> _selectCourse(int courseId, String courseTitle) async {
    setState(() => isSelectingCourse = true);
    try {
      final success = await ApiService().selectCourse(courseId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully selected $courseTitle')),
        );
        // Reload available courses to remove the selected one
        await _loadAvailableCourses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to select course')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting course: $e')),
      );
    } finally {
      setState(() => isSelectingCourse = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on selected index
    switch (index) {
      case 0: // Home - already on dashboard
        break;
      case 1: // Courses
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CoursesScreen()),
        );
        break;
      case 2: // Messages
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MessagesScreen()),
        );
        break;
      case 3: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  Widget _buildAvailableCourses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Available Courses to Teach',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3A59),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: isLoadingCourses
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                  ),
                )
              : availableCourses.isEmpty
                  ? const Center(
                      child: Text(
                        'No available courses at the moment',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: availableCourses.length,
                      itemBuilder: (context, index) {
              final course = availableCourses[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course['description'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: isSelectingCourse ? null : () => _selectCourse(course['id'], course['title']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF667EEA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: isSelectingCourse
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                                ),
                              )
                            : const Text('Select Course'),
                      ),
                    ],
                  ),
                ),
              );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildUpcomingClasses() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Classes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A59),
            ),
          ),
          const SizedBox(height: 16),
          ...upcomingClasses.map((classInfo) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.class_,
                    color: Color(0xFF667EEA),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classInfo['subject'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E3A59),
                        ),
                      ),
                      Text(
                        '${classInfo['class']} • ${classInfo['time']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStudentQueries() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Queries',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A59),
            ),
          ),
          const SizedBox(height: 16),
          ...studentQueries.map((query) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF764BA2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.question_answer,
                    color: Color(0xFF764BA2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        query['student'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E3A59),
                        ),
                      ),
                      Text(
                        query['query'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        query['time'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: isLoadingStats
                    ? _buildLoadingCard()
                    : _buildStatCard(
                        'Total Students',
                        performanceStats['totalStudents']?.toString() ?? '0',
                        Icons.people,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isLoadingStats
                    ? _buildLoadingCard()
                    : _buildStatCard(
                        'Avg Attendance',
                        '${performanceStats['averageAttendance'] ?? 0}%',
                        Icons.calendar_today,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: isLoadingStats
                    ? _buildLoadingCard()
                    : _buildStatCard(
                        'Engagement',
                        '${performanceStats['engagementRate'] ?? 0}%',
                        Icons.trending_up,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isLoadingStats
                    ? _buildLoadingCard()
                    : _buildStatCard(
                        'Assignments',
                        performanceStats['completedAssignments']?.toString() ?? '0',
                        Icons.assignment_turned_in,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'EduConnect Teacher',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvailableCourses(),
            const SizedBox(height: 24),
            _buildUpcomingClasses(),
            const SizedBox(height: 24),
            _buildStudentQueries(),
            const SizedBox(height: 24),
            _buildPerformanceOverview(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF667EEA),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
