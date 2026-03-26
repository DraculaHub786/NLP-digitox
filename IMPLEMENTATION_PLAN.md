**Implementation Plan — Features Add‑ons**

Overview: prioritized, actionable steps and concrete code/infra changes to implement the features in FEATURES_ADDONS.md.

1) Backend & Data
- Tech: Firebase Realtime Database (MVP) or Supabase/WebSocket for real‑time state.
- Schema highlights: users/{userId}/usage/{app}, users/{userId}/devices/{deviceId}, locks/{userId}/{app} (lockedBy, expiresAt), groups/{groupId}/sessions.
- Requirements: security rules, atomic transactions for quotas and lock acquisition.

2) Device Identity & Sync
- Generate and persist stable device id (Android: Settings.Secure.ANDROID_ID or FirebaseInstallations; iOS: identifierForVendor). Store hashed ID in local storage.
- Implement sync service: `lib/services/sync_service.dart` — real‑time listeners for quota/lock changes and atomic updates for usage.

3) Core Client Modules (Flutter)
- `lib/features/onboarding/` — onboarding quiz + persona fingerprinting UI.
- `lib/features/focus_session/` — goal creation, timer, reminders, white-noise player.
- `lib/services/restriction_engine.dart` — evaluates current state and enforces block/soft‑block.
- `lib/services/device_identity.dart` — device id utils.
- `lib/services/achievements.dart` — points and rewards engine.

4) Cross‑Device Enforcement
- Shared usage quota: implement atomic transaction to increment usage and deny when dailyLimit exceeded.
- Primary device + handoff: UI to claim/release primary device; backend flags and listeners.
- Optional lock: acquire lock via transaction with TTL; refresh on heartbeat while in foreground.

5) Platform Enforcement & Native Bridges
- Android: implement AccessibilityService overlay and a blocking Activity. Files: `android/app/src/main/.../FocusAccessibilityService.kt` and a blocking Activity to show overlays.
- iOS: document Screen Time/MDM limitations. Provide soft‑lock UI and MDM deployment guide for high-integrity mode.

6) Content Filtration (MVP → v2)
- MVP: Intent prompt + whitelist/blacklist by URL patterns (local URL interception / deep links where possible).
- v2: on-device sentiment/impact model with TFLite for short captions; integrate via `tflite_flutter` plugin.

7) Emotion & Adaptive Interventions
- Local detectors: simple heuristics first (unlock frequency, short session bursts, typing speed heuristics) to trigger micro‑interventions.
- Mood check‑ins: `lib/features/mood/` — store entries locally; use to adapt strictness.

8) Community & Shared Sessions
- Group model: create `groups` nodes in backend, session invitations, presence/heartbeat channels to show status.
- UI: `lib/features/shared_sessions/` — create/join session, view participant statuses.

9) Onboarding Personas & Motivation Engine
- Store persona fingerprint in user profile; switch UI language + rewards accordingly.

10) Privacy & Compliance
- Opt‑in toggles for cloud sync and cross-device features.
- Hash device IDs; store only aggregated totals and timestamps; provide data export and deletion endpoints.

11) Dependencies & Pubspec Suggestions
- `firebase_core`, `firebase_database`, `firebase_auth` (if needed), `shared_preferences`, `device_info_plus`, `geolocator`, `connectivity_plus`, `tflite_flutter` (v2), `flutter_local_notifications`, `audioplayers` or `just_audio`.

12) Files To Add / Modify (suggested)
- `lib/services/sync_service.dart`
- `lib/services/restriction_engine.dart`
- `lib/features/onboarding/quiz.dart`
- `lib/features/focus_session/session_page.dart`
- `lib/features/shared_sessions/*`
- `android/src/.../FocusAccessibilityService.kt`
- `ios/README_MDM.md` (instructions for MDM/ScreenTime)
- `firebase.rules.json` and deployment scripts
- `assets/themes/` (for themes)

13) Testing & QA
- Unit tests for quota/lock transactions (mock Firebase). Integration test for multi‑device flows (two emulators/accounts).
- Manual tests: Android overlay behavior, background/foreground lock heartbeat, offline reconciliation.

14) Rollout & Phasing (MVP → v1 → v2)
- MVP (3–6 weeks): shared quota, onboarding quiz, goal-oriented focus sessions, basic overlays on Android, soft-lock UX on iOS, persona defaults.
- v1 (3 months): primary device handoff, basic groups/shared sessions, content filtration primitives, achievements.
- v2 (6+ months): on-device sentiment models, Rescue Mode guided content, habit‑stacking hardware integrations, paid MDM features.

Next steps (developer actions):
- Create the skeleton files listed in section 12 and add baseline unit tests.
- Add Firebase project & set up Realtime DB rules.
- Implement `sync_service.dart` and `restriction_engine.dart` as first deliverables.
