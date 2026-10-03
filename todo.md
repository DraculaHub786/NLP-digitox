# TODO 1: App code, Firebase rules and repo cleanup

Repo: DraculaHub786/NLP-digitox, `main` @ `bc2c485` (Oct 2, 2026). Everything here was found by reading the code; I could not run Flutter, the tests or the Firebase emulator. The n8n work is in a separate file (`TODO_N8N.md`).

Priority: **P0** = shared sessions or groups do not work or are unsafe without it. **P1** = needed for a trustworthy launch. **P2** = polish.

---

## A. Firestore rules (`firestore.rules`) - P0

Groups cannot work with the current rules. `group_service.dart` uses three collections that have no rules (`group_invites`, `group_directory`, `users/{uid}/groups`), and a normal user can neither read a group nor add themselves to it.

- [ ] **A1. Add rules for the three missing collections** (field names match what `group_service.dart` writes: invite has `gid`, `name`, `ownerName`, `createdAt`, `expiresAt`; group has `ownerId`, `visibility`, `maxMembers`):
```
function isGroupAdmin(gid) {
  return request.auth != null &&
    exists(/databases/$(database)/documents/groups/$(gid)/members/$(request.auth.uid)) &&
    get(/databases/$(database)/documents/groups/$(gid)/members/$(request.auth.uid)).data.role in ["owner", "admin"];
}

match /group_invites/{code} {
  allow get: if request.auth != null;      // single lookup only, so codes cannot be listed
  allow list: if false;
  allow create: if request.auth != null && isGroupAdmin(request.resource.data.gid);
  allow update, delete: if request.auth != null && isGroupAdmin(resource.data.gid);
}

match /group_directory/{gid} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && request.resource.data.ownerId == request.auth.uid;
  allow update, delete: if request.auth != null && isGroupAdmin(gid);
}

match /users/{userId}/groups/{groupId} {
  allow read, create, update: if request.auth != null && request.auth.uid == userId;
  allow delete: if request.auth != null && (request.auth.uid == userId || isGroupAdmin(groupId));
}
```
Define `isGroupAdmin` once at the top of `match /documents/{...}` (functions inside `match /groups/{groupId}` are not visible to sibling matches).

- [ ] **A2. Let a normal user join a group.** In `match /groups/{groupId}/members/{memberId}`, replace the `create` rule with:
```
allow create: if request.auth != null && (
  // creator becomes the first owner
  (memberId == request.auth.uid &&
    (!exists(/databases/$(database)/documents/groups/$(groupId)) ||
     get(/databases/$(database)/documents/groups/$(groupId)).data.ownerId == request.auth.uid)) ||
  // an owner/admin adds someone
  isGroupAdmin(groupId) ||
  // self-join as a plain member, through a valid code or a public group
  (memberId == request.auth.uid && request.resource.data.role == "member" &&
    ( (request.resource.data.code is string &&
       exists(/databases/$(database)/documents/group_invites/$(request.resource.data.code)) &&
       get(/databases/$(database)/documents/group_invites/$(request.resource.data.code)).data.gid == groupId &&
       get(/databases/$(database)/documents/group_invites/$(request.resource.data.code)).data.expiresAt > request.time)
      || get(/databases/$(database)/documents/groups/$(groupId)).data.visibility == "public" ))
);
```
- [ ] **A3. Do not open `groups/{gid}` to every user.** The group document stores `inviteCode`, so a public `get` would leak it. Keep `allow read: if isMember();` and change the app instead (see section D, task D5): a non-member should read the **invite** (`group_invites/{code}`) or **directory** (`group_directory/{gid}`) document for the preview, capacity and visibility, never `groups/{gid}`.
- [ ] **A4. Capacity of groups is client-side only** (Firestore rules cannot count documents). Decide: accept for now (note in README), or add a `memberCount` field on the group document that a joiner increments in the same batch, guarded by a rule requiring `request.resource.data.memberCount == resource.data.memberCount + 1 && request.resource.data.memberCount <= resource.data.maxMembers` and `affectedKeys().hasOnly(['memberCount'])`. (P1)
- [ ] **A5. Leaderboard self-award (P1, decision needed).** `weekly_leaderboard` and `monthly_leaderboard` only validate the avatar URL, and `leaderboard` allows a user to create their own doc with any fields. Fully locking points means moving every point source (habits, tasks, streaks, focus) to server-side awards. Recommended path: first remove the **shared-session** client award (task D1), keep solo points client-written for now, and put server-only awards behind n8n later. Do not lock these rules until every client point source has moved, or the app will break.

