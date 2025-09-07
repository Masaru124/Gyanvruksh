import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gyanvruksh/screens/admin_dashboard.dart';
import 'package:gyanvruksh/screens/dashboard.dart';
import 'package:gyanvruksh/screens/teacher_dashboard.dart';
import 'package:gyanvruksh/screens/create_course.dart';
import 'package:gyanvruksh/screens/manage_users.dart';
import 'package:gyanvruksh/screens/manage_courses.dart';
import 'package:gyanvruksh/screens/courses_screen.dart';
import 'package:gyanvruksh/screens/leaderboard_screen.dart';
import 'package:gyanvruksh/screens/profile_screen.dart';
import 'package:gyanvruksh/screens/chatroom_screen.dart';
import 'package:gyanvruksh/blocs/theme_bloc.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/utils/responsive_utils.dart';

class NavigationScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const NavigationScreen({super.key, required this.user});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _navController;
  late Animation<double> _navAnimation;

  late final List<Widget> _studentPages;
  late final List<Widget> _adminPages;
  late final List<_NavigationItem> _studentNavItems;
  late final List<_NavigationItem> _adminNavItems;

  @override
  void initState() {
    super.initState();

    _navController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _navAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _navController, curve: Curves.easeInOut),
    );

    _studentPages = <Widget>[
      const DashboardScreen(),
      const CoursesScreen(),
      const ChatroomScreen(),
      const LeaderboardScreen(),
      const ProfileScreen(),
    ];

    _adminPages = <Widget>[
      const AdminDashboardScreen(),
      const CreateCourseScreen(),
      const ManageCoursesScreen(),
      const ManageUsersScreen(),
    ];

    _studentNavItems = [
      _NavigationItem(
        icon: FontAwesomeIcons.house,
        activeIcon: FontAwesomeIcons.house,
        label: 'Dashboard',
        color: const Color(0xFF3C6EFA),
      ),
      _NavigationItem(
        icon: FontAwesomeIcons.bookOpen,
        activeIcon: FontAwesomeIcons.bookOpen,
        label: 'Courses',
        color: const Color(0xFFA58DF5),
      ),
      _NavigationItem(
        icon: FontAwesomeIcons.comments,
        activeIcon: FontAwesomeIcons.comments,
        label: 'Chatroom',
        color: const Color(0xFF26A69A),
      ),
      _NavigationItem(
        icon: FontAwesomeIcons.trophy,
        activeIcon: FontAwesomeIcons.trophy,
        label: 'Leaderboard',
        color: const Color(0xFFFF9800),
      ),
      _NavigationItem(
        icon: FontAwesomeIcons.user,
        activeIcon: FontAwesomeIcons.user,
        label: 'Profile',
        color: const Color(0xFF9C27B0),
      ),
    ];

    _adminNavItems = [
      _NavigationItem(
        icon: FontAwesomeIcons.chartLine,
        activeIcon: FontAwesomeIcons.chartLine,
        label: 'Dashboard',
        color: const Color(0xFF3C6EFA),
      ),
      _NavigationItem(
        icon: FontAwesomeIcons.plus,
        activeIcon: FontAwesomeIcons.plus,
        label: 'Create',
        color: const Color(0xFF4CAF50),
      ),
      _NavigationItem(
        icon: FontAwesomeIcons.school,
        activeIcon: FontAwesomeIcons.school,
        label: 'Courses',
        color: const Color(0xFFA58DF5),
      ),
      _NavigationItem(
        icon: FontAwesomeIcons.users,
        activeIcon: FontAwesomeIcons.users,
        label: 'Users',
        color: const Color(0xFF26A69A),
      ),
    ];
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      _navController.forward(from: 0);
    }
  }

  Widget _buildMobileNavigation(BuildContext context, bool isAdmin) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final navItems = isAdmin ? _adminNavItems : _studentNavItems;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        items: navItems.map((item) {
          final isSelected = navItems.indexOf(item) == _selectedIndex;
          return BottomNavigationBarItem(
            icon: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(isSelected ? 8 : 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? item.color.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: FaIcon(
                item.icon,
                size: isSelected ? 24 : 20,
                color: isSelected ? item.color : colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            label: item.label,
          );
        }).toList(),
        currentIndex: _selectedIndex,
        selectedItemColor: navItems[_selectedIndex].color,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildTabletNavigation(BuildContext context, bool isAdmin) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final navItems = isAdmin ? _adminNavItems : _studentNavItems;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.secondary,
                ],
              ),
            ),
            child: Column(
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      FontAwesomeIcons.graduationCap,
                      color: colorScheme.onPrimary,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Gyanvruksh',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAdmin ? 'Admin Panel' : 'Learning Hub',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = index == _selectedIndex;

                return AnimatedBuilder(
                  animation: _navAnimation,
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? item.color.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: FaIcon(
                          item.icon,
                          color: isSelected
                              ? item.color
                              : colorScheme.onSurface.withOpacity(0.6),
                          size: 20,
                        ),
                        title: Text(
                          item.label,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isSelected
                                ? item.color
                                : colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        onTap: () => _onItemTapped(index),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                        .animate(target: isSelected ? 1 : 0)
                        .scaleXY(begin: 1, end: 1.05, duration: 200.ms);
                  },
                );
              },
            ),
          ),

          // Theme Toggle
          Padding(
            padding: const EdgeInsets.all(16),
            child: GlassmorphismCard(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              blurStrength: 10,
              opacity: 0.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dark Mode',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  BlocBuilder<ThemeBloc, ThemeState>(
                    builder: (context, state) {
                      return Switch(
                        value: state.isDark,
                        onChanged: (value) {
                          context.read<ThemeBloc>().add(ToggleTheme());
                        },
                        activeColor: colorScheme.primary,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawRole = widget.user['role'] ?? '';
    final role = rawRole.toString().trim().toLowerCase();
    final isAdmin = role == 'admin';
    final isTeacher = role == 'service_provider' || widget.user['is_teacher'] == true;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    // If teacher, show teacher dashboard directly
    if (isTeacher) {
      return const TeacherDashboard();
    }

    final pages = isAdmin ? _adminPages : _studentPages;

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            _buildTabletNavigation(context, isAdmin),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_selectedIndex),
                  child: pages[_selectedIndex],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: _buildMobileNavigation(context, isAdmin),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}
