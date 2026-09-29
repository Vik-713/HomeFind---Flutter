// File: lib/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../utils/error_handler.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of current Firebase Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current Firebase authenticated user
  User? get currentUser => _auth.currentUser;

  /// Whether an agent is currently logged in
  bool get isAuthenticated => _auth.currentUser != null;

  /// Log in agent with email and password
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('User authentication failed.');
      }

      // Fetch user profile from Firestore or return fallback
      final profile = await getUserProfile(user.uid);
      if (profile != null) {
        return profile;
      }

      return AppUser(
        uid: user.uid,
        name: user.displayName ?? email.split('@').first,
        email: user.email ?? email,
        role: 'agent',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw ErrorHandler.getErrorMessage(e);
    }
  }

  /// Register a new agent in Firebase Auth & Firestore
  Future<AppUser> registerAgent({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Agent registration failed.');
      }

      await user.updateDisplayName(name.trim());

      final appUser = AppUser(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        role: 'agent',
        createdAt: DateTime.now(),
      );

      // Save user profile doc to Firestore at users/{uid}
      await _firestore.collection('users').doc(user.uid).set(appUser.toMap());

      return appUser;
    } catch (e) {
      throw ErrorHandler.getErrorMessage(e);
    }
  }

  /// Get user profile from users/{uid} collection
  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Sign out current agent
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw ErrorHandler.getErrorMessage(e);
    }
  }
}
 