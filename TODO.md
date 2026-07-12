# Task: Fix quiz-blocking bug, finish onboarding restructure, close data-storage gaps

## Priority order and why
The quiz bug (Task A) is a **complete new-user blocker** — fix it first,
before anything else, since it means nobody can currently finish signing up
through onboarding. Task B (data storage) is needed before n8n can do
anything useful. Task C (onboarding restructure) is the cosmetic/structural
work from before, still pending — do it last since it's not blocking.

---

# TASK A — Fix the quiz-blocking overlay bug (CRITICAL, do first)

### A.1 The problem, precisely
`lib/ui/onboarding/onboarding_screen.dart`'s `build()` wraps the `PageView`
and a persistent control overlay (skip button, page dots, prev/next arrows,
"Finish setup" button) in a `Stack`. This overlay is rendered on **every**
page including the quiz, and sits visually on top of `OnboardingQuizPage`'s
own bottom button row (`lib/features/onboarding/quiz.dart` lines 141-176 —
Back/Next/Complete buttons), which occupies the same bottom screen region.
The outer overlay's bottom `Container` has an opaque background
(`color: Theme.of(context).colorScheme.surface`), so it **visually and
functionally covers** the quiz's real navigation buttons. Users can select
an answer (that's in the scrollable middle area, unaffected) but can never
reach a working Next/Complete button — the tap lands on the outer overlay
instead, which shows a "Finish setup" button gated on
`haveAllEssentialPermissions`, unrelated to quiz progress.

### A.2 The fix
The outer chrome (skip button, page dots, prev/next arrows, finish button)
should not render at all while the quiz page is showing — the quiz has its
own complete, self-contained navigation. In `onboarding_screen.dart`'s
`build()`:

```dart
final isQuizPage = _pages[_currentPage] is OnboardingQuizPage;
```

Wrap the entire `SafeArea(...)` overlay block in a conditional:
```dart
if (!isQuizPage)
  SafeArea(
    child: Padding(
      ...
    ),
  ),
```
(i.e. only include the overlay in the `Stack`'s children when the current
page isn't the quiz — when `isQuizPage` is true, the quiz's own Scaffold
becomes the only source of navigation controls, unobstructed.)

### A.3 Also fix the "Skip" button's target
`_skipToLastPage()` jumps to `_pages.length - 1`, which is already the quiz
page — confirm this still works once the overlay hide logic in A.2 is in
place (skipping should still land on the quiz, then the overlay should
correctly disappear once there since `_currentPage` will equal the quiz
index).

### A.4 Verify end-to-end
- Fresh signup → onboarding → reach the quiz page → confirm the outer
  skip/dots/arrows are gone and only the quiz's own progress bar + Back/Next
  buttons are visible.
- Answer all 5 questions, tap "Complete" on the last one → confirm the
  persona dialog appears and is dismissable.
- Test on a device/emulator with a taller and a shorter screen — this class
  of bug is easy to "half-fix" if the overlap only reproduces at certain
  screen heights.

---

# TASK B — Close remaining data-storage gaps for n8n

Do this before wiring up any n8n workflow — right now the onboarding-email
workflow specifically has nothing to read.

### B.1 Actually write to `signup_events` at signup
`signup_events` is currently only referenced in `deleteAccount()`'s cleanup
list — nothing ever creates a document there. In `signup_screen.dart`,
right after the `FirestoreService.instance.initializeUserData(...)` call
succeeds (both the email/password path around line 55 and the Google path
around line 118), add:
```dart
try {
  await FirebaseFirestore.instance
      .collection('signup_events')
      .doc(FirebaseAuthService.instance.userId)
      .set({
    'email': _emailController.text.trim(), // or user?.email for the Google path
    'username': _nameController.text.trim(), // or username for the Google path
    'createdAt': FieldValue.serverTimestamp(),
    'processed': false,
  });
} catch (e) {
  debugPrint('Failed to queue signup event: $e');
}
```
Wrap in try/catch, don't block signup on failure — consistent with the
existing pattern in this file.

### B.2 Auto-trigger email verification at signup
Right now `sendEmailVerification()` only fires from a manual "resend"
button in `tab_account.dart`. In `firebase_auth_service.dart`'s
`signUpWithEmail()`, right before returning the created user, add a call to
send verification automatically:
```dart
await userCredential.user?.sendEmailVerification();
```
(Google sign-in users don't need this — Google accounts are already
verified.) Keep the existing manual "resend" button in Account settings too
— useful if the first automatic email gets lost/delayed.

### B.3 Collect phone number and age
`FirestoreService.initializeUserData()` already accepts `phoneNumber` and
`age`, but nothing in the UI collects them yet. Add a short, skippable
"complete your profile" step — a small screen or dialog shown once after
either signup path completes (or slotted into the onboarding Welcome/
Statistics area from Task C, if that's done in the same pass) — that asks
for phone number and age, both optional, with a clear "Skip for now"
option. On submit or skip, write a `profileCompletionPrompted: true` flag
to `users/{uid}` so it's never shown again automatically.

### B.4 Verify end-to-end
- Fresh signup → confirm a `signup_events/{uid}` doc exists with
  `processed: false`
- Confirm a verification email actually arrives without needing to tap
  "resend" manually
- Confirm the profile-completion step appears once, doesn't reappear after
  being answered or skipped, and that entered phone/age actually land on
  `users/{uid}`

---

# TASK C — Finish the onboarding restructure (from the earlier task list)

Only the copy (Task 1) from the original plan was applied. The rest is
still pending — re-doing the checklist here for a single source of truth:

### C.1 Wire Welcome/Statistics into `_pages`
The strings exist in `app_en.arb` but aren't referenced anywhere in
`onboarding_screen.dart`. Add 2 more `OnboardingPage` entries at the front
of the `_pages` list:
```dart
late final List<Widget> _pages = [
  OnboardingPage(
    title: context.locale.onboarding_page_welcome_title,
    imgArtPath: "assets/illustrations/onboarding_5.png",
    description: context.locale.onboarding_page_welcome_info,
  ),
  OnboardingPage(
    title: context.locale.onboarding_page_statistics_title,
    imgArtPath: "assets/illustrations/onboarding_6.png",
    description: context.locale.onboarding_page_statistics_info,
  ),
  OnboardingPage(  // Focus — unchanged
    title: context.locale.onboarding_page_one_title,
    imgArtPath: "assets/illustrations/onboarding_1.png",
    description: context.locale.onboarding_page_one_info,
  ),
  OnboardingPage(  // Block Distractions — unchanged
    title: context.locale.onboarding_page_two_title,
    imgArtPath: "assets/illustrations/onboarding_2.png",
    description: context.locale.onboarding_page_two_info,
  ),
  OnboardingPage(  // Privacy First — unchanged
    title: context.locale.onboarding_page_three_title,
    imgArtPath: "assets/illustrations/onboarding_3.png",
    description: context.locale.onboarding_page_three_info,
  ),
  const PermissionsPage(),
  const OnboardingQuizPage(),
];
```

### C.2 Add `onboarding_4.png` to the Permissions page
Read `lib/ui/onboarding/permission_page.dart` in full, then add the
illustration at the top in the same visual style as `OnboardingPage` (see
`lib/ui/onboarding/onboarding_page.dart`'s `AspectRatio` + `Image.asset`
pattern), keeping the existing permission-request controls below it.
Confirm all 4 required permissions (usage access, display overlay, alarms,
notifications) have visible controls.

### C.3 Fix the permission-granted auto-advance
Still unresolved: `initState()`'s `ref.listenManual` calls
`_finishOnboarding()` directly the instant all 4 permissions are granted,
which would skip the quiz entirely. Change it to advance to the quiz page
instead:
```dart
if (!haveAllEssentialPermissions) return;
_controller.animateToPage(
  _pages.length - 1,
  duration: _animDuration,
  curve: _animCurve,
);
_subscription?.close();
```
Only call `_finishOnboarding()` from the quiz's own completion action
(Task C.4).

### C.4 Fix quiz completion to actually mark onboarding done
`quiz.dart`'s `_showPersonaResult()` still does
`Navigator.of(context).pushReplacementNamed('/home')` directly, never
calling `markOnboardingDone()` — meaning even after Task A's fix makes the
button tappable, completing the quiz still won't correctly persist
"onboarding is done," and the user would be sent back into onboarding on
next launch. Fix by either:
- (a) passing an `onComplete` callback from `OnboardingScreen` (which has
  `_finishOnboarding()`) down into `OnboardingQuizPage`, and calling that
  instead of navigating directly — recommended, single source of truth; or
- (b) having the "Get Started" button call
  `ref.read(mindfulSettingsProvider.notifier).markOnboardingDone()` then
  `NavigationService.instance.init(...)` directly, matching what
  `_finishOnboarding()` already does.

### C.5 Reframe quiz question copy (cosmetic, do last)
Reword question/option text to reference Focus/Block Distractions/Privacy/
Statistics by name where it fits the existing persona-mapping logic, so it
reads as a recap rather than a generic quiz. Keep the underlying
`_determinePersona()` logic and 5-question structure intact.

---

## Suggested execution order
1. **Task A** (unblock new users — nobody can sign up successfully until this lands)
2. **Task B** (data storage — needed before n8n has anything to act on)
3. **Task C.1 → C.4** (structural onboarding fixes)
4. **Task C.5** (copy pass, cosmetic, lowest urgency)

## Acceptance checklist
- [ ] Quiz page's own Next/Back/Complete buttons are visible and tappable,
      outer overlay chrome hidden while on the quiz page
- [ ] Completing the quiz successfully reaches the persona dialog and then
      the app, tested on at least 2 different screen sizes
- [ ] `signup_events/{uid}` is actually created at signup with
      `processed: false`
- [ ] A verification email arrives automatically after signup, no manual
      resend needed
- [ ] Phone/age collection step exists, is skippable, doesn't repeat
- [ ] `_pages` includes Welcome and Statistics slides in the correct order
- [ ] Permissions page shows `onboarding_4.png`
- [ ] Granting all permissions mid-onboarding advances to the quiz, does
      NOT skip straight into the app
- [ ] Completing the quiz calls `markOnboardingDone()` before navigating in
- [ ] Force-close + relaunch after completing onboarding goes straight to
      the dashboard, not back into onboarding
- [ ] Quiz question copy references the onboarding topics by name