// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:nlp_digitox/core/database/app_database.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/core/services/sync_service.dart';

/// Restriction Decision Result
class RestrictionDecision {
  final bool canOpen;
  final String reason;
  final RestrictionType type;

  const RestrictionDecision({
    required this.canOpen,
    required this.reason,
    required this.type,
  });

  /// Factory for allowing app
  factory RestrictionDecision.allow() => const RestrictionDecision(
        canOpen: true,
        reason: 'No restrictions apply',
        type: RestrictionType.none,
      );

  /// Factory for blocking app
  factory RestrictionDecision.block(String reason, RestrictionType type) =>
      RestrictionDecision(
        canOpen: false,
        reason: reason,
        type: type,
      );
}

/// Types of restrictions that can block an app
enum RestrictionType {
  none,
  timer,
  launchLimit,
  activePeriod,
  groupTimer,
  sharedQuota,
  crossDeviceLock,
  internet,
}

/// Restriction Engine
/// Implements local enforcement logic for app restrictions, coordinating with
/// SyncService for cross-device quotas and MethodChannelService for Android overlays
class RestrictionEngine {
  /// Private constructor to enforce singleton pattern
  RestrictionEngine._();

  /// Singleton instance
  static final RestrictionEngine instance = RestrictionEngine._();

  /// Cache of app restrictions for quick lookup
  final Map<String, AppRestriction> _restrictionCache = {};

  /// Cache of restriction groups
  final Map<int, RestrictionGroup> _groupCache = {};

  /// Cache of today's launch counts
  final Map<String, int> _launchCountCache = {};

  /// Cache of today's usage (to combine with sync service)
  final Map<String, int> _localUsageCache = {};

  /// Last cache refresh time
  DateTime? _lastCacheRefresh;

  /// Cache validity duration (refresh every 5 minutes)
  static const Duration _cacheValidity = Duration(minutes: 5);

  /// Initialize the restriction engine
  Future<void> init() async {
    try {
      await _refreshCache();
      debugPrint('RestrictionEngine: Initialized successfully');
    } catch (e) {
      debugPrint('RestrictionEngine init error: $e');
    }
  }

  /// Refresh the local cache from database
  Future<void> _refreshCache() async {
    try {
      final db = DriftDbService.instance.driftDb;

      // Load app restrictions
      final restrictions = await db.select(db.appRestrictionTable).get();
      _restrictionCache.clear();
      for (final restriction in restrictions) {
        _restrictionCache[restriction.appPackage] = restriction;
      }

      // Load restriction groups
      final groups = await db.select(db.restrictionGroupsTable).get();
      _groupCache.clear();
      for (final group in groups) {
        _groupCache[group.id] = group;
      }

      // Load launch counts
      final launchCounts = await MethodChannelService.instance.getAppsLaunchCount();
      _launchCountCache.clear();
      _launchCountCache.addAll(launchCounts);

      _lastCacheRefresh = DateTime.now();

      debugPrint('RestrictionEngine: Cache refreshed (${restrictions.length} restrictions, ${groups.length} groups)');
    } catch (e) {
      debugPrint('RestrictionEngine: Error refreshing cache: $e');
    }
  }

  /// Check if cache needs refresh
  Future<void> _ensureCacheValid() async {
    if (_lastCacheRefresh == null ||
        DateTime.now().difference(_lastCacheRefresh!) > _cacheValidity) {
      await _refreshCache();
    }
  }

