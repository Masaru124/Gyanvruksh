import '../services/enhanced_api_service.dart';
import 'base_repository.dart';

class CoursesRepository extends BaseRepository {
  static Future<List<dynamic>> getAllCourses() async {
    final response = await ApiService.listCourses();
    return response.isSuccess ? (response.data as List<dynamic>? ?? []) : [];
  }

  static Future<List<dynamic>> getMyCourses() async {
    final response = await ApiService.myCourses();
    return response.isSuccess ? (response.data as List<dynamic>? ?? []) : [];
  }

  static Future<bool> createCourse(String title, String description) async {
    final response = await ApiService.createCourse(title, description);
    return response.isSuccess;
  }

  static Future<List<dynamic>> getAvailableCourses() async {
    final response = await ApiService.availableCourses();
    return response.isSuccess ? (response.data as List<dynamic>? ?? []) : [];
  }

  static Future<bool> selectCourse(int courseId) async {
    final response = await ApiService.selectCourse(courseId);
    return response.isSuccess;
  }

  static Future<Map<String, dynamic>> teacherStats() async {
    final response = await ApiService.teacherStats();
    return response.isSuccess ? (response.data as Map<String, dynamic>? ?? {}) : {};
  }

  static Future<List<dynamic>> upcomingClasses() async {
    final response = await ApiService.upcomingClasses();
    return response.isSuccess ? (response.data as List<dynamic>? ?? []) : [];
  }

  static Future<List<dynamic>> studentQueries() async {
    final response = await ApiService.studentQueries();
    return response.isSuccess ? (response.data as List<dynamic>? ?? []) : [];
  }

  static Future<bool> enrollInCourse(int courseId) async {
    final response = await ApiService.enrollInCourse(courseId);
    return response.isSuccess;
  }

  static Future<List<dynamic>> getEnrolledCourses() async {
    final response = await ApiService.getEnrolledCourses();
    return response.isSuccess ? (response.data as List<dynamic>? ?? []) : [];
  }

  static Future<bool> unenrollFromCourse(int courseId) async {
    final response = await ApiService.unenrollFromCourse(courseId);
    return response.isSuccess;
  }

  static Future<List<dynamic>> getAvailableCoursesForEnrollment() async {
    final response = await ApiService.getAvailableCoursesForEnrollment();
    return response.isSuccess ? (response.data as List<dynamic>? ?? []) : [];
  }

  static Future<Map<String, dynamic>?> getCourseDetails(int courseId) async {
    final response = await ApiService.getCourseDetails(courseId);
    return response.isSuccess ? response.data as Map<String, dynamic>? : null;
  }

  static Future<List<dynamic>> getCourseNotes(int courseId) async {
    final response = await ApiService.getCourseNotes(courseId);
    return response.isSuccess ? (response.data as List<dynamic>? ?? []) : [];
  }

  static Future<List<dynamic>> getCategories() async {
    final response = await ApiService.getCategories();
    return response.isSuccess ? (response.data as List<dynamic>? ?? []) : [];
  }

  static Future<List<dynamic>> getLessons({int? courseId}) async {
    final response = await ApiService.getLessons(courseId: courseId);
    return response.isSuccess ? (response.data as List<dynamic>? ?? []) : [];
  }

  static Future<Map<String, dynamic>?> getLesson(int lessonId) async {
    final response = await ApiService.getLesson(lessonId);
    return response.isSuccess ? response.data as Map<String, dynamic>? : null;
  }

  static Future<bool> createLesson(int courseId, String title, String description, String contentType,
      {String? contentUrl, String? contentText, int durationMinutes = 0, int orderIndex = 0, bool isFree = false}) async {
    final response = await ApiService.createLesson(courseId, title, description, contentType,
        contentUrl: contentUrl, contentText: contentText, durationMinutes: durationMinutes,
        orderIndex: orderIndex, isFree: isFree);
    return response.isSuccess;
  }

  static Future<List<dynamic>> getQuizzes({int? courseId}) async {
    final response = await ApiService.getQuizzes(courseId: courseId);
    return response.isSuccess ? (response.data as List<dynamic>? ?? []) : [];
  }

  static Future<Map<String, dynamic>?> getQuiz(int quizId) async {
    final response = await ApiService.getQuiz(quizId);
    return response.isSuccess ? response.data as Map<String, dynamic>? : null;
  }

  static Future<List<dynamic>> getQuizQuestions(int quizId) async {
    final response = await ApiService.getQuizQuestions(quizId);
    return response.isSuccess ? (response.data as List<dynamic>? ?? []) : [];
  }

  static Future<Map<String, dynamic>?> submitQuizAttempt(int quizId, Map<String, dynamic> answers) async {
    final response = await ApiService.submitQuizAttempt(quizId, answers);
    return response.isSuccess ? response.data as Map<String, dynamic>? : null;
  }

  static Future<List<dynamic>> getQuizAttempts(int quizId) async {
    final response = await ApiService.getQuizAttempts(quizId);
    return response.isSuccess ? (response.data as List<dynamic>? ?? []) : [];
  }

  static Future<Map<String, dynamic>?> getCourseProgress(int courseId) async {
    final response = await ApiService.getCourseProgress(courseId);
    return response.isSuccess ? response.data as Map<String, dynamic>? : null;
  }

