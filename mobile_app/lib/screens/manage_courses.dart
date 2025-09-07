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
  List<dynamic> courseVideos = [];
  List<dynamic> courseNotes = [];
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

  Future<void> _loadCourseMaterials(int courseId) async {
    final videos = await ApiService().getCourseVideos(courseId);
    final notes = await ApiService().getCourseNotes(courseId);
    setState(() {
      courseVideos = videos;
      courseNotes = notes;
    });
  }

  Future<void> _editCourse(dynamic course) async {
    final titleCtrl = TextEditingController(text: course['title']);
    final descCtrl = TextEditingController(text: course['description']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Course Title'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Course Description'),
              maxLines: 3,
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
              if (titleCtrl.text.isNotEmpty && descCtrl.text.isNotEmpty) {
                Navigator.pop(context);
                setState(() => loading = true);
                try {
                  final success = await ApiService().updateCourse(
                    course['id'],
                    titleCtrl.text,
                    descCtrl.text,
                  );
                  if (success) {
                    if (mounted) {
                      ScaffoldMessenger.of(_mainContext).showSnackBar(
                        const SnackBar(content: Text('Course updated successfully')),
                      );
                    }
                    _loadData();
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(_mainContext).showSnackBar(
                        const SnackBar(content: Text('Failed to update course')),
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
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCourse(dynamic course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course['title']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => loading = true);
      try {
        final success = await ApiService().deleteCourse(course['id']);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(_mainContext).showSnackBar(
              const SnackBar(content: Text('Course deleted successfully')),
            );
          }
          _loadData();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(_mainContext).showSnackBar(
              const SnackBar(content: Text('Failed to delete course')),
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
  }

  Future<void> _editVideo(int courseId, dynamic video) async {
    final titleCtrl = TextEditingController(text: video['title']);
    final urlCtrl = TextEditingController(text: video['url']);
    final descCtrl = TextEditingController(text: video['description'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Video'),
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
                  final success = await ApiService().updateCourseVideo(
                    courseId,
                    video['id'],
                    titleCtrl.text,
                    urlCtrl.text,
                    description: descCtrl.text.isNotEmpty ? descCtrl.text : null,
                  );
                  if (success) {
                    if (mounted) {
                      ScaffoldMessenger.of(_mainContext).showSnackBar(
                        const SnackBar(content: Text('Video updated successfully')),
                      );
                    }
                    _loadCourseMaterials(courseId);
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(_mainContext).showSnackBar(
                        const SnackBar(content: Text('Failed to update video')),
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
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVideo(int courseId, int videoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video'),
        content: const Text('Are you sure you want to delete this video?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => loading = true);
      try {
        final success = await ApiService().deleteCourseVideo(courseId, videoId);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(_mainContext).showSnackBar(
              const SnackBar(content: Text('Video deleted successfully')),
            );
          }
          _loadCourseMaterials(courseId);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(_mainContext).showSnackBar(
              const SnackBar(content: Text('Failed to delete video')),
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
  }

  Future<void> _editNote(int courseId, dynamic note) async {
    final titleCtrl = TextEditingController(text: note['title']);
    final contentCtrl = TextEditingController(text: note['content']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Note'),
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
                  final success = await ApiService().updateCourseNote(
                    courseId,
                    note['id'],
                    titleCtrl.text,
                    contentCtrl.text,
                  );
                  if (success) {
                    if (mounted) {
                      ScaffoldMessenger.of(_mainContext).showSnackBar(
                        const SnackBar(content: Text('Note updated successfully')),
                      );
                    }
                    _loadCourseMaterials(courseId);
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(_mainContext).showSnackBar(
                        const SnackBar(content: Text('Failed to update note')),
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
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote(int courseId, int noteId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => loading = true);
      try {
        final success = await ApiService().deleteCourseNote(courseId, noteId);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(_mainContext).showSnackBar(
              const SnackBar(content: Text('Note deleted successfully')),
            );
          }
          _loadCourseMaterials(courseId);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(_mainContext).showSnackBar(
              const SnackBar(content: Text('Failed to delete note')),
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
  }

  void _showCourseDetails(dynamic course) {
    _loadCourseMaterials(course['id']);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: scrollController,
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
                const SizedBox(height: 16),
                Text('Videos:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (courseVideos.isEmpty)
                  const Text('No videos uploaded')
                else
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: courseVideos.length,
                      itemBuilder: (context, index) {
                        final video = courseVideos[index];
                        return ListTile(
                          title: Text(video['title']),
                          subtitle: Text(video['url']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editVideo(course['id'], video),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteVideo(course['id'], video['id']),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Text('Notes:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (courseNotes.isEmpty)
                  const Text('No notes uploaded')
                else
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: courseNotes.length,
                      itemBuilder: (context, index) {
                        final note = courseNotes[index];
                        return ListTile(
                          title: Text(note['title']),
                          subtitle: Text(note['content'].length > 50 ? '${note['content'].substring(0, 50)}...' : note['content']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editNote(course['id'], note),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteNote(course['id'], note['id']),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
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
                                  case 'edit':
                                    _editCourse(course);
                                    break;
                                  case 'delete':
                                    _deleteCourse(course);
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
                                  value: 'edit',
                                  child: Text('Edit Course'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete Course'),
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
