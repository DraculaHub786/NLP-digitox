# NLP-digitox — Master Fix Plan: Tamper Protection, Shared Sessions, Performance

Branch: `profilepic`. Every finding below was verified directly against the
real repo — git history for the deletions (commit `a8e926d`), live source
for the bugs. Nothing here is guessed.

---

# PART 1 — Restore Tamper Protection (Device Admin)

## 1.0 Root cause

Commit `a8e926d` ("New icong bugs and depreacted usage fixed") mixed the
icon-tree-shaking fix with an unrelated, accidental deletion of the entire
Device Admin / tamper-protection feature — both Dart and native Android.
Confirmed by diffing that exact commit. Two things were **not** deleted and
still exist today, which is what makes this a clean restore rather than a
rebuild: the `admin_description` string resource, and every localization
key the deleted UI used (`tamper_protection_tile_title`,
`permission_admin_title`, etc.) — all still present in `app_en.arb`.

## 1.1 Native — restore the two fully-deleted files

**New file:** `android/app/src/main/res/xml/digitox_admin_config.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>

<device-admin xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-policies>
        <force-lock />
    </uses-policies>
</device-admin>
```

**New file:** `android/app/src/main/java/com/nlp/digitox/receivers/DeviceAdminReceiver.kt`
```kotlin

package com.nlp.digitox.receivers

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent
import android.widget.Toast
import com.nlp.digitox.services.accessibility.DigitoxAccessibilityService
import com.nlp.digitox.services.accessibility.DigitoxAccessibilityService.Companion.ACTION_TAMPER_PROTECTION_CHANGED
import com.nlp.digitox.utils.Utils

/**
 * A DeviceAdminReceiver for handling device administration events for the Digitox app.
 */
class DeviceAdminReceiver : DeviceAdminReceiver() {
    override fun onEnabled(context: Context, intent: Intent) {
        Toast.makeText(context, "Tamper protection enabled", Toast.LENGTH_LONG).show()
        refreshWellbeingSettings(context)
        super.onEnabled(context, intent)
    }

    override fun onDisabled(context: Context, intent: Intent) {
        Toast.makeText(context, "Tamper protection disabled", Toast.LENGTH_LONG).show()
        refreshWellbeingSettings(context)
        super.onDisabled(context, intent)
    }

    private fun refreshWellbeingSettings(context: Context) {
        if (Utils.isServiceRunning(context, DigitoxAccessibilityService::class.java)) {
            val serviceIntent = Intent(
                context.applicationContext,
                DigitoxAccessibilityService::class.java
            ).setAction(ACTION_TAMPER_PROTECTION_CHANGED)

            context.startService(serviceIntent)
        }
    }
}
```
(`ACTION_TAMPER_PROTECTION_CHANGED` and its handler already exist in
`DigitoxAccessibilityService.kt` today — confirmed, this was never deleted —
so this file compiles against the current codebase as-is.)

## 1.2 `AndroidManifest.xml` — restore the receiver declaration

```xml
<!-- ADD back, in the <application> block, among the other <receiver> entries -->
<receiver
    android:name=".receivers.DeviceAdminReceiver"
    android:enabled="true"
    android:exported="false"
    android:label="@string/app_name"
    android:permission="android.permission.BIND_DEVICE_ADMIN">
    <meta-data
        android:name="android.app.device_admin"
        android:resource="@xml/digitox_admin_config" />

    <intent-filter>
        <action android:name="android.app.action.DEVICE_ADMIN_ENABLED" />
    </intent-filter>
</receiver>
```
Place it immediately before the existing `<receiver android:name=".receivers.DeviceBootReceiver" ...>` entry — that's exactly where it sat before deletion.

## 1.3 `PermissionsHelper.kt` — restore the permission check/request

```kotlin
// ADD back the import
import android.app.admin.DevicePolicyManager

// ADD back, inside object PermissionsHelper, before getAndAskAccessibilityPermission (or wherever fits)
/**
 * Checks if the device administration permission is granted and optionally asks for it if not granted.
 *
 * @param context          The application context used to check permissions and start activities.
 * @param askPermissionToo Whether to prompt the user to enable device administration permission if not granted.
 * @return True if device administration permission is granted, false otherwise.
 */
fun getAndAskAdminPermission(context: Context, askPermissionToo: Boolean): Boolean {
    val componentName = ComponentName(context, DeviceAdminReceiver::class.java)
    val devicePolicyManager =
        context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager

    if (devicePolicyManager.isAdminActive(componentName)) {
        return true
    }

    if (askPermissionToo) {
        try {
            val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
                .putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, componentName)
                .putExtra(
                    DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                    R.string.admin_description
                )
            context.startActivity(intent)
        } catch (e: ActivityNotFoundException) {
            Log.e(TAG, "getAndAskAdminPermission: Unable to open device ADMIN settings", e)
        }
    }
    return false
}
```
Also restore the import removed alongside it:
```kotlin
import com.nlp.digitox.receivers.DeviceAdminReceiver
```

## 1.4 `NewActivitiesLaunchHelper.kt` — restore the disable helper

