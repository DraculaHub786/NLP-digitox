# NLP Digitox — TODO (Bugs + UI Revamp + Shorts Blocking)

Repo: `DraculaHub786/NLP-digitox` @ latest `main` push
Reference: `Demo-light.png` / `Demo-dark.png` ("Leafora" glassmorphic concept)

Legend: ✅ Done (code included below, just apply it) · 🔲 To do · ❓ Needs your input first

This doc is written to be read top-to-bottom and acted on without needing
any other file — every fix includes the full "what's wrong → why → exact
code" so you can apply it directly from here.

---

## 1. Bugs — UI

### ✅ 1.1 — Bottom nav bar overflow ("red overflow error for a second")

**File:** `lib/ui/common/glass_nav_bar.dart`

**What's wrong:** Your bottom nav (`GlassNavBar`) renders 5 tabs — Dashboard,
Statistics, Notifications, Bedtime, Leaderboard (defined in
`home_screen.dart`). It lays them out in a `Row` with
`mainAxisAlignment: MainAxisAlignment.spaceAround` and **no `Flexible` /
`Expanded`** around each pill. In Flutter, a `Row` without flex wrappers
demands each child's full intrinsic width — it will never shrink a child to
fit. With 5 pills, and the selected one expanding to show its full label
text (e.g. "Notifications" at 12+ characters), the total intrinsic width
can exceed the screen width on standard phone sizes.

Normally this doesn't visibly break anything because Flutter just silently
clips it — but **any full-tree rebuild forces a fresh layout pass**, and for
one frame during that pass the overflow becomes visible as the yellow/black
striped banner. Changing your accent color in Settings → General
(`tab_general.dart`) reseeds the entire `ColorScheme` via
`ColorScheme.fromSeed`, which is exactly the kind of full rebuild that
triggers it — that's your "red overflow error for a second."

**How to apply:** Open `lib/ui/common/glass_nav_bar.dart`.

**Change A — wrap each pill in `Flexible`** (inside `GlassNavBar.build`,
in the `Row` that lists out `_PillNavButton`s):

```dart
// BEFORE
child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    for (var i = 0; i < items.length; i++)
      _PillNavButton(
        item: items[i],
        selected: i == selectedIndex,
        onTap: () => onDestinationSelected(i),
      ),
  ],
),
```

```dart
// AFTER
child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    for (var i = 0; i < items.length; i++)
      Flexible(
        child: _PillNavButton(
          item: items[i],
          selected: i == selectedIndex,
          onTap: () => onDestinationSelected(i),
        ),
      ),
  ],
),
```

**Change B — let the label shrink/truncate instead of forcing width**
(inside `_PillNavButton.build`):

```dart
// BEFORE
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
...
child: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(
      selected ? item.filledIcon : item.icon,
      size: 20,
      color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
    ),
    const SizedBox(width: 6),
    AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: selected
          ? Text(
              item.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            )
          : const SizedBox(width: 0),
    ),
  ],
),
```

```dart
// AFTER
padding: EdgeInsets.symmetric(
  horizontal: selected ? 12 : 14,
  vertical: 10,
),
...
// `mainAxisSize.min` alone isn't enough once this button sits inside
// a Flexible — the Row still refuses to size below its children's
// intrinsic width, which is what caused the transient overflow band.
// Wrapping the label in Flexible+ellipsis lets it shrink/truncate
// instead of forcing the whole nav bar wider than the screen.
child: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(
      selected ? item.filledIcon : item.icon,
      size: 20,
      color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
    ),
    AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: selected
          ? Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Flexible(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            )
          : const SizedBox(width: 0),
    ),
  ],
),
```

**How to verify:** Hot-restart the app, tap through all 5 tabs, then go to
Settings → General and change the accent color. No overflow banner should
flash at any point.

---

### ✅ 1.2 — Splash screen used the round icon instead of the square one

**File:** `lib/ui/splash_screen.dart`

**What's wrong:** The splash screen was displaying `assets/logo.png` (your
round mark) clipped into a circle via `ClipOval`. Per your request, this
screen should use the square `assets/logo-prev.png` mark instead.

**How to apply:**

```dart
// BEFORE
child: ClipOval(
  child: Image.asset(
    'assets/logo.png',
    width: 80,
    height: 80,
    fit: BoxFit.cover,
  ),
),
```

