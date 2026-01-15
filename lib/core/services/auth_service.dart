// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// A service class responsible for authenticating user if needed.
class AuthService {
  /// Private constructor to enforce singleton pattern.
  AuthService._();

  /// Singleton instance of the [AuthService].
  static final AuthService instance = AuthService._();

  /// Auth instance
  final _auth = LocalAuthentication();

  /// Returns `TRUE` if user have setup any type of biometrics and verified successfully
  /// otherwise `FALSE`.
  ///
  /// But if user does not have any biometrics available it returns `NULL`
  Future<bool?> authenticate() async {
    try {
      final List<BiometricType> availableBiometrics =
          await _auth.getAvailableBiometrics();

      /// Return null if no available biometrics
      if (availableBiometrics.isEmpty) return null;

      /// Return status
      return await _auth.authenticate(localizedReason: "Mindful");
    } catch (e) {
      debugPrint("Failed to authenticate : ${e.toString()}");
      return false;
    }
  }
}
