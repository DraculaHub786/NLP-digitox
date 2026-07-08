# Task: Restructure onboarding flow

Target sequence
1. Welcome
2. About the Statistics (feature)
3. Focus
4. Block Distractions
5. Privacy First
6. Permissions / "allowance" screen — uses `onboarding_4.png`
7. Quiz — matched to everything shown above
8. App starts

# Assumption I'm making — confirm before implementation
6 illustrations exist (`assets/illustrations/onboarding_1.png` through
`_6.png`), but only 1/2/3 are currently wired up (Focus/Block/Privacy), and
you explicitly said Permissions uses `onboarding_4.png`. That leaves
`onboarding_5.png` and `onboarding_6.png` unassigned. I'm assuming:
- **Welcome → `onboarding_5.png`**
- **Statistics → `onboarding_6.png`**

If you actually want a different pairing (or new artwork instead of reusing
5/6), say so before starting Task 1 — everything below is written assuming
this mapping.

---

# TASK 1 — Add copy for the 2 new slides (Welcome, Statistics)

### 1.1 Add English source strings
File: `lib/l10n/app_en.arb`
Add 4 new keys, following the exact naming pattern already used for the
other 3 slides (`onboarding_page_one_title`, `_one_info`, etc.):
```
onboarding_page_welcome_title
onboarding_page_welcome_info
onboarding_page_statistics_title
onboarding_page_statistics_info
```
Content should introduce the app (Welcome) and the Statistics/insights
feature (Statistics) in the same tone as the existing 3 slides — short
title, 1-2 sentence description.

### 1.2 Regenerate localization bindings
Run `flutter gen-l10n` (or equivalent build step already used in this repo)
so `context.locale.onboarding_page_welcome_title` etc. become available as
typed getters.

### 1.3 Flag for translation (don't fabricate)
There are **28 locale files** in `lib/l10n/` (`app_af.arb` through
`app_zh.arb`). Only add real content to `app_en.arb` in this task — do not
invent translations for the other 27. Missing keys in non-English `.arb`
files typically fall back to English at runtime (verify this repo's
`gen-l10n` config confirms that), so the app won't break, but plan a
separate translation pass before shipping so non-English users don't see
English text on 2 of 7 onboarding screens.

---

## TASK 2 — Reorder the onboarding page sequence

File: `lib/ui/onboarding/onboarding_screen.dart`, the `_pages` list
(currently 5 entries: 3x `OnboardingPage`, `PermissionsPage`,
`OnboardingQuizPage`).

### 2.1 Rebuild the list in the new order
```
_pages = [
  OnboardingPage(title: ...welcome_title, imgArtPath: "assets/illustrations/onboarding_5.png", description: ...welcome_info),
  OnboardingPage(title: ...statistics_title, imgArtPath: "assets/illustrations/onboarding_6.png", description: ...statistics_info),
  OnboardingPage(title: ...page_one_title, imgArtPath: "assets/illustrations/onboarding_1.png", description: ...page_one_info),      // Focus
  OnboardingPage(title: ...page_two_title, imgArtPath: "assets/illustrations/onboarding_2.png", description: ...page_two_info),      // Block Distractions
  OnboardingPage(title: ...page_three_title, imgArtPath: "assets/illustrations/onboarding_3.png", description: ...page_three_info),  // Privacy First
  const PermissionsPage(),
  const OnboardingQuizPage(),
];
```
Existing Focus/Block/Privacy `OnboardingPage` entries themselves don't need
new copy — just reordering.

### 2.2 Sanity-check `_skipToLastPage()` and the returning-user shortcut
No code change needed here — both already reference `_pages.length - 1`,
not a hardcoded index, so they'll correctly still land on the quiz page
after reordering. Just re-verify this after the list change, don't assume.

---

## TASK 3 — Turn the Permissions page into the "allowance" screen with `onboarding_4.png`

File: `lib/ui/onboarding/permission_page.dart` (262 lines, not yet read in
full for this task — read it first before editing).

### 3.1 Add the illustration
Currently `PermissionsPage` likely doesn't use an `OnboardingPage`-style
illustration layout. Add `onboarding_4.png` at the top, in the same visual
style as the other slides (see `lib/ui/onboarding/onboarding_page.dart`'s
`AspectRatio` + `Image.asset` pattern) — but keep whatever actual
permission-request UI (toggles/buttons per permission) already exists below
it; this task is about adding the illustration/header, not rebuilding the
permission-granting mechanics.

### 3.2 Confirm all 4 required permissions are represented
`onboarding_screen.dart` checks these 4 via `permissionProvider`:
`haveUsageAccessPermission`, `haveDisplayOverlayPermission`,
`haveAlarmsPermission`, `haveNotificationPermission`. Read
`permission_page.dart` and confirm all 4 have a visible request control —
if any are missing from the UI, add them.

