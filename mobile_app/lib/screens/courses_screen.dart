import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:gyanvruksh/services/enhanced_api_service.dart';
import 'package:gyanvruksh/screens/video_player_screen.dart';
import 'package:gyanvruksh/screens/lesson_screen.dart';
import 'package:gyanvruksh/viewmodels/lesson_viewmodel.dart';
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

      // Use getEnrolledCourses to get enrolled courses - returns List<dynamic>
      final response = await ApiService.getEnrolledCourses();
      setState(() {
        myCourses = response.isSuccess ? (response.data as List<dynamic>?) ?? [] : [];
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
      final response = await ApiService.listCourses();
      // Debug log to check the response
      print('Available courses response: $response');
      final List<Map<String, dynamic>> courseList = response.isSuccess
          ? (response.data as List<dynamic>?)
                  ?.map((c) {
                    if (c is Map<String, dynamic>) return c;
                    if (c is Map) return Map<String, dynamic>.from(c);
                    return <String, dynamic>{};
                  })
                  .cast<Map<String, dynamic>>()
                  .toList() ??
              []
          : [];
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
      // Use the enhanced API service enrollment method
      final response = await ApiService.enrollInCourse(courseId);

      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully enrolled in $courseTitle!')),
        );
        _loadCourses(); // Refresh to update enrollment status
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.userMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enrollment error: Please check your connection and try again')),
      );
      // Enrollment error: $e - logged for debugging
    } finally {
      setState(() => isEnrolling = false);
    }
  }

  void _navigateToCourseDetails(dynamic course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider<LessonViewModel>(
          create: (_) => LessonViewModel(),
          child: CourseDetailsScreen(course: course),
        ),
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
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        // Modern Header with Glassmorphism
                        GlassmorphismCard(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
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
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: FuturisticColors.primary
                                            .withOpacity(0.3),
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
                                    backgroundColor:
                                        colorScheme.surface.withOpacity(0.8),
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
                                  color:
                                      FuturisticColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            labelColor: colorScheme.onPrimary,
                            unselectedLabelColor:
                                colorScheme.onSurface.withOpacity(0.8),
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
                      ],
                    ),
                  ),
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

  Widget _buildCourseCard(dynamic course, int index, bool isEnrolled,
      ThemeData theme, ColorScheme colorScheme) {
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
                    isEnrolled
                        ? FontAwesomeIcons.bookOpen
                        : FontAwesomeIcons.plus,
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
                    onPressed: isEnrolling
                        ? () {}
                        : () => _enrollInCourse(course['id'], course['title']),
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
        .slideY(
            begin: 0.2,
            end: 0,
            duration: 500.ms,
            delay: Duration(milliseconds: index * 100));
  }
}

