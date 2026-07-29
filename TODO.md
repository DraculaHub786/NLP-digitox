# NLP-Digitox — Master TODO (Automation Support + UI Redesign + Branding Fix)

Every task below is a single, small, checkable action — check them off in order within each section. Sections are independent of each other and can be tackled in any order, but steps WITHIN a section must be done in sequence since later steps depend on earlier ones.

---

# SECTION A — Firestore Security Rules

**Note — updated to match what we actually built:** the n8n workflows ended up using **Cloudinary directly** to host badge images (`badgeUrl` points straight to a `res.cloudinary.com` URL), since Firebase Storage required a paid upgrade you didn't have. So there's no `storage.rules` work needed at all — remove that from your plan if you had it queued. There's also a **third collection**, `badge_verification`, that the workflows write to (the public lookup-by-verification-ID collection) which needs its own rule — this was missing before, added below.

### A1. Open `firestore.rules` in your project root
### A2. Inside the `match /databases/{database}/documents {` block, add this rule for the `badges` collection (this is where Node 9/11 in your weekly/monthly workflows write each winner's private record):
```
match /badges/{badgeId} {
  allow read: if request.auth != null && request.auth.uid == resource.data.uid;
  allow write: if false; // only the Admin SDK (n8n) can write
}
```
### A3. In the same block, add this rule for `badge_verification` (this is where Node 10/12 write the public lookup record used by verification IDs like `DTX-ABC123`):
```
match /badge_verification/{verificationId} {
  allow get: if true;   // anyone with the exact ID can look it up
  allow list: if false; // nobody can browse/enumerate all badges
  allow write: if false; // Admin SDK (n8n) only
}
```
### A4. In the same block, add this rule for `automation_state` (used by the onboarding workflow's checkpoint doc):
```
match /automation_state/{docId} {
  allow read, write: if false; // Admin SDK only
}
```
### A5. Save `firestore.rules` and deploy it:
```
firebase deploy --only firestore:rules
```
### A6. Test: as a signed-in user in the app, confirm reading YOUR OWN badge doc succeeds
### A7. Test: confirm attempting to read someone ELSE'S badge doc fails
### A8. Test: confirm a `badge_verification` doc CAN be fetched by its exact ID (e.g. via a direct `get` call) even without being signed in
### A9. Test: confirm you CANNOT list/browse all `badge_verification` docs at once (no query without a specific ID should return results)
### A10. Test: confirm any client-side write attempt to `badges`, `badge_verification`, or `automation_state` (e.g. from Firebase Console using a regular user token, not the Admin SDK) fails

---

# SECTION B — Fix Google Sign-In (Android + iOS)

### B1. Firebase Console → Authentication → Sign-in method → confirm Google shows "Enabled"
### B2. Open a terminal and run this to get your debug SHA-1/SHA-256:
```
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```
### B3. Copy the SHA-1 value from the output
### B4. Copy the SHA-256 value from the output
### B5. Firebase Console → Project settings → your Android app → "Add fingerprint" → paste the SHA-1
### B6. Repeat B5 for the SHA-256
### B7. Re-download `google-services.json` from Firebase Console
### B8. Replace the old file at `android/app/google-services.json` with the freshly downloaded one
### B9. Confirm `GoogleService-Info.plist` exists inside `ios/Runner/`
### B10. Open that plist file and find the `REVERSED_CLIENT_ID` value
### B11. Open `ios/Runner/Info.plist` and confirm there's a `CFBundleURLSchemes` entry that exactly matches the `REVERSED_CLIENT_ID` from B10 — add it if missing
### B12. Find your Google sign-in method in the codebase (likely `lib/core/services/` or an auth-related file)
### B13. Wrap the sign-in logic in try/catch with error logging, matching this shape:
```dart
try {
  final googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) {
    return; // user cancelled — normal, not a bug
  }
  final googleAuth = await googleUser.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  await FirebaseAuth.instance.signInWithCredential(credential);
} catch (e, st) {
  print('GOOGLE SIGN-IN ERROR: $e');
  // show a SnackBar/dialog to the user instead of failing silently
}
```
### B14. Test on Android: tapping "Sign in with Google" opens the account picker
### B15. Test on iOS: tapping "Sign in with Google" opens the Google auth sheet
### B16. If either test still fails, copy the exact error text from the console log printed in B13 and report it for a precise fix

---

# SECTION C — Optional Automation Improvements

