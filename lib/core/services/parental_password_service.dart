// Service for managing parental control password

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// A service class responsible for managing parental control password.
class ParentalPasswordService {
  /// Private constructor to enforce singleton pattern.
  ParentalPasswordService._();

  /// Singleton instance of the [ParentalPasswordService].
  static final ParentalPasswordService instance = ParentalPasswordService._();

  /// Key for storing the password hash
  static const String _passwordHashKey = 'parental_control_password_hash';

  /// Check if a password is set
  Future<bool> isPasswordSet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hash = prefs.getString(_passwordHashKey);
      return hash != null && hash.isNotEmpty;
    } catch (e) {
      debugPrint("Failed to check if password is set: ${e.toString()}");
      return false;
    }
  }

  /// Set a new password
  Future<bool> setPassword(String password) async {
    try {
      if (password.isEmpty) return false;
      
      final prefs = await SharedPreferences.getInstance();
      final hash = _hashPassword(password);
      return await prefs.setString(_passwordHashKey, hash);
    } catch (e) {
      debugPrint("Failed to set password: ${e.toString()}");
      return false;
    }
  }

  /// Verify if the provided password is correct
  Future<bool> verifyPassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString(_passwordHashKey);
      
      if (storedHash == null) return false;
      
      final inputHash = _hashPassword(password);
      return inputHash == storedHash;
    } catch (e) {
      debugPrint("Failed to verify password: ${e.toString()}");
      return false;
    }
  }

  /// Clear the stored password
  Future<bool> clearPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_passwordHashKey);
    } catch (e) {
      debugPrint("Failed to clear password: ${e.toString()}");
      return false;
    }
  }

  /// Hash the password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
