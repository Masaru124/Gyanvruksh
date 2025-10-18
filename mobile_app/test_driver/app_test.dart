import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Gyanvruksh App Tests', () {
    late FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      await driver.close();
    });

    test('App launches and shows splash screen', () async {
      // Wait for splash screen to appear
      await driver.waitFor(find.byType('SplashScreen'));
      
      // Wait for navigation to login/onboarding
      await driver.waitFor(find.byType('LoginScreen'), timeout: Duration(seconds: 10));
    });

    test('Login functionality works', () async {
      // Find login form elements
      final emailField = find.byValueKey('email_field');
      final passwordField = find.byValueKey('password_field');
      final loginButton = find.byValueKey('login_button');

      // Enter test credentials
      await driver.tap(emailField);
      await driver.enterText('test@example.com');
      
      await driver.tap(passwordField);
      await driver.enterText('password123');

      // Tap login button
      await driver.tap(loginButton);

      // Wait for dashboard or role selection
      await driver.waitFor(find.byType('RoleSelectionScreen'), timeout: Duration(seconds: 5));
    });

    test('Student dashboard loads correctly', () async {
      // Navigate to student dashboard
      final studentRole = find.byValueKey('student_role');
      await driver.tap(studentRole);

      // Wait for student dashboard
      await driver.waitFor(find.byType('StudentDashboard'), timeout: Duration(seconds: 5));

      // Check if quick actions are present
      await driver.waitFor(find.text('Quick Actions'));
      await driver.waitFor(find.text('Student Features'));
      await driver.waitFor(find.text('Progress Report'));
    });

    test('Student features navigation works', () async {
      // Tap on Student Features button
      final studentFeaturesButton = find.text('Student Features');
      await driver.tap(studentFeaturesButton);

      // Wait for student features screen
      await driver.waitFor(find.byType('StudentFeaturesScreen'), timeout: Duration(seconds: 5));

      // Check if all features are present
      await driver.waitFor(find.text('Study Plan'));
      await driver.waitFor(find.text('Progress Report'));
      await driver.waitFor(find.text('Study Groups'));
      await driver.waitFor(find.text('Ask Doubt'));
    });

    test('Teacher dashboard loads correctly', () async {
      // Navigate back and select teacher role
      await driver.tap(find.pageBack());
      await driver.tap(find.pageBack());
      
      final teacherRole = find.byValueKey('teacher_role');
      await driver.tap(teacherRole);

      // Wait for teacher dashboard
      await driver.waitFor(find.byType('TeacherDashboard'), timeout: Duration(seconds: 5));

      // Check if teacher elements are present
      await driver.waitFor(find.text('EduConnect Teacher'));
      await driver.waitFor(find.text('Performance Overview'));
    });

    test('Teacher advanced features work', () async {
      // Tap on advanced features button
      final advancedFeaturesButton = find.byTooltip('Advanced Features');
      await driver.tap(advancedFeaturesButton);

      // Wait for advanced features screen
      await driver.waitFor(find.byType('TeacherAdvancedFeaturesScreen'), timeout: Duration(seconds: 5));

      // Check tabs
      await driver.waitFor(find.text('Analytics'));
      await driver.waitFor(find.text('Students'));
      await driver.waitFor(find.text('Messages'));
      await driver.waitFor(find.text('Content'));
    });

    test('Admin dashboard loads correctly', () async {
      // Navigate back and select admin role
      await driver.tap(find.pageBack());
      await driver.tap(find.pageBack());
      
      final adminRole = find.byValueKey('admin_role');
      await driver.tap(adminRole);

      // Wait for admin dashboard
      await driver.waitFor(find.byType('AdminDashboardScreen'), timeout: Duration(seconds: 5));

      // Check if admin elements are present
      await driver.waitFor(find.text('Admin Dashboard'));
      await driver.waitFor(find.text('Quick Actions'));
    });

    test('Course creation works', () async {
      // Tap on Create Course
      final createCourseButton = find.text('Create Course');
      await driver.tap(createCourseButton);

      // Wait for create course screen
      await driver.waitFor(find.byType('CreateCourseScreen'), timeout: Duration(seconds: 5));

      // Fill course form
      await driver.tap(find.byValueKey('course_title_field'));
      await driver.enterText('Test Course');

      await driver.tap(find.byValueKey('course_description_field'));
      await driver.enterText('This is a test course');

      // Submit form
      await driver.tap(find.byValueKey('create_course_button'));
    });

    test('API connectivity test', () async {
      // Test if API endpoints are reachable
      // This would be implemented with actual API calls
      // For now, we'll check if error handling works properly
      
      // Navigate to a screen that makes API calls
      await driver.waitFor(find.byType('CoursesScreen'), timeout: Duration(seconds: 5));
      
      // Check if loading states work
      await driver.waitFor(find.byType('CircularProgressIndicator'), timeout: Duration(seconds: 2));
    });
  });
}
