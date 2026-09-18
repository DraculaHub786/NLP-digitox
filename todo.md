# Cloudinary Migration — AGENT (Coding) Tasks

File-by-file code changes for the NLP-Digitox repo. Values marked
`<from human-todo.md>` depend on an item in `human-todo.md` being done
first (Cloudinary cloud name, preset name, credentials) — everything
else here is pure code.

---

## 1. App configuration

- [ ] Add to the existing `.env` / `--dart-define-from-file` config
      (same mechanism already used for the AI API keys):
  ```
  CLOUDINARY_CLOUD_NAME=<from human-todo.md §1>
  CLOUDINARY_UPLOAD_PRESET=digitox_profile_unsigned
  CLOUDINARY_CLEANUP_WEBHOOK_URL=<from human-todo.md §2a>
  CLOUDINARY_CLEANUP_WEBHOOK_SECRET=<from human-todo.md §2a>
  ```
  The cloud name/preset aren't secrets (unsigned preset). The webhook
  secret is a shared value your app sends as a header so the webhook
  can't be abused if the URL leaks — treat it like any other app
  secret in your existing `.env` handling.

---

## 2. `pubspec.yaml`

- [ ] Remove:
  ```yaml
  firebase_storage: ^12.4.10
  ```
- [ ] Keep `http: ^1.2.0` and `image_picker: ^1.0.7` — no new HTTP
      package needed.
- [ ] Optional: add `cached_network_image` if you want disk caching on
      the leaderboard avatars. Skippable for a minimal first pass.
- [ ] Run `flutter pub get`; the only file that should break on removing
      `firebase_storage` is `profile_service.dart` (confirmed via grep —
      nothing else in the repo imports it).

---

## 3. `lib/core/services/profile_service.dart`

- [ ] Remove `import 'package:firebase_storage/firebase_storage.dart';`
      and the `final FirebaseStorage _storage` field.
- [ ] Add `import 'dart:convert';` and
      `import 'package:http/http.dart' as http;` (keep existing
      `import 'dart:io';`).
- [ ] Replace the body of `uploadProfilePicture()` — keep the
      `ImagePicker` block identical, only the upload mechanics change.
      Note: `public_id` uses a fresh timestamp on every upload (same
      naming pattern the original Firebase code used) — an unsigned
      preset can never overwrite an existing asset, so reusing a fixed
      ID would just make Cloudinary silently ignore the new upload and
      keep serving the old file. The previous asset is deleted
      separately via the n8n webhook, fire-and-forget, after the new
      one is confirmed live in Firestore:

  ```dart
  Future<String?> uploadProfilePicture() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    _isLoading = true;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image == null) {
        _isLoading = false;
        return null;
      }

      // Read the previous public_id BEFORE overwriting the Firestore
      // field, so we know what to ask n8n to delete afterward.
      final existingDoc =
          await _firestore.collection('users').doc(user.uid).get();
      final previousPublicId =
          existingDoc.data()?['profileImagePublicId'] as String?;

      final file = File(image.path);
      const cloudName = String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
      const uploadPreset =
          String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET');
      final newPublicId =
          'profile_pics/${user.uid}_${DateTime.now().millisecondsSinceEpoch}';

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['public_id'] = newPublicId
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final responseBody =
          jsonDecode(await streamedResponse.stream.bytesToString());

      if (streamedResponse.statusCode != 200) {
        throw Exception(
          'Cloudinary upload failed: ${responseBody['error']?['message'] ?? streamedResponse.statusCode}',
        );
      }

      final downloadUrl = responseBody['secure_url'] as String;
      final publicId = responseBody['public_id'] as String;

      await _firestore.collection('users').doc(user.uid).set({
        'profileImageUrl': downloadUrl,
        'profileImagePublicId': publicId,
        'profileImageUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Mirror onto the leaderboard doc too, so podium/list avatars
      // don't need a second Firestore read — see §5 below.
      await _firestore.collection('leaderboard').doc(user.uid).set({
        'profileImageUrl': downloadUrl,
      }, SetOptions(merge: true));

      _cachedProfileUrl = downloadUrl;
      _isLoading = false;

      // Fire-and-forget: ask n8n to delete the old asset. Never let a
      // failure here surface to the user — the new picture already
      // uploaded and saved successfully regardless of cleanup outcome.
      if (previousPublicId != null && previousPublicId.isNotEmpty) {
        _deleteOldCloudinaryAsset(previousPublicId);
      }

      debugPrint('ProfileService: Profile picture uploaded to Cloudinary');
      return downloadUrl;
    } catch (e) {
      _isLoading = false;
      debugPrint('ProfileService: Error uploading profile picture: $e');
      rethrow;
    }
  }

  /// Best-effort cleanup — asks n8n (which holds the Cloudinary API
  /// secret) to delete a previous profile picture asset. Never throws;
  /// a failure here just means one orphaned image, not a broken upload.
  void _deleteOldCloudinaryAsset(String publicId) {
    const webhookUrl =
        String.fromEnvironment('CLOUDINARY_CLEANUP_WEBHOOK_URL');
    const webhookSecret =
        String.fromEnvironment('CLOUDINARY_CLEANUP_WEBHOOK_SECRET');
    if (webhookUrl.isEmpty) return;

    http
        .post(
          Uri.parse(webhookUrl),
          headers: {
            'Content-Type': 'application/json',
            'X-Webhook-Secret': webhookSecret,
          },
          body: jsonEncode({'publicId': publicId}),
        )
        .catchError((e) {
      debugPrint('ProfileService: Cloudinary cleanup webhook failed: $e');
    });
  }
  ```
