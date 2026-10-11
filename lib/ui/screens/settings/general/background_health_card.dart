// Copyright (c) 2026 NLP digitox

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/core/utils/elapsed_time_format.dart';
import 'package:nlp_digitox/models/permissions_model.dart';
import 'package:nlp_digitox/models/tracking_health_model.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/providers/system/tracking_health_provider.dart';
import 'package:nlp_digitox/ui/common/status_dot.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';
import 'package:nlp_digitox/ui/screens/settings/general/background_health_rows.dart';

/// How long without a heartbeat counts as "tracking was down".
///
/// Mirrors `GAP_THRESHOLD_MS` in `TrackingHealth.kt`. The two have to agree:
/// the watchdog records a gap at exactly this age, so if this value were
/// smaller the card would cry wolf about outages the native side deliberately
/// does not count.
const Duration _kHeartbeatStaleAfter = Duration(minutes: 25);

/// The card that answers "why does tracking keep stopping, and what do I tap?".
///
/// Every warning here has a fix button beside it, because that is the only
/// reason the card exists. The Android side cannot be made unkillable — a
/// force-stop removes the Accessibility grant, the alarms and the service, and
/// nothing in the app survives that — so the honest product decision is to make
/// the remaining causes one tap away from being repaired and to say plainly
/// when the app could not see the day.
class BackgroundHealthCard extends ConsumerStatefulWidget {
  const BackgroundHealthCard({super.key});

  @override
  ConsumerState<BackgroundHealthCard> createState() =>
      _BackgroundHealthCardState();
}

class _BackgroundHealthCardState extends ConsumerState<BackgroundHealthCard> {
  /// True while a settings screen is being opened. A second tap while the first
  /// round trip is in flight is ignored rather than queueing another launch.
  bool _isBusy = false;

