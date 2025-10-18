import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:gyanvruksh/services/api.dart';

// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([ApiService])
class MockApiService extends Mock implements ApiService {}

// Mock data for testing
class MockData {
  static const Map<String, dynamic> studentStats = {
    'enrollments': {
      'total': 5,
      'completed': 2,
      'in_progress': 3,
    },
    'progress': {
      'average_progress': 75.5,
    },
    'attendance': {
      'attendance_percentage': 85.0,
    },
    'assignments': {
      'average_grade': 88.0,
    },
    'gyan_coins': 150,
  };

  static const Map<String, dynamic> teacherPerformance = {
    'total_revenue': 2500,
    'top_performing_course': {
      'course_title': 'Flutter Development',
      'enrollment_count': 45,
    },
    'course_performance': [
      {
        'course_title': 'Flutter Development',
        'total_enrolled': 45,
        'completed_students': 38,
        'completion_rate': 84.4,
        'revenue': 2250,
      },
      {
        'course_title': 'React Native',
        'total_enrolled': 32,
        'completed_students': 25,
        'completion_rate': 78.1,
        'revenue': 1600,
      },
    ],
  };

  static const Map<String, dynamic> studentManagement = {
    'total_students': 120,
    'active_students': 98,
    'at_risk_students': 5,
    'students': [
      {
        'student_name': 'John Doe',
        'student_email': 'john@example.com',
        'course_title': 'Flutter Development',
        'progress': 85,
        'performance_grade': 'A',
        'hours_completed': 24,
        'attendance_rate': 92,
        'last_activity': '2024-01-15',
      },
      {
        'student_name': 'Jane Smith',
        'student_email': 'jane@example.com',
        'course_title': 'React Native',
        'progress': 72,
        'performance_grade': 'B',
        'hours_completed': 18,
        'attendance_rate': 88,
        'last_activity': '2024-01-14',
      },
    ],
  };

  static const Map<String, dynamic> messages = {
    'total_messages': 15,
    'unread_count': 3,
    'messages': [
      {
        'subject': 'Question about Assignment 3',
        'from_student': 'John Doe',
        'course_title': 'Flutter Development',
        'message': 'I need help with the state management part...',
        'status': 'unread',
        'received_at': '2024-01-15',
      },
      {
        'subject': 'Project Submission',
        'from_student': 'Jane Smith',
        'course_title': 'React Native',
        'message': 'I have completed the project...',
        'status': 'read',
        'received_at': '2024-01-14',
      },
    ],
  };

  static const Map<String, dynamic> contentLibrary = {
    'videos': [
      {
        'title': 'Introduction to Flutter',
        'duration': '15:30',
        'views': 1250,
      },
    ],
    'documents': [
      {
        'title': 'Flutter Best Practices',
        'size': '2.5 MB',
        'downloads': 89,
      },
    ],
    'quizzes': [
      {
        'title': 'Flutter Fundamentals Quiz',
        'questions': 20,
        'avg_score': 85.5,
      },
    ],
  };

  static const List<Map<String, dynamic>> recommendations = [
    {
      'id': 1,
      'title': 'Advanced Dart Programming',
      'description': 'Master advanced Dart concepts and patterns',
      'rating': 4.8,
      'enrollment_count': 234,
    },
    {
      'id': 2,
      'title': 'UI/UX Design Principles',
      'description': 'Learn modern design principles for mobile apps',
      'rating': 4.6,
      'enrollment_count': 156,
    },
  ];

  static const List<Map<String, dynamic>> learningPath = [
    {
      'course_title': 'Flutter Development',
      'progress_percentage': 75.0,
      'priority': 'high',
      'next_lesson': {
        'title': 'State Management with Provider',
      },
    },
    {
      'course_title': 'React Native',
      'progress_percentage': 45.0,
      'priority': 'medium',
      'next_lesson': {
        'title': 'Navigation and Routing',
      },
    },
  ];

  static const List<Map<String, dynamic>> achievements = [
    {
      'title': 'First Course Completed',
      'description': 'Completed your first course successfully',
      'icon': '🎓',
    },
    {
      'title': 'Perfect Attendance',
      'description': 'Maintained 100% attendance for a month',
      'icon': '📅',
    },
  ];

  static const List<Map<String, dynamic>> upcomingDeadlines = [
    {
      'title': 'Mobile App Project Submission',
      'course_title': 'Flutter Development',
      'type': 'assignment',
      'priority': 'high',
      'due_date': '2024-01-20',
    },
    {
      'title': 'Mid-term Quiz',
      'course_title': 'React Native',
      'type': 'quiz',
      'priority': 'medium',
      'scheduled_at': '2024-01-18',
    },
  ];

  static const Map<String, dynamic> progressReport = {
    'summary': {
      'overall_progress': 68.5,
      'total_courses': 3,
      'completed_courses': 1,
      'in_progress_courses': 2,
    },
    'course_progress': [
      {
        'course_title': 'Flutter Development',
        'progress': 85,
      },
      {
        'course_title': 'React Native',
        'progress': 52,
      },
    ],
  };

  static const Map<String, dynamic> studyGroups = {
    'study_groups': [
      {
        'id': 1,
        'name': 'Advanced Flutter Study Group',
        'description': 'Weekly discussions on advanced Flutter topics',
        'members_count': 8,
        'max_members': 15,
        'meeting_schedule': 'Every Tuesday 7 PM',
        'is_member': true,
      },
      {
        'id': 2,
        'name': 'Mobile Dev Beginners',
        'description': 'Learn mobile development from scratch',
        'members_count': 12,
        'max_members': 20,
        'meeting_schedule': 'Every Saturday 10 AM',
        'is_member': false,
      },
    ],
  };
}
