// Persona service for NLP-Digitox

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
      _cachedProfile = PersonaProfile(
        persona: persona,
        scores: {},
        determinedAt: DateTime.now(),
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
      _cachedProfile = null;
      debugPrint('PersonaService: Persona cleared');
    } catch (e) {
      debugPrint('PersonaService: Error clearing persona: $e');
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
