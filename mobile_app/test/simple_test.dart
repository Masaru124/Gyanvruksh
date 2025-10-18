import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  testWidgets('Simple test to verify Flutter test setup', (WidgetTester tester) async {
    // Simple test to verify basic Flutter test setup works
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Test').animate().fadeIn(),
          ),
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
  });
}
