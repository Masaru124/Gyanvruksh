import 'package:flutter/material.dart';
import 'package:gyanvruksh/services/api.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<dynamic> studentQueries = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadStudentQueries();
  }

  Future<void> _loadStudentQueries() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final queries = await ApiService().studentQueries();
      setState(() {
        studentQueries = queries;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Queries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudentQueries,
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
                        onPressed: _loadStudentQueries,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : studentQueries.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.message, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No student queries yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Student questions will appear here',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: studentQueries.length,
                      itemBuilder: (context, index) {
                        final query = studentQueries[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              query['student_name'] ?? 'Unknown Student',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  query['course_title'] ?? 'General Query',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  query['message'] ?? 'No message',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  query['timestamp'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: query['status'] == 'unread' ? Colors.red : Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                query['status'] == 'unread' ? '!' : '✓',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {
                              // TODO: Open detailed query view with reply functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Query from: ${query['student_name']}')),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
