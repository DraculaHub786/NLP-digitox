// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase Authentication Service
/// Handles all authentication operations including email/password and Google Sign-In
class FirebaseAuthService {
  /// Private constructor to enforce singleton pattern
  FirebaseAuthService._();

  /// Singleton instance
  static final FirebaseAuthService instance = FirebaseAuthService._();

  /// Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Google Sign In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// Get user ID
  String? get userId => _auth.currentUser?.uid;

  /// Get user email
  String? get userEmail => _auth.currentUser?.email;

  /// Get user display name
  String? get userDisplayName => _auth.currentUser?.displayName;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName);
        await userCredential.user?.reload();
      }

      if (userCredential.user == null) {
        throw Exception('Failed to create user account');
      }

      debugPrint('User signed up: ${userCredential.user!.uid}');
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign up error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Sign up error: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Sign in with email and password
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to sign in');
      }

      debugPrint('User signed in: ${userCredential.user!.uid}');
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign in error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Sign in error: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Sign in with Google
  Future<User> signInWithGoogle() async {
    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        throw Exception('Sign in cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Failed to sign in with Google');
      }

      debugPrint('User signed in with Google: ${userCredential.user!.uid}');
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      debugPrint('Google sign in error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Google sign in error: $e');
      throw Exception('Failed to sign in with Google. Please try again.');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      debugPrint('User signed out');
    } catch (e) {
      debugPrint('Sign out error: $e');
      throw Exception('Failed to sign out. Please try again.');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Password reset error: $e');
      throw Exception('Failed to send password reset email. Please try again.');
    }
  }

  /// Reauthenticate user with password (required before sensitive operations)
  Future<void> reauthenticate(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      debugPrint('User reauthenticated successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('Reauthentication error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Reauthentication error: $e');
      throw Exception('Failed to verify password. Please try again.');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
      debugPrint('User account deleted');
    } on FirebaseAuthException catch (e) {
      debugPrint('Delete account error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Delete account error: $e');
      throw Exception('Failed to delete account. Please try again.');
    }
  }

  /// Update user display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.reload();
      debugPrint('Display name updated to: $displayName');
    } catch (e) {
      debugPrint('Update display name error: $e');
      throw Exception('Failed to update display name. Please try again.');
    }
  }

  /// Update user email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
      debugPrint('Verification email sent to: $newEmail');
    } on FirebaseAuthException catch (e) {
      debugPrint('Update email error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Update email error: $e');
      throw Exception('Failed to update email. Please try again.');
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      debugPrint('Password updated successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('Update password error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Update password error: $e');
      throw Exception('Failed to update password. Please try again.');
    }
  }

  /// Re-authenticate user (required for sensitive operations)
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      debugPrint('User re-authenticated successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('Re-authentication error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Re-authentication error: $e');
      throw Exception('Failed to verify password. Please try again.');
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('The password is too weak. Please use a stronger password.');
      case 'email-already-in-use':
        return Exception('An account with this email already exists.');
      case 'invalid-email':
        return Exception('The email address is invalid.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      case 'user-not-found':
        return Exception('No account found with this email.');
      case 'wrong-password':
        return Exception('Incorrect password. Please try again.');
      case 'invalid-credential':
        return Exception('Invalid login credentials. Please check your email and password.');
      case 'too-many-requests':
        return Exception('Too many failed attempts. Please try again later.');
      case 'operation-not-allowed':
        return Exception('This sign-in method is not enabled.');
      case 'requires-recent-login':
        return Exception('Please log out and log in again to perform this action.');
      case 'account-exists-with-different-credential':
        return Exception('An account with this email exists with a different sign-in method.');
      default:
        return Exception(e.message ?? 'An error occurred. Please try again.');
    }
  }
}
