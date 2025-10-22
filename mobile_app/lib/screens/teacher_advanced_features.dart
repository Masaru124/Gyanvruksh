import 'package:flutter/material.dart';
import 'package:gyanvruksh/services/enhanced_api_service.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';

class TeacherAdvancedFeaturesScreen extends StatefulWidget {
  const TeacherAdvancedFeaturesScreen({super.key});

  @override
  State<TeacherAdvancedFeaturesScreen> createState() =>
      _TeacherAdvancedFeaturesScreenState();
}

class _TeacherAdvancedFeaturesScreenState
    extends State<TeacherAdvancedFeaturesScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  Map<String, dynamic> _performanceData = {};
  Map<String, dynamic> _studentData = {};
  Map<String, dynamic> _messages = {};
  Map<String, dynamic> _contentLibrary = {};

  // Form variables
  int? _selectedCourseId;
  final _announcementTitleController = TextEditingController();
  final _announcementMessageController = TextEditingController();
  final _contentTitleController = TextEditingController();
  final _contentDescriptionController = TextEditingController();
  String _selectedContentType = 'video';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTeacherData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _announcementTitleController.dispose();
    _announcementMessageController.dispose();
    _contentTitleController.dispose();
    _contentDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadTeacherData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        ApiService.getTeacherPerformanceAnalytics(),
        ApiService.getStudentManagementData(),
        ApiService.getTeacherMessages(),
        ApiService.getContentLibrary(),
      ]);

      setState(() {
        _performanceData = results[0].isSuccess ? (results[0].data as Map<String, dynamic>?) ?? {} : {};
        _studentData = results[1].isSuccess ? (results[1].data as Map<String, dynamic>?) ?? {} : {};
        _messages = results[2].isSuccess ? (results[2].data as Map<String, dynamic>?) ?? {} : {};
        _contentLibrary = results[3].isSuccess ? (results[3].data as Map<String, dynamic>?) ?? {} : {};
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load teacher data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildAnalyticsTab(),
                          _buildStudentManagementTab(),
                          _buildCommunicationTab(),
                          _buildContentLibraryTab(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Text(
            'Advanced Teacher Tools',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        tabs: const [
          Tab(text: 'Analytics'),
          Tab(text: 'Students'),
          Tab(text: 'Messages'),
          Tab(text: 'Content'),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final coursePerformance =
        (_performanceData['course_performance'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassmorphismCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performance Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Total Revenue',
                          '\$${_performanceData['total_revenue'] ?? 0}',
                          Icons.attach_money,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Top Course',
                          _performanceData['top_performing_course']
                                  ?['course_title'] ??
                              'N/A',
                          Icons.star,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GlassmorphismCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Course Performance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...coursePerformance.map((course) => Card(
                        color: Colors.white.withOpacity(0.1),
                        child: ListTile(
                          title: Text(
                            course['course_title'] ?? 'Unknown Course',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Enrolled: ${course['total_enrolled']} | Completed: ${course['completed_students']}',
                                  style:
                                      const TextStyle(color: Colors.white70)),
                              Text(
                                  'Completion Rate: ${course['completion_rate']?.toStringAsFixed(1)}%',
                                  style:
                                      const TextStyle(color: Colors.white70)),
                            ],
                          ),
                          trailing: Text(
                            '\$${course['revenue']}',
                            style: const TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentManagementTab() {
    final students = (_studentData['students'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassmorphismCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Total Students',
                          '${_studentData['total_students'] ?? 0}',
                          Icons.people,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Active',
                          '${_studentData['active_students'] ?? 0}',
                          Icons.trending_up,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'At Risk',
                          '${_studentData['at_risk_students'] ?? 0}',
                          Icons.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GlassmorphismCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Student Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showGradingDialog,
                        icon: const Icon(Icons.grade),
                        label: const Text('Grade Assignment'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...students.map((student) => Card(
                        color: Colors.white.withOpacity(0.1),
                        child: ExpansionTile(
                          title: Text(
                            student['student_name'] ?? 'Unknown Student',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${student['course_title']} | Progress: ${student['progress']}%',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  _getGradeColor(student['performance_grade']),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              student['performance_grade'] ?? 'N/A',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: ${student['student_email']}',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  Text(
                                      'Hours Completed: ${student['hours_completed']}',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  Text(
                                      'Attendance Rate: ${student['attendance_rate']}%',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  Text(
                                      'Last Activity: ${student['last_activity']?.substring(0, 10)}',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationTab() {
    final messages = (_messages['messages'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassmorphismCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Communication Center',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAnnouncementDialog,
                        icon: const Icon(Icons.announcement),
                        label: const Text('Create Announcement'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Total Messages',
                          '${_messages['total_messages'] ?? 0}',
                          Icons.mail,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Unread',
                          '${_messages['unread_count'] ?? 0}',
                          Icons.mark_email_unread,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GlassmorphismCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Messages',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...messages.map((message) => Card(
                        color: Colors.white.withOpacity(0.1),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: message['status'] == 'unread'
                                ? Colors.red
                                : Colors.green,
                            child: Text(
                              (message['from_student'] as String?)
                                      ?.substring(0, 1) ??
                                  '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            message['subject'] ?? 'No Subject',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('From: ${message['from_student']}',
                                  style:
                                      const TextStyle(color: Colors.white70)),
                              Text('Course: ${message['course_title']}',
                                  style:
                                      const TextStyle(color: Colors.white70)),
                              Text(message['message'] ?? '',
                                  style:
                                      const TextStyle(color: Colors.white60)),
                            ],
                          ),
                          trailing: Text(
                            message['received_at']?.substring(0, 10) ?? '',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentLibraryTab() {
    final videos = (_contentLibrary['videos'] as List?) ?? [];
    final documents = (_contentLibrary['documents'] as List?) ?? [];
    final quizzes = (_contentLibrary['quizzes'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassmorphismCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Content Library',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showUploadDialog,
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload Content'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Videos',
                          '${videos.length}',
                          Icons.video_library,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Documents',
                          '${documents.length}',
                          Icons.description,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Quizzes',
                          '${quizzes.length}',
                          Icons.quiz,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildContentSection('Videos', videos, Icons.play_circle),
          const SizedBox(height: 20),
          _buildContentSection('Documents', documents, Icons.description),
          const SizedBox(height: 20),
          _buildContentSection('Quizzes', quizzes, Icons.quiz),
        ],
      ),
    );
  }

  Widget _buildContentSection(String title, List items, IconData icon) {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Card(
                  color: Colors.white.withOpacity(0.1),
                  child: ListTile(
                    leading: Icon(icon, color: Colors.white70),
                    title: Text(
                      item['title'] ?? 'Unknown Title',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _getItemSubtitle(item, title),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing:
                        const Icon(Icons.more_vert, color: Colors.white70),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getGradeColor(String? grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.orange;
      case 'C':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getItemSubtitle(Map item, String type) {
    switch (type) {
      case 'Videos':
        return 'Duration: ${item['duration']} | Views: ${item['views']}';
      case 'Documents':
        return 'Size: ${item['size']} | Downloads: ${item['downloads']}';
      case 'Quizzes':
        return 'Questions: ${item['questions']} | Avg Score: ${item['avg_score']}%';
      default:
        return '';
    }
  }

  void _showAnnouncementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _announcementTitleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _announcementMessageController,
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createAnnouncement();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showGradingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Grade Assignment'),
        content: const Text(
            'Assignment grading feature - select student and assignment to grade.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Grading feature activated')),
              );
            },
            child: const Text('Grade'),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Content'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _contentTitleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedContentType,
              decoration: const InputDecoration(labelText: 'Content Type'),
              items: const [
                DropdownMenuItem(value: 'video', child: Text('Video')),
                DropdownMenuItem(value: 'document', child: Text('Document')),
                DropdownMenuItem(value: 'quiz', child: Text('Quiz')),
              ],
              onChanged: (value) =>
                  setState(() => _selectedContentType = value!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentDescriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadContent();
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  void _createAnnouncement() async {
    if (_selectedCourseId != null &&
        _announcementTitleController.text.isNotEmpty &&
        _announcementMessageController.text.isNotEmpty) {
      try {
        final result = await ApiService.createAnnouncement(
          _announcementTitleController.text,
          _announcementMessageController.text,
          courseId: _selectedCourseId,
        );

        if (result.isSuccess && result.data != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    result.data?['message'] ?? 'Announcement created successfully')),
          );
          _announcementTitleController.clear();
          _announcementMessageController.clear();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create announcement')),
        );
      }
    }
  }

  void _uploadContent() async {
    if (_contentTitleController.text.isNotEmpty) {
      try {
        final result = await ApiService.uploadContent(
          _contentTitleController.text,
          _contentDescriptionController.text,
          _selectedContentType!,
          courseId: _selectedCourseId,
        );

        if (result.isSuccess && result.data != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(result.data?['message'] ?? 'Content uploaded successfully')),
          );
          _contentTitleController.clear();
          _contentDescriptionController.clear();
          _loadTeacherData(); // Refresh data
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload content')),
        );
      }
    }
  }
}
