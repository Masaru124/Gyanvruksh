import 'package:flutter/material.dart';
import 'package:gyanvruksh/services/api.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({super.key});

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  List<dynamic> courses = [];
  List<dynamic> teachers = [];
  bool loading = false;
  String? error;
  late BuildContext _mainContext;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final coursesData = await ApiService().listCourses();
      final usersData = await ApiService().listUsers();
      setState(() {
        courses = coursesData;
        teachers = usersData.where((user) => user['is_teacher'] == true).toList();
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

  Future<void> _assignTeacher(int courseId, int teacherId) async {
    setState(() => loading = true);
    try {
      final success = await ApiService().assignTeacherToCourse(courseId, teacherId);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(_mainContext).showSnackBar(
            const SnackBar(content: Text('Teacher assigned successfully')),
          );
        }
        _loadData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(_mainContext).showSnackBar(
            const SnackBar(content: Text('Failed to assign teacher')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(_mainContext).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> _uploadVideo(int courseId) async {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Video Title'),
            ),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(labelText: 'Video URL'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty && urlCtrl.text.isNotEmpty) {
                Navigator.pop(context);
                setState(() => loading = true);
                try {
                  final success = await ApiService().uploadCourseVideo(
                    courseId,
                    titleCtrl.text,
                    urlCtrl.text,
                    description: descCtrl.text.isNotEmpty ? descCtrl.text : null,
                  );

                  if (success) {
                    if (mounted) {
                      ScaffoldMessenger.of(_mainContext).showSnackBar(
                        const SnackBar(content: Text('Video uploaded successfully')),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(_mainContext).showSnackBar(
                        const SnackBar(content: Text('Failed to upload video')),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(_mainContext).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => loading = false);
                  }
                }
              }
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadNote(int courseId) async {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Note Title'),
            ),
            TextField(
              controller: contentCtrl,
              decoration: const InputDecoration(labelText: 'Note Content'),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty && contentCtrl.text.isNotEmpty) {
                Navigator.pop(context);
                setState(() => loading = true);
                try {
                  final success = await ApiService().uploadCourseNote(
                    courseId,
                    titleCtrl.text,
                    contentCtrl.text,
                  );

                  if (success) {
                    if (mounted) {
                      ScaffoldMessenger.of(_mainContext).showSnackBar(
                        const SnackBar(content: Text('Note uploaded successfully')),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(_mainContext).showSnackBar(
                        const SnackBar(content: Text('Failed to upload note')),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(_mainContext).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => loading = false);
                  }
                }
              }
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  void _showCourseDetails(dynamic course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course['title'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(course['description']),
              const SizedBox(height: 16),
              Text('Teacher: ${course['teacher_id'] != null ? 'Assigned' : 'Not assigned'}'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showTeacherSelection(course),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Assign Teacher'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _uploadVideo(course['id']),
                      icon: const Icon(Icons.video_call),
                      label: const Text('Upload Video'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _uploadNote(course['id']),
                      icon: const Icon(Icons.note_add),
                      label: const Text('Upload Note'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTeacherSelection(dynamic course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Teacher'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              return ListTile(
                title: Text(teacher['full_name']),
                subtitle: Text(teacher['email']),
                onTap: () {
                  Navigator.pop(context);
                  _assignTeacher(course['id'], teacher['id']);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _mainContext = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
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
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : courses.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No courses found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: course['teacher_id'] != null ? Colors.green : Colors.orange,
                              child: Icon(
                                course['teacher_id'] != null ? Icons.check : Icons.schedule,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              course['title'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(course['description']),
                                Text(
                                  course['teacher_id'] != null ? 'Teacher assigned' : 'No teacher assigned',
                                  style: TextStyle(
                                    color: course['teacher_id'] != null ? Colors.green : Colors.orange,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'details':
                                    _showCourseDetails(course);
                                    break;
                                  case 'assign':
                                    _showTeacherSelection(course);
                                    break;
                                  case 'video':
                                    _uploadVideo(course['id']);
                                    break;
                                  case 'note':
                                    _uploadNote(course['id']);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'details',
                                  child: Text('View Details'),
                                ),
                                const PopupMenuItem(
                                  value: 'assign',
                                  child: Text('Assign Teacher'),
                                ),
                                const PopupMenuItem(
                                  value: 'video',
                                  child: Text('Upload Video'),
                                ),
                                const PopupMenuItem(
                                  value: 'note',
                                  child: Text('Upload Note'),
                                ),
                              ],
                            ),
                            onTap: () => _showCourseDetails(course),
                          ),
                        );
                      },
                    ),
    );
  }
}
