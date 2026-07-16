// Persona service for NLP-Digitox

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nlp_digitox/models/persona_model.dart';

/// Persists and retrieves the user's persona from SharedPreferences.
/// Only used during first-time onboarding; re-accessible from Settings.
class PersonaService {
  PersonaService._();
  static final PersonaService instance = PersonaService._();

  static const String _personaKey = 'user_persona_v1';
  static const String _personaSetKey = 'user_persona_is_set';
  static const String _quizCompletedKey = 'quiz_completed';

  PersonaProfile? _cachedProfile;

  // ---------------------------------------------------------------------------
  // Persona retrieval
  // ---------------------------------------------------------------------------

  /// Returns the saved persona, or null if not yet set.
  Future<PersonaProfile?> getPersona() async {
    if (_cachedProfile != null) return _cachedProfile;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_personaSetKey) != true) return null;

      final key = prefs.getString(_personaKey);
      if (key == null) return null;

      final persona = UserPersonaExtension.fromKey(key);

      // Load raw answers if stored
      final answersJson = prefs.getString('user_persona_answers');
      final answers = answersJson != null
          ? Map<String, String>.from(
              jsonDecode(answersJson) as Map)
          : <String, String>{};

      _cachedProfile = PersonaProfile(
        persona: persona,
        scores: {},
        determinedAt: DateTime.now(),
        answers: answers,
      );
      return _cachedProfile;
    } catch (e) {
      debugPrint('PersonaService: Error loading persona: $e');
      return null;
    }
  }

  /// Whether persona has been set by the user
  Future<bool> isPersonaSet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_personaSetKey) == true;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Persona saving
  // ---------------------------------------------------------------------------

  /// Saves the persona profile determined by the quiz.
  Future<void> savePersona(PersonaProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_personaKey, profile.persona.key);
      await prefs.setBool(_personaSetKey, true);
      await prefs.setBool(_quizCompletedKey, true);  // atomic with save
      if (profile.answers.isNotEmpty) {
        await prefs.setString('user_persona_answers', jsonEncode(profile.answers));
      }
      _cachedProfile = profile;
      debugPrint('PersonaService: Saved persona — ${profile.persona.displayName}');
    } catch (e) {
      debugPrint('PersonaService: Error saving persona: $e');
    }
  }

  /// Clears the stored persona (used during data deletion)
  Future<void> clearPersona() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_personaKey);
      await prefs.remove(_personaSetKey);
      await prefs.remove(_quizCompletedKey);
      await prefs.remove('user_persona_answers');
      _cachedProfile = null;
      debugPrint('PersonaService: Persona cleared');
    } catch (e) {
      debugPrint('PersonaService: Error clearing persona: $e');
    }
  }

  /// Whether the user has completed the onboarding quiz.
  /// Returns false if the quiz_completed flag is missing OR if the
  /// persona data is corrupted (flag true but actual persona missing).
  Future<bool> isQuizCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final flag = prefs.getBool(_quizCompletedKey) == true;
      if (!flag) return false;
      // Corruption recovery: flag says completed but persona is missing
      final key = prefs.getString(_personaKey);
      if (key == null) {
        debugPrint('PersonaService: CORRUPTION — quiz_completed=true but persona key missing. Resetting flag.');
        await prefs.remove(_quizCompletedKey);
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Convenience defaults
  // ---------------------------------------------------------------------------

  /// Get recommended daily limit for current persona (minutes per app).
  Future<int> getRecommendedDailyLimit() async {
    final profile = await getPersona();
    return profile?.persona.recommendedDailyLimitMinutes ?? 60;
  }

  /// Get identity-based motivational statement for current persona.
  Future<String> getIdentityStatement() async {
    final profile = await getPersona();
    return profile?.persona.identityStatement ??
        'Build healthy habits, one day at a time.';
  }
}
