import 'package:flutter/material.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:gyanvruksh/screens/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? error;
  bool isEditing = false;

  // Controllers for editable fields
  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final user = await ApiService().getProfile();
      if (user != null) {
        setState(() {
          userData = user;
          _populateControllers();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load user data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _populateControllers() {
    if (userData != null) {
      fullNameCtrl.text = userData!['full_name'] ?? '';
      emailCtrl.text = userData!['email'] ?? '';
      phoneCtrl.text = userData!['phone_number'] ?? '';
      addressCtrl.text = userData!['address'] ?? '';
    }
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        _populateControllers(); // Reset to original values if canceling
      }
    });
  }

  Future<void> _saveProfile() async {
    try {
      final success = await ApiService().updateProfile(
        fullName: fullNameCtrl.text.isNotEmpty ? fullNameCtrl.text : null,
        phoneNumber: phoneCtrl.text.isNotEmpty ? phoneCtrl.text : null,
        address: addressCtrl.text.isNotEmpty ? addressCtrl.text : null,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        // Refresh user data
        await _loadUserProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        isEditing = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await ApiService().logout();
      if (mounted) {
        // Navigate to login screen and clear navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Even if logout fails, clear local data and navigate to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout error: $e')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: isEditing ? _saveProfile : _toggleEdit,
          ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _toggleEdit,
            ),
        ],
      ),
      body: isLoading
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
                        onPressed: _loadUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Profile Information
                      _buildProfileField(
                        label: 'Full Name',
                        controller: fullNameCtrl,
                        icon: Icons.person,
                        enabled: isEditing,
                      ),
                      const SizedBox(height: 16),

                      _buildProfileField(
                        label: 'Email',
                        controller: emailCtrl,
                        icon: Icons.email,
                        enabled: false, // Email typically not editable
                      ),
                      const SizedBox(height: 16),

                      _buildProfileField(
                        label: 'Phone Number',
                        controller: phoneCtrl,
                        icon: Icons.phone,
                        enabled: isEditing,
                      ),
                      const SizedBox(height: 16),

                      _buildProfileField(
                        label: 'Address',
                        controller: addressCtrl,
                        icon: Icons.location_on,
                        enabled: isEditing,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // Additional Info (Read-only)
                      _buildInfoCard(
                        title: 'Role',
                        value: userData?['role'] ?? 'Not specified',
                        icon: Icons.work,
                      ),
                      const SizedBox(height: 12),

                      _buildInfoCard(
                        title: 'Sub Role',
                        value: userData?['sub_role'] ?? 'Not specified',
                        icon: Icons.category,
                      ),
                      const SizedBox(height: 12),

                      if (userData?['educational_qualification'] != null)
                        _buildInfoCard(
                          title: 'Education',
                          value: userData!['educational_qualification'],
                          icon: Icons.school,
                        ),

                      const SizedBox(height: 12),

                      _buildInfoCard(
                        title: 'Gyan Coins',
                        value: userData?['gyan_coins']?.toString() ?? '0',
                        icon: Icons.monetization_on,
                      ),

                      const SizedBox(height: 24),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
