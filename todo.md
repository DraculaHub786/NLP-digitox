# Shared-session fix — implementation checklist

Legend: `[x]` applied and verified · `[~]` partially applied · `[ ]` not applied.
Code items are applied in-repo; items marked *(device/console/local)* are manual and cannot be done from the codebase.

## Phase 0 — Verify

- [ ] *(console)* Run `firebase deploy --only database` and compare the Rules tab with the repo file
- [ ] *(device)* Reproduce and capture `adb logcat | grep -E "RepoOperation|firebase_database"` — the `setValue at /sessions/... failed` line names the denied path
- [x] Add `test/rules/` harness (emulator + `@firebase/rules-unit-testing`): 80-char name ok / 81 rejected
- [x] Rules test: code-join into an invite room succeeds
- [x] Rules test: non-owner cannot start (`state: running`)
- [x] *(local)* Run the harness against the emulator: `cd test/rules && npm install && npm test` → **10 cases, all passed**

## Phase 1 — Stop silent failures

- [x] `create_session_sheet.dart`: `maxLength: 80` on the name field
- [x] `session_error_message.dart`: replace the generic `permission-denied` text with create/join-specific guidance
- [x] `session_lobby_screen.dart`: gate `_beginFocusRun` on `hasAllEssentialPermissions` (no latch, so a retry after resume works)
- [x] `database.rules.json`: `breaks` cap to `newData.val() <= 2` (confirmed `SessionLimits.maxBreaksPerRun == 2` first)

## Phase 2 — Make the run actually shared

- [x] Add a duration picker to the create sheet and send `durationSec` through `CreateSessionNotifier.createSession`
- [x] Delete the `runStartAt` line from `SharedSession.toMap()` — the server owns that field
- [x] `session_lobby_screen.dart`: derive the member's run length from `runStartAt + countdown + duration` (remaining time), not from `sharedDailyLimit`
- [x] `session_focus_bridge.dart` + `focus_mode_provider.dart`: `startSessionFromSharedSettings(session:, durationSec:)` sets `sessionDuration: durationSec`
- [x] Persist the focus-profile snapshot in `SharedSessionFocusTracker` before mutating it, and restore it in `SessionCompletionReconciler` on launch

## Phase 3 — Clock and presence

- [x] `SessionService.init()`: call `SessionClock.instance.start()` after `_database` is assigned
- [x] `session_lobby_screen.dart` `initState`: `SessionService.instance.startPresenceHeartbeat(sessionId)` while still in the lobby

## Phase 4 — Cleanup

- [x] Make `SessionService._database` injectable for the join/create tests (`SessionService.withDatabase`)
- [ ] *(local)* Tidy the `tmp_*` / `fix_leave*` files and the in-progress rebase
- [x] Skip the `memberCount` item — Discover already derives the live count in `getPublicSessions`

## Phase 5 — Two-device acceptance *(manual)*

- [ ] Host creates, a member joins by code, the host starts
- [ ] Both devices block apps in the same second
- [ ] Both end together and both are credited
- [ ] Kill and reopen a member's app mid-lobby; they reappear as present

---

## Verification run

- `flutter analyze lib` → **No issues found!**
- `flutter test` (services, providers, models, core, features, ui, config) → **397 tests, all passed**
- `test/rules` → `cd test/rules && npm install && npm test` → **10 cases, all passed**
  (needs the Firebase CLI and a JDK on PATH; the script runs the three suites with
  `--test-concurrency=1` on purpose — see `test/rules/README.md`)

### Notes on the applied items

* `create_session_sheet.dart` (max length), `session_error_message.dart` (per-instance
  create/join text) and the create-sheet duration picker were already in the tree and
  were verified rather than re-written. The remaining Phase 1–4 items were applied in
  this session.
* `_beginFocusRun` deliberately does **not** set `_hasOpenedTimer` when the permission
  gate fails, so the resume re-check starts the run once the user grants what is missing.
* `startSessionFromSharedSettings` now takes the whole `SharedSession`, so a caller can
  no longer pair one room's settings with another room's id, and the room's own
  `durationSec` is authoritative instead of the per-session `sharedDailyLimit`.
* `runStartAt` is no longer serialised by `toMap()`: only `ServerValue.timestamp`
  from `startSession` may set it, which is what the rules enforce.
