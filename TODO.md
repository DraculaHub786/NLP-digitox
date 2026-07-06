# Task: Fix known bugs in NLP-digitox (sequenced by priority)

## Context
Full read-through of `lib/core/services/leaderboard_service.dart` and
`lib/core/services/firebase_auth_service.dart`. Fix in the order below —
later items assume earlier ones are done (e.g. don't build the monthly
reset before the `monthlyPoints` field exists).

---

## P0 — Breaks the leaderboard/automation outright

### 1. Weekly reset only runs on-device (already being fixed via n8n)
`checkAndPerformWeeklyReset()` is driven by a `Timer.periodic` in
`lib/initializer.dart` (lines 77-79) — no device open at/after Monday 4 AM
means no reset. **Action:** remove the two calls in `initializer.dart`
(`checkAndPerformWeeklyReset()` and `startWeeklyResetMonitor()`); reset moves
entirely to the n8n cron job. Keep `getLeaderboardWeekInfo()` — it's
read-only and fine for a UI countdown.

### 2. `firestore.rules` has no rule for the `leaderboard` collection
Confirm the updated `firestore.rules` (already provided) is actually
deployed via `firebase deploy --only firestore:rules` — check this against
whatever is currently live in the Firebase Console, since the two may differ.

### 3. Mass reset corrupts the "last active" signal used for streak resets
`checkAndResetStreakIfNeeded()` resets a user's streak if
`daysSinceLastUpdate > 1`, computed from the `lastUpdated` field. But every
write to a leaderboard doc — including the **weekly/monthly batch reset** —
also sets `lastUpdated: FieldValue.serverTimestamp()`. So the moment n8n's
weekly reset runs, it stamps `lastUpdated` for every user simultaneously,
which makes a genuinely-inactive user look like they were "just active,"
defeating the inactivity check the next time it runs.
**Fix:** add a separate `lastActiveAt` field that is ONLY updated by real
user activity (`evaluateAndUpdateStreak()`, app opens, point-earning
actions) — never by the reset job. Update
`checkAndResetStreakIfNeeded()` to key off `lastActiveAt` instead of
`lastUpdated`. Leave `lastUpdated` as a generic "last write of any kind"
field. Make sure n8n's reset write does NOT touch `lastActiveAt`.

### 4. Multi-device streak evaluation is tracked locally, not in Firestore
`evaluateAndUpdateStreak()`'s "already evaluated today" guard reads/writes
`SharedPreferences` (`_lastStreakEvalDateKey`) — purely local to one device.
A user on two devices (or after a reinstall) can have their streak
incremented or reset twice for the same effective day, since neither device
knows what the other already did.
**Fix:** store `lastStreakEvalDate` on the `leaderboard/{uid}` Firestore doc
itself and check/set it there as the source of truth (keep the local
SharedPreferences check too, as a fast local skip, but Firestore must win).

### 5. No `monthlyPoints` field exists
Required for the monthly leaderboard/badge to have any data. Add to the
`LeaderboardUser` model (`fromFirestore`, `toMap`) and increment it inside
the same transaction in `addPoints()` that increments `points` and
`lifetimePoints`. Leave it untouched by the weekly reset; only the monthly
n8n job resets it.

### 6. No email stored on `leaderboard` or `users` docs
Blocks all mail automation (covered in the earlier user-profile-data prompt
— implement that one alongside this list, not separately).

---

## P1 — Real bugs / data hygiene

### 7. `deleteAccount()` never cleans up Firestore data
`firebase_auth_service.dart`'s `deleteAccount()` deletes the Firebase Auth
user but leaves `users/{uid}`, `leaderboard/{uid}`, `signup_events/{uid}`,
`streak_badges_awarded/{uid}`, and any `badges/{...}` entries referencing
that uid orphaned in Firestore forever.
**Fix:** before or after calling `_auth.currentUser?.delete()`, batch-delete
all of the above documents for that uid.