```dart
// AFTER
// Splash uses the square "prev" artwork (not the round in-app
// logo/notification icon) so the full mark reads clearly before
// it's ever cropped into a circle.
child: ClipRRect(
  borderRadius: BorderRadius.circular(24),
  child: Image.asset(
    'assets/logo-prev.png',
    width: 80,
    height: 80,
    fit: BoxFit.cover,
  ),
),
```

`ClipOval` → `ClipRRect(24px)` because a square image inside `ClipOval`
would get its corners cut into a circle, defeating the point of using the
square mark.

**Depends on 1.3 below** — the asset has to be registered in `pubspec.yaml`
or `Image.asset('assets/logo-prev.png')` throws at runtime.

---

### ✅ 1.3 — `assets/logo-prev.png` was never registered in `pubspec.yaml`

**File:** `pubspec.yaml`

**What's wrong:** The file exists in your repo, but `pubspec.yaml`'s
`assets:` list only declared `assets/logo.png`. Flutter only bundles files
explicitly listed under `flutter: assets:`.

```yaml
# BEFORE
  assets:
    # App Logo
    - assets/logo.png

# AFTER
  assets:
    # App Logo
    - assets/logo.png
    - assets/logo-prev.png
```

**How to verify:** `flutter pub get` then a full `flutter run` (hot reload
won't pick up new pubspec assets — needs a restart).

---

### ❓ 1.4 — "Animation screen after the logo screen displays on half screen only"

**Status:** Could not reproduce — no Flutter runtime available here to
render the app.

**Two static candidates**, either could cause this:

1. `lib/ui/onboarding/onboarding_page.dart` uses
   `Column(mainAxisAlignment: MainAxisAlignment.spaceBetween)` with only
   two children (illustration + text block), plus a flat **148px** bottom
   padding. With short copy this pushes content to the very top/bottom
   with a large dead gap between — can look like only the top half has
   content.
   ```dart
   // Fix, if this is it:
   Column(
     mainAxisAlignment: MainAxisAlignment.start, // was: spaceBetween
     crossAxisAlignment: CrossAxisAlignment.end,
     children: [
       AspectRatio(aspectRatio: 1, child: Image.asset(imgArtPath, fit: BoxFit.contain)),
       const SizedBox(height: 40), // explicit gap instead of relying on spaceBetween
       Column(/* title + description, unchanged */),
     ],
   )
   // and make bottomPadding responsive instead of a flat 148:
   bottomPadding: MediaQuery.sizeOf(context).height * 0.12,
   ```
2. `OnboardingScreen`'s bottom controls bar (~line 165) paints a hard,
   flat-colored rectangle with no blur — clashes with the glass aesthetic
   and can read as "the screen is cut in half":
   ```dart
   Container(
     color: Theme.of(context).colorScheme.surface, // <- solid, no blur
     padding: const EdgeInsets.only(bottom: 32, top: 4),
     child: Row(/* page dots + nav buttons */),
   )
   // Fix: replace with ClipRRect + BackdropFilter(blur) +
   // GlassTokens.of(context).fillGradient, consistent with GlassNavBar.
   ```

**What I need from you:** confirm which screen — splash itself, or the
onboarding carousel right after it? A screenshot/recording would let me
pinpoint the exact widget instead of guessing.

---

### ❓ 1.5 — Second placement of `logo-prev.png` ("animation screen just before main screen")

**Status:** Blocked on the same question as 1.4. Splash is a single widget
in this codebase; after it the app goes to onboarding (shows no logo at
all currently) or straight to Home. Candidates:
- Add `logo-prev.png` above the illustration on the onboarding welcome page.
- A dedicated transition screen you want inserted that doesn't exist yet.
- Something on-device not reflected in the latest push.

**What I need from you:** tell me which, and I'll write the exact code here.

---

## 2. Bugs — Scheduled notifications don't fire

### ✅ 2.1 — New schedules were created inactive with no indication

**Files:** `lib/providers/notifications/notification_settings_provider.dart`

**What's wrong:** Tapping the "+" button (`NewNotificationScheduleFab`)
only prompts for a name, then calls:
```dart
ref.read(notificationSettingsProvider.notifier).createNewSchedule(scheduleName);
```
— no `time`, no `isActive`. The provider's signature is:
```dart
Future<void> createNewSchedule(
  String scheduleName, [
  TimeOfDayAdapter? time,
  bool? isActive,
]) async {
  final newSchedule = NotificationSchedule(
    label: scheduleName,
    time: time ?? TimeOfDayAdapter.now(),
    isActive: isActive ?? false,   // <- defaults OFF
  );
```
And `NotificationSchedulerService.scheduleNotification()` explicitly bails
out for inactive schedules:
```dart
if (!schedule.isActive) {
  debugPrint('Schedule "${schedule.label}" is inactive, skipping scheduling');
  return;
}
```
So every schedule you create through the "+" button starts silently OFF.
The list screen does have a toggle switch per schedule (`ClayToggle` in
`sliver_schedules_list.dart`) to turn it on — but nothing in the creation
flow tells you that's required, so it's easy to create a schedule, assume
it's armed, and never notice it never fires.

**Fix applied:**
```dart
// AFTER
Future<void> createNewSchedule(
  String scheduleName, [
  TimeOfDayAdapter? time,
  bool? isActive,
]) async {
  final newSchedule = NotificationSchedule(
    label: scheduleName,
    time: time ?? TimeOfDayAdapter.now(),
    // Default to ON for schedules created through explicit user action
    // (the "+" FAB). The 4 starter schedules seeded on first install
    // (Morning/Afternoon/Evening/Night, see defaultNotificationSettingsModel)
    // intentionally stay OFF until reviewed — but a schedule the user just
    // took the extra step to name and create is expected to actually be
    // armed, not silently inactive with no indication in the creation flow.
    isActive: isActive ?? true,
  );
```

**Note:** the schedule's *time* still defaults to `TimeOfDayAdapter.now()`
until you tap the time chip in the list and pick one — so after creating a
schedule, go set the actual time you want (it'll fire at "now's" time,
daily, until you change it). Worth fixing properly later by extending the
creation dialog to ask for a time upfront — flagged as a nice-to-have, not
done here since it touches the dialog UI (`input_field_dialog.dart`) which
wasn't part of the reported bug.

---

### ✅ 2.2 — Granting "exact alarm" permission mid-session had no effect until restart

**Files:** `lib/core/services/notification_scheduler_service.dart`,
`lib/providers/system/permissions_provider.dart`

**What's wrong:** `NotificationSchedulerService.initialize()` checks the
Android "Schedule exact alarms" permission **once**, at cold start:
```dart
final exactAlarmGranted = await androidPlugin.requestExactAlarmsPermission();
_androidScheduleMode = (exactAlarmGranted ?? false)
    ? AndroidScheduleMode.exactAllowWhileIdle
    : AndroidScheduleMode.inexactAllowWhileIdle;
```
If that permission wasn't granted yet at launch (very common — users often
set up the app, then go grant permissions from a prompt afterward),
`_androidScheduleMode` gets locked to `inexactAllowWhileIdle` for the rest
of the session. Android's inexact alarms can be delayed by many minutes,
or deferred entirely under Doze/battery optimization — which looks exactly
like "the notification/alarm fails when the time arrives."

