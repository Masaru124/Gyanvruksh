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
}