  static Future<bool> updateLessonProgress(int courseId, int lessonId, double progressPercentage,
      {bool completed = false, int timeSpentMinutes = 0}) async {
    final response = await ApiService.updateLessonProgress(courseId, lessonId, progressPercentage,
        completed: completed, timeSpentMinutes: timeSpentMinutes);
    return response.isSuccess;
  }

  static Future<Map<String, dynamic>?> getUserPreferences() async {
    final response = await ApiService.getUserPreferences();
    return response.isSuccess ? response.data as Map<String, dynamic>? : null;
  }

  static Future<bool> updateUserPreferences({
    List<String>? preferredCategories,
    String? skillLevel,
    List<String>? learningGoals,
    int? dailyStudyTime,
    bool? notificationsEnabled,
  }) async {
    final response = await ApiService.updateUserPreferences(
      preferredCategories: preferredCategories,
      skillLevel: skillLevel,
      learningGoals: learningGoals,
      dailyStudyTime: dailyStudyTime,
      notificationsEnabled: notificationsEnabled,
    );
    return response.isSuccess;
  }

  // Enhanced content type support methods
  static Future<List<dynamic>> getLessonsByContentType(String contentType, {int? courseId}) async {
    final lessons = await getLessons(courseId: courseId);
    return lessons.where((lesson) => lesson['content_type'] == contentType).toList();
  }

  Future<List<dynamic>> getVideoLessons({int? courseId}) async {
    return await getLessonsByContentType('video', courseId: courseId);
  }

  Future<List<dynamic>> getAudioLessons({int? courseId}) async {
    return await getLessonsByContentType('audio', courseId: courseId);
  }

  Future<List<dynamic>> getTextLessons({int? courseId}) async {
    return await getLessonsByContentType('text', courseId: courseId);
  }

  Future<List<dynamic>> getInteractiveLessons({int? courseId}) async {
    return await getLessonsByContentType('interactive', courseId: courseId);
  }

  Future<List<dynamic>> getDocumentLessons({int? courseId}) async {
    return await getLessonsByContentType('document', courseId: courseId);
  }

  // Content format validation and processing
  bool isValidContentUrl(String url, String contentType) {
    switch (contentType) {
      case 'video':
        return url.contains('.mp4') || url.contains('.webm') || url.contains('.avi') ||
               url.contains('youtube.com') || url.contains('vimeo.com') ||
               url.contains('youtu.be');
      case 'audio':
        return url.contains('.mp3') || url.contains('.wav') || url.contains('.aac') ||
               url.contains('.ogg');
      case 'document':
        return url.contains('.pdf') || url.contains('.doc') || url.contains('.docx') ||
               url.contains('.ppt') || url.contains('.pptx');
      case 'interactive':
        return url.contains('.html') || url.contains('.htm') || url.isNotEmpty;
      default:
        return true; // Allow custom content types
    }
  }

  // Content metadata extraction
  Map<String, dynamic> getContentMetadata(Map<String, dynamic> lesson) {
    final contentType = lesson['content_type'] as String?;
    final contentUrl = lesson['content_url'] as String?;
    final contentText = lesson['content_text'] as String?;

    return {
      'contentType': contentType,
      'hasUrl': contentUrl != null && contentUrl.isNotEmpty,
      'hasText': contentText != null && contentText.isNotEmpty,
      'isValidUrl': contentUrl != null ? isValidContentUrl(contentUrl, contentType ?? '') : false,
      'estimatedDuration': lesson['duration_minutes'] ?? 0,
      'isFree': lesson['is_free'] ?? false,
      'fileExtension': contentUrl != null ? _getFileExtension(contentUrl) : null,
      'isExternalLink': contentUrl != null ? _isExternalLink(contentUrl) : false,
    };
  }

  String? _getFileExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final lastDot = path.lastIndexOf('.');
      if (lastDot != -1) {
        return path.substring(lastDot + 1).toLowerCase();
      }
    } catch (e) {
      // Invalid URL format
    }
    return null;
  }

  bool _isExternalLink(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.isNotEmpty && !uri.host.contains('localhost') && !uri.host.contains('10.0.2.2');
    } catch (e) {
      return false;
    }
  }

  // Content download/preparation methods
  Future<bool> prepareContentForOffline(int lessonId) async {
    try {
      final lesson = await getLesson(lessonId);
      if (lesson == null) return false;

      final metadata = getContentMetadata(lesson);
      if (!metadata['hasUrl'] || metadata['isExternalLink']) {
        return false; // Can't download external content
      }

      // Here you would implement actual download logic
      // For now, just return true for local content
      return true;
    } catch (e) {
      return false;
    }
  }

  // Content recommendation based on user preferences
  Future<List<dynamic>> getRecommendedLessons({int? courseId}) async {
    try {
      final preferences = await getUserPreferences();
      if (preferences == null) {
        return await getLessons(courseId: courseId);
      }

      // Filter lessons based on preferences
      final allLessons = await getLessons(courseId: courseId);
      final recommendedLessons = allLessons.where((lesson) {
        // Add recommendation logic here based on user preferences
        // For now, return all lessons
        return true;
      }).toList();

      return recommendedLessons;
    } catch (e) {
      return await getLessons(courseId: courseId);
    }
  }
}
