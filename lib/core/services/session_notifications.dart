// Copyright (c) 2026 NLP digitox

import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/constants/group_limits.dart';
import 'package:nlp_digitox/core/services/group_service.dart';
import 'package:nlp_digitox/core/services/notification_scheduler_service.dart';
import 'package:nlp_digitox/features/groups/group_schedule_format.dart';
import 'package:nlp_digitox/models/focus_group.dart';
import 'package:nlp_digitox/models/group_schedule_entry.dart';

/// One reminder the app intends to show before a scheduled group session.
///
/// A plain value so the decision of *which* reminders to keep can be tested
/// without a notification plugin, a database, or a clock.
@immutable
class GroupSessionReminder {
  /// The group the session belongs to.
  final String groupId;

  /// The group's name, used in the notification title.
  final String groupName;

  /// The schedule entry this reminder is for.
  final String entryId;

  /// What the planned session is called.
  final String title;

  /// When the planned session starts.
  final DateTime startsAt;

  /// When the reminder should fire — [startsAt] minus the lead time.
  final DateTime fireAt;

  const GroupSessionReminder({
    required this.groupId,
    required this.groupName,
    required this.entryId,
    required this.title,
    required this.startsAt,
    required this.fireAt,
  });

  /// Notification body text.
  String get body =>
      '$title — starts ${GroupScheduleFormat.relative(startsAt)}.';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupSessionReminder &&
          runtimeType == other.runtimeType &&
          groupId == other.groupId &&
          entryId == other.entryId &&
          fireAt == other.fireAt;

  @override
  int get hashCode => groupId.hashCode ^ entryId.hashCode ^ fireAt.hashCode;

  @override
  String toString() =>
      'GroupSessionReminder(groupId: $groupId, entryId: $entryId, '
      'fireAt: $fireAt)';
}

/// Turns scheduled group sessions into local notifications.
///
/// Deliberately *not* a second `FlutterLocalNotificationsPlugin`: the app has
/// exactly one, owned by [NotificationSchedulerService], and a second
/// `initialize()` would replace that service's tap handler. This service decides
/// which reminders should exist and hands them over to be scheduled.
///
/// Reminders are stored by the OS, so they fire while the app is closed — which
/// is the whole point. That also means they go stale: a session cancelled or
/// moved while the app was away still has its old alarm pending. Every sync
/// therefore clears the reminder range and re-schedules from the live schedule,
/// so the pending set is always derived from what the database currently says.
class SessionNotificationsService {
  SessionNotificationsService._();

  /// The production instance.
  static final SessionNotificationsService instance =
      SessionNotificationsService._();

  /// Whether a sync is in flight, so two triggers cannot interleave.
  bool _isSyncing = false;

  /// Picks the reminders worth scheduling, soonest first.
  ///
  /// Pure and static so it can be tested directly. The rules, in order:
  ///   * a session already past its start time is dropped — there is nothing
  ///     left to remind about;
  ///   * a reminder whose fire time has already passed is dropped too, because
  ///     the OS would either fire it immediately or discard it, and neither is
  ///     a reminder;
  ///   * reminders are ordered by fire time, so the soonest survive the cap;
  ///   * at most [limit] are kept, because each pending notification is an OS
  ///     alarm and an unbounded set is a battery problem.
  static List<GroupSessionReminder> selectReminders({
    required List<FocusGroup> groups,
    required Map<String, List<GroupScheduleEntry>> schedulesByGroup,
    required DateTime now,
    Duration lead = GroupLimits.reminderLead,
    int limit = GroupLimits.maxPendingReminders,
  }) {
    final reminders = <GroupSessionReminder>[];

    for (final group in groups) {
      final entries = schedulesByGroup[group.id];
      if (entries == null) continue;

      for (final entry in entries) {
        if (!entry.startsAt.isAfter(now)) continue;

        final fireAt = entry.startsAt.subtract(lead);
        if (!fireAt.isAfter(now)) continue;

        reminders.add(
          GroupSessionReminder(
            groupId: group.id,
            groupName: group.name,
            entryId: entry.id,
            title: entry.title,
            startsAt: entry.startsAt,
            fireAt: fireAt,
          ),
        );
      }
    }

    reminders.sort((a, b) => a.fireAt.compareTo(b.fireAt));
    if (reminders.length <= limit) return reminders;
    return reminders.sublist(0, limit);
  }

  /// Rebuilds every pending group reminder from live data.
  ///
  /// Safe to call often: it is cheap (one index read plus one schedule read per
  /// group) and fully idempotent, because the pending set is replaced rather
  /// than added to.
  Future<void> syncGroupReminders() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final groups = await GroupService.instance.getUserGroups();
      if (groups.isEmpty) {
        await NotificationSchedulerService.instance.cancelGroupReminders();
        return;
      }

      final schedules = <String, List<GroupScheduleEntry>>{};
      for (final group in groups) {
        schedules[group.id] = await GroupService.instance.getSchedule(group.id);
      }

      await _applyReminders(
        selectReminders(
          groups: groups,
          schedulesByGroup: schedules,
          now: DateTime.now(),
        ),
      );
    } catch (e) {
      // Reminders are a convenience: a failure here must never surface as a
      // broken group screen, and the next successful sync repairs the set.
      debugPrint('SessionNotificationsService: sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Drops every pending group reminder.
  ///
  /// Called on sign-out: a reminder for a group the next account cannot see
  /// would open a screen they have no access to.
  Future<void> cancelAllGroupReminders() async {
    try {
      await NotificationSchedulerService.instance.cancelGroupReminders();
    } catch (e) {
      debugPrint('SessionNotificationsService: cancel failed: $e');
    }
  }

  /// Replaces the pending set with [reminders].
  Future<void> _applyReminders(List<GroupSessionReminder> reminders) async {
    final scheduler = NotificationSchedulerService.instance;
    await scheduler.cancelGroupReminders();

    for (var slot = 0; slot < reminders.length; slot++) {
      final reminder = reminders[slot];
      try {
        await scheduler.scheduleGroupReminder(
          slot: slot,
          title: reminder.title,
          body: reminder.body,
          when: reminder.fireAt,
          groupId: reminder.groupId,
        );
      } catch (e) {
        // One failed alarm must not abandon the rest of the set.
        debugPrint(
          'SessionNotificationsService: could not schedule '
          '${reminder.entryId}: $e',
        );
      }
    }

    debugPrint(
      'SessionNotificationsService: ${reminders.length} reminder(s) pending',
    );
  }
}
