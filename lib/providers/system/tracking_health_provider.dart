// Copyright (c) 2026 NLP digitox

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/tracking_health_service.dart';
import 'package:nlp_digitox/models/tracking_health_model.dart';

/// The service behind [trackingHealthProvider]. Split out so a test can supply
/// its own reader without touching the method channel.
final trackingHealthServiceProvider = Provider<TrackingHealthService>(
  (ref) => const TrackingHealthService(),
);

/// A snapshot of the background-tracking health, for the Settings card.
///
/// `autoDispose` because it makes three native round trips: it should stop the
/// moment the card leaves the screen. The card's refresh action is
/// `ref.invalidate(trackingHealthProvider)`.
final trackingHealthProvider =
    FutureProvider.autoDispose<TrackingHealth>((ref) async {
  return ref.watch(trackingHealthServiceProvider).read();
});