```kotlin
// ADD back the imports
import android.app.admin.DevicePolicyManager
import com.nlp.digitox.receivers.DeviceAdminReceiver

// ADD back, inside object NewActivitiesLaunchHelper
/**
 * Deactivate the admin privileges.
 *
 * @param context The context to use for launching the activity.
 */
fun disableDeviceAdmin(context: Context) {
    try {
        val componentName = ComponentName(context, DeviceAdminReceiver::class.java)
        val devicePolicyManager =
            context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager

        if (devicePolicyManager.isAdminActive(componentName)) {
            devicePolicyManager.removeActiveAdmin(componentName)
        }
    } catch (e: Exception) {
        Log.e(TAG, "disableDeviceAdmin: Failed to deactivate admin", e)
        SharedPrefsHelper.insertCrashLogToPrefs(context, e)
    }
}
```

## 1.5 `FgMethodCallHandler.kt` — restore the four channel cases

```kotlin
// ADD back, alongside the other permission cases
"getAndAskAdminPermission" -> {
    result.success(
        PermissionsHelper.getAndAskAdminPermission(
            context,
            call.arguments() ?: false
        )
    )
}
```
```kotlin
// ADD back, alongside the other flag-read cases
"isDeviceAdminRevoked" -> {
    result.success(
        SharedPrefsHelper.getBoolean(
            context,
            KeepAliveHelper.PREF_KEY_DEVICE_ADMIN_REVOKED,
            false
        )
    )
}

"clearDeviceAdminRevokedFlag" -> {
    SharedPrefsHelper.putBoolean(
        context,
        KeepAliveHelper.PREF_KEY_DEVICE_ADMIN_REVOKED,
        false
    )
    result.success(true)
}
```
```kotlin
// ADD back, in the UTILS section
"disableDeviceAdmin" -> {
    NewActivitiesLaunchHelper.disableDeviceAdmin(context)
    result.success(true)
}
```

## 1.6 `KeepAliveHelper.kt` — restore the revocation-heartbeat monitoring

```kotlin
// ADD back, alongside the other PREF_KEY_* constants
// SharedPrefs key: set to true when Device Admin permission was previously
// granted but is now revoked (detected on keep-alive tick).
const val PREF_KEY_DEVICE_ADMIN_REVOKED = "device_admin_revoked"

// SharedPrefs key: tracks whether Device Admin was ever seen as active.
// Set once when admin is first detected as active; never cleared.
// Used to distinguish "never granted" from "was granted but revoked."
const val PREF_KEY_DEVICE_ADMIN_WAS_SEEN_ACTIVE = "device_admin_was_seen_active"
```
```kotlin
// ADD back, inside the keep-alive tick's try block, after the existing
// accessibility-service-paused check (Task C)
// ═══════════════════════════════════════════════════════════════════
// Task D: Device Admin revocation monitoring
// ═══════════════════════════════════════════════════════════════════
// Check if admin was previously granted but is now revoked by OEM.
// Uses two flags:
//   _WAS_SEEN_ACTIVE  → set once when admin is first detected active, never cleared
//   _REVOKED          → set when admin was active but no longer is
val isAdminActive = PermissionsHelper.getAndAskAdminPermission(context, false)

// If admin is active right now, note that we've seen it active at least once
if (isAdminActive) {
    if (!SharedPrefsHelper.getBoolean(context, PREF_KEY_DEVICE_ADMIN_WAS_SEEN_ACTIVE, false)) {
        SharedPrefsHelper.putBoolean(context, PREF_KEY_DEVICE_ADMIN_WAS_SEEN_ACTIVE, true)
    }
    // Clear any revocation flag
    if (SharedPrefsHelper.getBoolean(context, PREF_KEY_DEVICE_ADMIN_REVOKED, false)) {
        SharedPrefsHelper.putBoolean(context, PREF_KEY_DEVICE_ADMIN_REVOKED, false)
        Log.d(TAG, "Device Admin is active again — cleared revocation flag")
    }
} else {
    // Admin is not active. Flag as revoked only if we've ever seen it active before.
    val wasEverSeenActive = SharedPrefsHelper.getBoolean(
        context, PREF_KEY_DEVICE_ADMIN_WAS_SEEN_ACTIVE, false
    )
    if (wasEverSeenActive) {
        SharedPrefsHelper.putBoolean(context, PREF_KEY_DEVICE_ADMIN_REVOKED, true)
        Log.w(TAG, "Device Admin was previously enabled but is now inactive — flagging revocation")
    }
}
```

## 1.7 Two more native deletions the original session's summary missed

These two were also removed in the same commit but weren't mentioned in the
prior investigation — both are part of what actually makes tamper protection
*work* (blocking access to Settings while active), not just the toggle UI:

**`DeviceFeaturesManager.kt`** — restore admin-section detection:
```kotlin
// ADD back the import
import com.nlp.digitox.helpers.device.PermissionsHelper
```
```kotlin
// OLD (current)
            // Check for Accessibility section
            val isAccessibilitySectionOpen =
                node.findAccessibilityNodeInfosByText(context.getString(R.string.accessibility_description))
                        .isNotEmpty() ||
                        node.findAccessibilityNodeInfosByText(appName)
                            .any { it.text == appName }

            return isAccessibilitySectionOpen

// NEW (restored)
            // Check for Admin section
            val isAdminSectionOpen =
                node.findAccessibilityNodeInfosByViewId("com.android.settings:id/admin_name")
                    .firstOrNull()?.text == appName

            // Check for Accessibility section
            val isAccessibilitySectionOpen =
                node.findAccessibilityNodeInfosByText(context.getString(R.string.accessibility_description))
                        .isNotEmpty() ||
                        node.findAccessibilityNodeInfosByText(appName)
                            .any { it.text == appName }

            return (isAdminSectionOpen || isAccessibilitySectionOpen) &&
                    PermissionsHelper.getAndAskAdminPermission(context, false)
```

