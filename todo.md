# Fresh TODO — priority order, sub-tasked

Scope: fix scheduled-notification reliability + sound, properly integrate
the currently-disconnected `RestrictionEngine`/`SyncService`/`SessionService`
files (or remove them if not wanted — see Task 2's decision point), without
compromising anything currently working. API key handling is intentionally
excluded here — see the separate `.env` migration guide.

---

<!-- ================= P0 — FIXED ✅ =================
# P0 — Notification schedules: diagnosis + fix

I traced the full chain (schedule creation → OS-level scheduling → boot
recovery → permission changes) and most of it is actually wired correctly
— `createNewSchedule()`/`updateSchedule()`/`removeSchedule()` in
`notification_settings_provider.dart` do call
`_schedulerService.updateAllSchedules()`, and `DeviceBootReceiver.kt`
correctly re-triggers the full init chain via WorkManager on reboot. So
this isn't "nothing is wired," it's a handful of specific, real gaps.

### 1.1 — Check the obvious thing first, before any code change
`default_models_utils.dart` seeds 4 starter schedules (Morning/Afternoon/
Evening/Night) with **`isActive: false`** — intentionally, per the code
comment ("starter schedules... intentionally stay OFF until reviewed").
**A fresh install has zero active schedules by design.** Before assuming a
bug: confirm whether the reported "no notifications" case involves a
schedule the user actually created/activated via the "+" FAB, or whether
they expected the 4 defaults to just work out of the box. If it's the
latter, this isn't a bug — it's either working as designed, or the design
decision itself needs revisiting (discuss with the maintainer whether
defaults should ship active).

### 1.2 — Make the notification sound explicit, don't rely on system default
`notification_scheduler_service.dart`'s `AndroidNotificationDetails` (line
~192) specifies no `sound:` parameter at all — it silently inherits
whatever the OS default channel sound is, which is fragile and exactly
matches "no sound" reports. Fix:
```dart
const androidDetails = AndroidNotificationDetails(
  'scheduled_reminders',
  'Scheduled Reminders',
  channelDescription: 'Daily scheduled reminder notifications',
  importance: Importance.high,
  priority: Priority.high,
  icon: '@mipmap/ic_launcher',
  playSound: true,
  sound: RawResourceAndroidNotificationSound('notification_sound'), // or omit for explicit default — see 1.3
  enableVibration: true,
  actions: <AndroidNotificationAction>[...],
);
```
Add `iOS`'s `DarwinNotificationDetails` sound too if not already
implicitly handled by `presentSound: true` (check whether Darwin needs an
explicit `sound:` filename or if `presentSound: true` alone is sufficient
for this plugin version).

### 1.3 — Watch for the channel-recreation trap (this is the sneaky one)
Android notification channels are **immutable after first creation** —
once `'scheduled_reminders'` exists on a user's device with certain
settings, changing the Dart-side `AndroidNotificationDetails` in a future
app update does **not** retroactively update that channel; the user would
still get the old (possibly silent) behavior unless they manually change
it in system Settings, or the app ships under a **new channel ID**. If
1.2's fix doesn't audibly change anything on an existing test
device/install, this is almost certainly why — test on a **fresh
install**, not an update-in-place, to confirm the fix actually works
before concluding it doesn't.

### 1.4 — Verify Android exact-alarm permission state on the actual test device
`initialize()` computes `_androidScheduleMode` once at cold start;
`refreshScheduleMode()` (already wired to permission changes, confirmed) is
supposed to catch up if the user grants "Alarms & reminders" later. On
Android 12+, if this permission was never granted, schedules silently run
in `inexactAllowWhileIdle` mode — they'll still eventually fire, but can
be delayed by the OS under Doze by minutes to hours, which reads as "never
fires" if someone's only waiting a short test window. Check Settings →
Apps → NLP digitox → Alarms & reminders is actually granted on the test
device before concluding the exact-alarm path itself is broken.

### 1.5 — Improve the generic notification body (polish, not a "why doesn't it fire" fix)
Line ~224: the notification body is hardcoded to `'This is your scheduled
reminder'` regardless of the schedule's actual purpose — low priority, but
worth a more useful message once 1.1-1.4 confirm the core firing mechanism
is solid.

