
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';

/// Apps launch counts mapped to their package names provider
final appsLaunchCountProvider = FutureProvider.autoDispose<Map<String, int>>(
  (ref) async => await MethodChannelService.instance.getAppsLaunchCount(),
);
