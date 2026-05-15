
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';

/// Short content's screen time in SECONDS provider
final shortsScreenTimeProvider = FutureProvider.autoDispose<int>(
  (ref) async => await MethodChannelService.instance.getShortsScreenTimeSec(),
);
