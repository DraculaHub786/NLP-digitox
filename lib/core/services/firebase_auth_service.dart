
import 'package:cloud_firestore/cloud_firestore.dart';
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

      // B.2: Auto-send email verification so users don't need to tap "resend" manually.
      try {
        await userCredential.user!.sendEmailVerification();
        debugPrint('Verification email sent to: ${userCredential.user!.email}');
      } catch (e) {
        // Non-blocking — the manual "resend" button in Account settings still works.
        debugPrint('Failed to auto-send verification email: $e');
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
  /// Returns the signed-in [User] on success, or `null` if the user cancelled.
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in — return null, not an exception
        debugPrint('Google sign-in cancelled by user');
        return null;
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
      debugPrint('GOOGLE SIGN-IN ERROR: ${e.code} - ${e.message}');
      debugPrint('Stack trace: ${e.stackTrace}');
      rethrow;
    } catch (e, st) {
      debugPrint('GOOGLE SIGN-IN ERROR: $e');
      debugPrint('Stack trace: $st');
      rethrow;
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

  /// Check if user signed in with Google
  bool isSignedInWithGoogle() {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.providerData.any((info) => info.providerId == 'google.com');
  }

  /// Check if user signed in with Email/Password
  bool isSignedInWithEmail() {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.providerData.any((info) => info.providerId == 'password');
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

  /// Reauthenticate with Google (for Google Sign-In users)
  Future<void> reauthenticateWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.currentUser?.reauthenticateWithCredential(credential);
      debugPrint('User reauthenticated with Google successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('Google reauthentication error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Google reauthentication error: $e');
      throw Exception('Failed to verify Google account. Please try again.');
    }
  }

  /// Delete user account and clean up all associated Firestore documents.
  Future<void> deleteAccount() async {
    try {
      final uid = _auth.currentUser?.uid;

      if (uid != null) {
        final firestore = FirebaseFirestore.instance;
        final batch = firestore.batch();

        // Clean up all docs associated with this uid
        for (final collection in [
          'users',
          'leaderboard',
          'signup_events',
          'streak_badges_awarded',
        ]) {
          final docRef = firestore.collection(collection).doc(uid);
          batch.delete(docRef);
        }

        // Delete any badges docs referencing this uid
        final badgesSnapshot = await firestore
            .collection('badges')
            .where('userId', isEqualTo: uid)
            .get();
        for (final doc in badgesSnapshot.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
        debugPrint('Cleaned up Firestore docs for uid: $uid');
      }

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

  /// Send email verification to the current user.
  /// Returns true if the email was sent, false if already verified.
  Future<bool> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      if (user.emailVerified) {
        debugPrint('Email already verified');
        return false;
      }

      await user.sendEmailVerification();
      debugPrint('Verification email sent to: ${user.email}');
      return true;
    } catch (e) {
      debugPrint('Send email verification error: $e');
      throw Exception('Failed to send verification email. Please try again.');
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
