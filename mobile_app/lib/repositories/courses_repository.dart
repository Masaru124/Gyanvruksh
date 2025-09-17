import '../services/api.dart';
import 'base_repository.dart';

class CoursesRepository extends BaseRepository {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getAllCourses() async {
    return await handleApiCall(() => _apiService.listCourses());
  }

  Future<List<dynamic>> getMyCourses() async {
    return await handleApiCall(() => _apiService.myCourses());
  }

  Future<bool> createCourse(String title, String description) async {
    return await handleApiCall(() => _apiService.createCourse(title, description));
  }

  Future<List<dynamic>> getAvailableCourses() async {
    return await handleApiCall(() => _apiService.availableCourses());
  }

  Future<bool> selectCourse(int courseId) async {
    return await handleApiCall(() => _apiService.selectCourse(courseId));
  }

  Future<Map<String, dynamic>> getTeacherStats() async {
    return await handleApiCall(() => _apiService.teacherStats());
  }

  Future<List<dynamic>> getUpcomingClasses() async {
    return await handleApiCall(() => _apiService.upcomingClasses());
  }

  Future<List<dynamic>> getStudentQueries() async {
    return await handleApiCall(() => _apiService.studentQueries());
  }

  Future<bool> enrollInCourse(int courseId) async {
    return await handleApiCall(() => _apiService.enrollInCourse(courseId));
  }

  Future<List<dynamic>> getEnrolledCourses() async {
    return await handleApiCall(() => _apiService.getEnrolledCourses());
  }

  Future<bool> unenrollFromCourse(int courseId) async {
    return await handleApiCall(() => _apiService.unenrollFromCourse(courseId));
  }

  Future<List<dynamic>> getAvailableCoursesForEnrollment() async {
    return await handleApiCall(() => _apiService.getAvailableCoursesForEnrollment());
  }

  Future<Map<String, dynamic>?> getCourseDetails(int courseId) async {
    return await handleApiCall(() => _apiService.getCourseDetails(courseId));
  }

  Future<List<dynamic>> getCourseVideos(int courseId) async {
    return await handleApiCall(() => _apiService.getCourseVideos(courseId));
  }

  Future<List<dynamic>> getCourseNotes(int courseId) async {
    return await handleApiCall(() => _apiService.getCourseNotes(courseId));
  }

  // New methods for extended features
  Future<List<dynamic>> getCategories() async {
    return await handleApiCall(() => _apiService.getCategories());
  }

  Future<List<dynamic>> getLessons({int? courseId}) async {
    return await handleApiCall(() => _apiService.getLessons(courseId: courseId));
  }

  Future<Map<String, dynamic>?> getLesson(int lessonId) async {
    return await handleApiCall(() => _apiService.getLesson(lessonId));
  }

  Future<bool> createLesson(int courseId, String title, String description, String contentType,
      {String? contentUrl, String? contentText, int durationMinutes = 0, int orderIndex = 0, bool isFree = false}) async {
    return await handleApiCall(() => _apiService.createLesson(courseId, title, description, contentType,
        contentUrl: contentUrl, contentText: contentText, durationMinutes: durationMinutes,
        orderIndex: orderIndex, isFree: isFree));
  }

  Future<List<dynamic>> getQuizzes({int? courseId}) async {
    return await handleApiCall(() => _apiService.getQuizzes(courseId: courseId));
  }

  Future<Map<String, dynamic>?> getQuiz(int quizId) async {
    return await handleApiCall(() => _apiService.getQuiz(quizId));
  }

  Future<List<dynamic>> getQuizQuestions(int quizId) async {
    return await handleApiCall(() => _apiService.getQuizQuestions(quizId));
  }

  Future<Map<String, dynamic>?> submitQuizAttempt(int quizId, Map<String, dynamic> answers) async {
    return await handleApiCall(() => _apiService.submitQuizAttempt(quizId, answers));
  }

  Future<List<dynamic>> getQuizAttempts(int quizId) async {
    return await handleApiCall(() => _apiService.getQuizAttempts(quizId));
  }

  Future<Map<String, dynamic>?> getCourseProgress(int courseId) async {
    return await handleApiCall(() => _apiService.getCourseProgress(courseId));
  }

  Future<bool> updateLessonProgress(int courseId, int lessonId, double progressPercentage,
      {bool completed = false, int timeSpentMinutes = 0}) async {
    return await handleApiCall(() => _apiService.updateLessonProgress(courseId, lessonId, progressPercentage,
        completed: completed, timeSpentMinutes: timeSpentMinutes));
  }

  Future<Map<String, dynamic>?> getUserPreferences() async {
    return await handleApiCall(() => _apiService.getUserPreferences());
  }

  Future<bool> updateUserPreferences({
    List<String>? preferredCategories,
    String? skillLevel,
    List<String>? learningGoals,
    int? dailyStudyTime,
    bool? notificationsEnabled,
  }) async {
    return await handleApiCall(() => _apiService.updateUserPreferences(
        preferredCategories: preferredCategories,
        skillLevel: skillLevel,
        learningGoals: learningGoals,
        dailyStudyTime: dailyStudyTime,
        notificationsEnabled: notificationsEnabled));
  }

  // Enhanced content type support methods
  Future<List<dynamic>> getLessonsByContentType(String contentType, {int? courseId}) async {
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

      final preferredCategories = preferences['preferred_categories'] as List<dynamic>? ?? [];
      final skillLevel = preferences['skill_level'] as String?;

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