- [ ] `getProfileUrl()` — **no changes**, already Firestore-only.
- [ ] `removeProfilePicture()` — read `profileImagePublicId` before
      clearing it, delete both `profileImageUrl` and
      `profileImagePublicId` from Firestore (and mirror the removal onto
      `leaderboard/{uid}.profileImageUrl`), then call the same
      `_deleteOldCloudinaryAsset(previousPublicId)` fire-and-forget
      helper from §3's upload method so the asset is actually removed
      from Cloudinary too, not just unlinked in Firestore.

---

## 4. UI: profile avatar / profile screen

- [ ] `lib/ui/common/profile_avatar.dart` — **no changes**. Already
      backend-agnostic (`Image.network` off whatever URL
      `getProfileUrl()` returns).
- [ ] `lib/ui/screens/profile/profile_screen.dart` — **no changes**.

---

## 5. `lib/core/services/leaderboard_service.dart`

- [ ] Add `final String? profileImageUrl;` to `LeaderboardUser`, plus the
      constructor parameter (optional, default `null`).
- [ ] In `LeaderboardUser.fromFirestore`, add:
  ```dart
  profileImageUrl: data['profileImageUrl'] as String?,
  ```
- [ ] In `toMap()`, add:
  ```dart
  if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
  ```
- [ ] Thread `profileImageUrl` through every place in this file that
      constructs a `LeaderboardUser` — search for `LeaderboardUser(`
      (three sites: `fromFirestore`, the rebuild loop inside
      `_sortAndRank`, and the `leaderboardUser` local in
      `updateUserData`) — same pattern already used for `email` /
      `lifetimePoints`.
- [ ] In `updateUserData()`, read the current profile URL via
      `ProfileService.instance.getProfileUrl()` and pass it through, so
      the field survives an update even if it was set separately by §3.

---

## 6. UI: leaderboard avatars

- [ ] `lib/ui/screens/leaderboard/podium_card.dart` (~line 60) — the
      `CircleAvatar` currently has no image. Thread `profileImageUrl`
      into this widget's constructor (alongside `name`, `rank`, etc.)
      and change:
  ```dart
  CircleAvatar(
    radius: rank == 1 ? 26 : 20,
    backgroundColor: medal.withValues(alpha: 0.25),
    backgroundImage: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
        ? NetworkImage(profileImageUrl!)
        : null,
    child: (profileImageUrl == null || profileImageUrl!.isEmpty)
        ? Icon(FluentIcons.person_20_filled, color: medal)
        : null,
  )
  ```
- [ ] `lib/ui/screens/leaderboard/leaderboard_screen.dart` (~line 372) —
      same change to the `leading: CircleAvatar(...)` in
      `DefaultListTile`: show `user.profileImageUrl` as an image when
      present, fall back to the current rank-number avatar otherwise.
