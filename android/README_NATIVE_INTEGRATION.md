# Android Native Integration Guide - NLP-Digitox

This document describes the native Android components required for cross-device app locking, permission handling, and restriction overlays.

## Overview

The app uses native Android services and accessibility features to:
- Enforce app restrictions and quota limits
- Display overlay blocking UI when restrictions are triggered
- Track app usage and launch counts
- Manage system-level permissions

## Required Permissions

### AndroidManifest.xml

Add these permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- App Usage Tracking -->
<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" />

<!-- Accessibility Service for overlays and monitoring -->
<uses-permission android:name="android.permission.BIND_ACCESSIBILITY_SERVICE" />

<!-- Display overlay (for restriction messages) -->
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />

<!-- Notification access for app monitoring -->
<uses-permission android:name="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE" />

<!-- Device admin for policy manager features -->
<uses-permission android:name="android.permission.DEVICE_POWER" />

<!-- Exact alarms for restriction scheduling -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />

<!-- VPN service for DNS/internet filtering (optional) -->
<uses-permission android:name="android.permission.BIND_VPN_SERVICE" />

<!-- Read/Write settings -->
<uses-permission android:name="android.permission.READ_SETTINGS" />
<uses-permission android:name="android.permission.WRITE_SETTINGS" />

<!-- Do Not Disturb policy -->
<uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY" />

<!-- Query installed packages -->
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
```

## Required Services & Receivers

### Accessibility Service for Overlays

**File:** `android/app/src/main/java/com/nlp/digitox/services/FocusAccessibilityService.kt`

This service monitors app launches and displays restriction overlays. Placeholder provided below:

```kotlin
// PLACEHOLDER - Full implementation needed
// This service requires:
// 1. Monitor accessibility events for app launches
// 2. Display overlay when app restricted
// 3. Implement overlay UI for restriction messages
// 4. Handle back/home button interception
```

**AndroidManifest Entry:**
```xml
<service
    android:name=".services.FocusAccessibilityService"
    android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"
    android:exported="true">
    <intent-filter>
        <action android:name="android.accessibilityservice.AccessibilityService" />
    </intent-filter>
    <meta-data
        android:name="android.accessibilityservice"
        android:resource="@xml/accessibility_service_config" />
</service>
```

**Accessibility Service Config:** `android/app/src/main/res/xml/accessibility_service_config.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<accessibility-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:accessibilityEventTypes="typeWindowStateChanged|typeWindowContentChanged"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:accessibilityFlags="flagDefault|flagIncludeNotImportantViews"
    android:canPerformGestures="true"
    android:canRequestFilterKeyEvents="true"
    android:canRequestTouchExplorationMode="true"
    android:description="@string/accessibility_service_description"
    android:notificationTimeout="100" />
```

### Notification Listener Service

**AndroidManifest Entry:**
```xml
<service
    android:name=".services.NotificationListenerService"
    android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"
    android:exported="true">
    <intent-filter>
        <action android:name="android.service.notification.NotificationListenerService" />
    </intent-filter>
</service>
```

### Foreground Service for Tracking

**AndroidManifest Entry:**
```xml
<service
    android:name=".services.AppTrackingForegroundService"
    android:exported="false"
    android:foregroundServiceType="mediaProjection|packageUsageStats" />
```

**Service Permissions (API 31+):**
```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION" />
```

### Device Admin Receiver

**File:** `android/app/src/main/java/com/nlp/digitox/receivers/DeviceAdminReceiver.kt`

For advanced device policy features:

```kotlin
// PLACEHOLDER - Full implementation needed
// This receiver handles device policy events:
// 1. Lock device
// 2. Wipe cache/data
// 3. Set password policies
```

**AndroidManifest Entry:**
```xml
<receiver
    android:name=".receivers.DeviceAdminReceiver"
    android:description="@string/device_admin_description"
    android:exported="true"
    android:permission="android.permission.BIND_DEVICE_ADMIN">
    <intent-filter>
        <action android:name="android.app.action.DEVICE_ADMIN_ENABLED" />
    </intent-filter>
    <meta-data
        android:name="android.app.device_admin"
        android:resource="@xml/device_admin_policy" />