  /// Check if an app can be opened
  /// Returns a RestrictionDecision with the result and reason
  Future<RestrictionDecision> canOpenApp(String appPackage) async {
    try {
      await _ensureCacheValid();

      // Check local restrictions first
      final restriction = _restrictionCache[appPackage];

      // No restriction = allow
      if (restriction == null) {
        return RestrictionDecision.allow();
      }

      // Check internet restriction
      if (!restriction.canAccessInternet) {
        return RestrictionDecision.block(
          'Internet access is blocked for this app',
          RestrictionType.internet,
        );
      }

      // Check active period
      if (restriction.periodDurationInMins > 0) {
        final now = TimeOfDay.now();
        final nowMinutes = now.hour * 60 + now.minute;
        final startMinutes = restriction.activePeriodStart.hour * 60 +
            restriction.activePeriodStart.minute;
        final endMinutes =
            restriction.activePeriodEnd.hour * 60 + restriction.activePeriodEnd.minute;

        // Check if current time is within active period
        bool isWithinPeriod;
        if (startMinutes <= endMinutes) {
          // Same day period (e.g., 9:00 to 17:00)
          isWithinPeriod = nowMinutes >= startMinutes && nowMinutes <= endMinutes;
        } else {
          // Cross-midnight period (e.g., 22:00 to 06:00)
          isWithinPeriod = nowMinutes >= startMinutes || nowMinutes <= endMinutes;
        }

        if (!isWithinPeriod) {
          return RestrictionDecision.block(
            'App is restricted outside of ${_formatTime(restriction.activePeriodStart)} - ${_formatTime(restriction.activePeriodEnd)}',
            RestrictionType.activePeriod,
          );
        }
      }

      // Check launch limit
      if (restriction.launchLimit > 0) {
        final launchCount = _launchCountCache[appPackage] ?? 0;
        if (launchCount >= restriction.launchLimit) {
          return RestrictionDecision.block(
            'Launch limit reached ($launchCount/${restriction.launchLimit})',
            RestrictionType.launchLimit,
          );
        }
      }

      // Check timer (local usage)
      if (restriction.timerSec > 0) {
        final localUsageSec = _localUsageCache[appPackage] ?? 0;
        if (localUsageSec >= restriction.timerSec) {
          return RestrictionDecision.block(
            'Daily time limit reached',
            RestrictionType.timer,
          );
        }
      }

      // Check restriction group if associated
      if (restriction.associatedGroupId != null) {
        final group = _groupCache[restriction.associatedGroupId];
        if (group != null && group.timerSec > 0) {
          // Calculate total group usage
          int totalGroupUsageSec = 0;
          for (final groupAppPackage in group.distractingApps) {
            totalGroupUsageSec += _localUsageCache[groupAppPackage] ?? 0;
          }

          if (totalGroupUsageSec >= group.timerSec) {
            return RestrictionDecision.block(
              'Group "${group.groupName}" time limit reached',
              RestrictionType.groupTimer,
            );
          }
        }

        // Check group active period
        if (group != null && group.periodDurationInMins > 0) {
          final now = TimeOfDay.now();
          final nowMinutes = now.hour * 60 + now.minute;
          final startMinutes = group.activePeriodStart.hour * 60 +
              group.activePeriodStart.minute;
          final endMinutes =
              group.activePeriodEnd.hour * 60 + group.activePeriodEnd.minute;

          bool isWithinPeriod;
          if (startMinutes <= endMinutes) {
            isWithinPeriod = nowMinutes >= startMinutes && nowMinutes <= endMinutes;
          } else {
            isWithinPeriod = nowMinutes >= startMinutes || nowMinutes <= endMinutes;
          }

          if (!isWithinPeriod) {
            return RestrictionDecision.block(
              'Group "${group.groupName}" is restricted outside of ${_formatTime(group.activePeriodStart)} - ${_formatTime(group.activePeriodEnd)}',
              RestrictionType.activePeriod,
            );
          }
        }
      }

      // Check shared quota via SyncService
      final syncService = SyncService.instance;
      try {
        final usage = await syncService.getUsage(appPackage);
        final dailyMinutes = usage['dailyMinutes'] as int? ?? 0;
        final dailyLimit = usage['dailyLimit'] as int? ?? 0;

        if (dailyLimit > 0 && dailyMinutes >= dailyLimit) {
          return RestrictionDecision.block(
            'Shared daily quota exceeded ($dailyMinutes/$dailyLimit minutes)',
            RestrictionType.sharedQuota,
          );
        }
      } catch (e) {
        debugPrint('RestrictionEngine: Error checking shared quota: $e');
        // Continue without shared quota check if service unavailable
      }

      // Check cross-device lock
      try {
        final isLocked = await syncService.isLockedByOtherDevice(appPackage);
        if (isLocked) {
          return RestrictionDecision.block(
            'App is being used on another device',
            RestrictionType.crossDeviceLock,
          );
        }
      } catch (e) {
        debugPrint('RestrictionEngine: Error checking device lock: $e');
        // Continue without lock check if service unavailable
      }

      // All checks passed
      return RestrictionDecision.allow();
    } catch (e) {
      debugPrint('RestrictionEngine: Error in canOpenApp: $e');
      // Fail-safe: allow access if there's an error in the engine
      return RestrictionDecision.allow();
    }
  }

