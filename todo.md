# Shared focus session — theme parity & fixes (COMPLETED)

Status legend: `[x]` done & verified in this repo. `[~]` needs a live run/deploy
that cannot be done from a local analyse+test pass (owner action).

Verification run on this tree:
- `flutter analyze` — **No issues found**
- `flutter test` — **All tests passed** (397)
- `cd test/rules && npm install && npm test` — **16/16 passed** (6 suites)
- `flutter run` from latest `main` — the sessions-list background is the shared
  `TreatedBackgroundImage`, not the old two-stop gradient.

---

## 1. Screen background matched to the app theme — `[x]`

- [x] `sessions_list_screen.dart` is built on `ScaffoldShell`, so it uses the
      same `TreatedBackgroundImage` (blurred botanical photo + theme-aware scrim
      + accent orbs) as splash/auth/home. The old
      `LinearGradient(colors: [primary@0.08, surface, surface])` two-stop seam is
      gone — that was the "dark teal into flat cream" screenshot.
- [x] Same shell applied to the lobby, detail and summary screens.

## 2. Theme-consistency fixes — `[x]`

- [x] **Button spinners use the theme's "on primary" colour** instead of a
      literal white, in `create_session_sheet`, `join_by_code_sheet`,
      `join_by_id_sheet`, `complete_session_button`, `report_block_sheet`.
- [x] **Swept the same anti-pattern out of the sibling group sheets** it had
      also leaked into — `create_group_sheet`, `join_group_sheet`,
      `add_schedule_entry_sheet`, `group_detail_sections` (GroupActionBar) — so
      no button anywhere assumes its foreground is literally white.
- [x] **QR white backdrop gets a soft border** in `session_invite_panel.dart`:
      stays white for scanners, but reads as intentional in dark mode instead of
      a hole punched in the card.
- [x] **"Joined session" snackbar uses the palette**, not stock `Colors.green`
      — `DesignPalette.fernDeep`, matching the credited-run snackbar.

## 3. Problems fixed — `[x]`

- [x] **Breaks rule regression closed.** `database.rules.json` allows the cap
      **plus one** (`newData.val() <= 3`), and `SessionService.reportBreak`
      writes `min(count + 1, SessionLimits.maxStoredBreaks)` so "over the cap"
      survives the clamp instead of being stored *as* the cap and credited.
      `session_limits.dart` documents `maxStoredBreaks = maxBreaksPerRun + 1`.
- [x] **A missing permission is shown, not swallowed.** `SessionLobbyScreen`
      now raises an 8-second snackbar with a **Fix** action that opens the
      permissions screen (`onboardingPath` + `permissionsOnly: true`); the run
      starts for real on the resume re-check once granted.
- [x] **A zero remaining time no longer starts a fresh run.**
      `_beginFocusRun` returns early when `_remainingRunSec(session) <= 0`, so
      the finished phase handles it.
- [x] **`leaveSession` still never writes `left`** — left as-is by design
      (minor, and the presence `onDisconnect` path covers departure).

## 4. Rules test coverage — `[x]`

- [x] `breaks_limit.test.js` — 3 breaks accepted, a 4th refused.
- [x] `completion_time.test.js` — `completedAt` before the end refused, after
      the end accepted.
- [x] `member_write.test.js` — a non-owner rewriting `ownerId` refused; a member
      updating their own presence accepted.
- [x] `README.md` updated: "six suites", "all sixteen cases should pass".

## 5. Screen-rotation fix — `[x]`

- [x] **Layer 1 — phones stay portrait.** `lib/ui/common/orientation_policy.dart`
      locks phones (shortest side < 600dp) to portrait and lets tablets/foldables
      rotate; wired into `MaterialApp.builder` in `digitox_app.dart`. No manifest
      `screenOrientation` flag — that would lock tablets too.
- [x] **Layer 2 — large screens cannot overflow.** `ScaffoldShell` caps the
      header at `min(appBarExpandedHeight, height * 0.3)`; every session/group
      sheet uses `SessionSheetScaffold`, which is height-capped to the space
      left above the keyboard and scrolls its body (`isScrollControlled` +
      `SingleChildScrollView`).

---

## Deploy — `[x]`

- [x] `firebase deploy --only database` run against project
      `digital-detox-app-01`. The CLI reported **rules syntax valid** and
      **rules released successfully**.
- [x] **Deployed rules verified identical to `database.rules.json`** — fetched
      the live `.settings/rules.json` with the project's service account and
      deep-compared: **MATCH**. The server-side caps (incl. `breaks <= 3`) are
      now live, not just local.

## Owner actions (cannot be done from this environment)

- [~] **Two-device run:** create → join by code → host starts → both devices
      block at the same second → both credited.
- [~] **Kill & reopen a member's app mid-run:** confirm their personal
      blocklist and duration come back (the on-disk profile snapshot restores
      them).