  /// Runs a permission/action call, then re-reads everything it could have
  /// changed: the user may have come back from Settings having granted it.
  Future<void> _run(Future<void> Function() action) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    try {
      await action();
    } catch (e) {
      debugPrint('BackgroundHealthCard: action failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open that setting: $e')),
        );
      }
    } finally {
      // No `return` here: a `finally` that returns would swallow whatever the
      // `catch` above just handled.
      if (mounted) setState(() => _isBusy = false);
    }

    // Deliberately outside the `finally`: the refresh is awaited, and letting
    // it throw there would replace the exception the `catch` already handled.
    await _refreshFromSystem();
  }

  /// Re-reads the permission flags and the native health snapshot.
  ///
  /// Both can have changed while a settings screen was open — the user may
  /// have granted the permission, or the service may have been rebound.
  Future<void> _refreshFromSystem() async {
    if (!mounted) return;
    final notifier = ref.read(permissionProvider.notifier);
    await notifier.fetchPermissionsStatus();
    // The await above can outlive the widget (Settings closed, screen popped);
    // touching `ref` after dispose throws.
    if (mounted) ref.invalidate(trackingHealthProvider);
  }

  Future<void> _recheck() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    await _refreshFromSystem();
    if (mounted) setState(() => _isBusy = false);
  }

  /// "Grant" when the OS grant is gone, "Resume" when it is still held but the
  /// service process is not running.
  ///
  /// The distinction matters: `askAccessibilityPermission` only opens Settings
  /// when the system list does not contain our component, so offering it for a
  /// merely-paused service would do nothing at all.
  Future<void> _fixAccessibility(PermissionsModel permissions) {
    final notifier = ref.read(permissionProvider.notifier);
    if (permissions.haveAccessibilityPermission) {
      return notifier.clearAccessibilityServicePausedFlag();
    }
    return notifier.askAccessibilityPermission();
  }

  /// Opens the manufacturer's auto-start / background screen. Reports back when
  /// the device has no such screen, so the user is not left guessing whether
  /// the tap registered.
  Future<void> _openManufacturerSettings() async {
    final opened =
        await MethodChannelService.instance.openOemBackgroundSettings();
    if (opened || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'This device has no separate auto-start screen. Use the guidance in '
          'this card instead.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionProvider);
    final healthAsync = ref.watch(trackingHealthProvider);

    return SurfaceCard(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _accessibilityRow(permissions),
          _batteryRow(permissions),
          _notificationRow(permissions),
          _exactAlarmRow(permissions),
          const Divider(height: Spacing.xl),
          _manufacturerRow(),
          _manufacturerGuidance(),
          const Divider(height: Spacing.xl),
          ..._facts(healthAsync),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _isBusy ? null : _recheck,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Re-check'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accessibilityRow(PermissionsModel permissions) {
    final needsResume = permissions.haveAccessibilityPermission &&
        (!permissions.isAccessibilityServiceActive ||
            permissions.isAccessibilityServicePaused);
    final isHealthy = permissions.haveAccessibilityPermission && !needsResume;

    return HealthActionRow(
      icon: Icons.accessibility_new,
      title: 'Accessibility service',
      status: _accessibilityStatus(permissions),
      kind: _accessibilityKind(permissions),
      fixLabel: permissions.haveAccessibilityPermission ? 'Resume' : 'Grant',
      onFix: isHealthy ? null : () => _fixAccessibility(permissions),
    );
  }

  String _accessibilityStatus(PermissionsModel permissions) {
    if (permissions.permissionFetchFailed) {
      return 'Could not read the current state. Try Re-check.';
    }
    if (!permissions.haveAccessibilityPermission) {
      return 'The grant is off. Android clears it when the app is '
          'force-stopped, so it has to be re-granted by hand.';
    }
    if (permissions.isAccessibilityServicePaused ||
        !permissions.isAccessibilityServiceActive) {
      return 'Granted, but the service is not running right now. Blocking is '
          'paused until it comes back.';
    }
    return 'Granted and running. Blocking and live tracking are working.';
  }

  StatusDotKind _accessibilityKind(PermissionsModel permissions) {
    if (permissions.permissionFetchFailed) return StatusDotKind.warn;
    if (!permissions.haveAccessibilityPermission) return StatusDotKind.bad;
    if (permissions.isAccessibilityServicePaused ||
        !permissions.isAccessibilityServiceActive) {
      return StatusDotKind.warn;
    }
    return StatusDotKind.good;
  }

  Widget _batteryRow(PermissionsModel permissions) {
    final exempt = permissions.haveIgnoreOptimizationPermission;
    return HealthActionRow(
      icon: Icons.battery_charging_full,
      title: 'Battery optimisation',
      status: exempt
          ? 'Exempt. Android will not doze the tracker away.'
          : 'Not exempt. Android can delay or stop background work, which is '
              'the usual cause of a quiet gap in tracking.',
      kind: exempt ? StatusDotKind.good : StatusDotKind.warn,
      fixLabel: 'Exempt',
      onFix: exempt
          ? null
          : () => _run(
                () => ref
                    .read(permissionProvider.notifier)
                    .askIgnoreBatteryOptimizationPermission(),
              ),
    );
  }

  Widget _notificationRow(PermissionsModel permissions) {
    final granted = permissions.haveNotificationPermission;
    return HealthActionRow(
      icon: Icons.notifications_active,
      title: 'Notifications',
      status: granted
          ? 'Allowed. Warnings and reminders can reach you.'
          : 'Blocked. You will not see a warning when tracking stops.',
      kind: granted ? StatusDotKind.good : StatusDotKind.bad,
      fixLabel: 'Allow',
      onFix: granted
          ? null
          : () => _run(
                () => ref
                    .read(permissionProvider.notifier)
                    .askNotificationPermission(),
              ),
    );
  }

  Widget _exactAlarmRow(PermissionsModel permissions) {
    final granted = permissions.haveAlarmsPermission;
    return HealthActionRow(
      icon: Icons.alarm,
      title: 'Exact alarms',
      status: granted
          ? 'Allowed. The keep-alive watchdog can run on time.'
          : 'Not allowed. The watchdog falls back to an inexact alarm, which '
              'Doze can postpone by up to about an hour.',
      kind: granted ? StatusDotKind.good : StatusDotKind.warn,
      fixLabel: 'Allow',
      onFix: granted
          ? null
          : () => _run(
                () => ref
                    .read(permissionProvider.notifier)
                    .askExactAlarmPermission(),
              ),
    );
  }

  Widget _manufacturerRow() {
    return HealthActionRow(
      icon: Icons.phone_android,
      title: 'Manufacturer background limits',
      status: 'Many makers stop apps that are not locked in recents. Open the '
          'maker\'s own screen and allow auto-start and background activity.',
      kind: StatusDotKind.warn,
      fixLabel: 'Open',
      onFix: () => _run(_openManufacturerSettings),
    );
  }

  Widget _manufacturerGuidance() {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.sm),
      child: StyledText(
        'Xiaomi: turn auto-start on, set battery saver to "No restrictions" '
        'and lock the app in recents.\n'
        'Realme / Oppo: turn auto-launch on and allow background activity.\n'
        'Vivo: allow high background power use and turn auto-start on.\n'
        'Samsung: remove the app from "Sleeping apps" and add it to '
        '"Never sleeping".',
        fontSize: 12,
        isSubtitle: true,
        height: 1.5,
      ),
    );
  }

  List<Widget> _facts(AsyncValue<TrackingHealth> healthAsync) {
    final health = healthAsync.valueOrNull;
    final now = DateTime.now();
    final outageToday = health?.gapTotalOn(now) ?? Duration.zero;
    final exitReason = health?.lastExitReason;
    // "USER_REQUESTED" is the force-stop signature: the user (or an OEM
    // cleaner) asked for it, and nothing in the app can survive it.
    final exitKind =
        exitReason != null && exitReason.startsWith('USER_REQUESTED')
            ? StatusDotKind.warn
            : StatusDotKind.good;

    return [
      HealthFactRow(
        label: 'Last keep-alive heartbeat',
        value: _heartbeatLabel(health, now),
        kind: _heartbeatKind(health, now),
      ),
      HealthFactRow(
        label: 'How the process last ended',
        value: exitReason ?? 'Not recorded',
        kind: exitKind,
      ),
      if (outageToday > Duration.zero)
        HealthFactRow(
          label: 'Tracking off today',
          value: formatDurationShort(outageToday),
          kind: StatusDotKind.warn,
        ),
      if (healthAsync.hasError)
        HealthFactRow(
          label: 'Health read',
          value: 'Could not be read',
          kind: StatusDotKind.warn,
        ),
      Padding(
        padding: const EdgeInsets.only(top: Spacing.sm),
        child: StyledText(
          'A gap means no process was running, so blocking and live tracking '
          'have holes in them. Screen-time totals come from Android itself and '
          'are unaffected.',
          fontSize: 11,
          isSubtitle: true,
          height: 1.4,
        ),
      ),
    ];
  }

  String _heartbeatLabel(TrackingHealth? health, DateTime now) {
    final at = health?.lastHeartbeatAt;
    if (at == null) return 'Never';
    return describeElapsed(at, now);
  }

  StatusDotKind _heartbeatKind(TrackingHealth? health, DateTime now) {
    final at = health?.lastHeartbeatAt;
    if (at == null) return StatusDotKind.warn;
    final age = now.difference(at);
    return age > _kHeartbeatStaleAfter ? StatusDotKind.warn : StatusDotKind.good;
  }
}
