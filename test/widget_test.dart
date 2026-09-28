// File: test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_homefind/screens/common/splash_screen.dart';
import 'package:flutter_homefind/theme/app_theme.dart';

void main() {
  testWidgets('PublicLandingScreen basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const PublicLandingScreen(),
      ),
    );

    // Verify app title and buttons render
    expect(find.text('HOMEFIND'), findsOneWidget);
    expect(find.text('Browse Properties'), findsOneWidget);
    expect(find.text('Agent Login'), findsOneWidget);
  });
}
