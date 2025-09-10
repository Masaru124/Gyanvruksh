import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:gyanvruksh/screens/courses_screen.dart';
import 'package:gyanvruksh/screens/messages_screen.dart';
import 'package:gyanvruksh/screens/profile_screen.dart';
import 'package:gyanvruksh/screens/chatroom_screen.dart';
import 'package:gyanvruksh/widgets/backgrounds/cinematic_background.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/floating_elements.dart';
import 'package:gyanvruksh/widgets/animated_wave_background.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/widgets/glowing_button.dart';
import 'package:gyanvruksh/widgets/micro_interactions.dart';
import 'package:gyanvruksh/widgets/animated_text_widget.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';

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

  // Removed _selectCourse method since teachers cannot self-enroll
  // Courses are now assigned by admins only

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
      case 3: // Chatroom
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatroomScreen()),
        );
        break;
      case 4: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  Widget _buildAvailableCourses(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Available Courses to Teach',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: FuturisticColors.primary.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: isLoadingCourses
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(FuturisticColors.primary),
                  ),
                )
              : availableCourses.isEmpty
                  ? Center(
                      child: Text(
                        'No available courses at the moment',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: availableCourses.length,
                      itemBuilder: (context, index) {
                        final course = availableCourses[index];
                        return GlassmorphismCard(
                          width: 280,
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.all(20),
                          blurStrength: 12,
                          opacity: 0.1,
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course['title'],
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                course['description'],
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.8),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      FuturisticColors.primary.withOpacity(0.2),
                                      FuturisticColors.secondary.withOpacity(0.2),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Contact admin to assign this course',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: FuturisticColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100))
                        .slideX(begin: 0.2, end: 0, duration: 500.ms, delay: Duration(milliseconds: index * 100));
                      },
                    ),
        ),
      ],
    )
    .animate()
    .fadeIn(duration: 600.ms, delay: 200.ms)
    .slideY(begin: 0.1, end: 0, duration: 500.ms);
  }

  Widget _buildUpcomingClasses(ThemeData theme, ColorScheme colorScheme) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      blurStrength: 12,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Classes',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: FuturisticColors.primary.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...upcomingClasses.map((classInfo) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MicroInteractionWrapper(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          FuturisticColors.primary.withOpacity(0.2),
                          FuturisticColors.secondary.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.class_,
                      color: FuturisticColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classInfo['subject'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${classInfo['class']} • ${classInfo['time']}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 600.ms, delay: 300.ms)
    .slideY(begin: 0.1, end: 0, duration: 500.ms);
  }

  Widget _buildStudentQueries(ThemeData theme, ColorScheme colorScheme) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      blurStrength: 12,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Queries',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: FuturisticColors.primary.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...studentQueries.map((query) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MicroInteractionWrapper(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          FuturisticColors.primary.withOpacity(0.2),
                          FuturisticColors.secondary.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.question_answer,
                      color: FuturisticColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          query['student'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          query['query'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          query['time'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 600.ms, delay: 400.ms)
    .slideY(begin: 0.1, end: 0, duration: 500.ms);
  }

  Widget _buildPerformanceOverview(ThemeData theme, ColorScheme colorScheme) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      blurStrength: 12,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Overview',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: FuturisticColors.primary.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: isLoadingStats
                    ? _buildLoadingCard(theme, colorScheme)
                    : _buildStatCard(
                        theme,
                        colorScheme,
                        'Total Students',
                        performanceStats['totalStudents']?.toString() ?? '0',
                        Icons.people,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isLoadingStats
                    ? _buildLoadingCard(theme, colorScheme)
                    : _buildStatCard(
                        theme,
                        colorScheme,
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
                    ? _buildLoadingCard(theme, colorScheme)
                    : _buildStatCard(
                        theme,
                        colorScheme,
                        'Engagement',
                        '${performanceStats['engagementRate'] ?? 0}%',
                        Icons.trending_up,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isLoadingStats
                    ? _buildLoadingCard(theme, colorScheme)
                    : _buildStatCard(
                        theme,
                        colorScheme,
                        'Assignments',
                        performanceStats['completedAssignments']?.toString() ?? '0',
                        Icons.assignment_turned_in,
                      ),
              ),
            ],
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 600.ms, delay: 500.ms)
    .slideY(begin: 0.1, end: 0, duration: 500.ms);
  }

  Widget _buildStatCard(ThemeData theme, ColorScheme colorScheme, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FuturisticColors.primary.withOpacity(0.1),
            FuturisticColors.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FuturisticColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: FuturisticColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FuturisticColors.primary.withOpacity(0.05),
            FuturisticColors.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FuturisticColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(FuturisticColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    final api = ApiService();
    await api.logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _showNotifications() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: colorScheme.surface,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Sample notifications - in a real app, these would come from an API
              _buildNotificationItem(
                theme,
                colorScheme,
                'New student enrolled',
                'Alice Johnson joined your Mathematics class',
                '2 hours ago',
                Icons.person_add,
              ),
              _buildNotificationItem(
                theme,
                colorScheme,
                'Assignment submitted',
                'Bob Smith submitted Physics assignment',
                '4 hours ago',
                Icons.assignment_turned_in,
              ),
              _buildNotificationItem(
                theme,
                colorScheme,
                'Class reminder',
                'English class starts in 30 minutes',
                '30 min ago',
                Icons.schedule,
              ),
              _buildNotificationItem(
                theme,
                colorScheme,
                'Query received',
                'Carol Davis asked a question about homework',
                '1 day ago',
                Icons.question_answer,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(ThemeData theme, ColorScheme colorScheme, String title, String message, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MicroInteractionWrapper(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FuturisticColors.primary.withOpacity(0.1),
                    FuturisticColors.secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: FuturisticColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    time,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
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
            particleCount: 30,
            maxParticleSize: 4.0,
            particleColor: FuturisticColors.primary,
          ),

          // Floating Elements
          FloatingElements(
            elementCount: 8,
            maxElementSize: 45,
            icons: const [
              Icons.school,
              Icons.people,
              Icons.assignment,
              Icons.grade,
              Icons.class_,
              Icons.question_answer,
              Icons.calendar_today,
              Icons.trending_up,
            ],
          ),

          // Animated Wave Background
          AnimatedWaveBackground(
            color: FuturisticColors.neonBlue.withOpacity(0.04),
            height: MediaQuery.of(context).size.height,
          ),

          SafeArea(
            child: Column(
              children: [
                // Enhanced App Bar with Glassmorphism
                GlassmorphismCard(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  blurStrength: 15,
                  opacity: 0.1,
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    children: [
                      MicroInteractionWrapper(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                FuturisticColors.primary,
                                FuturisticColors.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'EduConnect Teacher',
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
                        ),
                      ),
                      MicroInteractionWrapper(
                        child: IconButton(
                          icon: Icon(
                            Icons.notifications,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                          onPressed: _showNotifications,
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.surface.withOpacity(0.8),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      MicroInteractionWrapper(
                        child: IconButton(
                          icon: Icon(
                            Icons.logout,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                          onPressed: _logout,
                          tooltip: 'Logout',
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.surface.withOpacity(0.8),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: -0.2, end: 0, duration: 500.ms),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAvailableCourses(theme, colorScheme),
                        const SizedBox(height: 24),
                        _buildUpcomingClasses(theme, colorScheme),
                        const SizedBox(height: 24),
                        _buildStudentQueries(theme, colorScheme),
                        const SizedBox(height: 24),
                        _buildPerformanceOverview(theme, colorScheme),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Enhanced Bottom Navigation
                GlassmorphismCard(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  blurStrength: 12,
                  opacity: 0.15,
                  borderRadius: BorderRadius.circular(20),
                  child: BottomNavigationBar(
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
                        icon: Icon(Icons.chat),
                        label: 'Chatroom',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: 'Profile',
                      ),
                    ],
                    currentIndex: _selectedIndex,
                    selectedItemColor: FuturisticColors.primary,
                    unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
                    onTap: _onItemTapped,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideY(begin: 0.2, end: 0, duration: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