**`DigitoxAccessibilityService.kt`** — restore blocking access to Settings
while admin is active (this is the actual enforcement — without it, tamper
protection's toggle exists but the user could still freely open Settings
and revoke it):
```kotlin
// OLD (current)
            shortsPlatformPackages.clear()
            val pm = packageManager

            // Fetch installed browser packages

// NEW (restored)
            shortsPlatformPackages.clear()
            val pm = packageManager

            // Check admin and add settings to blocked packages
            if (PermissionsHelper.getAndAskAdminPermission(this, false)) {
                devicePlatformPackages.add(SETTINGS_PACKAGE)
            }

            // Fetch installed browser packages
```

## 1.8 Dart — model, service, provider, UI

**File:** `lib/models/permissions_model.dart`
```dart
// ADD back, as a field
/// Indicates whether the Admin permission is granted.
final bool haveAdminPermission;

// ADD back, in the const constructor
this.haveAdminPermission = true,

// ADD back, as a field
/// Indicates whether Device Admin permission was previously granted but has
/// been silently revoked by the OEM. Set by the keep-alive heartbeat on the
/// native side when it detects admin went from active to inactive.
/// When true, the UI should show a lightweight one-tap re-enable nudge.
final bool isDeviceAdminRevoked;

// ADD back, in the const constructor
this.isDeviceAdminRevoked = false,

// ADD back, in copyWith's parameter list
bool? haveAdminPermission,
bool? isDeviceAdminRevoked,

// ADD back, in copyWith's return
haveAdminPermission: haveAdminPermission ?? this.haveAdminPermission,
isDeviceAdminRevoked: isDeviceAdminRevoked ?? this.isDeviceAdminRevoked,
```

**File:** `lib/core/services/method_channel_service.dart`
```dart
// ADD back, in the PERMISSIONS section
/// Checks if the admin permission is granted and optionally asks for it.
///
/// Returns `true` if the permission is granted Otherwise, returns `false`.
Future<bool> getAndAskAdminPermission(
        {bool askPermissionToo = false}) async =>
    await _methodChannel.invokeMethod(
      'getAndAskAdminPermission',
      askPermissionToo,
    );

/// Checks whether Device Admin permission was previously granted but has been
/// silently revoked by the OEM (detected by the keep-alive heartbeat on the
/// native side). When true, the UI should show a lightweight one-tap re-enable
/// nudge instead of requiring the user to discover it on their own.
Future<bool> isDeviceAdminRevoked() async =>
    await _methodChannel.invokeMethod('isDeviceAdminRevoked') ?? false;

/// Clears the Device Admin revoked flag on the native side (called when user
/// taps the re-enable nudge and the permission check confirms it's active again,
/// or when the user explicitly dismisses the warning).
Future<void> clearDeviceAdminRevokedFlag() async =>
    await _methodChannel.invokeMethod('clearDeviceAdminRevokedFlag');

/// Disable device Admin if active.
Future<bool> disableDeviceAdmin() async =>
    await _methodChannel.invokeMethod('disableDeviceAdmin');
```

**File:** `lib/providers/system/permissions_provider.dart`