### 8. No account-linking path for "email exists with different credential"
If a user signs up with email/password, then later taps "Sign in with
Google" using the same email address, Firebase throws
`account-exists-with-different-credential` and the app just shows a generic
error — there's no way for them to actually link the two sign-in methods.
**Fix:** on that specific error code, fetch the existing sign-in methods for
the email (`fetchSignInMethodsForEmail`) and guide the user to sign in with
their original method, then offer `linkWithCredential` to attach Google as
an additional provider.

### 9. Duplicate dead code
`reauthenticate(String password)` and `reauthenticateWithPassword(String
password)` in `firebase_auth_service.dart` are identical methods. Keep one,
delete the other, update call sites.

### 10. `addPoints()` can silently create an "Anonymous" leaderboard doc
The transaction in `addPoints()` uses `set(..., merge: true)` and will
happily create a brand-new leaderboard doc if one doesn't exist yet — but it
never writes `username`, `avatarEmoji`, or `email`. If `addPoints()` ever
runs before `updateUserData()` has completed for a new user (a real
possibility right at signup, since both are fired off close together),
that user shows up on the leaderboard as "Anonymous" with no email, so the
mail automation can't reach them either.
**Fix:** when the transaction detects the doc doesn't exist, seed
`username`, `email`, and a default `avatarEmoji` from
`FirebaseAuthService.instance` (`userDisplayName`, `userEmail`) at the same
time, not just points fields.

### 11. Client logic keys off device-local time, not a fixed timezone
`DateTime.now()` is used throughout `leaderboard_service.dart`
(`_getWeekStart`, `evaluateAndUpdateStreak`, etc.) — this is the device's
local clock, not a canonical app timezone. Removing the client-side weekly
reset (item #1) mostly neutralizes this for the leaderboard, but
`evaluateAndUpdateStreak()`'s daily streak logic still has the same
exposure: a user who changes their phone's timezone (or travels) gets a
different "day boundary" than everyone else.
**Decision needed, not just a fix:** either (a) explicitly accept "streak
days are per-user local time" as intended behavior and document it, or (b)
compute the effective day from a server timestamp instead of
`DateTime.now()`. Flag this rather than silently leaving it ambiguous.

---

## P2 — UX/completeness gaps (lower priority, do after P0/P1)

### 12. No `emailVerified` enforcement anywhere
Once `sendEmailVerification()` is added (per the earlier prompt), nothing in
the app actually checks or surfaces verification status. Add a soft
"verify your email" banner/reminder somewhere reasonable (e.g. profile
screen) — don't hard-block usage on it.

### 13. Leaderboard cache can show stale competitive rankings
`getTopUsers()` caches results for 5 minutes and is only invalidated by the
*local* user's own writes — so a user can see a stale Top 100 for up to 5
minutes after someone else scores. You already have `streamTopUsers()`
(real-time) implemented but apparently unused in the actual leaderboard
screen — since the user experience should feel "competitive," consider
switching the leaderboard UI to `streamTopUsers()` instead of the cached
`getTopUsers()`.

### 14. `forceWeeklyReset()` has no guard and ships in the app binary
It's not reachable by end users through normal UI, but make sure it's not
wired into any debug/test button in a production build — anyone who found a
way to trigger it would wipe every user's weekly points instantly.

---

## Acceptance checklist
- [ ] `initializer.dart` no longer calls the client-side weekly reset
- [ ] `lastActiveAt` field exists and drives `checkAndResetStreakIfNeeded()`;
      n8n's reset job never writes to it
- [ ] Streak "already evaluated today" check reads/writes Firestore, not
      just local SharedPreferences
- [ ] `monthlyPoints` exists, increments alongside `points`, untouched by
      weekly reset
- [ ] `deleteAccount()` cleans up every Firestore doc tied to that uid
- [ ] `account-exists-with-different-credential` has a real linking flow
- [ ] Duplicate reauthenticate method removed
- [ ] `addPoints()` seeds username/email/avatar on first-ever write, not
      just points fields
- [ ] Timezone behavior for streak day-boundary is a documented decision,
      not an accident