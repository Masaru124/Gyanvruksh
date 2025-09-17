class Course {
  final int id;
  final String title;
  final String description;
  final int? teacherId;
  final String? teacherName;
  final int? totalHours;
  final String? createdAt;
  final int? enrolledStudentsCount;

  Course({
    required this.id,
    required this.title,
    required this.description,
    this.teacherId,
    this.teacherName,
    this.totalHours,
    this.createdAt,
    this.enrolledStudentsCount,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      teacherId: json['teacher_id'],
      teacherName: json['teacher_name'],
      totalHours: json['total_hours'],
      createdAt: json['created_at'],
      enrolledStudentsCount: json['enrolled_students_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'total_hours': totalHours,
      'created_at': createdAt,
      'enrolled_students_count': enrolledStudentsCount,
    };
  }
}

class Lesson {
  final int id;
  final int courseId;
  final String title;
  final String? description;
  final String contentType;
  final String? contentUrl;
  final String? contentText;
  final int durationMinutes;
  final int orderIndex;
  final bool isFree;
  final String? scheduledAt;
  final String createdAt;

  Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.contentType,
    this.contentUrl,
    this.contentText,
    required this.durationMinutes,
    required this.orderIndex,
    required this.isFree,
    this.scheduledAt,
    required this.createdAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      contentType: json['content_type'] ?? '',
      contentUrl: json['content_url'],
      contentText: json['content_text'],
      durationMinutes: json['duration_minutes'] ?? 0,
      orderIndex: json['order_index'] ?? 0,
      isFree: json['is_free'] ?? false,
      scheduledAt: json['scheduled_at'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'content_type': contentType,
      'content_url': contentUrl,
      'content_text': contentText,
      'duration_minutes': durationMinutes,
      'order_index': orderIndex,
      'is_free': isFree,
      'scheduled_at': scheduledAt,
      'created_at': createdAt,
    };
  }
}

class Enrollment {
  final int id;
  final int studentId;
  final int courseId;
  final String enrolledAt;
  final int hoursCompleted;

  Enrollment({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.enrolledAt,
    required this.hoursCompleted,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      enrolledAt: json['enrolled_at'] ?? '',
      hoursCompleted: json['hours_completed'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'course_id': courseId,
      'enrolled_at': enrolledAt,
      'hours_completed': hoursCompleted,
    };
  }
}

class CourseProgress {
  final int courseId;
  final double progressPercentage;
  final String? lastAccessed;
  final int timeSpentMinutes;

  CourseProgress({
    required this.courseId,
    required this.progressPercentage,
    this.lastAccessed,
    required this.timeSpentMinutes,
  });

  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    return CourseProgress(
      courseId: json['course_id'] ?? 0,
      progressPercentage: (json['progress_percentage'] ?? 0.0).toDouble(),
      lastAccessed: json['last_accessed'],
      timeSpentMinutes: json['time_spent_minutes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'progress_percentage': progressPercentage,
      'last_accessed': lastAccessed,
      'time_spent_minutes': timeSpentMinutes,
    };
  }
}
