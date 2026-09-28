// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Attempt standard Firebase Initialization
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase successfully initialized for HomeFind app.');
  } catch (e) {
    debugPrint('Notice: Firebase initialization deferred or requires configuration. Details: $e');
    debugPrint('To configure your own Firebase project, run: flutterfire configure');
  }

  runApp(const HomeFindApp());
}
