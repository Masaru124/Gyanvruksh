import 'package:flutter/material.dart';
import 'package:gyanvruksh/services/api.dart';
import 'manage_users.dart';
import 'create_course.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  void _logout(BuildContext context) async {
    final api = ApiService();
    await api.logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: theme.colorScheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to the Admin Dashboard',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    context,
                    icon: Icons.manage_accounts,
                    title: 'Manage Users',
                    description: 'View all user details',
                    gradient: [
                      theme.colorScheme.primary.withOpacity(0.7),
                      theme.colorScheme.primary,
                    ],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManageUsersScreen()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.add_box,
                    title: 'Create Courses',
                    description: 'Add new courses',
                    gradient: [
                      theme.colorScheme.secondary.withOpacity(0.7),
                      theme.colorScheme.secondary,
                    ],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateCourseScreen()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.school,
                    title: 'Manage Courses',
                    description: 'Assign teachers, upload content',
                    gradient: [
                      Colors.orange.withOpacity(0.7),
                      Colors.orange,
                    ],
                    onTap: () {
                      // TODO: Navigate to course management screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Course management coming soon!')),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.analytics,
                    title: 'Analytics',
                    description: 'View platform statistics',
                    gradient: [
                      Colors.green.withOpacity(0.7),
                      Colors.green,
                    ],
                    onTap: () {
                      // TODO: Navigate to analytics screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Analytics coming soon!')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
