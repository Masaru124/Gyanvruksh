import 'package:flutter/material.dart';
import 'package:educonnect/services/api.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<dynamic> myCourses = [];
  List<Map<String, dynamic>> availableCourses = [];
  bool isLoading = true;
  bool isLoadingAvailable = true;
  String? error;
  String? availableError;
  bool isEnrolling = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _loadAvailableCourses();
  }

  Future<void> _loadCourses() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Use getEnrolledCourses instead of myCourses to get enrolled courses
      final courses = await ApiService().getEnrolledCourses();
      setState(() {
        myCourses = courses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadAvailableCourses() async {
    try {
      setState(() {
        isLoadingAvailable = true;
        availableError = null;
      });

      // Use listCourses API to fetch all courses (not only available-for-enrollment)
      final courses = await ApiService().listCourses();
      // Debug log to check the response
      print('Available courses response: $courses');
      final List<Map<String, dynamic>> courseList = courses.map((c) {
        if (c is Map<String, dynamic>) return c;
        if (c is Map) return Map<String, dynamic>.from(c);
        return <String, dynamic>{};
      }).cast<Map<String, dynamic>>().toList();
      setState(() {
        availableCourses = courseList;
        isLoadingAvailable = false;
      });
        } catch (e) {
      setState(() {
        availableError = e.toString();
        isLoadingAvailable = false;
      });
    }
  }

  Future<void> _enrollInCourse(int courseId, String courseTitle) async {
    setState(() => isEnrolling = true);
    try {
      final success = await ApiService().enrollInCourse(courseId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully enrolled in $courseTitle')),
        );
        // Refresh both lists
        await _loadCourses();
        await _loadAvailableCourses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to enroll in course')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error enrolling in course: $e')),
      );
    } finally {
      setState(() => isEnrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Courses'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _loadCourses();
                _loadAvailableCourses();
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Courses'),
              Tab(text: 'Available'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // My Courses Tab
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Error: $error'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadCourses,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : myCourses.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.school, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No courses enrolled yet',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Enroll in courses from the Available tab',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: myCourses.length,
                            itemBuilder: (context, index) {
                              final course = myCourses[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    child: const Icon(Icons.book, color: Colors.white),
                                  ),
                                  title: Text(
                                    course['title'] ?? 'Untitled Course',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    course['description'] ?? 'No description',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    // TODO: Navigate to course details
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Course: ${course['title']}')),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
            // Available Courses Tab
            isLoadingAvailable
                ? const Center(child: CircularProgressIndicator())
                : availableError != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Error: $availableError'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadAvailableCourses,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : availableCourses.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No courses available',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Courses will appear here when teachers are assigned',
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: availableCourses.length,
                            itemBuilder: (context, index) {
                              final course = availableCourses[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green,
                                    child: const Icon(Icons.add, color: Colors.white),
                                  ),
                                  title: Text(
                                    course['title'] ?? 'Untitled Course',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    course['description'] ?? 'No description',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: isEnrolling ? null : () => _enrollInCourse(course['id'], course['title']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: isEnrolling
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text('Enroll'),
                                  ),
                                ),
                              );
                            },
                          ),
          ],
        ),
      ),
    );
  }
}
