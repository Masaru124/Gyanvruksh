import 'package:flutter/material.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';

class StudentFeaturesScreen extends StatefulWidget {
  const StudentFeaturesScreen({super.key});

  @override
  State<StudentFeaturesScreen> createState() => _StudentFeaturesScreenState();
}

class _StudentFeaturesScreenState extends State<StudentFeaturesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  Map<String, dynamic> _studentStats = {};
  List<dynamic> _recommendations = [];
  List<dynamic> _learningPath = [];
  List<dynamic> _achievements = [];
  List<dynamic> _upcomingDeadlines = [];
  
  // Form variables
  int? _selectedCourseId;
  int _dailyStudyHours = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadStudentData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentData() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        ApiService().getStudentStats(),
        ApiService().getStudentRecommendedCourses(),
        ApiService().getLearningPath(),
        ApiService().getStudentAchievements(),
        ApiService().getUpcomingDeadlines(),
      ]);

      setState(() {
        _studentStats = results[0] as Map<String, dynamic>? ?? {};
        _recommendations = results[1] is List ? results[1] as List<dynamic> : [];
        _learningPath = results[2] is List ? results[2] as List<dynamic> : [];
        _achievements = (results[3] as Map<String, dynamic>?)?['achievements'] as List<dynamic>? ?? [];
        _upcomingDeadlines = (results[4] as Map<String, dynamic>?)?['upcoming_deadlines'] as List<dynamic>? ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load student data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.recommend), text: 'Recommended'),
            Tab(icon: Icon(Icons.route), text: 'Learning Path'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Achievements'),
            Tab(icon: Icon(Icons.schedule), text: 'Deadlines'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildRecommendationsTab(),
                  _buildLearningPathTab(),
                  _buildAchievementsTab(),
                  _buildDeadlinesTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadStudentData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsCards(),
          const SizedBox(height: 20),
          _buildQuickActions(),
          const SizedBox(height: 20),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final enrollments = _studentStats['enrollments'] as Map<String, dynamic>? ?? {};
    final progress = _studentStats['progress'] as Map<String, dynamic>? ?? {};
    final attendance = _studentStats['attendance'] as Map<String, dynamic>? ?? {};
    final assignments = _studentStats['assignments'] as Map<String, dynamic>? ?? {};

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Enrolled Courses',
                '${enrollments['total'] ?? 0}',
                Icons.book,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Completed',
                '${enrollments['completed'] ?? 0}',
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Avg Progress',
                '${progress['average_progress'] ?? 0}%',
                Icons.trending_up,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Attendance',
                '${attendance['attendance_percentage'] ?? 0}%',
                Icons.people,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Avg Grade',
                '${assignments['average_grade'] ?? 0}%',
                Icons.grade,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Gyan Coins',
                '${_studentStats['gyan_coins'] ?? 0}',
                Icons.monetization_on,
                Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
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
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
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
                  child: _buildActionButton(
                    'Study Plan',
                    Icons.schedule,
                    () => _generateStudyPlan(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Progress Report',
                    Icons.analytics,
                    () => _viewProgressReport(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Find Study Group',
                    Icons.group,
                    () => _findStudyGroup(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Ask Doubt',
                    Icons.help,
                    () => _askDoubt(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityItem('Completed Lesson: Introduction to Flutter', Icons.check, Colors.green),
            _buildActivityItem('Submitted Assignment: Mobile App Design', Icons.assignment, Colors.blue),
            _buildActivityItem('Joined Study Group: Advanced Programming', Icons.group, Colors.purple),
            _buildActivityItem('Earned Achievement: First Course Complete', Icons.emoji_events, Colors.amber),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String activity, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              activity,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Recommended Courses',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ..._recommendations.map((course) => _buildCourseCard(course)).toList(),
      ],
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course['title'] ?? 'Unknown Course',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              course['description'] ?? 'No description',
              style: const TextStyle(color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                Text(' ${course['rating'] ?? 0}', style: const TextStyle(color: Colors.white70)),
                const SizedBox(width: 16),
                Icon(Icons.people, color: Colors.white70, size: 16),
                Text(' ${course['enrollment_count'] ?? 0}', style: const TextStyle(color: Colors.white70)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _enrollInCourse(course['id']),
                  child: const Text('Enroll'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningPathTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Your Learning Path',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ..._learningPath.map((item) => _buildLearningPathItem(item)).toList(),
      ],
    );
  }

  Widget _buildLearningPathItem(Map<String, dynamic> item) {
    final progress = (item['progress_percentage'] ?? 0.0) as double;
    
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item['course_title'] ?? 'Unknown Course',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item['priority'] == 'high' ? Colors.red : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item['priority'] ?? 'medium',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              '${progress.toStringAsFixed(1)}% Complete',
              style: const TextStyle(color: Colors.white70),
            ),
            if (item['next_lesson'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Next: ${item['next_lesson']['title']}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Your Achievements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        if (_achievements.isEmpty)
          const Center(
            child: Text(
              'No achievements yet. Keep learning!',
              style: TextStyle(color: Colors.white70),
            ),
          )
        else
          ..._achievements.map((achievement) => _buildAchievementItem(achievement)).toList(),
      ],
    );
  }

  Widget _buildAchievementItem(Map<String, dynamic> achievement) {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              achievement['icon'] ?? '🏆',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement['title'] ?? 'Achievement',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    achievement['description'] ?? 'Description',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlinesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Upcoming Deadlines',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        if (_upcomingDeadlines.isEmpty)
          const Center(
            child: Text(
              'No upcoming deadlines',
              style: TextStyle(color: Colors.white70),
            ),
          )
        else
          ..._upcomingDeadlines.map((deadline) => _buildDeadlineItem(deadline)).toList(),
      ],
    );
  }

  Widget _buildDeadlineItem(Map<String, dynamic> deadline) {
    final isHighPriority = deadline['priority'] == 'high';
    
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              deadline['type'] == 'assignment' ? Icons.assignment : Icons.schedule,
              color: isHighPriority ? Colors.red : Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deadline['title'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    deadline['course_title'] ?? 'Unknown Course',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Due: ${deadline['due_date'] ?? deadline['scheduled_at'] ?? 'Unknown'}',
                    style: TextStyle(
                      color: isHighPriority ? Colors.red[300] : Colors.orange[300],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action methods
  void _generateStudyPlan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Study Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select course and target completion date:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Course'),
              items: _recommendations.map((course) {
                return DropdownMenuItem<int>(
                  value: course['id'] as int,
                  child: Text(course['title'] ?? 'Unknown Course'),
                );
              }).toList(),
              onChanged: (value) => _selectedCourseId = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Daily Study Hours'),
              keyboardType: TextInputType.number,
              onChanged: (value) => _dailyStudyHours = int.tryParse(value) ?? 2,
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
              _createStudyPlan();
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _viewProgressReport() async {
    try {
      final report = await ApiService().getProgressReport();
      if (report.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Progress Report'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Overall Progress: ${report['summary']?['overall_progress'] ?? 0}%'),
                  const SizedBox(height: 8),
                  Text('Total Courses: ${report['summary']?['total_courses'] ?? 0}'),
                  Text('Completed: ${report['summary']?['completed_courses'] ?? 0}'),
                  Text('In Progress: ${report['summary']?['in_progress_courses'] ?? 0}'),
                  const SizedBox(height: 16),
                  const Text('Course Progress:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...((report['course_progress'] as List?) ?? []).map((course) => 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('${course['course_title']}: ${course['progress']}%'),
                    )
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load progress report')),
      );
    }
  }

  void _findStudyGroup() async {
    try {
      final groups = await ApiService().getStudyGroups();
      final studyGroups = (groups['study_groups'] as List?) ?? [];
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Study Groups'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: studyGroups.length,
              itemBuilder: (context, index) {
                final group = studyGroups[index];
                return Card(
                  child: ListTile(
                    title: Text(group['name'] ?? 'Unknown Group'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group['description'] ?? ''),
                        Text('Members: ${group['members_count']}/${group['max_members']}'),
                        Text('Schedule: ${group['meeting_schedule'] ?? 'TBD'}'),
                      ],
                    ),
                    trailing: group['is_member'] == true 
                        ? const Icon(Icons.check, color: Colors.green)
                        : ElevatedButton(
                            onPressed: () => _joinStudyGroup(group['id']),
                            child: const Text('Join'),
                          ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load study groups')),
      );
    }
  }

  void _askDoubt() {
    final questionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ask a Doubt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Select Course'),
              items: _recommendations.map((course) {
                return DropdownMenuItem<int>(
                  value: course['id'] as int,
                  child: Text(course['title'] ?? 'Unknown Course'),
                );
              }).toList(),
              onChanged: (value) => _selectedCourseId = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: 'Your Question',
                hintText: 'Type your doubt here...',
              ),
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
              if (_selectedCourseId != null && questionController.text.isNotEmpty) {
                Navigator.pop(context);
                _submitDoubt(questionController.text, _selectedCourseId!);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _enrollInCourse(int courseId) async {
    try {
      final result = await ApiService().enrollInCourseDetailed(courseId);
      if (result.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Enrollment Successful'),
            content: Text('Successfully enrolled in ${result['course_title'] ?? 'course'}!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadStudentData(); // Refresh data
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to enroll in course')),
      );
    }
  }

  // Missing helper methods
  void _createStudyPlan() async {
    if (_selectedCourseId != null) {
      try {
        final targetDate = DateTime.now().add(const Duration(days: 30)); // Default 30 days
        final studyPlan = await ApiService().generateStudyPlan(
          _selectedCourseId!,
          targetDate,
          _dailyStudyHours,
        );
        
        if (studyPlan.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Study plan generated for ${studyPlan['course_title']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate study plan')),
        );
      }
    }
  }

  void _joinStudyGroup(int groupId) async {
    try {
      final result = await ApiService().joinStudyGroup(groupId);
      if (result.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Joined study group successfully')),
        );
        Navigator.pop(context); // Close dialog
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join study group')),
      );
    }
  }

  void _submitDoubt(String question, int courseId) async {
    try {
      final result = await ApiService().askDoubt(question, courseId);
      if (result.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Doubt submitted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit doubt')),
      );
    }
  }
}
