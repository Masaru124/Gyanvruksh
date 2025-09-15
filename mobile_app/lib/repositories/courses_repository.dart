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
}