## B. Realtime Database rules (`database.rules.json`) - P0

All items below need testing in the Firebase emulator before deploy.

- [ ] **B1. Session creation is probably rejected.** `createSession` writes the session and its invite in one `ref().update()`. The `invites/$code` rule reads `root.child('sessions')...ownerId`, but `root` is the data **before** the write, so the new session does not exist yet. Fix: add `'hostUid': userId` to the invite map in `createSession` (task D2) and change the rule to:
```
"invites": {
  "$code": {
    ".read": "auth != null",
    ".write": "auth != null && ((!data.exists() && newData.child('hostUid').val() === auth.uid) || (data.exists() && data.child('hostUid').val() === auth.uid))",
    "sid": { ".validate": "newData.isString() && newData.val().length > 0" },
    "hostUid": { ".validate": "newData.isString()" }
  }
}
```
- [ ] **B2. Invite-only sessions can be joined without a code.** `code` is only checked when present, and `joinSession(sessionId)` (plain ID join) sends none. Replace the member `.validate` with:
```
".validate": "newData.hasChildren(['displayName', 'joinedAt']) && (data.exists() || newData.parent().parent().child('ownerId').val() === $memberId || newData.parent().parent().child('visibility').val() === 'public' || root.child('sessions').child($sessionId).child('visibility').val() === 'public' || newData.child('code').exists())"
```
  Because join-by-ID now fails for private sessions, restrict `join_by_id_sheet.dart` to public sessions (task D6).
