// File: lib/utils/error_handler.dart

import 'package:firebase_auth/firebase_auth.dart';

class ErrorHandler {
  /// Converts technical Firebase or system exceptions into user-friendly messages.
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'The email address is improperly formatted.';
        case 'user-disabled':
          return 'This agent account has been disabled.';
        case 'user-not-found':
          return 'No agent account found matching this email.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Invalid email or password. Please try again.';
        case 'email-already-in-use':
          return 'An agent account with this email already exists.';
        case 'weak-password':
          return 'The password is too weak. Please use at least 6 characters.';
        case 'operation-not-allowed':
          return 'Email/password authentication is not enabled in Firebase Console.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'too-many-requests':
          return 'Too many failed login attempts. Please try again later.';
        default:
          return error.message ?? 'Authentication error occurred (${error.code}).';
      }
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Permission denied by Firebase Security Rules.';
        case 'unavailable':
          return 'Firebase service is currently unavailable. Please check internet access.';
        case 'not-found':
          return 'Requested document or resource was not found.';
        case 'already-exists':
          return 'Resource already exists.';
        default:
          return error.message ?? 'Database or storage operation failed (${error.code}).';
      }
    }

    if (error is String) {
      return error;
    }

    return error?.toString() ?? 'An unexpected error occurred. Please try again.';
  }
}
 