### C1. Find wherever `users/{uid}` is created at signup in the codebase
### C2. Add this field write at that same point:
```dart
await FirebaseFirestore.instance.collection('users').doc(uid).set({
  ...existingFields,
  'email': FirebaseAuth.instance.currentUser?.email,
}, SetOptions(merge: true));
```
### C3. Write a one-time backfill script (using the Admin SDK service account, not the app) that adds `email` to any existing `users/{uid}` docs missing it
### C4. Run the backfill script once
### C5. Test: a brand-new signup's `users/{uid}` doc contains a correct `email` field
### C6. Test: an existing (pre-change) user's doc now also has the `email` field after the backfill
### C7. (Optional) Add a `monthlyPoints` field to `leaderboard/{uid}`
### C8. (Optional) Increment `monthlyPoints` everywhere `points` currently increments
### C9. (Optional) Reset `monthlyPoints` to 0 only on the 1st of the month (same file as your existing weekly reset logic, likely `leaderboard_service.dart`)
### C10. (Optional) Test: mid-month, `monthlyPoints >= points` for any given user
### C11. (Optional) Test: both fields read 0 right after the 1st-of-month reset
### C12. (Optional) Before building a new badge-history screen, check whether `lib/ui/screens/achievements/achievements_screen.dart` or `lib/ui/screens/leaderboard/leaderboard_screen.dart` (both already exist in your app) already cover this — you may just need to add badge/verificationId data to an existing screen instead of building a new one
### C13. (Optional) If a new screen is genuinely needed, build one querying `badges` where `uid == currentUser.uid`, ordered by `awardedAt` descending
### C14. (Optional) Test: a user with at least one badge sees it listed with correct image and date

---

# SECTION D — Fix "Mindful" Branding Leak (non-English locales only)

**Context (read once, no action needed):** Your English strings in `android/app/src/main/res/values/strings.xml` already correctly say "NLP digitox." The bug only affects 11 other language files that were never updated when the app was renamed from its original template. Two specific strings are affected in each file: `accessibility_description` and `admin_description`.

### D1. Open `android/app/src/main/res/values-ar-rSA/strings.xml` (Arabic) — fix `accessibility_description` and `admin_description`, replacing "Mindful" with a properly translated reference to your app
### D2. Open `values-de-rDE/strings.xml` (German) — same fix
### D3. Open `values-es-rES/strings.xml` (Spanish) — same fix
### D4. Open `values-it-rIT/strings.xml` (Italian) — same fix
### D5. Open `values-ja-rJP/strings.xml` (Japanese) — same fix
### D6. Open `values-nl-rNL/strings.xml` (Dutch) — same fix
### D7. Open `values-pt-rBR/strings.xml` (Portuguese/Brazil) — same fix
### D8. Open `values-sr-rSP/strings.xml` (Serbian) — same fix
### D9. Open `values-tr-rTR/strings.xml` (Turkish) — same fix
### D10. Open `values-uk-rUA/strings.xml` (Ukrainian) — same fix
### D11. Open `values-zh-rCN/strings.xml` (Chinese) — same fix

For each of D1-D11: don't just delete the word "Mindful" — copy the corrected English sentence from the base `values/strings.xml`, translate it properly (or run it through a translation tool), and replace the full string value so the sentence still reads naturally.

### D12. On a test device, switch system language to German
### D13. Go to Settings → Accessibility → open your app's entry → confirm the description text now shows correct branding, not "Mindful"
### D14. Switch the test device's language back to normal
### D15. (Optional cleanup) You have two accessibility config XML files (`accessibility_service_config.xml`, unused, and `mindful_accessibility_config.xml`, the one actually wired up). Either delete the unused one, or rename the active one to something neutral and update its one reference in `AndroidManifest.xml` — cosmetic only, not user-facing
### D16. Visually confirm the icon shown on the Accessibility and Device Admin permission screens matches your current app icon (this is likely already correct — `AndroidManifest.xml` already points both to `@mipmap/ic_launcher` with no override found)

---

# SECTION E — Design System Foundation (`lib/config/app_themes.dart`)