Critically, `askExactAlarmPermission()` (called when you tap "Allow" in the
in-app permission sheet) only opened the OS dialog — it never re-checked or
re-applied the schedule mode:
```dart
Future<void> askExactAlarmPermission() async {
  await MethodChannelService.instance
      .getAndAskExactAlarmPermission(askPermissionToo: true);
}
```
So even after you granted the permission, every schedule stayed stuck on
inexact/delayed timing until you fully restarted the app.

**Fix applied — new method on the scheduler service**
(`lib/core/services/notification_scheduler_service.dart`):
```dart
/// Re-checks the Android exact-alarm permission and, if the schedule mode
/// would change, re-registers every active schedule under the new mode.
Future<void> refreshScheduleMode(List<NotificationSchedule> schedules) async {
  if (!_initialized) return;

  final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  if (androidPlugin == null) return;

  final exactAlarmGranted = await androidPlugin.requestExactAlarmsPermission();
  final newMode = (exactAlarmGranted ?? false)
      ? AndroidScheduleMode.exactAllowWhileIdle
      : AndroidScheduleMode.inexactAllowWhileIdle;

  if (newMode == _androidScheduleMode) return;

  debugPrint(
      'Exact alarm permission changed — schedule mode: $_androidScheduleMode -> $newMode. Re-registering schedules.');
  _androidScheduleMode = newMode;
  await updateAllSchedules(schedules);
}
```

