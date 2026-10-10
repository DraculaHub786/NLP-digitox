# In-app code and rules fixes — implementation status

**Audited:** 4 Oct 2026, against the working tree (not the plan).
**Evidence:** `flutter analyze --no-pub` → *No issues found!* · `flutter test` → **359 tests passed**, exit 0.

Legend: **[x]** applied as specified · **[~]** partially applied · **[ ]** not applied.
Each item names the file it lives in so the claim can be re-checked.

---

## Outstanding work

- [ ] **A6a** `test/providers/session_provider_test.dart` — add a test that `SessionLobbyNotifier.cancel()` invalidates `publicSessionsProvider`. The file currently only asserts that `publicSessionsProvider` is `autoDispose`.
- [ ] **A6b** `test/services/session_service_test.dart` — the fake-DB test for `getPublicSessions` (drops cancelled / missing / running entries, keeps entries it cannot verify, sets `isMember`) is missing; the only test is "returns an empty list when unreachable". **This is not test-only work:** `SessionService._database` is private and hard-wired to `FirebaseDatabase.instance`, so the handle has to be made injectable before a fake DB can drive it.
- [ ] **A6c** Rules tests for A1 — there is no rules-test harness in the repo: no `test/rules/` directory, no `@firebase/rules-unit-testing` dependency, no emulator config. A harness has to be created before the three A1 cases (owner cancels with a legacy invite; a stranger may delete a cancelled entry but not a live one) can be written.
- [ ] **C7 (UI half)** — `OemKeepAlive.openBackgroundSettings()` (Kotlin), the `openOemBackgroundSettings` channel handler in `FgMethodCallHandler.kt:546`, and the Dart wrapper at `method_channel_service.dart:429` all exist, but **no file in `lib/` calls the wrapper**. The two optional auto-start / background-activity rows are not in Settings.
- [ ] **D4 (remainder)** — the native half is done, but `DigitoxTrackerService`'s periodic loop never calls `TrackingHealth.markHeartbeat`, and `MethodChannelService.getTrackingGapsJson()` (`method_channel_service.dart:419`) has no consumer, so nothing surfaces "Tracking was off for 2 h 31 m today".
- [ ] **D5** — the background-health card in Settings is not implemented. Nothing under `lib/ui/screens/settings/` covers Accessibility / battery optimisation / notifications / exact alarms / heartbeat / last exit reason / OEM guidance.
- [ ] **B6** *(optional in the plan)* — the "celebrate a new badge" listener with a `seen_badge_ids` SharedPreferences list is not implemented.

### Not verifiable from the code
- **F.1** "Merge `profilepic` into `main`" — git history was not inspected.
- Deployment and device steps are not code: the `firebase deploy --only firestore:rules` for B1, the `adb logcat | findstr "SPLASH a11y"` run for C4, the D6 test procedure, and the Play declaration form for `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` (C7).

---

## A. Cancelled sessions still in Discover, join does nothing — P0

### A1. `database.rules.json` — **[x] applied**
- `invites/$code/.write` accepts the session owner via `root.child('sessions').child(data.child('sid').val()).child('ownerId').val() === auth.uid`, so a legacy invite without `hostUid` can be deleted.
- `publicSessions/$sessionId/.write` carries the added final clause: anyone may remove an entry whose session is missing, `cancelled`, or `isActive == false` — and only that.
- **Deployment note:** rules are deployed by `firebase deploy --only database`, separate from the Firestore deploy below.

### A2. `lib/core/services/session_service.dart` — **[x] applied**
- `cancelSession` is split exactly as specified: the authoritative `state`/`isActive` write first, then `_bestEffortRemove('publicSessions/$sessionId')`, `_bestEffortRemove('invites/$code')` and `_bestEffortRemove('users/$userId/sessions/$sessionId')`. `_bestEffortRemove` exists and takes the null-database guard.
- `startSession` calls `await _bestEffortRemove('publicSessions/$sessionId')` after the start write succeeds.
- `getPublicSessions` verifies every entry against `sessions/{id}`, appends dead ids, prunes them with `unawaited(_bestEffortRemove(...))`, stamps `memberCount`/`maxMembers`/`isMember`, and shows-but-never-deletes an entry it could not verify. `_attachLiveCapacity` is gone.
- `joinSession` is a one-line delegate to `_joinAsMember`, which carries the private-room rule (`code == null && !session.isPublic` → `SessionException`) and the lobby-only check.

### A3. `lib/providers/session_provider.dart` — **[x] applied**
- `publicSessionsProvider` is `FutureProvider.autoDispose` and arms `Timer(const Duration(seconds: 30), ref.invalidateSelf)` with `ref.onDispose(timer.cancel)`.
- `SessionLobbyNotifier.start()` / `.cancel()` / `.leave()` and `CompleteSessionNotifier.completeSession()` all invalidate `publicSessionsProvider` alongside `userSessionsProvider`.

