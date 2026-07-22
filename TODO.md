# App-Side Changes TODO — Support for n8n Automation

Split into **Required** (automation will misbehave or be insecure without these) and **Optional** (nice-to-haves, automation works without them).

---

## REQUIRED

### TODO 1 — Add Firestore security rules for `badges` collection
Right now your `firestore.rules` has no entry for `badges` at all, which means Firestore's default-deny applies — that's actually safe by accident, but you should make it explicit so a future rule change doesn't silently break it, and so the app CAN read badge history if you ever want to show it in-app.

**Change** — add inside the `match /databases/{database}/documents {` block in `firestore.rules`:
```
// Badges - written only by the n8n automation (Admin SDK bypasses rules),
// readable by the badge owner so the app can show their badge history
match /badges/{badgeId} {
  allow read: if request.auth != null && request.auth.uid == resource.data.uid;
  allow write: if false; // only the Admin SDK (n8n) can write
}
```

**Acceptance test:** Deploy rules (`firebase deploy --only firestore:rules`). From the app, a signed-in user reading their own badge doc succeeds; reading someone else's badge doc fails; any client-side `write` attempt (e.g. from Firebase console with a user token, not admin) fails.

---

### TODO 2 — Add Firestore security rules for `automation_state`
This collection (used by the onboarding polling workflow to store a checkpoint) should never be touched by the app or any client at all.

**Change** — add:
```
match /automation_state/{docId} {
  allow read, write: if false; // Admin SDK only
}
```

**Acceptance test:** Any attempt to read/write this from the Flutter app (or Firebase console as a regular user) is denied. n8n (using the Admin SDK service account) is unaffected since Admin SDK always bypasses security rules.

---

### TODO 3 — Add Storage rules so the app can display badge images
Your `storage.rules` currently has no `badges/` entry. n8n's uploads go through fine (Admin SDK bypasses storage rules too), but if you want the Flutter app to later *display* a user's badge image, the app needs read permission.

**Change** — add inside your `storage.rules`:
```
match /badges/{fileName} {
  allow read: if request.auth != null;
  allow write: if false; // only the Admin SDK (n8n) uploads badges
}
```

**Acceptance test:** Deploy storage rules. A signed-in user can load a badge image URL in an `Image.network()` widget; an unauthenticated request to the same URL is denied (unless you intentionally want badges public, in which case use `allow read: if true;` instead — tell me if so).

---

### TODO 4 — Fix Google Sign-In (Android + iOS)
This one's on your side to run through since I can't see your logs, but here's the exact order to check:

- [ ] **Firebase Console → Authentication → Sign-in method** — confirm Google shows "Enabled"
- [ ] **Android:** get your SHA-1 and SHA-256:
  ```
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```
  Add both to Firebase Console → Project settings → your Android app → "Add fingerprint". Re-download `google-services.json`, replace the one in `android/app/google-services.json`.
- [ ] **iOS:** confirm `GoogleService-Info.plist` is present in `ios/Runner/`, and that `ios/Runner/Info.plist` has a `CFBundleURLSchemes` entry matching the `REVERSED_CLIENT_ID` from that plist.
- [ ] Wrap your sign-in call so you actually see what's failing — find your Google sign-in method (likely in `lib/core/services/` or an auth-related file) and make sure it looks like:
  ```dart
  try {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      // user cancelled — this is normal, not a bug
      return;
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

**Acceptance test:** Tapping "Sign in with Google" on Android opens the account picker; on iOS it opens the Google auth sheet. If it still does nothing, the `print` above will show an error code/message in your console — send that to me and I'll give you the exact fix.

---

## OPTIONAL (automation works without these, but they improve it)

### TODO 5 — Store email on the user doc to skip the Auth lookup step
Right now n8n has to call the Identity Toolkit API every time to resolve `uid → email`. If you write `email` onto `users/{uid}` (or `leaderboard/{uid}`) at signup time, n8n's Workflow 1/2 can skip that HTTP call entirely — simpler and faster.

**Change** — wherever you currently create the `users/{uid}` doc on signup (likely in an auth/onboarding service), add:
```dart
await FirebaseFirestore.instance.collection('users').doc(uid).set({
  ...existingFields,
  'email': FirebaseAuth.instance.currentUser?.email,
}, SetOptions(merge: true));
```
Also run a **one-time backfill** for existing users (a small admin script using the service account, not an app change) to add `email` to docs that predate this change.

**Acceptance test:** A brand-new signup's `users/{uid}` doc contains an `email` field matching their Auth email. Existing users have it too after the backfill script runs once.

---

### TODO 6 — Monthly points field (only if you want true monthly totals instead of "most weekly wins")
See earlier plan — add a `monthlyPoints` field to `leaderboard/{uid}`, incremented everywhere `points` currently increments, reset to 0 only on the 1st of the month (leave this reset to the app's existing reset logic, same file as the weekly reset — likely `leaderboard_service.dart`).

**Acceptance test:** Mid-month, `monthlyPoints >= points` for any user (since weekly resets `points` but not `monthlyPoints`). Both are 0 right after the 1st-of-month reset.

### TODO 7 — In-app badge history UI (optional, purely cosmetic)
Once TODO 1's rules are in place, you could add a simple screen/widget that queries `badges` where `uid == currentUser.uid`, ordered by `awardedAt` descending, and displays each badge image + date. Not required for the automation to function — just lets users see their trophy case in-app.

**Acceptance test:** A user who has won at least one weekly/monthly badge sees it listed with the correct image and date in this screen.

---

## Suggested order to tackle these
1. TODO 4 (Google Sign-In) — blocks users from logging in at all, fix first
2. TODO 1, 2, 3 (security rules) — 10-minute job, do before n8n workflows go live so nothing is accidentally open
3. TODO 5 (email on user doc) — quick win, simplifies the n8n workflows
4. TODO 6, 7 — whenever you feel like it, not urgent