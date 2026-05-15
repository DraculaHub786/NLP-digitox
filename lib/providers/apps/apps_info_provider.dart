
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/models/app_info.dart';

/// A state notifier provider that manages a map of Package and installed Android application's info.
final appsInfoProvider =
    AsyncNotifierProvider<AppsInfoNotifier, Map<String, AppInfo>>(() {
  return AppsInfoNotifier();
});

class AppsInfoNotifier extends AsyncNotifier<Map<String, AppInfo>> {
  @override
  Future<Map<String, AppInfo>> build() async {
    return await _fetchAppsInfo();
  }

  /// Fetches and updates the list of installed Android applications.
  Future<void> refreshAppsInfo() async =>
      state = AsyncData(await _fetchAppsInfo());

  /// Fetches installed apps info from the device.
  Future<Map<String, AppInfo>> _fetchAppsInfo() async {
    final appsList = await MethodChannelService.instance.fetchDeviceAppsInfo();
    return Map.fromEntries(appsList.map((e) => MapEntry(e.packageName, e)));
  }
}