Add `haveAdminPermission:` and `isDeviceAdminRevoked:` entries to **both**
places `fetchPermissionsStatus()`-style state gets rebuilt (the initial
fetch and the app-resume re-check — two near-identical blocks):
```dart
haveAdminPermission: await _safeGetPermission(
  () => MethodChannelService.instance.getAndAskAdminPermission(),
  'admin',
),
```
```dart
isDeviceAdminRevoked: await _safeGetPermission(
  () => MethodChannelService.instance.isDeviceAdminRevoked(),
  'device admin revoked',
),
```
In `requestAllCriticalPermissions()`, add back (this repo already has a
newer Exact Alarms step from an earlier fix — insert admin alongside it,
order doesn't matter relative to that one):
```dart
await askAdminPermission();
await Future.delayed(500.ms);
```
Add back the three methods:
```dart
/// Requests the Admin permission and updates the internal state.
Future<void> askAdminPermission() async {
  await MethodChannelService.instance
      .getAndAskAdminPermission(askPermissionToo: true);
}

/// Request the device to disable admin if already enabled
Future<void> disableAdminPermission() async {
  try {
    await MethodChannelService.instance.disableDeviceAdmin();
    await Future.delayed(500.ms);
    state = state.copyWith(
      haveAdminPermission: await _safeGetPermission(
        () => MethodChannelService.instance.getAndAskAdminPermission(),
        'admin',
      ),
    );
  } catch (e) {
    debugPrint('PermissionNotifier: Error disabling admin permission: $e');
  }
}

/// Clears the Device Admin revoked flag and updates state.
/// Called from the UI when user taps the re-enable nudge.
Future<void> clearDeviceAdminRevokedFlag() async {
  try {
    await MethodChannelService.instance.clearDeviceAdminRevokedFlag();
    state = state.copyWith(
      isDeviceAdminRevoked: false,
      haveAdminPermission: await _safeGetPermission(
        () => MethodChannelService.instance.getAndAskAdminPermission(),
        'admin',
      ),
    );
  } catch (e) {
    debugPrint('PermissionNotifier: Error clearing admin revoked flag: $e');
  }
}
```

**New file:** `lib/ui/permissions/admin_permission_tile.dart`
```dart

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/core/database/adapters/time_of_day_adapter.dart';
import 'package:nlp_digitox/core/enums/item_position.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/providers/system/parental_controls_provider.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/dialogs/confirmation_dialog.dart';
import 'package:nlp_digitox/ui/permissions/accessibility_permission_card.dart';
import 'package:nlp_digitox/ui/permissions/permission_sheet.dart';
import 'package:nlp_digitox/ui/transitions/default_hero.dart';

class AdminPermissionTile extends ConsumerWidget {
  const AdminPermissionTile({super.key});

  void _toggleTamperProtection(
    BuildContext context,
    WidgetRef ref,
    bool isAdminEnabled,
    TimeOfDayAdapter uninstallWindowTime,
  ) async {
    /// Ask accessibility permission if not allowed
    if (!ref.read(permissionProvider).haveAccessibilityPermission) {
      const AccessibilityPermissionCard()
          .showAccessibilityPermissionSheet(context, ref);
      return;
    }

    if (isAdminEnabled) {
      /// User wants to Disable
      if (ref
          .read(parentalControlsProvider.notifier)
          .isBetweenUninstallWindow) {
        ref.read(permissionProvider.notifier).disableAdminPermission();
      } else {
        context.showSnackAlert(
          context.locale.permission_admin_snack_alert,
        );
      }
    } else {
      /// Confirm
      final isConfirm = await showConfirmationDialog(
        context: context,
        heroTag: HeroTags.tamperProtectionTileTag,
        icon: FluentIcons.shield_keyhole_20_filled,
        title: context.locale.tamper_protection_tile_title,
        info: context.locale.tamper_protection_confirmation_dialog_info,
        positiveLabel: context.locale.permission_button_grant_permission,
      );

      await Future.delayed(400.ms);
      if (!isConfirm || !context.mounted) return;

      /// User wants to Enable
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => PermissionSheet(
          icon: FluentIcons.shield_keyhole_20_filled,
          title: context.locale.permission_admin_title,
          description: context.locale.permission_admin_info,
          onTapGrantPermission: () {
            Navigator.of(sheetContext).maybePop();
            ref.read(permissionProvider.notifier).askAdminPermission();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final haveAdminPermission =
        ref.watch(permissionProvider.select((v) => v.haveAdminPermission));
    final haveAccessibilityPermission = ref
        .watch(permissionProvider.select((v) => v.haveAccessibilityPermission));

    final uninstallWindowTime = ref
        .watch(parentalControlsProvider.select((v) => v.uninstallWindowTime));

    return DefaultHero(
      tag: HeroTags.tamperProtectionTileTag,
      child: DefaultListTile(
        position: ItemPosition.mid,
        switchValue: haveAdminPermission && haveAccessibilityPermission,
        leadingIcon: FluentIcons.shield_keyhole_20_regular,
        titleText: context.locale.tamper_protection_tile_title,
        subtitleText: context.locale.tamper_protection_tile_subtitle,
        onPressed: () => _toggleTamperProtection(
          context,
          ref,
          haveAdminPermission,
          uninstallWindowTime,
        ),
      ),
    );
  }
}
```

**File:** `lib/ui/screens/parental_controls/parental_controls_screen.dart`

Restore the two imports:
```dart
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/permissions/admin_permission_tile.dart';
```
Restore the local var in `build()`:
```dart
final isAdminEnabled =
    ref.watch(permissionProvider.select((v) => v.haveAdminPermission));
```
Restore the tile, right before the "Uninstall window" `SliverToBoxAdapter`:
```dart
/// Tamper protection
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
    child: const AdminPermissionTile(),
  ),
),
```
Restore the guard inside the uninstall-window tile's `onTap`, right before
the `showCustomTimePickerDialog(...)` call:
```dart
if (isAdminEnabled &&
    !ref
        .read(parentalControlsProvider.notifier)
        .isBetweenUninstallWindow) {
  context.showSnackAlert(
    context.locale.permission_admin_snack_alert,
  );
  return;
}
```

## 1.9 Verification

- [ ] `flutter analyze` — no errors from the restored files.
- [ ] Parental Controls screen shows "Tamper protection" tile again.
- [ ] Enabling it opens the real Android "Activate device admin app?" system
      dialog, and once granted, the app cannot be uninstalled/force-stopped
      outside the configured uninstall window.
- [ ] Opening Settings → Apps while tamper protection is active is blocked
      by the accessibility service (confirms 1.7's restoration, not just
      the toggle).
- [ ] Manually revoking admin from a device admin list (simulating OEM
      revocation) shows the "revoked" nudge on next keep-alive tick.

---

# PART 2 — Shared Sessions: fix the Create button (never loads)

## 2.0 Root cause — confirmed

**File:** `lib/providers/session_provider.dart`
```dart
class CreateSessionNotifier extends StateNotifier<AsyncValue<SharedSession>> {
  final SessionService _sessionService;

  CreateSessionNotifier(this._sessionService) : super(const AsyncValue.loading());
```
The notifier starts in `AsyncValue.loading()` **before any action is ever
taken**. The Create button:
```dart
onPressed: createState.isLoading ? null : _submit,
```
is therefore `null` (disabled) the instant the create-session sheet opens —
`createState.isLoading` is already `true` with nothing running. This is
exactly "the option to create never loaded" — it looks perpetually stuck,
because it is.

## 2.1 Fix

```dart
// OLD
class CreateSessionNotifier extends StateNotifier<AsyncValue<SharedSession>> {
  final SessionService _sessionService;

  CreateSessionNotifier(this._sessionService) : super(const AsyncValue.loading());

// NEW
class CreateSessionNotifier extends StateNotifier<AsyncValue<SharedSession?>> {
  final SessionService _sessionService;

  // Starts as idle data (null), not loading — loading should only begin
  // once the user actually taps Create. Starting in .loading() disabled
  // the Create button from the moment the sheet opened, since the button
  // is gated on `createState.isLoading`.
  CreateSessionNotifier(this._sessionService) : super(const AsyncValue.data(null));
```
```dart
// File: lib/providers/session_provider.dart — update the provider's generic too
// OLD
final createSessionProvider = StateNotifierProvider.autoDispose<CreateSessionNotifier, AsyncValue<SharedSession>>((ref) {

// NEW
final createSessionProvider = StateNotifierProvider.autoDispose<CreateSessionNotifier, AsyncValue<SharedSession?>>((ref) {
```
Everywhere else `createSessionProvider`'s data is consumed (e.g. to read the
created session's ID after success), it already goes through
`AsyncValue.guard`/`.value`, so the nullable type only requires a null check
at the one or two places that unwrap the successful result — check
`createState.value?.id` (or equivalent) rather than assuming non-null.

## 2.2 Verification

- [ ] Open the create-session sheet — the Create button should be enabled
      immediately, not greyed out/spinning.
- [ ] Submit — button shows a spinner only while the actual `createSession`
      call is in flight, then either navigates on success or shows an error.

---

# PART 3 — Shared Sessions: wire `SessionSettings` into real enforcement

*(This was designed in an earlier pass in this conversation and has not
been applied yet — included here so this file is the single complete
reference. Skip if already applied.)*

## 3.0 What this connects

`SessionSettings` (`sharedDailyLimit`, `focusApps`, `blockedApps`) is fully
modeled and stored in Firebase RTDB, but nothing reads it back into the
app's actual blocking mechanism. Real blocking is driven by
`FocusProfile.distractingApps`, sent to native via
`MethodChannelService.updateFocusSession()`.

## 3.1 `FocusModeNotifier` — apply + restore

**File:** `lib/providers/focus/focus_mode_provider.dart`
```dart
// ADD import
import 'package:nlp_digitox/models/shared_session_model.dart';

// ADD field
FocusProfile? _previousProfileBeforeSharedSession;

// ADD methods
Future<void> startSessionFromSharedSettings(SessionSettings settings) async {
  _previousProfileBeforeSharedSession = state.focusProfile;

  state = state.copyWith(
    focusProfile: state.focusProfile.copyWith(
      distractingApps:
          settings.blockedApps ?? state.focusProfile.distractingApps,
      sessionDuration:
          settings.sharedDailyLimit ?? state.focusProfile.sessionDuration,
    ),
  );
  _updateFocusProfileInDb();

  await startNewSession();
}

Future<void> endSharedSession() async {
  if (state.activeSession.value != null) {
    await giveUpOrFinishFocusSession(
      isTheSessionSuccessful: true,
      isFiniteSession: state.activeSession.value!.durationSecs > 0,
    );
  }

  if (_previousProfileBeforeSharedSession != null) {
    state = state.copyWith(
      focusProfile: _previousProfileBeforeSharedSession!,
    );
    _updateFocusProfileInDb();
    _previousProfileBeforeSharedSession = null;
  }
}

bool get isInSharedSessionFocus => _previousProfileBeforeSharedSession != null;
```

## 3.2 UI hook

**File:** `lib/features/shared_sessions/sessions_list_screen.dart`, inside
`SessionDetailScreen`:
```dart
Consumer(
  builder: (context, ref, _) {
    final isInSharedFocus =
        ref.watch(focusModeProvider.notifier).isInSharedSessionFocus;
    final settings = session.settings;

    if (isInSharedFocus) {
      return OutlinedButton.icon(
        onPressed: () => ref.read(focusModeProvider.notifier).endSharedSession(),
        icon: const Icon(Icons.stop_circle_outlined),
        label: const Text('Stop Focusing With This Group'),
      );
    }

    return FilledButton.icon(
      onPressed: settings == null
          ? null
          : () {
              ref.read(focusModeProvider.notifier)
                  .startSessionFromSharedSettings(settings);
              Navigator.of(context).pushNamed(AppRoutes.activeSessionPath);
            },
      icon: const Icon(Icons.play_arrow),
      label: const Text('Start Focusing With This Group'),
    );
  },
),
```

## 3.3 Decide semantics before shipping

`blockedApps` maps directly onto the existing blocklist mechanism above with
zero native changes. `focusApps` as an allowlist ("only these apps are
usable") has no native support today — that's separate scope if wanted.

---

# PART 4 — Performance: startup sequencing + resource leaks

## 4.0 Root cause — confirmed: 16 sequential awaits at every app start

**File:** `lib/initializer.dart`, `initializeServicesAndSchedules()` — every
one of these currently runs one after another, even though most are
independent of each other:
```
fetchAppsRestrictions → updateAppRestrictions → updateInternetBlockedApps
→ fetchRestrictionGroups → updateRestrictionsGroups
→ loadBedtimeSchedule → updateBedtimeSchedule
→ loadWellBeingSettings → updateWellBeingSettings
→ loadNotificationSettings → updateNotificationSettings
→ SessionService.init()
→ ProductivityNotificationService.initialize()
→ NotificationSchedulerService.initialize() → updateAllSchedules
→ ProductivityResetService.initialize()
→ LeaderboardService: checkAndResetStreakIfNeeded → evaluateAndUpdateStreak → markActive
```
Real dependencies: each "fetch X then push X to native" pair is internally
sequential (can't push what hasn't been fetched), and `notificationSettings`
is used by two different calls. But the four fetch→push pairs are
independent *of each other*, `SessionService.init()`/
`ProductivityNotificationService.initialize()`/
`ProductivityResetService.initialize()` don't depend on any DB read here,
and the Leaderboard chain (which does have to stay internally sequential —
check-and-reset must happen before evaluate, which must happen before
mark-active) doesn't depend on any of the above either.

## 4.1 Fix — group into `Future.wait` batches

**File:** `lib/initializer.dart`
```dart
// OLD
static Future<void> initializeServicesAndSchedules() async {
  final startTimeStamp = DateTime.now();

  final dynamicDao = DriftDbService.instance.driftDb.dynamicRecordsDao;
  final uniqueDao = DriftDbService.instance.driftDb.uniqueRecordsDao;

  /// fetch app restrictions
  var appRestrictions = await dynamicDao.fetchAppsRestrictions();
  final internetBlockedApps = appRestrictions
      .where((e) => !e.canAccessInternet)
      .map((e) => e.appPackage)
      .toList();

  /// filter out restrictions
  appRestrictions.removeWhere(
    (e) =>
        e.timerSec <= 0 &&
        e.periodDurationInMins <= 0 &&
        e.launchLimit <= 0 &&
        e.associatedGroupId == null,
  );

  /// update tracker service
  await MethodChannelService.instance.updateAppRestrictions(appRestrictions);

  /// update vpn service
  await MethodChannelService.instance
      .updateInternetBlockedApps(internetBlockedApps);

  /// Update restriction groups
  final restrictionGroups = await dynamicDao.fetchRestrictionGroups();
  await MethodChannelService.instance
      .updateRestrictionsGroups(restrictionGroups);

  /// Fetch and update bedtime routine
  final bedtime = await uniqueDao.loadBedtimeSchedule();
  await MethodChannelService.instance.updateBedtimeSchedule(bedtime);

  /// Fetch and update wellbeing
  final wellbeing = await uniqueDao.loadWellBeingSettings();
  await MethodChannelService.instance.updateWellBeingSettings(wellbeing);

  /// Fetch and update notification settings
  final notificationSettings = await uniqueDao.loadNotificationSettings();
  await MethodChannelService.instance
      .updateNotificationSettings(notificationSettings);

  /// Initialize shared-session service (Firebase RTDB backed; safe in stub
  /// mode when Firebase/auth unavailable). Must be ready before any screen
  /// can create/join a shared focus session.
  await SessionService.instance.init();

  /// Initialize productivity notification service
  await ProductivityNotificationService.instance.initialize();

  /// Initialize notification scheduler service
  await NotificationSchedulerService.instance.initialize();
  await NotificationSchedulerService.instance.updateAllSchedules(notificationSettings.schedules);

  /// Initialize productivity reset service for daily resets and notifications
  await ProductivityResetService.instance.initialize();

  /// Check and reset leaderboard streak if user was inactive
  await LeaderboardService.instance.checkAndResetStreakIfNeeded();

  /// Evaluate streak based on today's screen time (< 8hrs = +1, > 8hrs = reset)
  await LeaderboardService.instance.evaluateAndUpdateStreak();

  /// Stamp lastActiveAt so streak inactivity detection has a real user-activity signal
  await LeaderboardService.instance.markActive();

  /// Start periodic monitor for daily streak evaluation (runs every 6 hours)
  LeaderboardService.instance.startDailyStreakEvaluation();

  debugPrint(
    "All necessary services and schedules are initialized and it took ${DateTime.now().difference(startTimeStamp).inMilliseconds}ms.",
  );
}

// NEW
static Future<void> initializeServicesAndSchedules() async {
  final startTimeStamp = DateTime.now();

  final dynamicDao = DriftDbService.instance.driftDb.dynamicRecordsDao;
  final uniqueDao = DriftDbService.instance.driftDb.uniqueRecordsDao;

  // The four "fetch settings, then push to native" pairs below are
  // independent of each other — each pair has an internal fetch→push
  // dependency, but nothing depends on another pair's result — so they run
  // concurrently instead of one after another. Same for the three service
  // .initialize() calls, and SessionService.init(), none of which touch
  // the DAOs above at all.
  await Future.wait([
    _syncAppRestrictions(dynamicDao),
    _syncRestrictionGroups(dynamicDao),
    _syncBedtimeSchedule(uniqueDao),
    _syncWellbeingSettings(uniqueDao),
    _syncNotificationSettings(uniqueDao),
    SessionService.instance.init(),
    ProductivityNotificationService.instance.initialize(),
    ProductivityResetService.instance.initialize(),
  ]);

  /// Leaderboard chain has a real internal ordering dependency (reset must
  /// happen before evaluate, which must happen before mark-active), so it
  /// stays sequential — but it doesn't depend on anything in the batch
  /// above, so it could also just as validly run before/alongside it. It's
  /// placed after here only so `startDailyStreakEvaluation()` reliably
  /// starts from a freshly-evaluated state.
  await LeaderboardService.instance.checkAndResetStreakIfNeeded();
  await LeaderboardService.instance.evaluateAndUpdateStreak();
  await LeaderboardService.instance.markActive();
  LeaderboardService.instance.startDailyStreakEvaluation();

  debugPrint(
    "All necessary services and schedules are initialized and it took ${DateTime.now().difference(startTimeStamp).inMilliseconds}ms.",
  );
}

static Future<void> _syncAppRestrictions(dynamic dynamicDao) async {
  var appRestrictions = await dynamicDao.fetchAppsRestrictions();
  final internetBlockedApps = appRestrictions
      .where((e) => !e.canAccessInternet)
      .map((e) => e.appPackage)
      .toList();

  appRestrictions.removeWhere(
    (e) =>
        e.timerSec <= 0 &&
        e.periodDurationInMins <= 0 &&
        e.launchLimit <= 0 &&
        e.associatedGroupId == null,
  );

  await Future.wait([
    MethodChannelService.instance.updateAppRestrictions(appRestrictions),
    MethodChannelService.instance.updateInternetBlockedApps(internetBlockedApps),
  ]);
}

static Future<void> _syncRestrictionGroups(dynamic dynamicDao) async {
  final restrictionGroups = await dynamicDao.fetchRestrictionGroups();
  await MethodChannelService.instance.updateRestrictionsGroups(restrictionGroups);
}

static Future<void> _syncBedtimeSchedule(dynamic uniqueDao) async {
  final bedtime = await uniqueDao.loadBedtimeSchedule();
  await MethodChannelService.instance.updateBedtimeSchedule(bedtime);
}

static Future<void> _syncWellbeingSettings(dynamic uniqueDao) async {
  final wellbeing = await uniqueDao.loadWellBeingSettings();
  await MethodChannelService.instance.updateWellBeingSettings(wellbeing);
}

static Future<void> _syncNotificationSettings(dynamic uniqueDao) async {
  final notificationSettings = await uniqueDao.loadNotificationSettings();
  await Future.wait([
    MethodChannelService.instance.updateNotificationSettings(notificationSettings),
    NotificationSchedulerService.instance.initialize().then(
      (_) => NotificationSchedulerService.instance.updateAllSchedules(notificationSettings.schedules),
    ),
  ]);
}
```
*(The `dynamic` DAO parameter types are a quick way to keep this snippet
self-contained — replace with the actual `DynamicRecordsDao`/
`UniqueRecordsDao` types from `app_database.dart` for a real PR; Dart's
analyzer will tell you the exact names if they differ from what Part A of
the wellbeing-report plan assumed.)*

## 4.2 Root cause — `SessionService` leaks timers/listeners forever

**File:** `lib/core/services/session_service.dart` — `release()` exists,
cancels all presence heartbeat `Timer`s and RTDB listener subscriptions, and
clears the session cache — but is **never called anywhere** in the app,
confirmed by a repo-wide search. Every session a user has ever joined keeps
its 30-second heartbeat timer and live listener running for the entire
process lifetime, including after sign-out.

## 4.3 Fix — call `release()` on sign-out

**File:** `lib/core/services/firebase_auth_service.dart`
```dart
// OLD
Future<void> signOut() async {
  try {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
    debugPrint('User signed out');
  } catch (e) {
    debugPrint('Sign out error: $e');
    throw Exception('Failed to sign out. Please try again.');
  }
}

// NEW
Future<void> signOut() async {
  try {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
      // Cancels every shared-session presence heartbeat Timer and RTDB
      // listener — without this, they leak for the rest of the process
      // lifetime (including for whoever signs in next in the same app
      // session), since nothing else ever calls SessionService.release().
      SessionService.instance.release(),
    ]);
    debugPrint('User signed out');
  } catch (e) {
    debugPrint('Sign out error: $e');
    throw Exception('Failed to sign out. Please try again.');
  }
}
```
Add the import if not already present:
```dart
import 'package:nlp_digitox/core/services/session_service.dart';
```

## 4.4 Root cause — `getUserSessions()` N+1 sequential fetch

**File:** `lib/core/services/session_service.dart`
```dart
// OLD
final sessions = <SharedSession>[];

for (final sessionId in sessionIds) {
  final session = await getSession(sessionId);
  if (session != null && session.isActive) {
    sessions.add(session);
  }
}

// NEW
final fetched = await Future.wait(
  sessionIds.map((id) => getSession(id)),
);
final sessions = fetched
    .whereType<SharedSession>()
    .where((s) => s.isActive)
    .toList();
```
For a user in a handful of sessions this is a small win; it becomes a real
one if `getUserSessions()` is ever called for someone in dozens.

## 4.5 Verification

- [ ] Compare the `debugPrint` startup-time log before/after — should drop
      meaningfully (exact amount depends on device/network, but the batched
      version can't be slower, only faster or equal).
- [ ] Sign out, then check (via a debug log or breakpoint) that
      `SessionService`'s internal timer/listener maps are empty afterward.
- [ ] Sign out and back in as a different account in the same app session —
      confirms no leftover heartbeat timers from the previous account are
      still firing.

---

# PART 5 — Performance: stacked `BackdropFilter` blur (touch lag)

*(Also designed earlier in this conversation, included here for
completeness — skip if already applied.)*

## 5.0 Root cause

Five `BackdropFilter` blur layers render simultaneously on most top-level
screens: `TreatedBackgroundImage`'s background (sigma 16) + 3 decorative
orbs (sigma 8 each), plus `GlassNavBar`'s persistent bottom-nav blur (sigma
12) — and because `ScaffoldShell` sets `extendBody: true`, that last one is
re-blurring live scrolling content every frame, not a static background.
Each `BackdropFilter` forces a `SaveLayer` + real blur pass every frame —
this is a well-documented, expensive pattern, and having 5 stacked on the
most-visited screens is a credible, direct cause of dropped frames, which
is what reads as "laggy, late to respond to touch."

## 5.1 Remove the 3 orb blurs — free, zero visual loss

**File:** `lib/ui/common/treated_background_image.dart`
```dart
// OLD
class _Orb extends StatelessWidget {
  final double size;
  final Color color;

  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: const SizedBox.shrink(),
      ),
    );
  }
}

// NEW
class _Orb extends StatelessWidget {
  final double size;
  final Color color;

  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    // No BackdropFilter: the RadialGradient already fades to fully
    // transparent at the edge, which reads as "soft" on its own. Three of
    // these were stacking on every screen using TreatedBackgroundImage —
    // removing them is a pure win with no visual difference.
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
```

## 5.2 Pre-blur the background image instead of blurring it live

**Offline, one-time:**
```bash
magick assets/backgrounds/bg_light.jpg -blur 0x16 assets/backgrounds/bg_light_blurred.jpg
magick assets/backgrounds/bg_dark.jpg  -blur 0x16 assets/backgrounds/bg_dark_blurred.jpg
```

**File:** `lib/ui/common/treated_background_image.dart`
```dart
// OLD
Image.asset(
  isDark ? 'assets/backgrounds/bg_dark.jpg' : 'assets/backgrounds/bg_light.jpg',
  key: ValueKey(isDark),
  fit: BoxFit.cover,
),

BackdropFilter(
  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
  child: const ColoredBox(color: Colors.transparent),
),

// NEW
// Pre-blurred at build time instead of blurred live every frame — the
// image never changes or moves, so there is no reason to pay a per-frame
// SaveLayer + blur cost for it.
Image.asset(
  isDark ? 'assets/backgrounds/bg_dark_blurred.jpg' : 'assets/backgrounds/bg_light_blurred.jpg',
  key: ValueKey(isDark),
  fit: BoxFit.cover,
),
```
(Delete the `BackdropFilter` block entirely; register the two new assets in
`pubspec.yaml`.)

## 5.3 Nav bar blur — cheaper + isolated

**File:** `lib/ui/common/glass_nav_bar.dart`
```dart
// OLD
child: ClipRRect(
  borderRadius: BorderRadius.circular(Radii.xl),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
    child: Container(

// NEW
child: RepaintBoundary(
  child: ClipRRect(
    borderRadius: BorderRadius.circular(Radii.xl),
    child: BackdropFilter(
      // Lowered 12→8 (cost scales with sigma); RepaintBoundary isolates
      // this layer's repaints from unrelated slide/animation work in the
      // surrounding tree.
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
```
(Close the added `RepaintBoundary(` with a matching `)` at the same nesting
level the old `BackdropFilter`'s wrapper closed at.)


## 5.5 Verification

- [ ] `flutter run --profile`, open the Performance Overlay, scroll a long
      list (Notes/Habits) before and after — raster-thread time per frame
      should drop noticeably after 5.1+5.2 alone.
- [ ] Confirm background still looks correct in light/dark mode with the
      pre-blurred assets.

---

# Full file list (all parts)

**New files**
- `android/app/src/main/res/xml/digitox_admin_config.xml`
- `android/app/src/main/java/com/nlp/digitox/receivers/DeviceAdminReceiver.kt`
- `lib/ui/permissions/admin_permission_tile.dart`

**Edited — Part 1 (tamper protection)**
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/java/com/nlp/digitox/helpers/device/PermissionsHelper.kt`
- `android/app/src/main/java/com/nlp/digitox/helpers/device/NewActivitiesLaunchHelper.kt`
- `android/app/src/main/java/com/nlp/digitox/FgMethodCallHandler.kt`
- `android/app/src/main/java/com/nlp/digitox/helpers/KeepAliveHelper.kt`
- `android/app/src/main/java/com/nlp/digitox/services/accessibility/DeviceFeaturesManager.kt`
- `android/app/src/main/java/com/nlp/digitox/services/accessibility/DigitoxAccessibilityService.kt`
- `lib/models/permissions_model.dart`
- `lib/core/services/method_channel_service.dart`
- `lib/providers/system/permissions_provider.dart`
- `lib/ui/screens/parental_controls/parental_controls_screen.dart`

**Edited — Part 2 (create-session bug)**
- `lib/providers/session_provider.dart`

**Edited — Part 3 (enforcement wiring)**
- `lib/providers/focus/focus_mode_provider.dart`
- `lib/features/shared_sessions/sessions_list_screen.dart`

**Edited — Part 4 (startup + leak performance)**
- `lib/initializer.dart`
- `lib/core/services/firebase_auth_service.dart`
- `lib/core/services/session_service.dart`

**Edited — Part 5 (blur performance)**
- `lib/ui/common/treated_background_image.dart`
- `lib/ui/common/glass_nav_bar.dart`
- `lib/ui/common/scaffold_shell.dart` (optional)