  /// Handle app launch attempt
  /// This should be called when a user attempts to open an app
  /// Returns true if the app was allowed to open, false if blocked
  Future<bool> onAppLaunchAttempt(String appPackage) async {
    try {
      debugPrint('RestrictionEngine: Launch attempt for $appPackage');

      final decision = await canOpenApp(appPackage);

      if (decision.canOpen) {
        debugPrint('RestrictionEngine: Allowing $appPackage');

        // Try to acquire lock for concurrent usage tracking (optional)
        try {
          final lockAcquired = await SyncService.instance.acquireLock(appPackage, ttlMinutes: 30);
          if (lockAcquired) {
            debugPrint('RestrictionEngine: Acquired lock for $appPackage');
          }
        } catch (e) {
          debugPrint('RestrictionEngine: Error acquiring lock: $e');
        }

        return true;
      } else {
        debugPrint('RestrictionEngine: Blocking $appPackage - ${decision.reason}');

        // Show overlay or blocking UI (Android specific)
        try {
          await _showBlockOverlay(appPackage, decision);
        } catch (e) {
          debugPrint('RestrictionEngine: Error showing block overlay: $e');
        }

        return false;
      }
    } catch (e) {
      debugPrint('RestrictionEngine: Error in onAppLaunchAttempt: $e');
      // Fail-safe: allow access if there's an error
      return true;
    }
  }

  /// Show blocking overlay (Android specific)
  /// This would invoke native code to show an overlay preventing app access
  Future<void> _showBlockOverlay(String appPackage, RestrictionDecision decision) async {
    // TODO: Implement native overlay via MethodChannelService
    // For now, just log the block
    debugPrint('RestrictionEngine: Would show overlay for $appPackage: ${decision.reason}');

    // Example of how this would be called:
    // await MethodChannelService.instance.showRestrictionOverlay(
    //   appPackage: appPackage,
    //   message: decision.reason,
    //   restrictionType: decision.type.name,
    // );
  }

  /// Update local usage cache (called periodically or on app focus change)
  void updateLocalUsage(String appPackage, int usageSec) {
    _localUsageCache[appPackage] = usageSec;
  }

  /// Sync local usage to shared quota
  Future<void> syncUsageToShared(String appPackage, int additionalMinutes) async {
    if (additionalMinutes <= 0) return;

    try {
      final success = await SyncService.instance.incrementUsage(
        appPackage,
        additionalMinutes,
      );

      if (success) {
        debugPrint('RestrictionEngine: Synced $additionalMinutes minutes for $appPackage');
      } else {
        debugPrint('RestrictionEngine: Failed to sync usage - quota exceeded');
      }
    } catch (e) {
      debugPrint('RestrictionEngine: Error syncing usage: $e');
    }
  }

  /// Force cache refresh
  Future<void> refreshCache() => _refreshCache();

  /// Clear all caches
  void clearCache() {
    _restrictionCache.clear();
    _groupCache.clear();
    _launchCountCache.clear();
    _localUsageCache.clear();
    _lastCacheRefresh = null;
    debugPrint('RestrictionEngine: Cache cleared');
  }

  /// Helper method to format TimeOfDay without context
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
