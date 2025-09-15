import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:gyanvruksh/screens/video_player_screen.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/widgets/custom_animated_button.dart';
import 'package:gyanvruksh/widgets/neumorphism_container.dart';
import 'package:gyanvruksh/widgets/backgrounds/cinematic_background.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/floating_elements.dart';
import 'package:gyanvruksh/widgets/animated_wave_background.dart';
import 'package:gyanvruksh/widgets/micro_interactions.dart';
import 'package:gyanvruksh/widgets/animated_text_widget.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';


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



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Stack(
          children: [
            // Cinematic Background
            CinematicBackground(isDark: false),

            // Enhanced Particle Background
            ParticleBackground(
              particleCount: 35,
              maxParticleSize: 4.0,
              particleColor: FuturisticColors.primary,
            ),

            // Floating Elements
            FloatingElements(
              elementCount: 10,
              maxElementSize: 50,
              icons: const [
                Icons.book,
                Icons.school,
                Icons.lightbulb,
                Icons.computer,
                Icons.star,
                Icons.grade,
                Icons.access_time,
                Icons.explore,
                Icons.search,
                Icons.play_circle,
              ],
            ),

            // Animated Wave Background
            AnimatedWaveBackground(
              color: FuturisticColors.neonBlue.withOpacity(0.05),
              height: MediaQuery.of(context).size.height,
            ),

            SafeArea(
              child: Column(
                children: [
                  // Modern Header with Glassmorphism
                  GlassmorphismCard(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    padding: const EdgeInsets.all(16),
                    blurStrength: 15,
                    opacity: 0.1,
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      children: [
                        MicroInteractionWrapper(
                          child: NeumorphismContainer(
                            padding: const EdgeInsets.all(12),
                            borderRadius: BorderRadius.circular(16),
                            child: Icon(
                              FontAwesomeIcons.graduationCap,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AnimatedTextWidget(
                            text: 'My Learning Journey',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: FuturisticColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            animationType: AnimationType.fade,
                            duration: const Duration(milliseconds: 800),
                          ),
                        ),
                        MicroInteractionWrapper(
                          child: IconButton(
                            onPressed: () {
                              _loadCourses();
                              _loadAvailableCourses();
                            },
                            icon: Icon(
                              Icons.refresh,
                              color: colorScheme.primary,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.surface.withOpacity(0.8),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.2, end: 0, duration: 500.ms),

                  // Modern Tab Bar with Glassmorphism
                  GlassmorphismCard(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(4),
                    blurStrength: 12,
                    opacity: 0.15,
                    borderRadius: BorderRadius.circular(20),
                    child: TabBar(
                      indicator: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            FuturisticColors.primary,
                            FuturisticColors.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: FuturisticColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      labelColor: colorScheme.onPrimary,
                      unselectedLabelColor: colorScheme.onSurface.withOpacity(0.8),
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.book),
                              SizedBox(width: 8),
                              Text('My Courses'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.explore),
                              SizedBox(width: 8),
                              Text('Discover'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideY(begin: -0.1, end: 0, duration: 400.ms),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      children: [
                        // My Courses Tab
                        _buildMyCoursesTab(theme, colorScheme),
                        // Available Courses Tab
                        _buildAvailableCoursesTab(theme, colorScheme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyCoursesTab(ThemeData theme, ColorScheme colorScheme) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading your courses...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomAnimatedButton(
              onPressed: _loadCourses,
              text: 'Try Again',
              backgroundColor: colorScheme.primary,
              textColor: colorScheme.onPrimary,
            ),
          ],
        ),
      );
    }

    if (myCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeumorphismContainer(
              padding: const EdgeInsets.all(32),
              borderRadius: BorderRadius.circular(80),
              child: Icon(
                FontAwesomeIcons.bookOpen,
                size: 64,
                color: colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ready to start learning?',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore available courses and begin your journey',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomAnimatedButton(
              onPressed: () => DefaultTabController.of(context).animateTo(1),
              text: 'Browse Courses',
              backgroundColor: colorScheme.primary,
              textColor: colorScheme.onPrimary,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: myCourses.length,
      itemBuilder: (context, index) {
        final course = myCourses[index];
        return _buildCourseCard(course, index, true, theme, colorScheme);
      },
    );
  }

  Widget _buildAvailableCoursesTab(ThemeData theme, ColorScheme colorScheme) {
    if (isLoadingAvailable) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Discovering courses...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (availableError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load courses',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              availableError!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomAnimatedButton(
              onPressed: _loadAvailableCourses,
              text: 'Retry',
              backgroundColor: colorScheme.primary,
              textColor: colorScheme.onPrimary,
            ),
          ],
        ),
      );
    }

    if (availableCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeumorphismContainer(
              padding: const EdgeInsets.all(32),
              borderRadius: BorderRadius.circular(80),
              child: Icon(
                FontAwesomeIcons.magnifyingGlass,
                size: 64,
                color: colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No courses available yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Courses will appear here once teachers add them',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: availableCourses.length,
      itemBuilder: (context, index) {
        final course = availableCourses[index];
        return _buildCourseCard(course, index, false, theme, colorScheme);
      },
    );
  }

  Widget _buildCourseCard(dynamic course, int index, bool isEnrolled, ThemeData theme, ColorScheme colorScheme) {
    return GlassmorphismCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      blurStrength: 10,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _navigateToCourseDetails(course),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                NeumorphismContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(12),
                  child: Icon(
                    isEnrolled ? FontAwesomeIcons.bookOpen : FontAwesomeIcons.plus,
                    color: isEnrolled ? colorScheme.primary : Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['title'] ?? 'Untitled Course',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course['subject'] ?? 'General',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isEnrolled)
                  CustomAnimatedButton(
                    onPressed: isEnrolling ? () {} : () => _enrollInCourse(course['id'], course['title']),
                    width: 80,
                    height: 36,
                    backgroundColor: Colors.green,
                    text: isEnrolling ? '...' : 'Enroll',
                    textColor: Colors.white,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              course['description'] ?? 'No description available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  course['duration'] ?? 'Duration not specified',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.grade,
                  size: 16,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  course['grade_level'] ?? 'All levels',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100))
        .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: Duration(milliseconds: index * 100));
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