### A4. `lib/features/shared_sessions/widgets/session_cards.dart` — **[x] applied**
- The lobby-screen import is present, `_join` skips the service call when `isMember` is true, invalidates `publicSessionsProvider` on both the success and failure paths, pushes `SessionLobbyScreen`, and labels the button `_isMember ? 'Open' : 'Join'`. `joinByIdProvider` is untouched.

### A5. Members' phones when the host cancels — **[x] applied**
- `SessionLobbyScreen.build` listens to `sessionDetailProvider(widget.sessionId)` and calls `focus.endSharedSession()` when the session is cancelled and this device is in a shared-session focus.
- The durable half is also in: `lib/core/services/session_completion_reconciler.dart:85` handles `SessionPhase.cancelled` and ends the focus run at line 94.

### A6. Tests — **[ ] not applied**
See the outstanding list. No rules harness exists, and the service-level test needs an injectable database handle first.

---

## B. Badges not shown in Achievements — P0

### B1. `firestore.rules` — **[x] applied**
The `badges/{badgeId}` block matches the plan: `get` gated on `badgeId.matches(request.auth.uid + '_.*')`, `list` gated on `resource.data.userId == request.auth.uid`, `delete` on the same field, and `create, update: if false`.
**Deployment note:** requires `firebase deploy --only firestore:rules`.

### B2. `lib/ui/screens/achievements/achievements_screen.dart` — **[x] applied**
Both `StreamBuilder<QuerySnapshot>` blocks (carousel and list) query `collection('badges').where('userId', isEqualTo: currentUserId)` with no `orderBy`, both return a `"Couldn't load badges: …"` line on `hasError`, and both sort in Dart with `badges.sort((a, b) => b.earnedAt.compareTo(a.earnedAt))`.

### B3. `lib/models/badge_model.dart` — **[x] applied**
The file header comment now reads `badges/{uid}_{period}_{cycle}, written by n8n`; `_asDate` handles `Timestamp`, `DateTime`, `int` and `String` with a `DateTime.now()` fallback; the weekly branch maps `2026-W37` to `Week 37, 2026`.

### B4. ISO week id — **[x] applied**
`_isoWeek`, `_getWeekId` and `_formatWeekLabel` are implemented as specified (Thursday-based ISO week-year). `_getWeekOfYear` no longer exists.

### B5. Account deletion — **[x] applied**
`firebase_auth_service.dart:313` wraps the `badges` query and delete loop in its own `try/catch` that logs `Failed to delete badge docs for $uid` and does not block the rest of the deletion.

### B6. Celebrate a new badge — **[ ] not applied** (optional in the plan)

### B7. Check — console step
After B1 and B2 are deployed, open Achievements on the account that won. If it is still empty, check that the badge document carries a `userId` field; documents written before the n8n mask fix may lack it.

---

## C. Accessibility permission page keeps coming back — P0

### C1. `lib/models/permissions_model.dart` — **[x] applied**
`hasCorePermissions` excludes Accessibility by design (and short-circuits to `true` on `permissionFetchFailed`); `hasAllEssentialPermissions` is `hasCorePermissions && haveAccessibilityPermission`.

### C2. `lib/ui/splash_screen.dart` — **[x] applied**
`_haveCorePermissions` is declared, assigned from `perms.hasCorePermissions` next to the existing assignment, printed as `core=$_haveCorePermissions` in the `SPLASH onboarding:` debug line, and used as the routing gate in `_goToNextScreen`.

### C3. Recovery page and quiz — **[x] applied**
`onboarding_screen.dart:113` (the permission listener) and `:208` (the pager gate) both use `perms.hasCorePermissions` when `permissionsOnly`, and `hasAllEssentialPermissions` otherwise. `quiz.dart:51` and `session_detail_screen.dart:419` keep `hasAllEssentialPermissions`, so group focus still requires Accessibility.

### C4. Prove the cause on your phone — **[x] applied** (diagnostics shipped)
- `PermissionsHelper.backgroundDiagnostics(context)` reports `expected_component`, `enabled_services_raw`, `has_accessibility_permission`, `is_accessibility_service_active`, `ignoring_battery_optimizations`, `can_schedule_exact_alarms`, `last_exit_reason` and `sdk_int`.
- `FgMethodCallHandler.kt:447` handles `getBackgroundDiagnostics`.
- `method_channel_service.dart:407` is the Dart wrapper.
- `splash_screen.dart:131` prints `SPLASH a11y $diagnostics` when the Accessibility grant looks missing.
- The `adb logcat | findstr "SPLASH a11y"` run is a device step.

### C5. Dashboard banner — **[x] applied**
`tab_dashboard.dart` imports `ui/permissions/accessibility_permission_card.dart` and places `const AccessibilityPermissionCard()` as the first sliver, before `SliverActiveSessionAlert`.

### C6. Notify the moment it is lost — **[x] applied**
`KeepAliveHelper` defines `PREF_KEY_ACCESSIBILITY_WAS_SEEN_ACTIVE` and `PREF_KEY_ACCESSIBILITY_LOST_NOTIFIED_AT`, `monitorAccessibilityService` marks "was seen active" on every tick where the grant is held, and `notifyAccessibilityLostIfNeeded` throttles to one warning per 6 hours on `NotificationHelper.pushAccessibilityLostNotification`. Flags go through `SharedPrefsHelper` like the neighbouring keys.

