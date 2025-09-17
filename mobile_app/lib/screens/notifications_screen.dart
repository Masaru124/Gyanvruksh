import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/widgets/backgrounds/cinematic_background.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/micro_interactions.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => isLoading = true);
    
    try {
      final result = await ApiService().get('/api/notifications').catchError((_) => []);
      
      setState(() {
        notifications = result as List<dynamic>;
        isLoading = false;
        
        // Fallback data
        if (notifications.isEmpty) {
          notifications = [
            {
              'id': 1,
              'title': 'New Assignment Posted',
              'message': 'Mathematics Problem Set 3 has been posted. Due date: Jan 20, 2024',
              'type': 'assignment',
              'time': '2 hours ago',
              'isRead': false,
            },
            {
              'id': 2,
              'title': 'Quiz Reminder',
              'message': 'Physics Quiz scheduled for tomorrow at 10:00 AM',
              'type': 'quiz',
              'time': '4 hours ago',
              'isRead': false,
            },
            {
              'id': 3,
              'title': 'Grade Updated',
              'message': 'Your Chemistry Lab Report has been graded: 92/100',
              'type': 'grade',
              'time': '1 day ago',
              'isRead': true,
            },
            {
              'id': 4,
              'title': 'Course Announcement',
              'message': 'New study materials uploaded for Advanced Mathematics',
              'type': 'announcement',
              'time': '2 days ago',
              'isRead': true,
            },
            {
              'id': 5,
              'title': 'Achievement Unlocked',
              'message': 'Congratulations! You\'ve earned the "Quick Learner" badge',
              'type': 'achievement',
              'time': '3 days ago',
              'isRead': true,
            },
          ];
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        notifications = [
          {
            'id': 1,
            'title': 'New Assignment Posted',
            'message': 'Mathematics Problem Set 3 has been posted. Due date: Jan 20, 2024',
            'type': 'assignment',
            'time': '2 hours ago',
            'isRead': false,
          },
          {
            'id': 2,
            'title': 'Quiz Reminder',
            'message': 'Physics Quiz scheduled for tomorrow at 10:00 AM',
            'type': 'quiz',
            'time': '4 hours ago',
            'isRead': false,
          },
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const CinematicBackground(isDark: true),
          const ParticleBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(theme),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildNotificationsList(theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final unreadCount = notifications.where((n) => !n['isRead']).length;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Notifications',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: FuturisticColors.error,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$unreadCount new',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 12),
          MicroInteractionWrapper(
            onTap: _markAllAsRead,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [FuturisticColors.primary.withOpacity(0.3), FuturisticColors.secondary.withOpacity(0.3)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const FaIcon(FontAwesomeIcons.checkDouble, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildNotificationsList(ThemeData theme) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.bell,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: MicroInteractionWrapper(
            onTap: () => _markAsRead(notification['id']),
            child: GlassmorphismCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getNotificationColor(notification['type']).withOpacity(0.3),
                          _getNotificationColor(notification['type']).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FaIcon(
                      _getNotificationIcon(notification['type']),
                      color: _getNotificationColor(notification['type']),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification['title'],
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: notification['isRead'] ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!notification['isRead'])
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: FuturisticColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification['message'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.clock,
                              size: 12,
                              color: Colors.white60,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              notification['time'],
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate()
          .fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100))
          .slideX(begin: 0.2, end: 0, duration: 500.ms);
      },
    );
  }

  void _markAsRead(int notificationId) {
    setState(() {
      final index = notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        notifications[index]['isRead'] = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['isRead'] = true;
      }
    });
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'assignment':
        return FontAwesomeIcons.fileAlt;
      case 'quiz':
        return FontAwesomeIcons.questionCircle;
      case 'grade':
        return FontAwesomeIcons.star;
      case 'announcement':
        return FontAwesomeIcons.bullhorn;
      case 'achievement':
        return FontAwesomeIcons.trophy;
      default:
        return FontAwesomeIcons.bell;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'assignment':
        return FuturisticColors.primary;
      case 'quiz':
        return FuturisticColors.warning;
      case 'grade':
        return FuturisticColors.success;
      case 'announcement':
        return FuturisticColors.accent;
      case 'achievement':
        return FuturisticColors.warning;
      default:
        return FuturisticColors.primary;
    }
  }
}