class CourseDetailsScreen extends StatefulWidget {
  final dynamic course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  List<dynamic> lessons = [];
  List<dynamic> quizzes = [];
  bool isLoadingLessons = true;
  bool isLoadingQuizzes = true;
  String? lessonsError;
  String? quizzesError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLessons();
      _loadQuizzes();
    });
  }

  Future<void> _loadLessons() async {
    try {
      setState(() {
        isLoadingLessons = true;
        lessonsError = null;
      });
      final lessonVM = context.read<LessonViewModel>();
      await lessonVM.loadLessons(courseId: widget.course['id']);
      setState(() {
        lessons = lessonVM.lessons;
        isLoadingLessons = false;
      });
    } catch (e) {
      setState(() {
        lessonsError = e.toString();
        isLoadingLessons = false;
      });
    }
  }

  Future<void> _loadQuizzes() async {
    try {
      setState(() {
        isLoadingQuizzes = true;
        quizzesError = null;
      });
      // For now, we'll use a placeholder since quiz loading isn't implemented in the viewmodel
      // TODO: Implement quiz loading in viewmodel
      setState(() {
        quizzes = [];
        isLoadingQuizzes = false;
      });
    } catch (e) {
      setState(() {
        quizzesError = e.toString();
        isLoadingQuizzes = false;
      });
    }
  }

  void _navigateToLesson(int lessonId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(lessonId: lessonId),
      ),
    );
  }

  void _navigateToVideoPlayer(int courseId, String courseTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            VideoPlayerScreen(courseId: courseId, courseTitle: courseTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Cinematic Background
          CinematicBackground(isDark: false),

          // Enhanced Particle Background
          ParticleBackground(
            particleCount: 25,
            maxParticleSize: 3.0,
            particleColor: FuturisticColors.primary,
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                GlassmorphismCard(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  blurStrength: 15,
                  opacity: 0.1,
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back,
                            color: colorScheme.onSurface),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.course['title'] ?? 'Course Details',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.course['description'] ?? 'No description',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Tabs
                Expanded(
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        TabBar(
                          tabs: const [
                            Tab(text: 'Lessons'),
                            Tab(text: 'Quizzes'),
                            Tab(text: 'Info'),
                          ],
                          labelColor: colorScheme.primary,
                          unselectedLabelColor: colorScheme.onSurfaceVariant,
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildLessonsTab(theme, colorScheme),
                              _buildQuizzesTab(theme, colorScheme),
                              _buildInfoTab(theme, colorScheme),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsTab(ThemeData theme, ColorScheme colorScheme) {
    if (isLoadingLessons) {
      return const Center(child: CircularProgressIndicator());
    }

    if (lessonsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: colorScheme.error),
            const SizedBox(height: 16),
            Text('Error loading lessons', style: theme.textTheme.bodyLarge),
            Text(lessonsError!, style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            CustomAnimatedButton(
              onPressed: _loadLessons,
              text: 'Retry',
              backgroundColor: colorScheme.primary,
              textColor: colorScheme.onPrimary,
            ),
          ],
        ),
      );
    }

    if (lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book,
                size: 64, color: colorScheme.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No lessons available', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Lessons will be added by the instructor',
                style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return GlassmorphismCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          blurStrength: 10,
          opacity: 0.1,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            leading: NeumorphismContainer(
              padding: const EdgeInsets.all(12),
              borderRadius: BorderRadius.circular(12),
              child: Icon(
                _getContentTypeIcon(lesson['content_type']),
                color: colorScheme.primary,
              ),
            ),
            title: Text(
              lesson['title'] ?? 'Untitled Lesson',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${lesson['duration_minutes'] ?? 0} minutes • ${lesson['content_type'] ?? 'Unknown'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(Icons.play_arrow, color: colorScheme.primary),
            onTap: () => _navigateToLesson(lesson['id']),
          ),
        );
      },
    );
  }

  Widget _buildQuizzesTab(ThemeData theme, ColorScheme colorScheme) {
    if (isLoadingQuizzes) {
      return const Center(child: CircularProgressIndicator());
    }

    if (quizzesError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: colorScheme.error),
            const SizedBox(height: 16),
            Text('Error loading quizzes', style: theme.textTheme.bodyLarge),
            Text(quizzesError!, style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            CustomAnimatedButton(
              onPressed: _loadQuizzes,
              text: 'Retry',
              backgroundColor: colorScheme.primary,
              textColor: colorScheme.onPrimary,
            ),
          ],
        ),
      );
    }

    if (quizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz,
                size: 64, color: colorScheme.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No quizzes available', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Quizzes will be added by the instructor',
                style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return GlassmorphismCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          blurStrength: 10,
          opacity: 0.1,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            leading: NeumorphismContainer(
              padding: const EdgeInsets.all(12),
              borderRadius: BorderRadius.circular(12),
              child: Icon(
                Icons.quiz,
                color: colorScheme.primary,
              ),
            ),
            title: Text(
              quiz['title'] ?? 'Untitled Quiz',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${quiz['questions_count'] ?? 0} questions',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(Icons.arrow_forward, color: colorScheme.primary),
            onTap: () {
              // TODO: Navigate to quiz screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Quiz functionality coming soon!')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoTab(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course header
          GlassmorphismCard(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            blurStrength: 10,
            opacity: 0.1,
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course['title'] ?? 'Untitled Course',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.course['description'] ?? 'No description available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Course details
          GlassmorphismCard(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            blurStrength: 10,
            opacity: 0.1,
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                _buildDetailRow(
                    'Subject',
                    widget.course['subject'] ?? 'Not specified',
                    theme,
                    colorScheme),
                const Divider(),
                _buildDetailRow(
                    'Grade Level',
                    widget.course['grade_level'] ?? 'All levels',
                    theme,
                    colorScheme),
                const Divider(),
                _buildDetailRow(
                    'Duration',
                    widget.course['duration'] ?? 'Not specified',
                    theme,
                    colorScheme),
                const Divider(),
                _buildDetailRow(
                    'Total Hours',
                    widget.course['total_hours']?.toString() ?? 'Not specified',
                    theme,
                    colorScheme),
              ],
            ),
          ),

          // Prerequisites
          if (widget.course['prerequisites'] != null &&
              widget.course['prerequisites'].isNotEmpty)
            GlassmorphismCard(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              blurStrength: 10,
              opacity: 0.1,
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prerequisites',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.course['prerequisites'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

          // Learning objectives
          if (widget.course['objectives'] != null &&
              widget.course['objectives'].isNotEmpty)
            GlassmorphismCard(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              blurStrength: 10,
              opacity: 0.1,
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learning Objectives',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.course['objectives'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

          // Watch Videos Button
          Center(
            child: CustomAnimatedButton(
              onPressed: () => _navigateToVideoPlayer(
                  widget.course['id'], widget.course['title']),
              text: 'Watch Course Videos',
              backgroundColor: colorScheme.primary,
              textColor: colorScheme.onPrimary,
              width: 200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  IconData _getContentTypeIcon(String? contentType) {
    switch (contentType) {
      case 'video':
        return Icons.play_circle;
      case 'audio':
        return Icons.audiotrack;
      case 'text':
        return Icons.article;
      case 'interactive':
        return Icons.touch_app;
      default:
        return Icons.book;
    }
  }
}
