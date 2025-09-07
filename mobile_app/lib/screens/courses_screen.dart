import 'package:flutter/material.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:gyanvruksh/screens/video_player_screen.dart';

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

  void _navigateToCourseDetails(dynamic course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsScreen(course: course),
      ),
    );
  }

  void _navigateToVideoPlayer(int courseId, String courseTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(courseId: courseId, courseTitle: courseTitle),
      ),
    );
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
                                    _navigateToCourseDetails(course);
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

class CourseDetailsScreen extends StatefulWidget {
  final dynamic course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  void _navigateToVideoPlayer(int courseId, String courseTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(courseId: courseId, courseTitle: courseTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course['title'] ?? 'Course Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Icon(
                          Icons.book,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.course['title'] ?? 'Untitled Course',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.course['description'] ?? 'No description available',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Course details
            const Text(
              'Course Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A59),
              ),
            ),
            const SizedBox(height: 16),

            // Course details cards
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow('Course ID', widget.course['id']?.toString() ?? 'N/A'),
                    const Divider(),
                    _buildDetailRow('Subject', widget.course['subject'] ?? 'Not specified'),
                    const Divider(),
                    _buildDetailRow('Grade Level', widget.course['grade_level'] ?? 'Not specified'),
                    const Divider(),
                    _buildDetailRow('Duration', widget.course['duration'] ?? 'Not specified'),
                    const Divider(),
                    _buildDetailRow('Credits', widget.course['credits']?.toString() ?? 'Not specified'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Additional information
            if (widget.course['prerequisites'] != null && widget.course['prerequisites'].isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prerequisites',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3A59),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.course['prerequisites'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Watch Videos Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _navigateToVideoPlayer(widget.course['id'], widget.course['title']),
                icon: const Icon(Icons.play_circle_fill, size: 28),
                label: const Text(
                  'Watch Course Videos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Learning objectives
            if (widget.course['objectives'] != null && widget.course['objectives'].isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Learning Objectives',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3A59),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.course['objectives'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2E3A59),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
