# NLP-Digitox: Shared & Group Focus Sessions - Master Plan

Base branch: `main` (`profilepic` was merged in via PRs #8/#9; branch new work from `main`).

## 0. How to read this plan

**Verified from the repo** (README, `pubspec.yaml`, `firestore.rules`, `todo.md` audit notes): Flutter + Riverpod, Firebase Auth, Realtime Database (RTDB) for sessions, Firestore for user data/leaderboards, n8n for webhooks, `app_links`, `flutter_local_notifications`, `just_audio`, Android-native blocking (`android/app/src/main/java/com/nlp/digitox/...`), files named in `todo.md`: `lib/core/services/session_service.dart`, `sessions_list_screen.dart`, `focus_session_screen.dart`, `database.rules.json`, `profile_service.dart`.

**Not verified** (I could not open `lib/`): exact folder of each screen/provider/model and the names of the existing Focus Mode service. Paths marked **[confirm]** must be located with `grep -rn` before editing. Commands are given in Section 6.

## 1. Goal and scope

**Goal:** people on different phones join one session, see each other live, focus on one synchronized timer with app blocking active, and get rewarded fairly for completing it. Groups make this repeatable.

**In scope (v1):** invite-code/link sessions, lobby + ready check, synchronized server-time timer, presence, focus enforcement per device, completion verification, points, groups with scheduled sessions, reporting/blocking.

**Out of scope (v1):** free-text chat (emoji reactions only), pause/resume in shared mode, joining after start, iOS enforcement (timer works, blocking does not), public stranger matchmaking (behind a flag until Phase 5).

## 2. Architecture

```
 Flutter app (each phone)
  ├─ UI: list → lobby → focus → summary
  ├─ Riverpod: session stream, members stream, clock
  ├─ SessionService  ──────► RTDB  sessions/, invites/, users/{uid}/sessions
  ├─ SessionClock    ◄────── RTDB  .info/serverTimeOffset
  ├─ PresenceService ──────► RTDB  members/{uid}.status  (+ onDisconnect)
  ├─ SessionFocusBridge ───► existing Focus Mode engine (Dart → Kotlin foreground service)
  └─ GroupService    ──────► Firestore groups/
 n8n (service account)
  ├─ POST /session-complete  verify ID token + read RTDB → write sessionResults + points
  └─ cron  /session-cleanup  delete stale sessions/invites
```

Key decisions:
1. **Timestamps, not ticks.** The host writes one server timestamp; every device derives the timer from it. Nothing needs to stream every second.
2. **Rules do the integrity work** wherever possible (completion time, ownership, member self-write), n8n only for points.
3. **RTDB for live sessions, Firestore for groups** (queryable, persistent).

## 3. Data model

### RTDB

```
sessions/{sid}
  ownerId            string   (immutable)
  title              string
  type               "study" | "work" | "creative"
  visibility         "private" | "invite" | "public"
  capacity           number   (soft limit, client + n8n enforced)
  durationSec        number   (immutable once running)
  countdownSec       number   (default 5)
  state              "lobby" | "running" | "cancelled"
  runStartAt         server timestamp (set once by host on Start)
  groupId?           string
  createdAt          server timestamp
  members/{uid}
    displayName, photoUrl, role ("host"|"member")
    status   "joined" | "ready" | "focusing" | "away" | "left"
    joinedAt (ts), lastSeen (ts), leftAt? (ts)
    breaks   number   (times the user broke focus)
    completedAt? (ts) (rule: only if now >= endAt)
    code     string   (invite code used to join; validated by rule)

invites/{code}       { sid, title, hostName, durationSec, expiresAt }
publicSessions/{sid} { title, type, durationSec, memberCount }   (Phase 5 only)
users/{uid}/sessions/{sid}: true
sessionResults/{sid}/{uid}  { focusedSec, completed, points, at }   (n8n only)
```

Derived (never stored):
```
startEffective = runStartAt + countdownSec*1000
endAt          = startEffective + durationSec*1000
phase          = lobby | countdown | running | finished   (from state + server "now")
```

### Firestore (Phase 3)

```
groups/{gid}                 { name, ownerId, visibility, createdAt, liveSession?: {sid, code} }
groups/{gid}/members/{uid}   { role: owner|admin|member, joinedAt, displayName, photoUrl }
groups/{gid}/schedule/{id}   { title, startsAt, durationSec, type, createdBy }
groups/{gid}/stats/{uid}     { sessionsCompleted, focusedSec, streak }   (n8n only)
reports/{id}                 { reporterUid, targetUid, sid|gid, reason, at }
blocks/{uid}/blocked/{uid2}  {}
```

## 4. Core algorithms

### 4.1 Synchronized clock (`SessionClock`)
1. Listen to `.info/serverTimeOffset` (RTDB) → `offsetMs`.
2. `serverNowMs = DateTime.now().millisecondsSinceEpoch + offsetMs`.
3. UI ticker (1 Hz, `Stream.periodic`) computes `remaining = endAt - serverNowMs`.
4. Re-read the offset on reconnect. Tolerance target: ±1 s across devices.

### 4.2 Lifecycle
```
create → lobby ──host Start──► running(countdown → focus) ──endAt──► finished (derived)
            └──host Cancel──► cancelled
```
- Host taps Start: one update `{state:'running', runStartAt: ServerValue.timestamp}`.
- Every client's session stream sees `running`, computes `startEffective`, shows countdown, then starts Focus Mode for the remaining duration.
- At `endAt` each client stops Focus Mode, writes `members/{uid}/completedAt = ServerValue.timestamp`, and calls the completion webhook.
- The host disconnecting does **not** stop the session (it is timestamp-driven). Only Cancel does.

### 4.3 Presence (`SessionPresenceService`)
1. Listen to `.info/connected`.
2. When connected: set `status` (focusing/ready), `lastSeen`, and register `onDisconnect().update({status:'away', lastSeen: ServerValue.timestamp})`.
3. Show a member as "away" only after 60-90 s grace (Android backgrounds apps in focus mode).
4. Heartbeat every 45 s (`lastSeen` only). Remove the old fast heartbeat.

### 4.4 Focus enforcement (`SessionFocusBridge`)
- Session `running` + past countdown → call the existing Focus Mode start with `duration = endAt - now`.
- User stops Focus Mode early or force-quits → `breaks += 1`, `status='left'` if they exit the session.
- Completion requires: joined before `startEffective`, `leftAt` absent, `breaks <= 2` (config), `completedAt` written after `endAt`.

### 4.5 Completion & points (n8n `/session-complete`)
1. Input `{sid, idToken}`; verify via Identity Toolkit `accounts:lookup` → `uid`.
2. Read `sessions/{sid}` and `members/{uid}` through the RTDB REST API (service account).
3. Reject unless the criteria in 4.4 hold and `sessionResults/{sid}/{uid}` does not exist (idempotent).
4. Look up points by reason (`shared_session_completed`, group bonus) in the `leaderboard_config` Firestore doc.
5. Write `sessionResults`, then the leaderboard docs (Admin write), then update group stats.

## 5. Security rules

### 5.1 `database.rules.json` (replace/extend the `sessions` block; combines the pending audit fixes)

```json
"sessions": {
  "$sessionId": {
    ".read": "auth != null && (root.child('sessions').child($sessionId).child('ownerId').val() === auth.uid || root.child('sessions').child($sessionId).child('members').child(auth.uid).exists() || data.child('visibility').val() === 'public')",
    ".write": "auth != null && (!data.exists() || data.child('ownerId').val() === auth.uid)",
    "ownerId":  { ".validate": "(!data.exists() && newData.val() === auth.uid) || (data.exists() && newData.val() === data.val())" },
    "state":    { ".validate": "newData.val() === 'lobby' || newData.val() === 'running' || newData.val() === 'cancelled'" },
    "runStartAt": { ".validate": "(!data.exists() && newData.val() === now) || newData.val() === data.val()" },
    "durationSec": { ".validate": "newData.isNumber() && newData.val() >= 300 && newData.val() <= 14400 && (!data.exists() || newData.val() === data.val())" },
    "members": {
      "$memberId": {
        ".write": "auth != null && ((($memberId === auth.uid) && (data.exists() || root.child('sessions').child($sessionId).child('state').val() === 'lobby')) || root.child('sessions').child($sessionId).child('ownerId').val() === auth.uid)",
        "code": { ".validate": "!newData.exists() || root.child('invites').child(newData.val()).child('sid').val() === $sessionId || root.child('sessions').child($sessionId).child('visibility').val() === 'public'" },
        "completedAt": { ".validate": "newData.val() === now && now >= (root.child('sessions').child($sessionId).child('runStartAt').val() + (root.child('sessions').child($sessionId).child('countdownSec').val() + root.child('sessions').child($sessionId).child('durationSec').val()) * 1000)" },
        "breaks": { ".validate": "newData.isNumber() && newData.val() >= 0 && newData.val() <= 50" }
      }
    }
  }
},
"invites": {
  "$code": {
    ".read": "auth != null",
    ".write": "auth != null && ((!data.exists() && root.child('sessions').child(newData.child('sid').val()).child('ownerId').val() === auth.uid) || (data.exists() && root.child('sessions').child(data.child('sid').val()).child('ownerId').val() === auth.uid))"
  }
},
"sessionResults": { ".read": "auth != null", ".write": false }
```

Notes: no `.read` at the `invites` root, so codes cannot be listed. `capacity` cannot be enforced in RTDB rules (no `numChildren`), so it is soft. Existing `publicSessions` rules stay for Phase 5 with the corrected `memberCount` rule from `todo.md` item 12.

### 5.2 `firestore.rules`
- Delete the stale `shared_sessions` block. Add `groups/{gid}` rules in Phase 3 using `exists(/databases/$(database)/documents/groups/$(gid)/members/$(request.auth.uid))` for membership, role checks for admin writes, `stats/*` and `reports` write rules (`stats` write: false).
- Apply the `!exists(...) || diff(...).hasOnly(...)` leaderboard fix from `todo.md` item 11 **only after** the points webhook ships.

## 6. File-by-file change list

Locate unknown files first:
```
grep -rln "SharedSession\|SessionService" lib/
grep -rln "createSessionProvider\|userSessionsProvider" lib/
grep -rln "FocusMode\|focus_session\|startFocus" lib/ android/app/src/main/java
grep -rn "app_links\|AppLinks" lib/ android/app/src/main/AndroidManifest.xml
```

| # | File | Action | What changes |
|---|---|---|---|
| 1 | `database.rules.json` | Edit | Replace with Section 5.1. Deploy: `firebase deploy --only database`. Verify timestamp in console. |
| 2 | `firebase.json` | Edit | Add `emulators` (auth 9099, database 9000, firestore 8080) for rules tests. |
| 3 | `firestore.rules` | Edit | Remove `shared_sessions`; add groups/reports/blocks (Phase 3). |
| 4 | Session model (`SharedSession`) **[confirm path, likely `lib/models/`]** | Edit | Add `type`, `visibility`, `capacity`, `durationSec`, `countdownSec`, `state`, `runStartAt`, `groupId`. Add getters `startEffective`, `endAt`. Remove client-owned `memberCount` from the session (keep in `publicSessions` only). |
| 5 | `lib/models/session_member.dart` | New | `SessionMember` (fields from 3), `MemberStatus` enum, `fromMap/toMap`. |
| 6 | `lib/models/session_result.dart` | New | `SessionResult` read model. |
| 7 | `lib/core/services/session_clock.dart` | New | Section 4.1. Exposes `Stream<int> serverNowMs` and `int now()`. |
| 8 | `lib/core/services/session_presence_service.dart` | New | Section 4.3. Replaces heartbeat code in `SessionService` (`_startPresenceHeartbeat`/`_stopPresenceHeartbeat`). |
| 9 | `lib/core/services/session_service.dart` | Edit (major) | (a) `createSession`: apply Fix A from `todo.md` (atomic multi-path `update` with 15 s timeout) and also write `invites/{code}`. (b) New `joinByCode(code)`: read `invites/{code}`, write `members/{uid}` with `code` field, index under `users/{uid}/sessions`. (c) New `setReady(sid, bool)`. (d) New `startSession(sid)` (host only): update `{state:'running', runStartAt: ServerValue.timestamp}`. (e) New `cancelSession(sid)`. (f) `leaveSession`: write `leftAt`/`status:'left'` instead of deleting members mid-run; reorder `memberCount` write before removal for public sessions (`todo.md` item 12b). (g) New `reportBreak(sid)` (increments `breaks`). (h) New `markCompleted(sid)` then call webhook. (i) New `kickMember(sid, uid)`. (j) Streams: `watchSession(sid)`, `watchMembers(sid)`. (k) Generate 6-char invite codes (unambiguous alphabet), 24 h expiry. |
| 10 | `lib/core/services/session_focus_bridge.dart` | New | Section 4.4. Subscribes to session + clock; calls the **existing** Focus Mode start/stop **[confirm names via grep]**; raises `reportBreak` on early stop. |
| 11 | Session providers **[confirm path]** | Edit/New | Fix `createSessionProvider` error surfacing. Add `sessionProvider(sid)`, `membersProvider(sid)`, `sessionPhaseProvider(sid)` (derived from clock), `sessionClockProvider`, `joinByCodeProvider`. Ensure providers `autoDispose` and cancel RTDB subscriptions (addresses "consumer does not rebuild" / "navigation races init" findings: initialise the service in `main`/an `AsyncNotifier` and `await` it before navigating). |
| 12 | `sessions_list_screen.dart` **[confirm path]** | Edit | Apply Fix B (in-sheet error text, scroll view). Add fields: type, duration, visibility, capacity. Add "Join with code" button + QR scan/share actions. |
| 13 | `session_lobby_screen.dart` | New | Member grid with photos (`profileImageUrl`), ready toggles, invite code/QR/share link, Host controls (Start enabled when ≥1 other ready or host override, Cancel, Kick). Auto-navigates to focus screen when `state == running`. |
| 14 | `focus_session_screen.dart` **[confirm path]** | Edit | Add "shared mode": countdown overlay, server-time remaining, member ring/list with live status, emoji reactions (write `reactions/{sid}/{uid}` short-lived), "leave session" confirmation that warns about breaking the streak. Keep existing solo mode untouched behind a flag. |
| 15 | `session_summary_screen.dart` | New | Results after `endAt`: who completed, your points (from `sessionResults`), streak update, "Focus again" button. |
| 16 | `lib/main.dart` / router **[confirm]** | Edit | Handle `digitox://join/{code}` and `https://<domain>/join/{code}` via `app_links`; if not signed in, defer until sign-in completes; route to lobby via `joinByCode`. |
| 17 | `android/app/src/main/AndroidManifest.xml` | Edit | Intent filter for the join link scheme/host (autoVerify for https links). Confirm foreground service type is already declared for Focus Mode. |
| 18 | `android/.../FgMethodCallHandler.kt` and focus service | Verify (edit only if needed) | Ensure Focus Mode can be started with an arbitrary duration and an externally supplied session id, and that an "ended early by user" event is sent back to Dart. Add that callback if missing. |
| 19 | `lib/core/services/leaderboard_service.dart` **[confirm]** | Edit | Route shared-session points via the webhook (no client `addPoints` for this reason). |
| 20 | `pubspec.yaml` | Edit | Add `qr_flutter`, `mobile_scanner`, `share_plus` (invite share). Phase 4: `firebase_messaging`. |
| 21 | `lib/config/env.dart` (from `todo.md` item 3) | New | Add `SESSION_COMPLETE_WEBHOOK_URL`, `SESSION_CLEANUP_*` keys; add them to `.env.example`. |
| 22 | `backend/n8n/session_complete.json`, `session_cleanup.json` | New | Workflows from 4.5 and a daily cron deleting sessions older than 24 h (lobby) / 48 h (any) and expired invites. |
| 23 | `lib/core/services/group_service.dart` + `lib/models/group*.dart` | New (Phase 3) | Group CRUD, invite, roles, schedule, live-session pointer, stats read. |
| 24 | `lib/ui/screens/groups/*` **[confirm UI folder]** | New (Phase 3) | Groups list, group detail (members, schedule, stats, "Start group session"), invite flow. |
| 25 | `lib/core/services/session_notifications.dart` | New (Phase 3-4) | Local scheduled reminders (`flutter_local_notifications`) for scheduled group sessions; FCM push for invites and "session starting". |
| 26 | `lib/ui/.../report_block_sheet.dart` | New (Phase 5) | Report/block member; writes `reports`, `blocks`; hides blocked users' names/photos. |
| 27 | `l10n` ARB **[confirm, per `l10n.yaml`, likely `lib/l10n/app_en.arb`]** | Edit | Add new strings to English only; the Crowdin config handles other locales. |
| 28 | `README.md` | Edit | Replace "works completely offline / no data transmitted" with an accurate statement: solo features stay offline; shared sessions send display name, photo and focus status to other participants via Firebase. |
| 29 | `test/` | New | See Section 8. |
| 30 | `.github/workflows` | Edit | Run `flutter analyze`, unit tests, and rules tests on PRs. |

## 7. Phases, tasks, acceptance criteria

Estimates are rough single-developer working days.

### Phase 0 - Foundations (3-4 d)
Tasks: rows 1, 2, 9a, 12 (Fix B), 11 (error surfacing), `.env`/`env.dart` cleanup, deploy rules, emulators.
Accept: on two real accounts, create → join → leave works; `PERMISSION_DENIED` shown clearly if rules block; rules deployed and verified.

### Phase 1 - Real-time core (8-10 d)
Tasks: rows 4-11, 13, 14 (shared mode), 15, 10, 18.
Accept: 3 phones join a lobby; host starts; countdown and timer stay within ±1 s; each phone's apps are blocked; kill/reopen the app mid-session and it resumes to the correct remaining time; early exit registers a break.

### Phase 2 - Invites & discovery (3-4 d)
Tasks: rows 9b/9k, 12 (join, QR), 16, 17, 20.
Accept: a link opened on a fresh install/logged-out phone joins the right lobby after sign-in; expired/invalid codes show a friendly error.

### Phase 3 - Groups (7-10 d)
Tasks: rows 3, 23, 24, 25 (local reminders).
Accept: create a group, invite members, schedule a session, members get a reminder, group live session is joinable in one tap from the group screen.

### Phase 4 - Integrity, points, push (4-6 d)
Tasks: rows 19, 21, 22, 25 (FCM), 20, then Firestore leaderboard lockdown (`todo.md` item 11 Phase 1).
Accept: a modified client cannot award itself points; duplicate webhook calls award once; stale sessions disappear within a day.

### Phase 5 - Safety & launch (4-5 d)
Tasks: rows 26, 28, `publicSessions` discovery behind a remote flag, rate limits, beta.
Accept: report/block works; privacy text updated; beta of 20-50 users with no critical bugs for a week.

## 8. Test plan

- **Unit tests** (`test/`): `SessionClock` math with fake offsets; phase derivation (lobby/countdown/running/finished); invite code generator; completion-criteria function.
- **Rules tests** (emulator, `@firebase/rules-unit-testing`): non-member cannot read; member cannot write session root or change `ownerId`; join only in lobby and only with a valid code; `completedAt` rejected before `endAt`; kick only by owner; results not client-writable.
- **Manual multi-device matrix:** airplane mode 60 s mid-session; app swiped away; wrong phone clock (±5 min); host loses connection; two joins at the same time; low battery / battery saver; Android 12-15.
- **Load:** simulate expected concurrent users against the emulator/staging project; check RTDB connection usage.

## 9. Edge cases and decisions

| Case | Behaviour |
|---|---|
| Host disconnects | Session continues (timestamp-driven); only Cancel ends it early. |
| Joiner arrives after start | Not allowed in v1 (rule: lobby only). |
| Nobody else joins | Host can start solo; no group bonus. |
| Phone clock wrong | Irrelevant - uses server offset. |
| User denies Accessibility/overlay permission | Cannot mark "ready"; explain why (also fixes audit item 15). |
| Duplicate completion calls | Webhook is idempotent per `sid+uid`. |
| Abandoned lobbies | Cleanup cron after 24 h. |
| Abuse in public rooms | Public rooms stay behind a flag until report/block ships. |

**Decisions to confirm before Phase 1:** (1) invite-only first (recommended); (2) synced mode only (recommended); (3) n8n vs Cloud Functions on Blaze for the completion webhook (n8n recommended for launch); (4) RTDB Spark limit of about 100 concurrent connections - plan the Blaze upgrade before public launch; verify current quotas.

## 10. Definition of done

- All Section 6 rows for the phase are merged; `flutter analyze` clean; unit + rules tests green in CI.
- Rules deployed and verified in the Firebase console.
- Manual multi-device matrix passed on at least 3 physical devices.
- README/privacy text matches actual data flow.
- No client code path can write points, `sessionResults`, or another user's member node.