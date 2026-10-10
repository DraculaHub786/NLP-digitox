// Copyright (c) 2026 NLP digitox

import 'package:shared_preferences/shared_preferences.dart';

/// Remembers which badges have already been celebrated for a user.
///
/// Keyed per user id: the same device can carry more than one account, and a
/// single shared list would either celebrate the other account's badges or
/// silently swallow the current user's.
abstract class BadgeSeenStore {
  /// Badge ids already celebrated for [userId], or `null` when this account has
  /// never been synced on this device.
  ///
  /// The `null` case is load-bearing. "No entry yet" is a first sighting — a
  /// baseline — while an empty set means "the user is up to date and has
  /// nothing". Conflating them would celebrate every historical badge the first
  /// time the app ever looked, which is exactly the flood this exists to stop.
  Future<Set<String>?> readSeen(String userId);

  /// Overwrites the celebrated set for [userId].
  Future<void> writeSeen(String userId, Set<String> badgeIds);
}

/// [BadgeSeenStore] backed by `SharedPreferences`.
class SharedPrefsBadgeSeenStore implements BadgeSeenStore {
  const SharedPrefsBadgeSeenStore();

  /// `seen_badge_ids_<uid>`.
  ///
  /// The uid suffix is the whole point: an un-suffixed key would be shared by
  /// every account that ever signed in on this device.
  static String keyFor(String userId) => 'seen_badge_ids_$userId';

  @override
  Future<Set<String>?> readSeen(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(keyFor(userId));
    return raw?.toSet();
  }

  @override
  Future<void> writeSeen(String userId, Set<String> badgeIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(keyFor(userId), badgeIds.toList());
  }
}