### E1. Open `lib/config/app_themes.dart` and locate this line near the top:
```dart
static const _kSeedColor = Color(0xFF4DD6D9); // Turquoise/Cyan
```
### E2. Replace it with:
```dart
static const _kSeedColor = Color(0xFF1F2E23); // Forest green (from app icon)
```
### E3. Save and do a full hot RESTART (not hot reload)
### E4. Test: any default button/switch/focused text field now tints green instead of turquoise
### E5. Run `flutter --version` in a terminal and confirm it reports 3.22 or newer
### E6. If older than 3.22, run `flutter upgrade` before continuing
### E7. In the same file, find the `ColorScheme.fromSeed(...)` call inside `lightTheme()`
### E8. Add a `secondaryKey` parameter to it:
```dart
secondaryKey: const Color(0xFF8E9271), // sage/olive from your icon
```
### E9. Find the second `ColorScheme.fromSeed(...)` call inside `darkTheme()` and add the same `secondaryKey` parameter there too
### E10. If either E8 or E9 throws a compile error saying `secondaryKey` isn't recognized, stop and report this — there's a `.copyWith()` fallback approach we'll use instead
### E11. Test: any secondary-colored component (FAB, chip, secondary button) now shows the sage/olive tone specifically
### E12. In `lightTheme()`, find every occurrence of `0xFFF8FAFC` and replace with `0xFFFBF6EC` (should appear at least twice — `surface` inside `ColorScheme.fromSeed` and `scaffoldBackgroundColor`)
### E13. In `darkTheme()`, find every occurrence of `0xFF0F172A` and replace with `0xFF14180F` (same two spots)
### E14. In `darkTheme()`'s `cardTheme`, find this line:
```dart
color: isAmoled ? const Color(0xFF1A1A1A) : const Color(0xFF1E293B),
```
Change only the second (non-AMOLED) value to `const Color(0xFF1C2118)` — leave the AMOLED value untouched
### E15. In `darkTheme()`'s `inputDecorationTheme`, find the equivalent `fillColor` line and apply the same change (non-AMOLED value → `0xFF1C2118`)
### E16. In `lightTheme()`'s `inputDecorationTheme`, find:
```dart
fillColor: const Color(0xFFF1F5F9),
```
Change to `const Color(0xFFF3EFE3)`
### E17. Test: restart the app, toggle light/dark mode, confirm backgrounds and cards read warm cream/near-black in both modes with zero blue-grey or blue-black remaining
### E18. Find the `materialColors` map (starts with `'Turquoise': _createMaterialColor(...)`)
### E19. Add a new first entry above 'Turquoise':
```dart
'Forest Green': _createMaterialColor(const Color(0xFF1F2E23)),
```
### E20. Search the codebase for where `materialColors` is used (likely in `lib/ui/screens/settings/`) to find the default-selected value
### E21. If the default is hardcoded to `'Turquoise'`, change it to `'Forest Green'`
### E22. Test: fully uninstall and reinstall the app, open the color picker in Settings, confirm "Forest Green" appears and is already selected without tapping anything

---

# SECTION F — Dashboard Hero Cards (`modern_glance_cards.dart`)

### F1. Open `lib/ui/screens/home/dashboard/modern_glance_cards.dart`
### F2. Find the Screen Time card's gradient colors and replace with:
```dart
colors: [Color(0xFF28392C), Color(0xFF3D5341)], // forest green gradient
begin: Alignment.topLeft,
end: Alignment.bottomRight,
```
### F3. Find the Focus Time card's gradient colors and replace with:
```dart
colors: [Color(0xFF838764), Color(0xFFA3A78D)], // sage green gradient
begin: Alignment.topLeft,
end: Alignment.bottomRight,
```
### F4. Find the `BoxShadow` used on these two cards and replace with:
```dart
BoxShadow(
  color: Color(0xFF1F2E23).withOpacity(0.16),
  blurRadius: 24,
  offset: Offset(0, 10),
)
```
### F5. (Optional) Add a 1px top highlight to fake a light source:
```dart
border: Border(top: BorderSide(color: Colors.white.withOpacity(0.15), width: 1)),
```
### F6. Do NOT change the existing 20px corner radius — leave as is
### F7. Test: the two hero cards visually read as deeper/richer than the four mini cards below them

---

# SECTION G — Dashboard Mini Cards (same file, `modern_glance_cards.dart`)

### G1. Find the 4 mini card color definitions (Mobile Data, WiFi Data, Unlocks, Notifications)
### G2. Recolor Mobile Data: background `Color(0xFFF0F5F2)`, icon `Color(0xFF3D5341)`
### G3. Recolor WiFi Data: background `Color(0xFFF5F6EF)`, icon `Color(0xFF838764)`
### G4. Recolor Unlocks: background `Color(0xFFDCE6E0)`, icon `Color(0xFF1F2E23)`
### G5. Recolor Notifications: background `Color(0xFFE8E9DE)`, icon `Color(0xFF4F5238)`
### G6. Set a subtle shadow on all four (do not use the strong Section F shadow here):
```dart
BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: Offset(0,2))
```
### G7. Test: all 6 Dashboard cards (2 hero + 4 mini) belong to the same 2-color family, no leftover purple/cyan/amber/pink

---

# SECTION H — Colors to explicitly LEAVE ALONE (read before doing anything else app-wide)

Confirm you will NOT touch any of the following — changing them would break intentional functionality or convention, not improve it:

### H1. `lib/ui/screens/leaderboard/leaderboard_screen.dart` — rank #1/#2/#3 gold/silver/bronze medal colors stay as-is (rank #4+ already auto-inherits from theme, no action needed there)
### H2. `lib/ui/screens/settings/account/tab_account.dart` — red/orange danger-zone colors stay as-is
### H3. `lib/ui/screens/home/dashboard/sliver_ai_analysis.dart` — red/orange/green sentiment colors stay as-is
### H4. `lib/ui/screens/settings/privacy_settings_screen.dart` — red/orange/green/grey status colors stay as-is
### H5. `lib/ui/screens/chat_settings/chat_settings_screen.dart` — red delete-action color stays as-is
### H6. `lib/ui/screens/productivity/habits_screen.dart`, `notes_screen.dart`, `tasks_screen.dart` — the entire user-facing color-tagging system (purple/amber/teal/pink/blue/green/grey) stays completely untouched
### H7. `lib/ui/screens/shorts_blocking/sliver_shorts_quick_actions.dart` — the grey disabled-state color stays as-is
### H8. `lib/ui/screens/active_session/timer_progress_clock.dart` — the needle's `colorScheme.error` color stays as-is (already theme-aware, intentional)

---

# SECTION I — Full-App Visual Verification (after Section E-G are done; expect NO code changes here, just checking)

Restart the app and click through each of these, confirming they now read green/sage and nothing looks broken:

### I1. Statistics tab (`home/statistics/tab_statistics.dart`, `application_tile.dart`)
### I2. Notifications tab (`home/notifications/tab_notifications.dart`)
### I3. Bedtime tab (`home/bedtime/tab_bedtime.dart` + schedule/quick-action widgets)
### I4. Focus Mode (`focus/focus_screen.dart`, `focus_mode/tab_focus.dart` + configurations, distracting apps list)
### I5. Focus Timeline (`focus/focus_timeline/tab_focus_timeline.dart`, `sliver_heatmap_calender.dart`, `session_card.dart`)
### I6. Active Session (`active_session/active_session_screen.dart`, `timer_progress_clock.dart` — ring/fill/notch already theme-aware; the 2 small decorative white dots on the clock face are optional/low-priority to touch)
### I7. App Dashboard (`app_dashboard/app_dashboard_screen.dart` + restrictions, internet tile, timer tile, emergency FAB)
### I8. Website Blocking (`websites_blocking/websites_blocking_screen.dart` + website tile, blocked list)
### I9. Restriction Groups (`restriction_groups/restriction_groups_screen.dart` + group card, create/update screen)
### I10. Shorts Blocking (`shorts_blocking/shorts_blocking_screen.dart`, `shorts_timer_chart.dart` — already theme-aware; do a full end-to-end test here since it's tied to the Section D accessibility fix)
### I11. Parental Controls (`parental_controls/parental_controls_screen.dart` + gate, invincible mode settings)
### I12. Notifications history (`notifications/notifications_screen.dart` + conversation tile, notification tile, timeline tabs)
### I13. Achievements (`achievements/achievements_screen.dart` — already uses `colorScheme.tertiary`; keep the orange 7-day-streak fire indicator as-is per Section H reasoning)
### I14. Settings (`settings/settings_screen.dart`, `general/tab_general.dart`, `about/tab_about.dart`, `database/tab_database.dart` + sub-widgets)
### I15. Chat Settings (`chat_settings/chat_settings_screen.dart` — verify everything except the red delete action from H5)
### I16. Change Logs (`change_logs/change_logs_screen.dart`, `change_log_card.dart`)

---

# SECTION J — Decide the "Tip" Callout Card

### J1. Open `lib/ui/screens/home/dashboard/sliver_funny_motivation.dart`
### J2. Decide: Option A (keep amber `#FFF3CD`/`#2D2A1A` as an intentional third accent) or Option B (fold into brand palette)
### J3. If Option B: change light background to `Color(0xFFF0F5F2)` and dark background to `Color(0xFF1C2118)`
### J4. Test: the card is either fully consistent with the decision — not half-changed

---

# Suggested overall order
1. Section B (Google Sign-In) — blocks users from logging in, fix first
2. Section A (security rules) — quick, do before n8n workflows go live
3. Section D (branding fix) — quick per-file edits, high user-visible impact
4. Section E (design system foundation) — everything visual depends on this
5. Section F, G (Dashboard cards) — highest-traffic screen, do first after the foundation
6. Section H (read-only, no action — just keep in mind while doing I)
7. Section I (full verification pass)
8. Section J (final small decision)
9. Section C (optional automation improvements) — whenever convenient, not urgent