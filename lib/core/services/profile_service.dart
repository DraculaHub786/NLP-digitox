import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Reads a config value from compile-time constant (production) with fallback
/// to runtime .env (development).
String _cfg(String key) {
  const compileTime = String.fromEnvironment;
  final v = compileTime(key);
  return v.isNotEmpty ? v : (dotenv.env[key] ?? '');
}

/// Reads/writes the user's profile picture.
///
/// Storage backend is Cloudinary (unsigned upload preset) — the app never
/// holds the Cloudinary API secret. Old assets are deleted by asking an n8n
/// webhook (which does hold the secret) to remove them, because an unsigned
/// preset can never overwrite or delete anything itself.
class ProfileService {
  static ProfileService? _instance;
  static ProfileService get instance {
    _instance ??= ProfileService._();
    return _instance!;
  }

  ProfileService._();

  static const String _usersCollection = 'users';
  static const String _cloudinaryFolder = 'profile_pics';

  /// Board collections that carry a denormalised copy of the profile image URL
  /// so the leaderboard/podium can render avatars without a second read.
  static const List<String> _boardCollections = [
    'leaderboard',
    'weekly_leaderboard',
    'monthly_leaderboard',
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _cachedProfileUrl;
  bool _hasLoadedProfileUrl = false;
  bool _isLoading = false;

  /// Emits whenever the profile picture URL changes (upload / removal) so any
  /// on-screen avatar refreshes immediately instead of waiting for a rebuild.
  final ValueNotifier<String?> profileUrlNotifier = ValueNotifier<String?>(null);

  bool get isLoading => _isLoading;

  Future<String?> getProfileUrl() async {
    if (_hasLoadedProfileUrl) {
      return _cachedProfileUrl;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc =
          await _firestore.collection(_usersCollection).doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        _cachedProfileUrl = doc.data()!['profileImageUrl'] as String?;
      }
      _hasLoadedProfileUrl = true;
      return _cachedProfileUrl;
    } catch (e) {
      debugPrint('ProfileService: Error getting profile URL: $e');
      return null;
    }
  }

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

      // Read the previous public_id BEFORE overwriting the Firestore field, so
      // we know what to ask n8n to delete afterwards.
      final existingDoc =
          await _firestore.collection(_usersCollection).doc(user.uid).get();
      final previousPublicId =
          existingDoc.data()?['profileImagePublicId'] as String?;

      final cloudName = _cfg('CLOUDINARY_CLOUD_NAME');
      final uploadPreset = _cfg('CLOUDINARY_UPLOAD_PRESET');
      if (cloudName.isEmpty || uploadPreset.isEmpty) {
        throw Exception(
          'Cloudinary is not configured — ensure .env file exists with '
          'CLOUDINARY_CLOUD_NAME and CLOUDINARY_UPLOAD_PRESET, '
          'or build with --dart-define-from-file=.env',
        );
      }

      // A fresh public_id on every upload: an unsigned preset can never
      // overwrite an existing asset, so a fixed id would make Cloudinary
      // silently keep serving the old file.
      final newPublicId =
          '$_cloudinaryFolder/${user.uid}_${DateTime.now().millisecondsSinceEpoch}';

      final file = File(image.path);
      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['public_id'] = newPublicId
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final responseBody = _decodeUploadResponse(
        await streamedResponse.stream.bytesToString(),
      );

      if (streamedResponse.statusCode != 200) {
        throw Exception(
          'Cloudinary upload failed: '
          '${responseBody['error']?['message'] ?? streamedResponse.statusCode}',
        );
      }

      final downloadUrl = responseBody['secure_url'] as String;
      final publicId = responseBody['public_id'] as String;

      await _firestore.collection(_usersCollection).doc(user.uid).set({
        'profileImageUrl': downloadUrl,
        'profileImagePublicId': publicId,
        'profileImageUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Mirror onto the leaderboard docs so podium/list avatars don't need a
      // second Firestore read — see LeaderboardService.streamTopUsers.
      await _mirrorProfileImageUrl(downloadUrl);

      _setCachedProfileUrl(downloadUrl);
      _isLoading = false;

      // Fire-and-forget: ask n8n to delete the old asset. Never let a failure
      // here surface to the user — the new picture is already live regardless
      // of the cleanup outcome.
      if (previousPublicId != null && previousPublicId.isNotEmpty) {
        _triggerCleanupWebhook(previousPublicId);
      }

      debugPrint('ProfileService: Profile picture uploaded to Cloudinary');
      return downloadUrl;
    } catch (e) {
      _isLoading = false;
      debugPrint('ProfileService: Error uploading profile picture: $e');
      rethrow;
    }
  }