- [ ] `NetworkImage` has no built-in error fallback like
      `Image.network`'s `errorBuilder` — if a broken/expired URL should
      degrade gracefully here too, wrap with `Image.network(...,
      errorBuilder: ...)` inside the `CircleAvatar`'s `child` instead of
      `backgroundImage`, matching `profile_avatar.dart`'s pattern.

---

## 7. `firestore.rules` — profile image validation

- [ ] Under `match /users/{userId}`, tighten the existing rule:
  ```js
  match /users/{userId} {
    allow read: if request.auth != null && request.auth.uid == userId;
    allow write: if request.auth != null && request.auth.uid == userId
      && (!('profileImageUrl' in request.resource.data)
          || request.resource.data.profileImageUrl == null
          || request.resource.data.profileImageUrl
               .matches('https://res\\.cloudinary\\.com/<from human-todo.md §1>/.*'));
    // ...existing habits/tasks/chats/settings subcollection rules unchanged
  }
  ```
- [ ] Under `match /leaderboard/{userId}`, add the same
      `profileImageUrl` pattern check to the existing `allow write`
      rule.
- [ ] Leave the actual `firebase deploy` command to human-todo.md §3 —
      it needs an authenticated CLI session.

---

## 8. Retire Firebase Storage references

- [ ] Delete `storage.rules` (confirmed nothing else needs it — the
      bucket was never provisioned on Spark anyway).
- [ ] Check `deploy_firebase.sh` / `deploy_firebase.ps1` for a
      `storage:rules` deploy target and remove it, so scripted deploys
      don't fail against a non-existent bucket.

---

## 9. Badges: Firestore rules + data model

- [ ] New Firestore subcollection (no schema migration needed — just
      start writing docs of this shape once the n8n side, human-todo.md
      §2b, starts producing them):
      `leaderboard/{uid}/badges/{docId}`
  - `docId` is the n8n-generated `weekId` (e.g. `2026-W37`) or `monthId`
    (e.g. `2026-09`) — the two formats can't collide with each other.
  - Fields: `title` (string), `imageUrl` (string, the Cloudinary
    on-the-fly transformation URL), `period` (`"weekly"` | `"monthly"`),
    `cycleLabel` (string — currently the same value as `docId`),
    `verificationId` (string, e.g. `DTX-7K2N9P`), `earnedAt` (timestamp)
- [ ] Add to `firestore.rules`:
  ```js
  match /leaderboard/{userId} {
    // ...existing rule...
    match /badges/{badgeId} {
      allow read: if request.auth != null;
      allow write: if false; // only n8n (via REST + API key) writes this
    }
  }
  ```

---

## 10. `lib/ui/screens/achievements/achievements_screen.dart`

- [ ] Replace the hardcoded `itemCount: 3` / `labels` list in the badge
      `PageView.builder` with a `StreamBuilder` over
      `FirebaseFirestore.instance.collection('leaderboard').doc(uid).collection('badges').orderBy('earnedAt', descending: true).snapshots()`.
- [ ] Define a fixed set of display "slots" (e.g. last 3 weekly cycles)
      and for each:
  - Badge doc exists → render its `imageUrl` via `Image.network` inside
    the existing card layout, plus `title` / `cycleLabel`.
  - No matching doc → keep today's existing placeholder box exactly as
    it renders now.
- [ ] Replace the static "Badges — Coming soon / No badges yet" card
      (~lines 331–345) with the same data-backed list, or remove it if
      the carousel above now covers the same information.

---

## Cross-references to human-todo.md

- §1 (env config) needs Cloudinary cloud name + preset name from
  human-todo.md §1, and the cleanup webhook URL + secret from
  human-todo.md §2a.
- §7 and §9 (rules) need the cloud name from human-todo.md §1, and the
  actual `firebase deploy` from human-todo.md §3.
- §9/§10 (badges) only display real data once human-todo.md §2b (n8n
  badge workflow) is actually writing badge docs — until then the code
  will correctly show the empty-slot fallback, which is fine to ship
  first.