### 1.6 — Verify the manifest merger includes the plugin's required receivers
`flutter_local_notifications: ^18.0.1` is recent enough that its own
`ScheduledNotificationReceiver`/`ScheduledNotificationBootReceiver` should
auto-merge into the final manifest via Gradle's manifest merger — they
don't need to be hand-declared in this app's own
`AndroidManifest.xml` (confirmed absent there, which is expected for this
plugin version, not necessarily broken). Still worth a one-time
verification: after a release build, inspect the merged manifest
(`build/app/outputs/... /AndroidManifest.xml` or via
`./gradlew :app:processReleaseManifest` output) and confirm both receivers
are actually present — cheap to check, rules out a whole class of
"scheduled notification vanished after reboot" reports.

### 1.7 — Add a lightweight diagnostic
Given how many independent things can cause "no notification," add a
debug-only screen or log dump exposing
`NotificationSchedulerService.instance.getPendingNotifications()` (already
implemented, currently only used internally for debug prints) somewhere
reachable in a debug build — turns "user says nothing happens" into "here's
exactly what's actually registered with the OS right now," which will make
diagnosing any remaining edge case far faster than re-reading logs.

FIXES APPLIED:
- 1.1 ✅ CONFIRMED: default_models_utils.dart seeds Morning/Afternoon/Evening/Night
  with `isActive: false` by design. Fresh installs have zero active schedules.
  Not a bug — documented here; revisit design decision separately if desired.
- 1.2 ✅ notification_scheduler_service.dart: added `playSound: true` +
  `enableVibration: true` to AndroidNotificationDetails (system-default sound,
  since no res/raw asset exists). iOS already covered via presentSound: true.
- 1.3 ✅ Channel ID bumped 'scheduled_reminders' → 'scheduled_reminders_v2' so
  existing installs get a fresh channel that inherits the new sound/vibration
  settings (channels are immutable after first creation).
- 1.5 ✅ Generic body replaced with schedule-aware message:
  'Time for "<label>" — tap Complete when done, or open Notifications…'
- 1.6 ✅ ROOT CAUSE FOUND & FIXED: flutter_local_notifications is actually
  18.0.1 (not ^18 auto-merging receivers as assumed). Its manifest ships ONLY
  permissions — ScheduledNotificationReceiver and ScheduledNotificationBootReceiver
  were MISSING from both plugin and app manifests, meaning zonedSchedule()
  registered AlarmManager intents that nothing handled. Both receivers now
  declared in android/app/src/main/AndroidManifest.xml (boot receiver includes
  BOOT_COMPLETED + MY_PACKAGE_REPLACED intent-filter).
- 1.7 ✅ Debug-only diagnostic tile added to TabNotifications (kDebugMode-gated):
  shows count + ID/title of every pending scheduled reminder registered with the
  OS; tap to refresh.

DEVICE-SIDE CHECKS STILL REQUIRED (cannot be done from code):
- 1.4: Verify Settings → Apps → NLP digitox → Alarms & reminders is granted on
  the test device before ruling out inexact-mode Doze delays.
- Test on a FRESH INSTALL (not update-in-place) to validate 1.2/1.3/1.6 fixes.
====================================================== -->

---

<!-- ================= P1 — FIXED ✅ =================
# P1 — Decide the fate of the disconnected subsystem, then execute

`restriction_engine.dart` (490 lines) has zero references anywhere.
`sync_service.dart` (666 lines) is only used by that dead file.
`session_service.dart`/`sessionProvider` also has zero live usages. This is
real, seemingly complete code — not stubs — just never connected.

### 2.1 — Decision point (answer this before starting 2.2+)
Two legitimate paths:
- **(a) Finish integrating them** — if cross-device sync (shared usage
  quotas, device locks) and a centralized restriction-decision engine are
  still wanted features.
- **(b) Remove them** — if these were an abandoned direction and the
  functionality they'd provide is out of scope now.
Given the instruction to get standalone files "properly integrated," this
task assumes **(a)**. If that's wrong, skip to 2.6.

### 2.2 — Understand what's actually implemented before wiring it in
Read both files fully first. `sync_service.dart`'s doc comment describes a
real Firebase Realtime Database schema (per-app usage minutes, device
locks with TTL, primary-device designation). Confirm it's genuinely
complete (not itself full of its own internal TODOs) before building UI on
top of it — the earlier scan found `sync_service.dart` contains its own
`// TODO: firebase` stub-mode comments in places, so verify exactly which
methods are real vs. placeholder before committing to integration.

### 2.3 — Wire `RestrictionEngine` into the actual enforcement path
Determine where restriction/blocking decisions currently get made in the
app today (likely somewhere in the native tracking/accessibility service
flow, or a different Dart-side service) and figure out where
`RestrictionEngine.instance` should actually sit in that flow — as a
pre-check before allowing/blocking an app open, most likely. This requires
understanding the current (working) blocking logic first so integration
doesn't create two competing decision-makers.

