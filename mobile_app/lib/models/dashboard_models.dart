class StudentDashboardStats {
  final int enrolledCourses;
  final int completedCourses;
  final int totalStudyHours;
  final int currentStreak;
  final int gyanCoins;
  final int achievementsCount;
  final String rank;

  StudentDashboardStats({
    required this.enrolledCourses,
    required this.completedCourses,
    required this.totalStudyHours,
    required this.currentStreak,
    required this.gyanCoins,
    required this.achievementsCount,
    required this.rank,
  });

  factory StudentDashboardStats.fromJson(Map<String, dynamic> json) {
    return StudentDashboardStats(
      enrolledCourses: json['enrolled_courses'] ?? 0,
      completedCourses: json['completed_courses'] ?? 0,
      totalStudyHours: json['total_study_hours'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      gyanCoins: json['gyan_coins'] ?? 0,
      achievementsCount: json['achievements_count'] ?? 0,
      rank: json['rank'] ?? 'Beginner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enrolled_courses': enrolledCourses,
      'completed_courses': completedCourses,
      'total_study_hours': totalStudyHours,
      'current_streak': currentStreak,
      'gyan_coins': gyanCoins,
      'achievements_count': achievementsCount,
      'rank': rank,
    };
  }
}

class TeacherDashboardStats {
  final int totalCourses;
  final int totalStudents;
  final int activeStudents;
  final double averageCompletionRate;
  final int totalLessons;
  final double engagementScore;

  TeacherDashboardStats({
    required this.totalCourses,
    required this.totalStudents,
    required this.activeStudents,
    required this.averageCompletionRate,
    required this.totalLessons,
    required this.engagementScore,
  });

  factory TeacherDashboardStats.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardStats(
      totalCourses: json['total_courses'] ?? 0,
      totalStudents: json['total_students'] ?? 0,
      activeStudents: json['active_students'] ?? 0,
      averageCompletionRate: (json['average_completion_rate'] ?? 0.0).toDouble(),
      totalLessons: json['total_lessons'] ?? 0,
      engagementScore: (json['engagement_score'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_courses': totalCourses,
      'total_students': totalStudents,
      'active_students': activeStudents,
      'average_completion_rate': averageCompletionRate,
      'total_lessons': totalLessons,
      'engagement_score': engagementScore,
    };
  }
}

class CourseRecommendation {
  final int id;
  final String title;
  final String description;
  final String teacherName;
  final int enrolledStudents;
  final int totalHours;
  final String recommendationReason;

  CourseRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherName,
    required this.enrolledStudents,
    required this.totalHours,
    required this.recommendationReason,
  });

  factory CourseRecommendation.fromJson(Map<String, dynamic> json) {
    return CourseRecommendation(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      teacherName: json['teacher_name'] ?? '',
      enrolledStudents: json['enrolled_students'] ?? 0,
      totalHours: json['total_hours'] ?? 0,
      recommendationReason: json['recommendation_reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'teacher_name': teacherName,
      'enrolled_students': enrolledStudents,
      'total_hours': totalHours,
      'recommendation_reason': recommendationReason,
    };
  }
}

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final String createdAt;
  final String? actionUrl;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.actionUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['created_at'] ?? '',
      actionUrl: json['action_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'created_at': createdAt,
      'action_url': actionUrl,
    };
  }
}

class UpcomingClass {
  final int? lessonId;
  final int courseId;
  final String courseTitle;
  final String lessonTitle;
  final String? description;
  final String? scheduledAt;
  final int durationMinutes;
  final String contentType;

  UpcomingClass({
    this.lessonId,
    required this.courseId,
    required this.courseTitle,
    required this.lessonTitle,
    this.description,
    this.scheduledAt,
    required this.durationMinutes,
    required this.contentType,
  });

  factory UpcomingClass.fromJson(Map<String, dynamic> json) {
    return UpcomingClass(
      lessonId: json['lesson_id'],
      courseId: json['course_id'] ?? 0,
      courseTitle: json['course_title'] ?? '',
      lessonTitle: json['lesson_title'] ?? '',
      description: json['description'],
      scheduledAt: json['scheduled_at'],
      durationMinutes: json['duration_minutes'] ?? 0,
      contentType: json['content_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lesson_id': lessonId,
      'course_id': courseId,
      'course_title': courseTitle,
      'lesson_title': lessonTitle,
      'description': description,
      'scheduled_at': scheduledAt,
      'duration_minutes': durationMinutes,
      'content_type': contentType,
    };
  }
}

class StudentQuery {
  final int messageId;
  final int studentId;
  final String? studentName;
  final String message;
  final String timestamp;

  StudentQuery({
    required this.messageId,
    required this.studentId,
    this.studentName,
    required this.message,
    required this.timestamp,
  });

  factory StudentQuery.fromJson(Map<String, dynamic> json) {
    return StudentQuery(
      messageId: json['message_id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      studentName: json['student_name'],
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'student_id': studentId,
      'student_name': studentName,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
