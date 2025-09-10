import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:gyanvruksh/widgets/backgrounds/cinematic_background.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/floating_elements.dart';
import 'package:gyanvruksh/widgets/animated_wave_background.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/widgets/micro_interactions.dart';
import 'package:gyanvruksh/widgets/animated_text_widget.dart';
import 'package:gyanvruksh/widgets/glowing_button.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';
import 'package:gyanvruksh/screens/courses_screen.dart';
import 'package:gyanvruksh/screens/messages_screen.dart';
import 'package:gyanvruksh/screens/profile_screen.dart';
import 'package:gyanvruksh/screens/chatroom_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List<dynamic> courses = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService().listCourses();
    setState(() {
      courses = data;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Home - already on dashboard
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CoursesScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MessagesScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatroomScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
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
                          'EduConnect Student',
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
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: -0.2, end: 0, duration: 500.ms),

                // Main Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: courses.isEmpty
                          ? Center(
                              child: Text(
                                'No courses available',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: courses.length,
                              itemBuilder: (context, index) {
                                final course = courses[index];
                                return GlassmorphismCard(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(20),
                                  blurStrength: 12,
                                  opacity: 0.1,
                                  borderRadius: BorderRadius.circular(20),
                                  child: MicroInteractionWrapper(
                                    child: ListTile(
                                      title: Text(
                                        course['title'],
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        course['description'],
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurface.withOpacity(0.8),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100))
                                .slideX(begin: 0.2, end: 0, duration: 500.ms, delay: Duration(milliseconds: index * 100));
                              },
                            ),
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
