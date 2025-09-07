import 'package:flutter/material.dart';
import 'package:gyanvruksh/services/api.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<dynamic> users = [];
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final fetchedUsers = await ApiService().listUsers();
      setState(() {
        users = fetchedUsers;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _deleteUser(int userId) async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final success = await ApiService().deleteUser(userId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted successfully')));
        _fetchUsers();
      } else {
        setState(() {
          error = 'Failed to delete user';
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _showUserDetails(dynamic user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(user['full_name'] ?? 'User Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Email', user['email']),
                _buildDetailRow('Role', user['role']),
                _buildDetailRow('Sub Role', user['sub_role']),
                _buildDetailRow('Age', user['age']?.toString()),
                _buildDetailRow('Gender', user['gender']),
                _buildDetailRow('Phone', user['phone_number']),
                _buildDetailRow('Address', user['address']),
                _buildDetailRow('Educational Qualification', user['educational_qualification']),
                _buildDetailRow('Preferred Language', user['preferred_language']),
                _buildDetailRow('Emergency Contact', user['emergency_contact']),
                _buildDetailRow('Aadhar Card', user['aadhar_card']),
                _buildDetailRow('Account Details', user['account_details']),
                _buildDetailRow('Date of Birth', user['dob']),
                _buildDetailRow('Marital Status', user['marital_status']),
                _buildDetailRow('Years of Experience', user['year_of_experience']?.toString()),
                _buildDetailRow('Parents Contact', user['parents_contact_details']),
                _buildDetailRow('Parents Email', user['parents_email']),
                _buildDetailRow('Seller Type', user['seller_type']),
                _buildDetailRow('Company ID', user['company_id']),
                _buildDetailRow('Seller Record', user['seller_record']),
                _buildDetailRow('Company Details', user['company_details']),
                _buildDetailRow('Gyan Coins', user['gyan_coins']?.toString()),
                _buildDetailRow('Is Teacher', user['is_teacher']?.toString()),
                _buildDetailRow('Is Active', user['is_active']?.toString()),
                _buildDetailRow('Created At', user['created_at']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUser(user['id']);
              },
              child: const Text('Delete User', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUsers,
          ),
        ],
      ),
      body: loading
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
                        onPressed: _fetchUsers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : users.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No users found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: user['is_active'] == true ? Colors.green : Colors.grey,
                              child: Icon(
                                user['is_teacher'] == true ? Icons.school : Icons.person,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              user['full_name'] ?? 'No Name',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user['email'] ?? 'No Email'),
                                Text(
                                  'Role: ${user['role']} | Sub-role: ${user['sub_role'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                                ),
                                Text(
                                  'Gyan Coins: ${user['gyan_coins'] ?? 0}',
                                  style: const TextStyle(fontSize: 12, color: Colors.green),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.info, color: Colors.blue),
                              onPressed: () => _showUserDetails(user),
                            ),
                            onTap: () => _showUserDetails(user),
                          ),
                        );
                      },
                    ),
    );
  }
}