### 3.3 Fix the auto-advance behavior — this is the important one
Right now, `onboarding_screen.dart`'s `initState()` sets up:
```dart
_subscription = ref.listenManual<PermissionsModel>(
  permissionProvider,
  (_, perms) {
    final haveAllEssentialPermissions = ...;
    if (!haveAllEssentialPermissions) return;
    _finishOnboarding();       // <-- ends onboarding immediately
    _subscription?.close();
  },
);
```
This **ends onboarding the instant all 4 permissions are granted**,
regardless of which page the user is on — meaning in the new flow, a user
could finish granting permissions and get dropped straight into the app,
**skipping the quiz entirely**. Since you explicitly want the quiz to
always run after permissions, change this listener to advance to the next
page (the quiz) instead of calling `_finishOnboarding()` directly:
```dart
if (!haveAllEssentialPermissions) return;
_controller.animateToPage(
  _pages.length - 1,   // quiz is now always the last page
  duration: _animDuration,
  curve: _animCurve,
);
_subscription?.close();
```
Only call `_finishOnboarding()` from the quiz's completion action (see Task
5).

---

## TASK 4 — Redesign the quiz to reference what was just shown

File: `lib/features/onboarding/quiz.dart` (`OnboardingQuizPage`).

### 4.1 Don't discard the existing persona-fingerprinting logic
The current quiz isn't just cosmetic — it drives `PersonaService` and
personalizes the app (Professional/Student/Parent/Senior/Social-User/General
modes). Keep `_determinePersona()`, `_getPersonaInfo()`, and the underlying
question→persona mapping intact.

### 4.2 Reframe question copy to reference the onboarding slides
Rewrite the question text/options (currently generic: "What best describes
your current situation?", "What is your primary goal?", etc.) so they read
as a recap tied to what was just shown — e.g. referencing Focus, Block
Distractions, Privacy, and Statistics by name where it naturally fits the
existing persona-mapping logic, so it feels like "matching" rather than a
disconnected generic quiz. This is a copywriting task — I can draft
suggested question/option text as a follow-up if you want, once the Welcome
and Statistics copy from Task 1 is finalized (the quiz should reference
consistent terminology).

### 4.3 Keep the existing 5-question structure unless you want more
No indication more questions are needed — reuse the current
`occupation` / `primary_goal` / `biggest_distraction` / `usage_time` /
`motivation` structure, just re-worded.

---

## TASK 5 — Fix onboarding completion so the app actually starts correctly

### 5.1 The bug
`_completeQuiz()` → `_showPersonaResult()` in `quiz.dart` currently does:
```dart
Navigator.of(context).pop();
Navigator.of(context).pushReplacementNamed('/home');
```
This is a real, pre-existing bug: it never calls
`mindfulSettingsProvider.notifier.markOnboardingDone()`. So `isOnboardingDone`
stays `false` in the user's settings. Next time they open the app,
`splash_screen.dart` checks `settings.isOnboardingDone` and sends them right
back into onboarding — even though they already completed it.

### 5.2 The fix
`OnboardingQuizPage` needs access to the same completion path
`onboarding_screen.dart` uses. Two ways to do this, pick one:
- **(a)** Have `OnboardingQuizPage` accept an `onComplete` callback passed
  down from `OnboardingScreen` (which already has `_finishOnboarding()`),
  and call that instead of navigating directly.
- **(b)** Have the "Get Started" button call
  `ref.read(mindfulSettingsProvider.notifier).markOnboardingDone()` directly,
  then call `NavigationService.instance.init(...)` (matching exactly what
  `_finishOnboarding()` in `onboarding_screen.dart` already does), instead
  of a raw `pushReplacementNamed('/home')`.

Option (a) is cleaner (one source of truth for "onboarding is done",
matching the existing skip/permissions-driven completion paths already in
`onboarding_screen.dart`) — recommended unless there's a reason
`OnboardingQuizPage` needs to stay decoupled from its parent.

### 5.3 Verify end-to-end
After the fix: complete onboarding → force-close the app → relaunch →
confirm it goes straight to the dashboard, not back into onboarding.

---

## Suggested implementation order
1. Task 1 (copy) — needed before Task 2 can reference the new keys
2. Task 2 (reorder pages)
3. Task 3 (permissions screen + auto-advance fix)
4. Task 5 (completion bug fix) — do this before Task 4's copy pass so the
   flow is functionally correct first
5. Task 4 (quiz copy rewrite) — cosmetic/content pass last, once the
   structural flow works

## Acceptance checklist
- [ ] Confirmed image mapping (Welcome=5, Statistics=6) or corrected it
- [ ] Welcome and Statistics slides show correct copy in English
- [ ] Other 27 locale files flagged for translation, not fabricated
- [ ] Page order is: Welcome → Statistics → Focus → Block Distractions →
      Privacy First → Permissions → Quiz
- [ ] Permissions page shows `onboarding_4.png` and all 4 required
      permission controls
- [ ] Granting all permissions mid-onboarding advances to the quiz, does
      NOT skip straight into the app
- [ ] Quiz question copy references Focus/Block/Privacy/Statistics content
- [ ] Completing the quiz calls `markOnboardingDone()` before navigating in
- [ ] Force-close + relaunch after completing onboarding goes straight to
      the dashboard, not back into onboarding