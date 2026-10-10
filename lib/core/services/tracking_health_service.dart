// Copyright (c) 2026 NLP digitox

import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/models/tracking_health_model.dart';

/// Reads how healthy the background tracking pipeline has been.
///
/// Every value comes from the native side, which is the only place that can see
/// it: the gap log and the heartbeat are written by the keep-alive watchdog
/// (`KeepAliveHelper.tick` → `TrackingHealth.kt`), which keeps running when the
/// Dart isolate is gone.
///
/// Each source is read independently and its failure is swallowed. That is
/// deliberate — this is a diagnostics screen, and one unavailable probe must
/// not blank the whole card when the other two answered.
class TrackingHealthService {
  const TrackingHealthService();

  Future<TrackingHealth> read() async {
    return TrackingHealth(
      lastHeartbeatAt: await _readLastHeartbeatAt(),
      lastExitReason: await _readLastExitReason(),
      gaps: await _readGaps(),
    );
  }

  Future<DateTime?> _readLastHeartbeatAt() async {
    try {
      final heartbeatMs = await MethodChannelService.instance.getLastHeartbeatAt();
      if (heartbeatMs <= 0) return null;
      return DateTime.fromMillisecondsSinceEpoch(heartbeatMs);
    } catch (e) {
      debugPrint('TrackingHealthService: heartbeat read failed: $e');
      return null;
    }
  }

  Future<List<TrackingGap>> _readGaps() async {
    try {
      final rawJson = await MethodChannelService.instance.getTrackingGapsJson();
      return TrackingHealth.parseGaps(rawJson);
    } catch (e) {
      debugPrint('TrackingHealthService: gap log read failed: $e');
      return const [];
    }
  }

  /// How the OS says this process last ended. `USER_REQUESTED` beside a lost
  /// Accessibility grant is the force-stop case — the one thing the app cannot
  /// recover from by itself.
  Future<String?> _readLastExitReason() async {
    try {
      final diagnostics =
          await MethodChannelService.instance.getBackgroundDiagnostics();
      final reason = diagnostics['last_exit_reason'];
      if (reason is String && reason.isNotEmpty) return reason;
      return null;
    } catch (e) {
      debugPrint('TrackingHealthService: diagnostics read failed: $e');
      return null;
    }
  }
}
