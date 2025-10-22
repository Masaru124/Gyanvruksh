import 'package:flutter/material.dart';
import 'package:gyanvruksh/services/enhanced_api_service.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/screens/attendance_management.dart';
import 'package:gyanvruksh/screens/create_course.dart';
import 'package:gyanvruksh/screens/edit_course.dart';

class TeacherCourseManagementScreen extends StatefulWidget {
  const TeacherCourseManagementScreen({super.key});

  @override
  State<TeacherCourseManagementScreen> createState() =>
      _TeacherCourseManagementScreenState();
}

class _TeacherCourseManagementScreenState
    extends State<TeacherCourseManagementScreen> {
  List<dynamic> _myCourses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMyCourses();
  }

  Future<void> _loadMyCourses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final coursesResult = await ApiService.myCourses();
      final courses = coursesResult.isSuccess ? (coursesResult.data as List<dynamic>?) ?? [] : [];

      // Load enrollment data for each course
      for (var course in courses) {
        if (course is Map<String, dynamic> && course['id'] != null) {
          try {
            final enrollmentsResult =
                await ApiService.getCourseEnrollments(course['id']);
            final enrollments = enrollmentsResult.isSuccess ? (enrollmentsResult.data as List<dynamic>?) ?? [] : [];
            course['enrollment_count'] = enrollments.length;
            course['enrollments'] = enrollments;
          } catch (e) {
            course['enrollment_count'] = 0;
            course['enrollments'] = [];
          }
        }
      }

      setState(() {
        _myCourses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load courses: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToAttendance(Map<String, dynamic> course) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceManagementScreen(
          courseId: course['id'],
          courseTitle: course['title'],
        ),
      ),
    );
  }

  Future<void> _navigateToCreateCourse() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateCourseScreen()),
    );

    if (result == true) {
      _loadMyCourses(); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _navigateToCreateCourse,
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Create New Course',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red[300], size: 64),
                        const SizedBox(height: 16),
                        Text(_error!,
                            style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadMyCourses,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadMyCourses,
                    child: _myCourses.isEmpty
                        ? _buildEmptyState()
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              _buildStatsCard(),
                              const SizedBox(height: 20),
                              _buildCoursesGrid(),
                            ],
                          ),
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateCourse,
        backgroundColor: Colors.white.withOpacity(0.9),
        foregroundColor: const Color(0xFF667EEA),
        icon: const Icon(Icons.add),
        label: const Text('New Course'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school,
            size: 80,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(height: 20),
          const Text(
            'No courses yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Create your first course to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _navigateToCreateCourse,
            icon: const Icon(Icons.add),
            label: const Text('Create Course'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF667EEA),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalCourses = _myCourses.length;
    final publishedCourses =
        _myCourses.where((c) => c['is_published'] == true).length;
    final totalEnrollments = _myCourses.fold<int>(
        0, (sum, course) => sum + (course['enrollment_count'] as int? ?? 0));

    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Course Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Courses',
                    totalCourses.toString(),
                    Icons.book,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Published',
                    publishedCourses.toString(),
                    Icons.publish,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Enrollments',
                    totalEnrollments.toString(),
                    Icons.people,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCoursesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Courses',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _myCourses.length,
          itemBuilder: (context, index) {
            final course = _myCourses[index];
            return _buildCourseCard(course);
          },
        ),
      ],
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final isPublished = course['is_published'] ?? false;
    final enrollmentCount = course['enrollment_count'] ?? 0;
    final rating = course['rating'] ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassmorphismCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course['title'] ?? 'Untitled Course',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course['description'] ?? 'No description',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPublished
                          ? Colors.green.withOpacity(0.8)
                          : Colors.orange.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isPublished ? 'Published' : 'Draft',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.people, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$enrollmentCount students',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    course['difficulty'] ?? 'Beginner',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToAttendance(course),
                      icon: const Icon(Icons.assignment_turned_in, size: 16),
                      label: const Text('Attendance'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _viewCourseDetails(course),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Manage'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewCourseDetails(Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCourseScreen(course: course),
      ),
    ).then((updated) {
      if (updated == true) {
        _loadMyCourses();
      }
    });
  }
}
