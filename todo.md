# Points not reaching the leaderboard — status

Last worked: 2026-10-12. Everything under **DONE** is finished and verified;
the original analysis is kept, commented out, at the bottom for reference.

---

## DONE (verified this pass)

- [x] **Fix 1 — `firestore.rules`.** `validAvatar()` helper added; the
      `leaderboard/{userId}` create/update rules now accept every field the
      client writes (`lifetimePoints`, `pointsBreakdown`, `lastUpdated`,
      `lastActiveAt`, …) with a +100-per-write bound and a "never decreases"
      rule; the same bound added to `weekly_leaderboard` and
      `monthly_leaderboard` (which previously had no bound at all).
- [x] **Fix 2 — client no longer hides the failure.**
      `LeaderboardService.addPoints` returns `Future<bool>`; all **8** call
      sites check it before recording the award —
      7 in `productivity_points_service.dart` (habit, task, daily streak,
      screen-time, bedtime, app-restriction, focus session) and 1 in
      `notification_scheduler_service.dart` (`_markScheduleCompleted`).
      Verified with `findstr /S /N /C:"addPoints" lib\*.dart`.
- [x] **`flutter analyze`** → `No issues found! (ran in 12.2s)`, exit 0.
- [x] **Firestore rules tests** in `test/firestore_rules/`
      (`leaderboard_points.test.js` + `harness.js`) — pin both halves: the
      writes the app performs are allowed, and the ones it must never perform
      are refused.
- [x] **Emulator runs — re-run first-hand this pass**, not merely read from the
      captured log:
      - `test/firestore_rules` (Firestore rules): `# tests 27 / # pass 27 /
        # fail 0`, exit 0 (also archived at
        `test/firestore_rules/run_output.txt`).
      - `test/rules` (Realtime Database rules): `# tests 16 / # pass 16 /
        # fail 0`, exit 0.
      Both suites need their `node_modules`; `npm --prefix test/firestore_rules
      install` restores the Firestore one (it is git-ignored).
- [x] **Rules DEPLOYED to production.** The repo rules were correct but were
      *not* live — the deployed ruleset was still the old, broken one. Diffed
      live vs local (only the leaderboard block, `validAvatar()` and the
      `badges` read rule differed), deployed, and re-verified.
      - previous ruleset: `46897095-7ad1-41f7-8608-4a0d47f8a46d`
      - deployed ruleset: `2e5c79c9-2e67-4f65-a791-1cc16d721a79`
      - rollback: Firebase Console → Firestore → Rules → history, or redeploy
        the previous ruleset id.
- [x] **Live authenticated-client probe PASSES** (`scripts/probe-live-leaderboard-rules.js`):

      deployed ruleset contains validAvatar():  true
      deployed ruleset contains lifetime cap:   true
      create  weekly_leaderboard  points=30        -> 200  PASS
      create  leaderboard         lifetimePoints=0 -> 200  PASS
      update  leaderboard         0 -> 30  (+30)   -> 200  PASS   (was 403)
      update  leaderboard         30 -> 5030 cheat -> 403  PASS

- [x] **Mock data seeded into the live DB** (`scripts/seed-mock-leaderboard.js`).
      10 users (`mock_lb_aria` … `mock_lb_juno`) written to `leaderboard`,
      `weekly_leaderboard` and `monthly_leaderboard`; read back through the
      board's own `orderBy('points', desc)` query.
      - remove them again: `node scripts/seed-mock-leaderboard.js --cleanup`
      - read-only check:     `node scripts/seed-mock-leaderboard.js --verify`

> **The root cause was the deployed ruleset, not the repo file.** The client
> code writes were fine; the live rules refused them and `addPoints` swallowed
> the error. Both halves are now fixed and the live write succeeds.

---

## OPEN ITEMS / SUGGESTIONS

Ordered by value. The user said to stop after the fixes and review — these are
proposals, nothing below has been applied.

