import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:gyanvruksh/services/api.dart';
import 'mock_data.dart';

// Generate mocks with: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([ApiService])
class MockApiService extends Mock implements ApiService {
  @override
  Future<Map<String, dynamic>> getStudentStats() async {
    return MockData.studentStats;
  }

  @override
  Future<List<dynamic>> getStudentRecommendedCourses({int limit = 10}) async {
    return MockData.recommendations;
  }

  @override
  Future<List<dynamic>> getLearningPath() async {
    return MockData.learningPath;
  }

  @override
  Future<Map<String, dynamic>> getStudentAchievements() async {
    return {'achievements': MockData.achievements};
  }

  @override
  Future<Map<String, dynamic>> getUpcomingDeadlines({int daysAhead = 7}) async {
    return {'upcoming_deadlines': MockData.upcomingDeadlines};
  }

  @override
  Future<Map<String, dynamic>> getProgressReport() async {
    return MockData.progressReport;
  }

  @override
  Future<Map<String, dynamic>> getStudyGroups() async {
    return MockData.studyGroups;
  }

  @override
  Future<Map<String, dynamic>> getTeacherPerformanceAnalytics() async {
    return MockData.teacherPerformance;
  }

  @override
  Future<Map<String, dynamic>> getStudentManagementData() async {
    return MockData.studentManagement;
  }

  @override
  Future<Map<String, dynamic>> getTeacherMessages() async {
    return MockData.messages;
  }

  @override
  Future<Map<String, dynamic>> getContentLibrary() async {
    return MockData.contentLibrary;
  }

  @override
  Future<Map<String, dynamic>> enrollInCourseDetailed(int courseId) async {
    final course = MockData.recommendations.firstWhere(
      (c) => c['id'] == courseId,
      orElse: () => MockData.recommendations.first,
    );
    return {
      'success': true,
      'course_title': course['title'],
      'message': 'Successfully enrolled in ${course['title']}',
    };
  }

  @override
  Future<Map<String, dynamic>> generateStudyPlan(
    int courseId,
    DateTime targetDate,
    int dailyStudyHours,
  ) async {
    final course = MockData.recommendations.firstWhere(
      (c) => c['id'] == courseId,
      orElse: () => MockData.recommendations.first,
    );
    return {
      'course_title': course['title'],
      'target_date': targetDate.toIso8601String(),
      'daily_hours': dailyStudyHours,
      'total_days': targetDate.difference(DateTime.now()).inDays,
    };
  }

  @override
  Future<Map<String, dynamic>> joinStudyGroup(int groupId) async {
    final group = MockData.studyGroups['study_groups']!.firstWhere(
      (g) => g['id'] == groupId,
      orElse: () => MockData.studyGroups['study_groups']!.first,
    );
    return {
      'success': true,
      'message': 'Successfully joined ${group['name']}',
    };
  }

  @override
  Future<Map<String, dynamic>> askDoubt(String question, int courseId) async {
    return {
      'success': true,
      'message': 'Your doubt has been submitted successfully',
      'doubt_id': 12345,
    };
  }

  @override
  Future<Map<String, dynamic>> createAnnouncement(
    int courseId,
    String title,
    String message,
  ) async {
    return {
      'success': true,
      'message': 'Announcement created successfully',
      'announcement_id': 67890,
    };
  }

  @override
  Future<Map<String, dynamic>> uploadContent(
    String title,
    String contentType,
    String description,
  ) async {
    return {
      'success': true,
      'message': 'Content uploaded successfully',
      'content_id': 11111,
    };
  }
}
