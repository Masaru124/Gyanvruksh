import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/widgets/backgrounds/cinematic_background.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/micro_interactions.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProfileScreen extends StatefulWidget {
  const SettingsProfileScreen({super.key});

  @override
  State<SettingsProfileScreen> createState() => _SettingsProfileScreenState();
}

class _SettingsProfileScreenState extends State<SettingsProfileScreen> {
  Map<String, dynamic> userProfile = {};
  bool isLoading = true;
  bool notificationsEnabled = true;
  bool darkModeEnabled = true;
  bool soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await ApiService().get('/api/user/profile').catchError((_) => {});
      
      setState(() {
        userProfile = result as Map<String, dynamic>;
        notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? true;
        soundEnabled = prefs.getBool('sound_enabled') ?? true;
        isLoading = false;
        
        // Fallback data
        if (userProfile.isEmpty) {
          userProfile = {
            'name': prefs.getString('user_name') ?? 'Student',
            'email': 'student@gyanvruksh.com',
            'phone': '+91 98765 43210',
            'class': 'Class 12',
            'section': 'A',
            'rollNumber': '2024001',
            'joinDate': '2024-01-01',
            'avatar': '👨‍🎓',
          };
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        userProfile = {
          'name': 'Student',
          'email': 'student@gyanvruksh.com',
          'phone': '+91 98765 43210',
          'class': 'Class 12',
          'section': 'A',
          'rollNumber': '2024001',
          'joinDate': '2024-01-01',
          'avatar': '👨‍🎓',
        };
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
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileSection(theme),
                              const SizedBox(height: 24),
                              _buildSettingsSection(theme),
                              const SizedBox(height: 24),
                              _buildAccountSection(theme),
                              const SizedBox(height: 100),
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

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Text(
            'Settings & Profile',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildProfileSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GlassmorphismCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [FuturisticColors.primary, FuturisticColors.secondary],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        userProfile['avatar'] ?? '👨‍🎓',
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProfile['name'] ?? 'Student',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${userProfile['class']} - ${userProfile['section']}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: FuturisticColors.accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Roll No: ${userProfile['rollNumber']}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MicroInteractionWrapper(
                    onTap: _editProfile,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [FuturisticColors.accent.withOpacity(0.3), FuturisticColors.primary.withOpacity(0.3)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const FaIcon(FontAwesomeIcons.edit, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildProfileInfo(theme),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildProfileInfo(ThemeData theme) {
    final profileItems = [
      {'icon': FontAwesomeIcons.envelope, 'label': 'Email', 'value': userProfile['email']},
      {'icon': FontAwesomeIcons.phone, 'label': 'Phone', 'value': userProfile['phone']},
      {'icon': FontAwesomeIcons.calendar, 'label': 'Joined', 'value': userProfile['joinDate']},
    ];

    return Column(
      children: profileItems.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              FaIcon(
                item['icon'] as IconData,
                color: FuturisticColors.accent,
                size: 16,
              ),
              const SizedBox(width: 12),
              Text(
                item['label'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Text(
                item['value'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettingsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'App Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GlassmorphismCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildSettingItem(
                theme,
                FontAwesomeIcons.bell,
                'Notifications',
                'Receive push notifications',
                notificationsEnabled,
                (value) => _updateSetting('notifications_enabled', value),
              ),
              const SizedBox(height: 16),
              _buildSettingItem(
                theme,
                FontAwesomeIcons.moon,
                'Dark Mode',
                'Enable dark theme',
                darkModeEnabled,
                (value) => _updateSetting('dark_mode_enabled', value),
              ),
              const SizedBox(height: 16),
              _buildSettingItem(
                theme,
                FontAwesomeIcons.volumeUp,
                'Sound Effects',
                'Enable app sounds',
                soundEnabled,
                (value) => _updateSetting('sound_enabled', value),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildSettingItem(ThemeData theme, IconData icon, String title, String subtitle, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [FuturisticColors.primary.withOpacity(0.3), FuturisticColors.secondary.withOpacity(0.3)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FaIcon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: FuturisticColors.accent,
          activeTrackColor: FuturisticColors.accent.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildAccountSection(ThemeData theme) {
    final accountItems = [
      {'icon': FontAwesomeIcons.lock, 'title': 'Change Password', 'subtitle': 'Update your password'},
      {'icon': FontAwesomeIcons.shield, 'title': 'Privacy Settings', 'subtitle': 'Manage your privacy'},
      {'icon': FontAwesomeIcons.questionCircle, 'title': 'Help & Support', 'subtitle': 'Get help and support'},
      {'icon': FontAwesomeIcons.infoCircle, 'title': 'About', 'subtitle': 'App version and info'},
      {'icon': FontAwesomeIcons.signOutAlt, 'title': 'Logout', 'subtitle': 'Sign out of your account'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...accountItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLogout = item['title'] == 'Logout';
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: MicroInteractionWrapper(
              onTap: () => _handleAccountAction(item['title'] as String),
              child: GlassmorphismCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isLogout 
                              ? [FuturisticColors.error.withOpacity(0.3), FuturisticColors.error.withOpacity(0.1)]
                              : [FuturisticColors.accent.withOpacity(0.3), FuturisticColors.primary.withOpacity(0.3)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FaIcon(
                        item['icon'] as IconData,
                        color: isLogout ? FuturisticColors.error : Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isLogout ? FuturisticColors.error : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            item['subtitle'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FaIcon(
                      FontAwesomeIcons.chevronRight,
                      color: Colors.white60,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ).animate()
            .fadeIn(duration: 600.ms, delay: Duration(milliseconds: 400 + (index * 100)))
            .slideX(begin: 0.2, end: 0, duration: 500.ms);
        }).toList(),
      ],
    );
  }

  void _editProfile() {
    // Navigate to profile edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile editing coming soon!'),
        backgroundColor: FuturisticColors.accent,
      ),
    );
  }

  void _updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    
    setState(() {
      switch (key) {
        case 'notifications_enabled':
          notificationsEnabled = value;
          break;
        case 'dark_mode_enabled':
          darkModeEnabled = value;
          break;
        case 'sound_enabled':
          soundEnabled = value;
          break;
      }
    });
  }

  void _handleAccountAction(String action) {
    switch (action) {
      case 'Change Password':
        _showChangePasswordDialog();
        break;
      case 'Privacy Settings':
        _showPrivacySettings();
        break;
      case 'Help & Support':
        _showHelpSupport();
        break;
      case 'About':
        _showAboutDialog();
        break;
      case 'Logout':
        _showLogoutDialog();
        break;
    }
  }

  void _showChangePasswordDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Change password feature coming soon!'),
        backgroundColor: FuturisticColors.accent,
      ),
    );
  }

  void _showPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Privacy settings coming soon!'),
        backgroundColor: FuturisticColors.accent,
      ),
    );
  }

  void _showHelpSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Help & support coming soon!'),
        backgroundColor: FuturisticColors.accent,
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FuturisticColors.surface,
        title: Text(
          'About Gyanvruksh',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Gyanvruksh Educational Platform\nVersion 1.0.0\n\nEmpowering minds through innovative learning.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: FuturisticColors.accent)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FuturisticColors.surface,
        title: Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: Text('Logout', style: TextStyle(color: FuturisticColors.error)),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}