</receiver>
```

**Device Admin Policy:** `android/app/src/main/res/xml/device_admin_policy.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<device-admin xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-policies>
        <limit-password />
        <watch-login />
        <reset-password />
        <force-lock />
        <wipe-data />
        <set-global-proxy />
        <expire-password />
        <encrypted-storage />
        <disable-keyguard-features />
    </uses-policies>
</device-admin>
```

## MethodChannel Communication

### Flutter → Native

The app communicates with native services via MethodChannel: `com.nlp.digitox.methodchannel.fg`

**Key Methods:**

| Method | Purpose | Parameters | Returns |
|--------|---------|------------|---------|
| `getAndAskAccessibilityPermission` | Check/request accessibility permission | `askPermissionToo: bool` | `bool` |
| `getAndAskDisplayOverlayPermission` | Check/request overlay permission | `askPermissionToo: bool` | `bool` |
| `getAndAskUsageAccessPermission` | Check/request usage access | `askPermissionToo: bool` | `bool` |
| `getAndAskAdminPermission` | Check/request device admin | `askPermissionToo: bool` | `bool` |
| `showRestrictionOverlay` | Display restriction UI | `{appPackage, message}` | `bool` |
| `getAppsLaunchCount` | Get app launch counts | None | `Map<String, int>` |
| `getDeviceAppsInfo` | Get installed apps | None | `List<AppInfo>` |

## Overlay Implementation

### Blocking Overlay Activity

**File:** `android/app/src/main/java/com/nlp/digitox/activities/RestrictionOverlayActivity.kt`

This activity is displayed when an app is blocked. Key features:

```kotlin
// PLACEHOLDER - Implement:
// 1. Full-screen blocking activity
// 2. Show restriction reason (quota exceeded, time limit, cross-device lock)
// 3. Display appeal/override options (if emergency unlock available)
// 4. Intercept back button to prevent bypass
// 5. Intercept home button
// 6. Update via intent broadcasts for live messaging
```

**AndroidManifest Entry:**
```xml
<activity
    android:name=".activities.RestrictionOverlayActivity"
    android:excludeFromRecents="true"
    android:exported="false"
    android:noHistory="true"
    android:taskAffinity="com.nlp.digitox.overlay"
    android:theme="@style/OverlayTheme" />
```

**Overlay Theme:** `android/app/src/main/res/values/overlay_theme.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="OverlayTheme" parent="Theme.MaterialComponents.NoActionBar">
        <item name="android:windowBackground">@android:color/transparent</item>
        <item name="android:windowNoTitle">true</item>
        <item name="android:windowFullscreen">true</item>
        <item name="android:windowDrawsSystemBarBackgrounds">false</item>
    </style>
</resources>
```

## Cross-Device Lock Implementation

### Lock Heartbeat Service

For maintaining locks across device boundaries:

1. **Service State:** Serialize lock state to Firebase Realtime Database
2. **Refresh Mechanism:** Call `SyncService.refreshLockTTL()` every 2 minutes
3. **App Detection:** Use `AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED` to detect app launch
4. **Block Action:** Launch `RestrictionOverlayActivity` with restriction details

### Lock Flow

```
App Launch Attempt
    ↓
AccessibilityService intercepts event
    ↓
Check RestrictionEngine.canOpenApp(package)
    ↓
If blocked
    ├─→ Launch RestrictionOverlayActivity
    ├─→ Pass restriction details via intent
    └─→ Block app launch
Else
    ├─→ Acquire lock via SyncService.acquireLock()
    ├─→ Start heartbeat: SyncService.startLockHeartbeat()
    └─→ Allow app launch