1. **Prove it end-to-end on a device (highest priority).**
   The probe proves the *rules* allow the write; it does not prove the app
   renders it. On a device/simulator: complete one habit, then open
   Leaderboard → Weekly. The `mock_lb_*` rows should sit above you and your
   own row should appear with 30 more points.
   Note: habits already flagged "awarded today" (SharedPreferences
   `habit_points_awarded_today`) will **not** re-award today — either clear app
   storage or complete a *different* habit.

2. **The +100/write cap only slows cheating — it does not stop it.**
   A determined user can still write repeatedly. The real fix is to move the
   award off the client: a Cloud Function (or the existing n8n webhook pattern
   used for shared sessions) that writes points with the Admin SDK after
   verifying the action. App Check would close most of the remaining gap.
   Tracked here, deliberately not done.

3. **Confirm the weekly/monthly reset workflows actually run.**
   The n8n "Weekly/Monthly Leaderboard Winner" workflows reset the period
   boards with the Admin SDK (bypassing rules, so unaffected by this change).
   If they are not scheduled, the weekly/monthly boards never roll over and
   the bound above is the only thing left. Check `leaderboard_config/weekly_reset`
   and `monthly_reset` have a recent `lastResetDate`.

4. **Focus-session points can still be lost silently.**
   `awardPointsForFocusSession` has no local "already awarded" flag (by design —
   focus sessions legitimately repeat). With `addPoints` now returning `false`
   on failure, a failed write there just logs and the points are gone.
   Consider a small retry queue (e.g. re-attempt on next app foreground).

5. **`_backfillMissingAvatars` does one `users/{uid}` read per avatar-less row,
   on every stream snapshot.** With the mock rows (which have no avatar) that is
   10 extra reads per snapshot, and it scales with the board. Consider capping
   it, running it once per session, or seeding the avatar at write time only.

6. **The `badges` read rule changed too.** The deploy also replaced
   `allow read (id match)` with `get` (id match) + `list` (by `userId`) +
   `delete` (own). That is the repo's intended state and fixes the badge list
   being denied, but it is an extra behaviour change that shipped with this
   deploy — worth a quick check that the achievements/badges screen lists
   correctly.

7. **Keep or delete the helper scripts.** Added under `scripts/`:
   `seed-mock-leaderboard.js`, `probe-live-leaderboard-rules.js`,
   `dump-live-rules.js`. They are useful for re-verifying a deploy; delete
   them if you would rather not carry service-account tooling in the repo.
   (`scripts/service-account.json` is already git-ignored.)

---

## Reference: original analysis (commented out — completed)

<!--
## Why it fails

1. The rule blocks every update except three fields. `firestore.rules` line 238
   (`match /leaderboard/{userId}`) allowed an existing document to change only
   `profileImageUrl`, `profileImagePublicId` and `username`. That lockdown
   arrived in commit 56a1b35 ("Shared session impmenetation for forced firebase
   rules", Sep 29). It only takes effect once the rules are deployed.
2. `addPoints` writes fields the rule forbids — `lifetimePoints`,
   `pointsBreakdown`, `lastUpdated`, `lastActiveAt` — inside one transaction that
   also covers the weekly and monthly documents. A transaction is all-or-nothing,
   so one denied write means none of the three documents update.
3. The app reports success anyway — `addPoints` caught the error and only logged
   it; `awardHabitCompletionPoints` then marked the habit awarded for the day and
   sent the notification.
4. Other writes were blocked too: the streak update, the `lastActiveAt` update
   and `updateUserData` all wrote non-allowed fields.

## Fix 1: rules — DONE (see above)

Add `validAvatar()` at the top of `match /databases/{database}/documents` and
replace the `leaderboard/{userId}` block; apply the same grow-only-by-100 bound
to `weekly_leaderboard` and `monthly_leaderboard`.

Deploy with `firebase deploy --only firestore:rules`.   <-- DONE 2026-10-12

## Fix 2: the app should not hide the failure — DONE (see above)

Make `addPoints` return `Future<bool>` and mark the day awarded only on success
at each of the 7 call sites in `productivity_points_service.dart` (plus the
notification-scheduler call site).   <-- DONE
-->
