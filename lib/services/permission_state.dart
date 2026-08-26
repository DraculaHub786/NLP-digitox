import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reactive flag for the one-time shorts-blocking accessibility permission
/// onboarding flow. Once the user has seen the full permission sheet
/// (tapped "Agree & Continue" or dismissed with "Not Now"), only a
/// lightweight re-enable banner is shown afterwards.
final permissionOnboardedProvider = FutureProvider<bool>((ref) {
  return PermissionState.hasCompletedOnboarding();
});

/// Persists whether the shorts-blocking accessibility permission onboarding
/// flow has been completed, so the full grant sheet never reappears for a
/// user who has already seen it once.
class PermissionState {
  static const _keyOnboarded = 'shorts_blocking_permission_onboarded';

  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboarded) ?? false;
  }

  static Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarded, true);
  }
}