```

## Permission Request Flow

### Critical Permissions (Recommended Order)

1. **Notification Permission** (Android 13+)
   - Used for onboarding notifications

2. **Usage Access Permission**
   - Required for app usage tracking
   - Shows system settings dialog

3. **Accessibility Permission**
   - Required for app launch interception
   - Shows accessibility settings

4. **Display Overlay Permission**
   - Required for restriction UI
   - Shows app info settings

5. **Device Admin Permission**
   - Optional: advanced features
   - Shows device admin request dialog

6. **DND Permission**
   - Optional: silence interruptions during focus

7. **Exact Alarm Permission** (Android 12+)
   - Optional: precision scheduling

### Permission Lifecycle

```
[Onboarding] → RequestAllCriticalPermissions()
                    ↓
              Permission Dialog (native)
                    ↓
              [User Grants/Denies]
                    ↓
              App Resumes (AppLifecycleState.resumed)
                    ↓
              PermissionNotifier.didChangeAppLifecycleState()
                    ↓
              Re-check specific permission via MethodChannel
                    ↓
              Update permissionProvider state
                    ↓
              UI reflects updated permission status
```

## Testing Checklist

- [ ] Accessibility permission request shows correctly
- [ ] Display overlay permission request shows correctly
- [ ] Device admin permission can be granted/revoked
- [ ] Usage access is obtainable
- [ ] Overlay activity displays on screen
- [ ] Overlay cannot be bypassed with back button
- [ ] Lock heartbeat maintains lock TTL
- [ ] App launch detection works in accessibility service
- [ ] Permission state updates on app resume
- [ ] Multiple apps can be tracked concurrently
- [ ] Cross-device lock blocks launch attempts from other devices

## Manifest Required Entries Summary

```xml
<manifest package="com.nlp.digitox">
    <!-- Permissions -->
    <uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" />
    <uses-permission android:name="android.permission.BIND_ACCESSIBILITY_SERVICE" />
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <uses-permission android:name="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE" />
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY" />
    <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />

    <application>
        <!-- Services -->
        <service android:name=".services.FocusAccessibilityService" ... />
        <service android:name=".services.NotificationListenerService" ... />
        <service android:name=".services.AppTrackingForegroundService" ... />

        <!-- Receivers -->
        <receiver android:name=".receivers.DeviceAdminReceiver" ... />

        <!-- Activities -->
        <activity android:name=".activities.RestrictionOverlayActivity" ... />

        <!-- Resources -->
        <meta-data android:name="android.accessibility_service" ... />
        <meta-data android:name="android.app.device_admin" ... />
    </application>
</manifest>
```

## Native Implementation Status

| Component | Status | Notes |
|-----------|--------|-------|
| FocusAccessibilityService | ⚠️ Placeholder | Needs full implementation for app monitoring |
| RestrictionOverlayActivity | ⚠️ Placeholder | Needs UI and back-button prevention |
| DeviceAdminReceiver | ⚠️ Placeholder | For advanced device policies |
| MethodChannel Handlers | ✅ Exists | `FgMethodCallHandler.kt` |
| Permission Helpers | ✅ Exists | `PermissionsHelper.kt` |
| Manifest Integration | ✅ Partial | Add missing service declarations |

## Next Steps for Complete Implementation

1. Implement `FocusAccessibilityService` with full event handling
2. Create `RestrictionOverlayActivity` with UI blocking
3. Implement `DeviceAdminReceiver` for device policies
4. Wire overlay display via `MethodChannelService`
5. Test with multiple apps and cross-device scenarios
6. Optimize heartbeat for battery efficiency
7. Add comprehensive error handling for all services

## Related Flutter Code

- `lib/core/services/method_channel_service.dart` - Flutter side of MethodChannel
- `lib/core/services/restriction_engine.dart` - Enforcement logic
- `lib/core/services/sync_service.dart` - Cross-device sync and locking
- `lib/providers/system/permissions_provider.dart` - Permission state management

## References

- [Android Accessibility Service Docs](https://developer.android.com/guide/topics/ui/accessibility/service)
- [Device Policy Manager](https://developer.android.com/reference/android/app/admin/DevicePolicyManager)
- [Notification Listener Service](https://developer.android.com/reference/android/service/notification/NotificationListenerService)
- [Android Themes Overlay](https://developer.android.com/guide/topics/ui/look-and-feel/themes-overlay)