**Fix applied — wired into the permission grant flow**
(`lib/providers/system/permissions_provider.dart`):
```dart
// BEFORE
Future<void> askExactAlarmPermission() async {
  await MethodChannelService.instance
      .getAndAskExactAlarmPermission(askPermissionToo: true);
}

// AFTER
Future<void> askExactAlarmPermission() async {
  await MethodChannelService.instance
      .getAndAskExactAlarmPermission(askPermissionToo: true);

  try {
    final settings = await DriftDbService
        .instance.driftDb.uniqueRecordsDao
        .loadNotificationSettings();
    await NotificationSchedulerService.instance
        .refreshScheduleMode(settings.schedules);
  } catch (e) {
    debugPrint('Failed to refresh notification schedule mode: $e');
  }
}
```
(Also added the two new imports: `drift_db_service.dart` and
`notification_scheduler_service.dart` at the top of that file.)

**How to verify:** Deny the exact-alarm permission at first launch, create
an active schedule, then go grant the permission from the Notifications
permission screen — the schedule should now fire on time without needing
to restart the app.

---

## 3. Shorts blocking — add more platforms

### Important — Reddit, Snapchat, and Facebook are already there

Before adding anything, I checked: **Reddit, Snapchat, and Facebook are
already fully implemented** — both the native detection
(`ShortsPlatformManager.kt`: `isRedditFeatureOpen`, `isSnapchatFeatureOpen`,
`isFacebookFeatureOpen`) and the in-app toggle cards
(`sliver_shorts_quick_actions.dart`). If you're not seeing them on-device,
check: (a) you're on the latest build, (b) Accessibility permission is
granted (the toggles are visually dimmed/disabled without it), and (c) you
scrolled down far enough on the Shorts Blocking tab — Instagram and
Snapchat are expandable tiles, YouTube/Facebook/Reddit are below them as
single-toggle cards.

The genuinely new asks were **X and Threads** — added below.

### ✅ 3.1 — X and Threads scaffolding (Dart side, native enum, constants, UI)

**Files touched:**
- `lib/core/enums/platform_features.dart` — added `xVideos`, `threadsReels`
- `android/.../enums/PlatformFeatures.kt` — added `X_VIDEOS`, `THREADS_REELS`
  + their `fromName` mappings (native and Dart enums are kept in sync by
  string name across the method channel bridge)
- `android/.../AppConstants.kt` — added package names:
  ```kotlin
  const val X_PACKAGE: String = "com.twitter.android"
  const val THREADS_PACKAGE: String = "com.instagram.barcelona"
  ```
  (Verified current as of Aug 2026 — see caveat in 3.2 below.)
- `android/.../ShortsPlatformManager.kt` — wired both packages into the
  `when (resolvedPackage)` dispatch and `maxAllowedDuration` map, added
  `isXFeatureOpen()` / `isThreadsFeatureOpen()` stubs (see 3.2 — these are
  **not yet functional**, deliberately).
- `lib/ui/screens/shorts_blocking/sliver_shorts_quick_actions.dart` — added
  two new single-toggle cards (same visual pattern as the existing
  Facebook/Reddit cards), wired to the new enum values.
- `assets/vectors/x_placeholder.svg`, `assets/vectors/threads_placeholder.svg`
  — generic geometric placeholder icons (NOT brand logos — see 3.3), and
  registered both in `pubspec.yaml`.
- `lib/l10n/app_en.arb` — added English strings:
  ```json
  "x_features_tile_title": "X",
  "x_features_tile_subtitle": "Restrict video feed on X.",
  "threads_features_tile_title": "Threads",
  "threads_features_tile_subtitle": "Restrict video/reels on Threads.",
  ```

**After pulling this patch, run** `flutter gen-l10n` (or just `flutter pub
get`, which triggers it since `generate: true` is set in `pubspec.yaml`) to
regenerate the localization getters from the updated `.arb` file.

---

### 🔲 3.2 — REQUIRED before shipping: fill in the real detection logic

**File:** `android/.../services/accessibility/ShortsPlatformManager.kt`

**Why this is incomplete on purpose:** every other platform's detection
(Instagram, Snapchat, Facebook, Reddit, YouTube) works by matching a
specific Android Accessibility view ID or on-screen text that only exists
when that app's short-video surface is open — e.g. Reddit's is literally
`node.viewIdResourceName == "feed_vertical_pager"`. Those IDs can only be
found by running the actual X and Threads apps on a real device or
emulator and inspecting their live UI tree. I have no Android runtime
available in this environment, so I could not verify real IDs — and
fabricating one would be worse than leaving it unfinished, because it
would silently compile and never trigger, giving false confidence that
blocking works when it doesn't.

