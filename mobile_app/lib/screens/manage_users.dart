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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text(user['full_name'] ?? 'No Name'),
                      subtitle: Text('${user['email']} - Role: ${user['role']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(user['id']),
                      ),
                    );
                  },
                ),
    );
  }
}
