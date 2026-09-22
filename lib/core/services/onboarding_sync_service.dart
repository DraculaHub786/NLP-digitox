// Copyright (c) 2026 NLP digitox

import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/services/firestore_service.dart';
import 'package:nlp_digitox/core/services/persona_service.dart';
import 'package:nlp_digitox/models/persona_model.dart';

/// Mirrors the completed persona quiz to Firestore, and restores it locally
/// on a fresh install for a returning, already-onboarded user — so a
/// reinstall shows the permissions screen only, never the intro slides or
/// quiz again.
///
/// This does NOT and cannot restore OS-level special permissions (Usage
/// Access, Display over apps, Exact Alarms, Ignore Battery Optimization) —
/// those are revoked by Android itself on every uninstall and must always
/// be re-granted by hand; no app can persist them across a real reinstall.
class OnboardingSyncService {
  OnboardingSyncService._();
  static final OnboardingSyncService instance = OnboardingSyncService._();

  /// Call right after the quiz is completed and the persona is saved
  /// locally, so a future reinstall can restore it. `isOnboardingDone`
  /// itself is synced separately by DigitoxSettingsNotifier — this only
  /// adds the persona fields on top of whatever settings map already
  /// exists, so the two writes never clobber each other.
  Future<void> pushPersonaToCloud(PersonaProfile persona) async {
    try {
      final settings = await FirestoreService.instance.getUserSettings();
      settings['personaKey'] = persona.persona.key;
      settings['personaAnswers'] = persona.answers;
      await FirestoreService.instance.updateSettings(settings);
      debugPrint('OnboardingSyncService: persona pushed to cloud');
    } catch (e) {
      debugPrint('OnboardingSyncService: push failed (non-blocking): $e');
    }
  }

  /// Call once at startup, before deciding whether to show onboarding.
  /// Returns true if a completed persona was found in the cloud and
  /// restored locally.
  Future<bool> restoreFromCloudIfNeeded() async {
    if (await PersonaService.instance.isQuizCompleted()) return false;

    try {
      final settings = await FirestoreService.instance.getUserSettings();
      final isDone = settings['isOnboardingDone'] == true;
      final personaKey = settings['personaKey'] as String?;
      if (!isDone || personaKey == null) return false;

      final rawAnswers = settings['personaAnswers'];
      final answers = rawAnswers is Map
          ? rawAnswers.map((k, v) => MapEntry(k.toString(), v.toString()))
          : <String, String>{};

      await PersonaService.instance.savePersona(
        PersonaProfile(
          persona: UserPersonaExtension.fromKey(personaKey),
          scores: const {},
          determinedAt: DateTime.now(),
          answers: answers,
        ),
      );
      debugPrint('OnboardingSyncService: persona restored from cloud');
      return true;
    } catch (e) {
      debugPrint('OnboardingSyncService: restore failed (non-blocking): $e');
      return false;
    }
  }
}