### C7. Reduce the kills — **[~] partially applied**
Native side done: `OemKeepAlive.kt` exists with per-OEM intents and an app-details fallback; `FgMethodCallHandler.kt:546` exposes `openOemBackgroundSettings`; `method_channel_service.dart:429` wraps it. The two optional rows in Settings were never added, and the wrapper has no caller. Nothing here gates onboarding or `missing`/`hasAllEssentialPermissions`, as required.

---

## D. 24/7 background — P1

### D1. Exact watchdog — **[x] applied**
`KeepAliveHelper.scheduleKeepAlive` uses `setExactAndAllowWhileIdle` when `Build.VERSION.SDK_INT < S || alarmManager.canScheduleExactAlarms()`, falls back to `setAndAllowWhileIdle`, and catches `SecurityException` with a second inexact attempt. `scheduleImmediateRestart` follows the same pattern.

### D2. Second, independent chain — **[x] applied**
`KeepAliveHelper.tick(context)` holds the shared work (heartbeat, tracker restart, VPN restart, accessibility and device-admin checks), and `workers/KeepAliveWorker.kt` is a periodic 15-minute worker that calls `tick` and then re-arms the alarm chain. `scheduleKeepAlive` also calls `KeepAliveWorker.enqueuePeriodic`, so the chain is registered on the alarm path too. `restartTrackerService` catches a refused `startForegroundService` and falls back to an expedited job.

### D3. Boot receiver — **[x] applied**
`DeviceBootReceiver.kt` uses `ContextCompat.startForegroundService` for both the tracker and the VPN, with a comment explaining that a plain `startService` throws during a boot broadcast.

### D4. Heartbeat and gap log — **[~] partially applied**
`helpers/device/TrackingHealth.kt` exists with `markHeartbeat` (25-minute gap threshold, 20-gap cap, newest-first), `lastHeartbeatAt` and `gapsJson`. `tick()` calls `markHeartbeat` first. `FgMethodCallHandler` exposes `getTrackingGaps` and a heartbeat getter; `method_channel_service.dart:419` wraps the gaps call.
**Missing:** the call from `DigitoxTrackerService`'s periodic loop, and any UI that renders the gaps.

### D5. Background-health card in Settings — **[ ] not applied**

### D6. How to test 24/7 — device procedure
1. Install a release APK once, grant everything including the battery exemption.
2. Lock the phone for 2 hours: the heartbeat keeps advancing, no gap recorded.
3. Swipe the app out of recents: the tracker returns within seconds.
4. Force-stop from Settings: everything stops. On reopening the dashboard card appears, diagnostics show `USER_REQUESTED`, one gap is recorded.
5. Reboot: tracker and watchdog return without opening the app.

---

## E. Files — actual state

| File | Section | State |
|---|---|---|
| `database.rules.json` | A1 | applied |
| `firestore.rules` | B1 | applied |
| `lib/core/services/session_service.dart` | A2 | applied |
| `lib/providers/session_provider.dart` | A3 | applied |
| `lib/features/shared_sessions/widgets/session_cards.dart` | A4 | applied |
| `lib/features/shared_sessions/session_lobby_screen.dart` | A5 | applied |
| `lib/ui/screens/achievements/achievements_screen.dart` | B2, B4 | applied |
| `lib/models/badge_model.dart` | B3 | applied |
| `lib/core/services/firebase_auth_service.dart` | B5 | applied |
| `lib/models/permissions_model.dart` | C1 | applied |
| `lib/ui/splash_screen.dart` | C2, C4 | applied |
| `lib/ui/onboarding/onboarding_screen.dart` | C3 | applied |
| `lib/ui/screens/home/dashboard/tab_dashboard.dart` | C5 | applied |
| `PermissionsHelper.kt`, `FgMethodCallHandler.kt`, `method_channel_service.dart` | C4, C7, D4 | native and channel applied; no Dart caller for C7 or D4 |
| `helpers/KeepAliveHelper.kt` | C6, D1, D2 | applied |
| `receivers/DeviceBootReceiver.kt` | D3 | applied |
| `helpers/device/OemKeepAlive.kt`, `workers/KeepAliveWorker.kt`, `helpers/device/TrackingHealth.kt` | C7, D2, D4 | all three exist and are wired natively |
| Settings background-health card (`D5`) | D5 | **does not exist** |

## F. Order of work — status

1. Merge `profilepic` into `main` — not inspected.
2. **B (badges)** — applied. Needs the Firestore rules deploy.
3. **A (cancel and Discover)** — applied. Needs the Realtime Database rules deploy.
4. **C** — applied (C1–C6; C7's UI rows outstanding). The C4 diagnostics run is a device step.
5. **D** — D1–D3 applied, D4 partial, D5 outstanding.
6. `flutter analyze` — **clean** (`No issues found!`, 53.6 s). `flutter test` — **359 passed**, exit 0, with no rules tests among them.
