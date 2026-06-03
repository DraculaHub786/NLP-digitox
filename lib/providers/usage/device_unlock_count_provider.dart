import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';

final deviceUnlockCountProvider = FutureProvider.autoDispose<int>(
  (ref) => MethodChannelService.instance.getDeviceUnlockCount(),
);