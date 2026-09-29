// File: lib/app.dart

import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/common/splash_screen.dart';

class HomeFindApp extends StatelessWidget {
  const HomeFindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HOMEFIND - Property Listing & Viewing Scheduler',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
 