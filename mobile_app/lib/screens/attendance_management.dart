import 'package:flutter/material.dart';
import 'package:gyanvruksh/services/enhanced_api_service.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';

class AttendanceManagementScreen extends StatefulWidget {
  final int courseId;
  final String courseTitle;

  const AttendanceManagementScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<AttendanceManagementScreen> createState() => _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState extends State<AttendanceManagementScreen> {
  List<dynamic> _sessions = [];
  List<dynamic> _lessons = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        ApiService.get('/api/attendance/course/${widget.courseId}/sessions'),
        ApiService.getLessons(courseId: widget.courseId),
      ]);

      final sessionsResponse = results[0];
      final lessonsResponse = results[1];

      setState(() {
        _sessions = sessionsResponse.isSuccess
            ? (sessionsResponse.data as List<dynamic>?) ?? []
            : [];
        _lessons = lessonsResponse.isSuccess
            ? (lessonsResponse.data as List<dynamic>?) ?? []
            : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _sessions = [];
        _lessons = [];
        _error = 'Failed to load attendance data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createAttendanceSession(int lessonId) async {
    try {
      final response = await ApiService.post('/api/attendance/sessions/create', {
        'course_id': widget.courseId,
        'lesson_id': lessonId,
        'session_name': 'Session ${DateTime.now().day}/${DateTime.now().month}',
        'session_date': DateTime.now().toIso8601String(),
      });

      if (response.isSuccess) {
        _loadData(); // Refresh data

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Attendance session created successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create session: $e')),
        );
      }
    }
  }

  Future<void> _viewAttendanceDetails(int lessonId) async {
    try {
      final response = await ApiService.get('/api/attendance/lesson/$lessonId');

      if (response.isSuccess && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceDetailsScreen(
              lessonId: lessonId,
              attendanceData: response.data as Map<String, dynamic>? ?? {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load attendance details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance - ${widget.courseTitle}'),
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
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red[300], size: 64),
                        const SizedBox(height: 16),
                        Text(_error!, style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildStatsCard(),
                        const SizedBox(height: 20),
                        _buildLessonsSection(),
                        const SizedBox(height: 20),
                        _buildSessionsSection(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalSessions = _sessions.length;
    final avgAttendance = _sessions.isEmpty
        ? 0.0
        : _sessions
                .map((s) => (s['attendance_percentage'] ?? 0.0) as double)
                .reduce((a, b) => a + b) /
            totalSessions;

    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Sessions',
                    totalSessions.toString(),
                    Icons.event,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Avg Attendance',
                    '${avgAttendance.toStringAsFixed(1)}%',
                    Icons.people,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Lessons',
                    _lessons.length.toString(),
                    Icons.book,
                  ),
                ),
              ],
            ),
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
            fontSize: 24,
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

  Widget _buildLessonsSection() {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lessons',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ..._lessons.map((lesson) => _buildLessonItem(lesson)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonItem(Map<String, dynamic> lesson) {
    final hasSession = _sessions.any((s) => s['lesson_id'] == lesson['id']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson['title'] ?? 'Untitled Lesson',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (lesson['description'] != null)
                  Text(
                    lesson['description'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (hasSession)
            ElevatedButton.icon(
              onPressed: () => _viewAttendanceDetails(lesson['id']),
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withValues(alpha: 0.8),
                foregroundColor: Colors.white,
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _createAttendanceSession(lesson['id']),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.withValues(alpha: 0.8),
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionsSection() {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Sessions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (_sessions.isEmpty)
              const Center(
                child: Text(
                  'No attendance sessions yet',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            else
              ..._sessions.take(5).map((session) => _buildSessionItem(session)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(Map<String, dynamic> session) {
    final attendancePercentage = (session['attendance_percentage'] ?? 0.0) as double;
    final sessionDate = DateTime.tryParse(session['session_date'] ?? '');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lesson ${session['lesson_id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (sessionDate != null)
                  Text(
                    '${sessionDate.day}/${sessionDate.month}/${sessionDate.year}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${attendancePercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: attendancePercentage >= 75
                      ? Colors.green[300]
                      : attendancePercentage >= 50
                          ? Colors.orange[300]
                          : Colors.red[300],
                ),
              ),
              Text(
                '${session['present_students']}/${session['total_students']}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AttendanceDetailsScreen extends StatefulWidget {
  final int lessonId;
  final Map<String, dynamic> attendanceData;

  const AttendanceDetailsScreen({
    super.key,
    required this.lessonId,
    required this.attendanceData,
  });

  @override
  State<AttendanceDetailsScreen> createState() => _AttendanceDetailsScreenState();
}

class _AttendanceDetailsScreenState extends State<AttendanceDetailsScreen> {
  List<Map<String, dynamic>> _studentAttendances = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  void _loadAttendanceData() {
    final studentAttendance = widget.attendanceData['student_attendance'] as List<dynamic>? ?? [];
    _studentAttendances = studentAttendance
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> _saveAttendance() async {
    try {
      final attendanceList = _studentAttendances.map((student) => {
        'student_id': student['student_id'],
        'is_present': student['is_present'],
        'notes': student['notes'] ?? '',
      }).toList();

      // Mark attendance for each student individually
      for (final student in attendanceList) {
        await ApiService.post('/api/attendance/mark', {
          'session_id': student['session_id'] ?? 1,
          'student_id': student['student_id'],
          'is_present': student['is_present'],
          'notes': student['notes'] ?? '',
        });
      }

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save attendance: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Details'),
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
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _saveAttendance,
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            )
          else
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit, color: Colors.white),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 20),
            _buildStudentList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalStudents = _studentAttendances.length;
    final presentStudents = _studentAttendances.where((s) => s['is_present'] == true).length;
    final attendancePercentage = totalStudents > 0 ? (presentStudents / totalStudents) * 100 : 0.0;

    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.attendanceData['lesson_title'] ?? 'Lesson Details',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Total', totalStudents.toString(), Icons.people),
                ),
                Expanded(
                  child: _buildStatItem('Present', presentStudents.toString(), Icons.check_circle),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Percentage',
                    '${attendancePercentage.toStringAsFixed(1)}%',
                    Icons.analytics,
                  ),
                ),
              ],
            ),
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
        ),
      ],
    );
  }

  Widget _buildStudentList() {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Student Attendance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ..._studentAttendances.map((student) => _buildStudentItem(student)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentItem(Map<String, dynamic> student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['student_name'] ?? 'Unknown Student',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  student['student_email'] ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (_isEditing)
            Switch(
              value: student['is_present'] ?? false,
              onChanged: (value) {
                setState(() {
                  student['is_present'] = value;
                });
              },
              activeColor: Colors.green,
            )
          else
            Icon(
              student['is_present'] == true ? Icons.check_circle : Icons.cancel,
              color: student['is_present'] == true ? Colors.green[300] : Colors.red[300],
            ),
        ],
      ),
    );
  }
}