  Future<void> removeProfilePicture() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Read the previous public_id before deleting it from Firestore.
      final existingDoc =
          await _firestore.collection(_usersCollection).doc(user.uid).get();
      final previousPublicId =
          existingDoc.data()?['profileImagePublicId'] as String?;

      await _firestore.collection(_usersCollection).doc(user.uid).set({
        'profileImageUrl': FieldValue.delete(),
        'profileImagePublicId': FieldValue.delete(),
        'profileImageUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Clear the copies on the leaderboard docs so avatars fall back to the
      // default in the same way the profile screen does.
      await _mirrorProfileImageUrl(null);

      _setCachedProfileUrl(null);

      if (previousPublicId != null && previousPublicId.isNotEmpty) {
        _triggerCleanupWebhook(previousPublicId);
      }

      debugPrint('ProfileService: Profile picture removed');
    } catch (e) {
      debugPrint('ProfileService: Error removing profile picture: $e');
      rethrow;
    }
  }

  void clearCache() {
    _cachedProfileUrl = null;
    _hasLoadedProfileUrl = false;
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  void _setCachedProfileUrl(String? url) {
    _cachedProfileUrl = url;
    _hasLoadedProfileUrl = true;
    profileUrlNotifier.value = url;
  }

  /// Parses a Cloudinary response body, tolerating non-JSON error pages
  /// (gateways, proxies) so the caller can still report the HTTP status.
  Map<String, dynamic> _decodeUploadResponse(String rawBody) {
    if (rawBody.isEmpty) return const {};
    try {
      return jsonDecode(rawBody) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('ProfileService: Non-JSON Cloudinary response: $e');
      return const {};
    }
  }

  /// Writes (or clears) the denormalised avatar URL on the leaderboard docs.
  ///
  /// Best-effort: a failure here must never break the upload/removal the user
  /// just performed. Board docs that don't exist yet are skipped — they are
  /// seeded with the URL by `LeaderboardService.addPoints` instead, so an
  /// image-only doc never lands in a period collection.
  Future<void> _mirrorProfileImageUrl(String? url) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    for (final collection in _boardCollections) {
      try {
        final ref = _firestore.collection(collection).doc(user.uid);
        final snapshot = await ref.get();
        if (!snapshot.exists) continue;

        await ref.set({
          'profileImageUrl': url ?? FieldValue.delete(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint(
          'ProfileService: Failed to mirror avatar to $collection: $e',
        );
      }
    }
  }

  /// Best-effort cleanup — asks n8n (which holds the Cloudinary API secret) to
  /// delete a previous profile picture asset. Never throws; a failure here just
  /// means one orphaned image, not a broken upload.
  void _triggerCleanupWebhook(String publicId) {
    final webhookUrl = _cfg('CLOUDINARY_CLEANUP_WEBHOOK_URL');
    final webhookSecret = _cfg('CLOUDINARY_CLEANUP_WEBHOOK_SECRET');

    if (webhookUrl.isEmpty || webhookSecret.isEmpty) {
      debugPrint(
        'ProfileService: Cleanup webhook not configured — skipping asset '
        'cleanup for $publicId',
      );
      return;
    }

    http
        .post(
          Uri.parse(webhookUrl),
          headers: {
            'Content-Type': 'application/json',
            // Lower-case: dart:io sends header names lower-cased, and the n8n
            // IF node matches `$json.headers['x-webhook-secret']`.
            'x-webhook-secret': webhookSecret,
          },
          body: jsonEncode({'publicId': publicId}),
        )
        .then((_) {})
        .catchError((e) {
      debugPrint('ProfileService: Cleanup webhook failed (non-blocking): $e');
    });
  }
}