- [ ] **B3. Anyone can create `publicSessions/{id}`** (the `!data.exists() ||` branch). Require ownership for create and update; include `hostUid` in the written entry (task D2):
```
".write": "auth != null && ((!data.exists() && newData.child('hostUid').val() === auth.uid) || (data.exists() && data.child('hostUid').val() === auth.uid) || (!newData.exists() && root.child('sessions').child($sessionId).child('ownerId').val() === auth.uid))"
```
- [ ] **B4. `sessionResults` is readable by everyone** (top-level `.read`). Allow reading only by members of that session (the summary screen lists every member's result via `getSessionResults`):
```
"sessionResults": {
  "$sid": {
    ".read": "auth != null && root.child('sessions').child($sid).child('members').child(auth.uid).exists()",
    ".write": false
  }
}
```
- [ ] **B5. Add indexes** (needed by the n8n cleanup queries): `"sessions": { ".indexOn": ["createdAt"], ... }` and `"invites": { ".indexOn": ["expiresAt"], ... }`.
- [ ] **B6. Make `breaks` monotonic** and block self-promotion: in `members.$memberId`, `breaks` validate `newData.isNumber() && newData.val() >= (data.exists() ? data.val() : 0) && newData.val() <= 50`; and `role` validate `newData.val() === 'member' || (newData.val() === 'host' && newData.parent().parent().parent().child('ownerId').val() === $memberId)`.
- [ ] **B7. Fix the wrong comment.** `session_service.dart` (`joinSession`, comment above the `update`) says "the rules close that race". RTDB rules cannot count members, so session capacity is only enforced by the client. Either accept and document, or enforce it in n8n (a session joined beyond `maxMembers` is ignored for points).
- [ ] **B8. Tests.** Add emulator tests (`@firebase/rules-unit-testing`) for: create session plus invite in one update, join with a valid code, join without a code (must fail on non-public), non-member write (must fail), `completedAt` before end (must fail), kicking, results read by a non-member (must fail).
- [ ] **B9. Remove `firebase.rules.json`** (old rules using `owner`, not `ownerId`). Keep `database.rules.json` only.

## C. Points: remove the client-side award - P0

The webhook and the app would both pay, and the client path can be forged.

- [ ] **C1.** `lib/core/services/session_service.dart`: delete the two calls to `ProductivityPointsService.instance.awardSharedSessionCompletionPoints(...)` (in `completeSession`, ~line 537, and in `_claimCompletionPointsIfFinished`, ~line 570). Keep `_claimCompletionPointsIfFinished` only if it triggers the webhook call (task C2), otherwise delete it.
- [ ] **C2.** Make completion server-driven: `SessionCompletionService.reportCompletion` must return the result (`status`, `points`, `reason`) instead of `void`, so the UI can show it.
- [ ] **C3.** `lib/features/shared_sessions/widgets/complete_session_button.dart`: the dialog and snackbar print a fixed `ProductivityPointsService.sharedSessionCompletionPoints` (50). Replace with the webhook result (for example "Completed - 50 points" or "Completed - no points (needs 2 or more people and at least 15 minutes)").
- [ ] **C4.** `lib/features/shared_sessions/session_summary_screen.dart`: show points from `sessionResults/{sid}/{uid}` (already read by `getResult`), not a locally computed number.
- [ ] **C5.** Remove or retire `sharedSessionCompletionPoints`, `awardSharedSessionCompletionPoints`, the SharedPreferences "already awarded" list and `SharedSessionFocusTracker`'s role in payout, once the webhook is the only source. Update their tests (`shared_session_focus_tracker_test.dart`).
- [ ] **C6.** Remove `SESSION_WEBHOOK_SECRET` from the app: `lib/config/api_keys.dart`, `.env.example`, and the `x-digitox-secret` header in `session_completion_service.dart`. It is compiled into the app, so it protects nothing; the ID token is the real authentication. (Optional: send the token as `Authorization: Bearer ...` instead of in the body. The updated n8n workflow accepts both.)

## D. In-app code fixes

### D-P0: shared session core

- [ ] **D1. Breaks are never recorded.** `SessionFocusBridge.reportBreak` has no caller anywhere in the app, so leaving a focus run early costs nothing. In `lib/providers/focus/focus_mode_provider.dart`, in `endSharedSession()` (and wherever a shared run is given up early), call `SessionFocusBridge.instance.reportBreak(sessionId)` when `isSuccessful` is false and the shared session's `endAt` has not passed. Capture the session id before it is cleared (`_activeSharedSessionId`). Add a test.
- [ ] **D2. `createSession`** (`session_service.dart`, ~line 308): add `'hostUid': userId` to the `invites/$inviteCode` map and to the `publicSessions/$sessionId` map (needed by B1 and B3).
- [ ] **D3. Completion is lost if the app is not open at the end.** `completeRun` is only called from `SessionLobbyScreen` (`session_lobby_screen.dart:68`) while that screen is mounted and observing the phase. If the app is backgrounded for the whole run (the normal case during focus) and killed by Android, nothing is recorded and no points are paid. Add a reconciler:
  - on app start and on `AppLifecycleState.resumed`, read `users/{uid}/sessions`, and for each session whose phase is `finished` and not yet completed, call `SessionFocusBridge.instance.completeRun(session)`;
  - schedule a local notification at `endAt` ("Session finished - tap to collect your points") using `session_notifications.dart`, so the user reopens the app;
  - keep this idempotent (the bridge already de-dupes per launch, and the webhook per `sid + uid`).
  Also: add `WidgetsBindingObserver` handling to the lobby screen so the phase is re-evaluated on resume (no lifecycle handling exists in `lib/features/shared_sessions` today).
- [ ] **D4. `_hasHandledStart` / `_hasHandledFinish`** in the lobby screen are per-widget; reopening the screen after the run started will not start the focus run. Drive the start from the bridge or the reconciler (D3), not only from `ref.listen` on a mounted widget.
- [ ] **D5. Group join must not read `groups/{gid}`** (consequence of A3). In `group_service.dart`:
  - `resolveInviteCode` already reads `group_invites/{code}`: also store `visibility`, `maxMembers` and a `memberCount` snapshot on the invite document in `issueInviteCode` (~line 947) so the join flow can check them;
  - `_addSelfAsMember` (~line 567): replace `getGroup(groupId)` and `group.isListed` / `group.isFull` with a read of the invite document (code join) or `group_directory/{gid}` (public join);
  - keep `getGroup` for members only.
- [ ] **D6. Join by ID (`join_by_id_sheet.dart`)**: only offer it for public sessions (B2). Private and invite-only sessions are joined by code or link.
- [ ] **D7. Real share link.** The manifest only registers the custom scheme `com.nlp.digitox://join/{code}`. WhatsApp, Telegram and most messengers do not make custom schemes tappable, so a shared invite is just text. Add an https link such as `https://nlpdigitox.me/join/{code}`: Android App Links intent filter with `android:autoVerify="true"`, a hosted `/.well-known/assetlinks.json`, a small web page that redirects to the Play Store when the app is missing, and `share_plus` text containing both the link and the 6-character code. (P1)

### D-P1: bugs reported earlier (re-check each; some may already be fixed)

- [ ] **D8.** `sessions_list_screen.dart` was rewritten; confirm there is no `ref.watch(focusModeProvider.notifier)` (use state or `select`, otherwise the UI never rebuilds). Command: `grep -rn "focusModeProvider.notifier" lib/features/shared_sessions`.
- [ ] **D9.** `_beginFocusRun` in the lobby screen awaits the start, then navigates: good. Confirm `startSessionFromSharedSettings` fails safely if a required permission (accessibility) is missing, and that `permission_page.dart` / `permissions_provider.dart` require accessibility before a shared focus run (changed in PR #10; confirm).
- [ ] **D10.** `badge_model.dart`: `monthNames[month]` must be range-checked (1 to 12). `date_time_utils.dart`: invalid calendar dates must be rejected, not normalised.
- [ ] **D11.** No `firebase_messaging` in `pubspec.yaml`: invites and "session starting" are local-notification only, so nobody is notified when someone else invites them. Add FCM only if you want invites delivered to people who have the app closed. (P2)
- [ ] **D12.** `mobile_scanner` is not in `pubspec.yaml`: QR codes can be displayed (`qr_flutter`) but not scanned in-app. Optional. (P2)

### D-P1: privacy and policy

- [ ] **D13.** `README.md` line ~154 says core features work offline "with no account, ever": fine. Add a clear paragraph that shared sessions and groups send display name, photo, focus status and completion to other participants through Firebase, and that report/block exists.
- [ ] **D14.** Update the in-app privacy text, the Play Console Data safety form and the privacy policy for shared sessions, groups, reports and blocks.
- [ ] **D15.** Confirm Report/Block (`report_block_sheet.dart`, `report_block_service.dart`) is reachable from the lobby, member list and group roster, and that blocked users are hidden. (Play Store requires this for user-generated content.)

## E. Repo cleanup - P1

- [ ] **E1.** `git rm` these tracked temp/test files from the repo root (open each first for secrets): `fix_tab_account.py`, `test_groq_chat.dart`, `test_http_direct.dart`, `test_sentiment_json.dart`, `test_weekly_reset.dart`, `tmp_associated_domains_test.txt`, `tmp_build2.txt`, `tmp_diff_dart.txt`, `tmp_diff_native.txt`, `tmp_kill_hung_test.ps1`, `tmp_list_groq_models.ps1`, `tmp_orig_admin_config.txt`, `tmp_orig_admin_receiver.txt`, `tmp_test_groq_model.ps1`. Add `tmp_*` and `test_*.dart` (root only) to `.gitignore`.
- [ ] **E2.** Delete `firebase.rules.json` (B9).
- [ ] **E3.** `backend/n8n/session_complete.json` and `session_cleanup.json` are a different, unfinished design (no credentials on the HTTP nodes). Replace them with the files from `TODO_N8N.md` (with credential references only, no secrets) or delete them. Keep one source of truth.
- [ ] **E4.** Extend `.github/workflows/ci.yml` with a job that runs the rules tests in the Firebase emulator (B8) after `flutter test`.
- [ ] **E5.** If a release keystore or `key.properties` was ever committed in history, rotate the upload key. Check: `git log --all --diff-filter=A --name-only | grep -E "jks|keystore|key.properties"`.

## F. Profile picture cleanup (app side)

- [ ] **F1.** `profile_service.dart` already sends `Authorization: Bearer <ID token>` and `{publicId}`. Point `CLOUDINARY_CLEANUP_WEBHOOK_URL` in the build at the n8n **v2** path (`.../webhook/delete-cloudinary-asset-v2`).
- [ ] **F2.** Confirm the Cloudinary public IDs the app uploads start with `profile_pics/{uid}_` (the v2 workflow rejects anything else). Check one uploaded image in the Cloudinary console, or the upload-preset folder setting.
- [ ] **F3.** `.env.example`: update the comment on `CLOUDINARY_CLEANUP_WEBHOOK_URL` to say the URL is public and authentication is by ID token.

## G. Manual test checklist (two real Android devices, release-like build) - before launch

1. Create a session with an invite; confirm the invite and public entry exist in the database.
2. Join by code on the second device; try joining a private session by ID (must fail).
3. Ready, host starts, both countdown within about 1 second, both get app blocking.
4. Lock the screen for the whole run; reopen after the end: completion must be recorded (D3).
5. Leave the run early on one device: `breaks` increments, no points for that member (D1).
6. Check the leaderboard gets exactly one award per member (no double pay).
7. Group: create, share code, join from another account, schedule an entry, see the roster.
8. Report and block a member; confirm they disappear.
9. Airplane mode for 60 seconds mid-run; the timer stays correct and presence recovers.

## Suggested order
1. A, B (rules) with emulator tests, then deploy rules.
2. D2, D1, D3/D4 (core fixes), then C (remove client awards) together with the n8n `Session Complete` workflow going live.
3. D5, D6 (group and join paths), then E (cleanup) and F.
4. D7 (https links), D13 to D15 (privacy and safety), manual checklist G, then release.