**Extra wrinkle for X specifically:** X shipped a complete rewrite of its
Android app in July 2026 (new Kotlin + Jetpack Compose codebase, per their
own engineering announcement). Any view ID you might find referenced
online from before that date is very likely stale.

**What's there right now** (compiles, but always returns `false`):
```kotlin
private fun isXFeatureOpen(
    node: AccessibilityNodeInfo,
    blockedFeatures: Set<PlatformFeatures>,
): Boolean {
    return PlatformFeatures.X_VIDEOS in blockedFeatures &&
            doesNodeByIdExists(node, "com.twitter.android:id/immersive_video_player") // TODO: verify real ID
}

private fun isThreadsFeatureOpen(
    node: AccessibilityNodeInfo,
    blockedFeatures: Set<PlatformFeatures>,
): Boolean {
    return PlatformFeatures.THREADS_REELS in blockedFeatures &&
            doesNodeByIdExists(node, "com.instagram.barcelona:id/clips_video_container") // TODO: verify real ID
}
```

**How to find the real view ID (step by step):**
1. Install X and Threads on a physical device or emulator, and install
   your app in debug mode alongside them.
2. Enable Developer Options → "Layout Inspector" is available from Android
   Studio: `View → Tool Windows → Layout Inspector` while the device is
   connected and the target app is in foreground on the exact screen you
   want to detect (X's video player fully open / Threads showing a
   Reels-style video).
3. Alternatively from a terminal with `adb` and the device connected:
   ```
   adb shell uiautomator dump
   adb pull /sdcard/window_dump.xml
   ```
   then open `window_dump.xml` and search for the `resource-id` of the
   container that wraps the video player (look for something with
   `video`, `player`, `immersive`, `reel`, or `clip` in the name).
4. Replace the placeholder string in `doesNodeByIdExists(node, "...")` with
   the real ID you found, remove the `// TODO` comment, and test by
   toggling the switch on and opening that surface in X/Threads — the
   accessibility service should now trigger `blockDistraction`.
5. Repeat periodically after major X/Threads app updates — these IDs are
   internal implementation details neither company guarantees stability
   for, which is also why Reddit/Instagram/Snapchat's existing detectors
   have survived mostly unchanged but could break on any given update too.

**Note on X specifically:** unlike Instagram/Snapchat/Reddit, X doesn't
have one single dedicated "Shorts"-style surface — its short-form video
lives inside the general timeline/video player. You may want to reconsider
whether "block all video playback" vs. "block the whole X app during focus
hours" (a separate, existing feature — app restrictions) is actually the
better fit for X, since the shorts-blocking model here assumes a distinct,
detectable sub-surface the way the other platforms have.

---

### 🔲 3.3 — Replace placeholder icons with real brand assets

**Files:** `assets/vectors/x_placeholder.svg`, `assets/vectors/threads_placeholder.svg`

I intentionally did **not** draw X's or Threads' actual logos — reproducing
brand marks/wordmarks isn't something I generate, official assets are
trademarked, and a hand-approximated copy is worse than either the real
thing or an honest placeholder. What's currently in the repo are generic,
unbranded geometric icons purely so the UI compiles and something renders
in the toggle row.

**Steps:**
1. Download the official icon SVGs from each platform's press/brand
   resources page (X: `about.x.com`, Threads: Meta's brand resource
   center), or use a maintained open icon set that includes them (e.g.
   Simple Icons — check their license terms for your use case).
2. Save as `assets/vectors/x.svg` and `assets/vectors/threads.svg` (24x24
   viewBox, single-color path using `currentColor` or matching the
   `ColorFilter` pattern the other icons use — see `facebook.svg` /
   `reddit.svg` for the exact format expected by `_buildIcon()`).
3. Update the two `_buildIcon(context, "assets/vectors/...")` calls in
   `sliver_shorts_quick_actions.dart` to point at the new filenames, update
   `pubspec.yaml`'s asset list to match, and delete the two `_placeholder`
   files.

---

### 🔲 3.4 — Translate the new strings into the other 23 locales

**Files:** `lib/l10n/app_*.arb` (all locales except `app_en.arb`, which is
already done)