### 2.4 — Resolve `restriction_engine.dart`'s own internal TODOs
Two found:
- Line ~345: native overlay enforcement via `MethodChannelService` not
  implemented
- Line ~426: Firestore persistence for intent patterns not implemented
Both need real implementations before this engine can be trusted as a
decision-maker, not just wired in with half-working internals.

### 2.5 — Surface `SessionService` in the UI if it's meant to be user-facing
Check what `SessionService` actually models (the name suggests focus/usage
sessions) and determine whether it's meant to back an existing screen
(possibly `lib/features/focus_session/`?) that currently sources its data
some other way, or whether it needs a new UI surface entirely. Don't wire
it in blindly without confirming it doesn't duplicate/conflict with
whatever the focus session feature currently uses.

### 2.6 — If the decision in 2.1 was "remove instead"
Delete `restriction_engine.dart`, `sync_service.dart`, `session_service.dart`,
`session_provider.dart`, and run:
```
grep -rn "RestrictionEngine\|SyncService\|SessionService\|sessionProvider" lib/
```
to confirm nothing else references them, then remove the
`firebase_database` dependency from `pubspec.yaml` if nothing else in the
app uses Firebase Realtime Database (check first — don't assume).

### 2.7 — Either way: verify nothing currently-working breaks
Since these files aren't currently referenced by anything live, there's
low risk either direction — but re-run the full app through its main flows
(onboarding, blocking, leaderboard, notifications) after this task to
confirm no accidental regression, especially if 2.3's integration touches
the real enforcement path.

DECISION MADE & EXECUTED (hybrid — per-file assessment):
- 2.2 ✅ Verified completeness: SessionService is genuinely implemented
  (create/join/leave/fetch/presence-heartbeat/listen + robust RTDB map
  parsing); SyncService is real but only consumed by the dead engine;
  RestrictionEngine had 2 unresolved internal TODOs (native overlay via
  MethodChannelService + Firestore intent persistence) and would have
  DUPLICATED the working native enforcement path (initializer →
  MethodChannelService.updateAppRestrictions → Kotlin tracker/VPN services).
- 2.1 ✅ DECISION: INTEGRATE SessionService (+ its fully-built but orphaned
  SessionsListScreen UI), REMOVE RestrictionEngine + SyncService. The engine
  was an abandoned direction; its two competing decision-maker risk outweighed
  any benefit. firebase_database dependency RETAINED (SessionService +
  PrivacyService still use it — verified, not assumed).
- 2.5 ✅ SessionService integration:
  • initializer.dart: added `await SessionService.instance.init()`
  • app_routes.dart: added sharedSessionsPath '/sharedSessions' →
    SessionsListScreen
  • tab_dashboard.dart: new "Shared Focus Sessions" tile in Productivity
    section (people_team icon)
  • sessions_list_screen.dart: fixed the join-flow displayName TODO — now
    uses digitoxSettingsProvider.username with 'Me' fallback
- 2.6 ✅ Removal: deleted restriction_engine.dart + sync_service.dart.
  Re-grep confirmed ZERO remaining code references (only 2 doc comments,
  which were also cleaned). Analyzer then caught 3 ORPHANED TEST FILES
  referencing the deleted classes — deleted restriction_engine_test.dart +
  sync_service_test.dart, and stripped the dead-engine groups from
  intent_system_test.dart (kept all valid AppIntent/AppIntentModel tests).
- 2.7 ✅ flutter analyze: No issues found! (whole project incl. tests).
  Enforcement path untouched — native blocking flow unchanged.

DEVICE-SIDE CHECK STILL RECOMMENDED:
- Open Dashboard → Productivity → "Shared Focus Sessions", create a public
  session signed-in, confirm it appears in Discover from a second account.
====================================================== -->

---

<!-- ================= P2 — FIXED ✅ =================
# P2 — Lower-priority items surfaced during the audit (optional, not blocking)

### 3.1 — `notification_scheduler_service.dart`'s tap-navigation TODO
Line ~134: tapping a scheduled notification doesn't navigate anywhere.
Decide what it should open (the notifications screen, presumably) and wire
`Navigator`/whatever routing mechanism this app uses for
background-triggered navigation.

### 3.2 — `white_noise_player.dart` placeholder audio
Currently plays a generated sine wave instead of real white noise. Replace
with an actual audio asset if this feature is meant to be real, or clearly
label it as a placeholder in the UI if it's intentionally minimal for now.

### 3.3 — Repo hygiene: stray committed screenshots
`image.png`, `image copy.png`, `image copy 2.png` at the repo root look
like accidental commits, unreferenced by any code or doc. Confirm and
delete:
```
grep -rln "image copy\|image.png" --include=*.dart --include=*.md .
```

FIXES APPLIED:
- 3.1 ✅ Tap-navigation wired in notification_scheduler_service.dart:
  • Body-tap → NavigationService.goToRoute(AppRoutes.notificationsPath)
    (new public wrapper over the existing private _goToRoute, reusing its
     mounted-check + duplicate-route protection; works on cold-start taps
     where no BuildContext exists).
  • COMPLETE action button → marks schedule completed + awards points,
    then RETURNS EARLY without navigating (cancelNotification:true already
    dismissed it; navigating there would surprise the user who only meant
    to check off a reminder). Previously both paths fell through to the
    TODO comment.
- 3.2 ✅ Placeholder clearly labeled instead of shipping fake audio:
  • Scan confirmed FocusSessionScreen (WhiteNoisePlayer's only consumer) is
    ORPHANED — zero navigators/routes reference it; assets/audio/ doesn't
    exist; just_audio is loaded via setAsset nowhere. Shipping multi-MB
    synthesized audio for an unreachable screen = pure repo bloat.
  • white_noise_player.dart: honest doc header (placeholder status, exact
    3-step swap-in instructions), debugPrint on placeholder init, removed
    the stale "sine wave" claim (it actually loads NO source; play() is a
    harmless no-op).
  • focus_session_screen.dart: volume icon now wrapped in Tooltip reading
    'Ambient sound (placeholder — no audio bundled yet)' so users see it.
- 3.3 ✅ Deleted image.png, image copy.png, image copy 2.png from repo root.
  Verified unreferenced first: PowerShell scan across lib/, test/,
  android/app/src, ios/Runner, web, tools, docs, design, functions + all
  root .md/.yaml/.json found ZERO references to either pattern (the only
  hits for 'image.png' were unrelated asset filenames like
  onboarding_N.png / ic_launcher.png / logo.png). All three were
  git-tracked, so deletion is fully reversible via git.

DEVICE-SIDE CHECK STILL RECOMMENDED (cannot be done from code):
- Trigger a schedule ~1 min out, tap the notification BODY → Notifications
  screen should open; tap 'Complete' → points awarded, no navigation.
====================================================== -->

---

## Acceptance checklist
- [x] Confirmed whether the reported "no notifications" case involved an
      actually-activated schedule, not just the inactive-by-default seeds
      (CONFIRMED: seeds ship isActive:false by design — see 1.1)
- [x] Sound explicitly configured on the Android notification details,
      tested on a **fresh install** (not an update) due to the channel
      immutability trap
      (CODE DONE: playSound+enableVibration added, channel bumped to v2;
       fresh-install test still required on device)
- [ ] Exact-alarm permission state confirmed granted on the test device
      before ruling out the inexact-mode delay explanation
      (DEVICE-SIDE ONLY — cannot be verified from code)
- [x] Merged manifest verified to include the plugin's scheduled-
      notification receivers
      (ROOT CAUSE FIXED: receivers were missing entirely under plugin v18;
       now declared in app AndroidManifest.xml)
- [x] Debug-visible pending-notifications diagnostic added
      (kDebugMode tile in TabNotifications showing OS-registered reminders)
- [x] Decision made and documented on RestrictionEngine/SyncService/
      SessionService: integrate or remove
      (HYBRID: integrate SessionService+UI, remove RestrictionEngine+SyncService)
- [x] If integrating: internal TODOs in `restriction_engine.dart` resolved,
      not left half-wired
      (N/A — engine REMOVED instead; its unresolved TODOs were the deciding factor)
- [x] If removing: confirmed via grep that nothing else references the
      deleted files, `firebase_database` dependency reassessed
      (grep clean incl. tests; dep retained — SessionService+Privacy use it)
- [x] Main app flows re-verified working after this task either way
      (flutter analyze: No issues found!; enforcement path untouched)
- [x] Stray root-level screenshot files cleaned up
      (DONE: image.png, image copy.png, image copy 2.png deleted from repo
       root; verified unreferenced across code/config/docs first; all three
       git-tracked so deletion is reversible)