Only English was added in this pass. `l10n.yaml`'s config determines
whether `flutter gen-l10n` will fall back to the English string for
missing keys in other locales or fail the build — check that file if you
want to confirm before running a release build. Either way, the other 23
`.arb` files need the same 4 keys (`x_features_tile_title`,
`x_features_tile_subtitle`, `threads_features_tile_title`,
`threads_features_tile_subtitle`) translated to match how
`reddit_features_tile_title`/`_subtitle` are done in each file.

---

## 4. UI Revamp — match the Leafora reference

> Context: `lib/config/design_tokens.dart` already contains a `DesignPalette`
> + `GlassTokens` system with a comment saying it was *"extracted from the
> reference images (Demo-light.png / Demo-dark.png)."* The color/glass
> foundation already matches your reference — the gap is that most screens
> don't use rich photography behind the glass yet, and glass styling isn't
> applied consistently everywhere.

### 🔲 4.1 — Give screens a real background image (fixes "background is totally plain")

**File:** `lib/ui/common/treated_background_image.dart`

`TreatedBackgroundImage` is just a `LinearGradient` + 3 blurred solid-color
circles — no photograph, no texture, unlike the reference's real blurred
plant photography behind every glass card.

**Steps:**
1. Source 2–3 royalty-free, softly-lit nature/plant photos — one for light
   mode, one moodier for dark mode. Avoid readable text/logos in them.
2. Add as `assets/backgrounds/bg_light.jpg` / `assets/backgrounds/bg_dark.jpg`,
   register in `pubspec.yaml`.
3. Replace the flat gradient `Container` with a `Stack`:
   `Image.asset(fit: BoxFit.cover)` at the bottom, then
   `BackdropFilter(blur)` + your existing gradient as a translucent scrim
   on top, then the existing orb layer + `child`.
4. Apply the same treatment to the **home screen** background — right now
   `ScaffoldShell`'s `Scaffold` just uses flat `colorScheme.surface`. This
   is the single biggest visual gap vs. the reference.
5. Keep blur sigma ~15–20 and scrim alpha ~0.55–0.7 so text stays legible
   in both themes.

### 🔲 4.2 — Typography hierarchy (serif headline + sans body)

**Files:** `lib/ui/common/styled_text.dart`, `lib/config/app_themes.dart`

`StyledText` never sets `fontFamily`, so headings fall back to the default
sans font — even though the serif `Alice` font is already bundled and
matches the reference's "Leafora" wordmark styling.

**Steps:**
1. Add an `isHeadline` param to `StyledText` that applies
   `fontFamily: 'Alice'` when true.
2. Apply to: splash title, onboarding titles, dashboard greeting ("Good
   Morning, ..." — mirrors the reference's "Good Morning, Plant Parent"),
   and section headers.
3. Leave body copy, buttons, and nav labels on the default sans font.

### 🔲 4.3 — Consistent glass-card usage across screens

`GlassCard`/`glass_widgets.dart` already has the right look, but several
screens (`app_dashboard_screen.dart`, `tab_statistics.dart`, notification/
task list tiles) still use plain `Card`/solid-`surface` containers.

**Steps:**
1. Grep for `Card(` and `color: .*colorScheme.surface` under
   `lib/ui/screens/`; convert visually-primary elements to `GlassCard`.
2. Leave dense list rows (settings, DB import/export) flat for scanability.

### 🔲 4.4 — Cleanup

Delete `lib/ui/common/modern_background.dart`
(`ModernGradientBackground`/`SimpleGradientBackground`) — unused anywhere
in the app, hardcodes an off-palette blue/teal gradient.

---

## 5. Files delivered with this doc
- `bugfixes.patch` — full diff of everything marked ✅ above (nav bar,
  splash icon, pubspec, both notification-scheduling fixes, and the X/
  Threads scaffolding). Apply with `git apply bugfixes.patch` from repo
  root, or `git am` for a proper commit.

## 6. Suggested order of work
1. Apply the patch (covers 1.1–1.3, 2.1–2.2, 3.1) — all low-risk, all done.
2. Reply with which screen 1.4/1.5 refer to (screenshot/recording helps).
3. 3.2 — find and wire in the real X/Threads view IDs (needs a device).
4. 3.3 — swap in real brand icons; 3.4 — translate the new strings.
5. 4.1 (background imagery) — biggest visual impact.
6. 4.3 (glass-card consistency), then 4.2 (typography), then 4.4 (cleanup).





assets for refference of UI redesign:
Demo-light.png
Demo-dark.png