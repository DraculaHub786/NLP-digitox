# Background Persistence & Permission Fixes

## Priority Issues Found

### Issue 1: Services stop when app is closed from background
- ✅ `MindfulTrackerService.stopIfNoUsage()` kills service when idle → **FIXED**: service is now persistent START_STICKY
- ✅ `MindfulVpnService` also stops when no blocked apps → **FIXED**: passthrough VPN mode keeps it alive
- ✅ `FgMethodCallHandler.dispose()` unbinds ALL services on activity destroy → **FIXED**: fresh handler recreated instead
- ✅ No reconnection logic when activity restarts → **FIXED**: `ensureAllServicesRunning()` in onStart()

### Issue 2: Shorts/accessibility permission resets on re-open
- ✅ `PermissionNotifier` only re-checks last asked permission → **FIXED**: all 10 permissions re-checked on resume
- ✅ No persistent cache of permission state in SharedPrefs → **FIXED**: settings restored via `restoreAllSettingsOnReconnect()`
- ✅ When app is killed, method channel handler resets → **FIXED**: handler recreated on activity restart
- ✅ Accessibility service config depends on Flutter to push settings → **FIXED**: re-pushed from SharedPrefs on reconnect

### Issue 3: No persistent data collection when app backgrounded
- ✅ `LaunchTrackingManager` stops when tracker service stops → **FIXED**: tracker service never stops
- ✅ No heartbeat/keepalive mechanism → **FIXED**: services are START_STICKY + self-restart in onDestroy()
- ✅ Midnight reset and other scheduled tasks stop working → **FIXED**: boot receiver starts services directly

## Fix Implementation Steps

- ✅ **Fix 1: Make MindfulTrackerService persistent**
  - Changed to always return `START_STICKY`
  - Removed `stopIfNoUsage()` - service never self-stops
  - Added self-restart in `onDestroy()` to recover from system kills
  - Starts foreground notification once and keeps it

- ✅ **Fix 2: Make MindfulVpnService persistent**
  - Changed to always return `START_STICKY`
  - Added passthrough VPN mode (when no blocked apps, still runs)
  - Removed all `stopAndDisposeService()` calls on non-fatal errors
  - Added auto-retry on VPN connection failure
  - Added self-restart in `onDestroy()`

- ✅ **Fix 3: Reconnect services on activity restart**
  - Added `ensureAllServicesRunning()` to FgMethodCallHandler
  - MainActivity now calls it in `onStart()` every time activity resumes
  - Also re-binds to notification and focus services

- ✅ **Fix 4: Fix PermissionNotifier to re-check ALL permissions**
  - `didChangeAppLifecycleState()` now calls `recheckAllPermissions()` instead of only checking last asked
  - On every resume from background, all 10 permission types are re-fetched
  - Accessibility/shorts blocking permission no longer resets on re-open

- ✅ **Fix 5: Cache & restore settings persistently across restarts**
  - Added `restoreAllSettingsOnReconnect()` to FgMethodCallHandler
  - Re-pushes wellbeing settings via SharedPrefs to trigger accessibility service reload
  - Re-pushes app restrictions and internet blocked apps
  - Added `getSetWellBeingSettingsAsJsonString()` helper to SharedPrefsHelper

- ✅ **Fix 6: Keep FgMethodCallHandler alive across activity restarts**
  - `MainActivity.onDestroy()` now creates a fresh handler instead of calling `dispose()`
  - All service connection state survives activity recreation

- ✅ **Fix 7: DeviceBootReceiver restores all services on boot**
  - Now directly starts `MindfulTrackerService` foreground service on boot
  - Also directly starts `MindfulVpnService` if internet blocking had been configured
  - Still runs Flutter-side initialization via WorkManager for DB/notifications

- ✅ **Fix 8: Settings restored on every service reconnect**
  - `ensureAllServicesRunning()` calls `restoreAllSettingsOnReconnect()` automatically
  - Accessibility service re-reads shorts/feature blocking from SharedPrefs
  - Tracker service re-reads app restrictions from SharedPrefs

## Files Modified

| File | Change |
|------|--------|
| `MainActivity.kt` | Added `onStart()` with `ensureAllServicesRunning()`, fixed `onDestroy()` to not dispose handler |
| `FgMethodCallHandler.kt` | Added `ensureAllServicesRunning()`, `restoreAllSettingsOnReconnect()` |
| `MindfulTrackerService.kt` | Persistent `START_STICKY`, removed `stopIfNoUsage`, self-restart on destroy |
| `RestrictionManager.kt` | Removed `stopIfNoUsage` callback dependency |
| `MindfulVpnService.kt` | Persistent `START_STICKY`, passthrough VPN, auto-retry on failure |
| `DeviceBootReceiver.kt` | Directly starts tracker + VPN foreground services on boot |
| `SharedPrefsHelper.kt` | Added `getSetWellBeingSettingsAsJsonString()` method |
| `permissions_provider.dart` | Re-checks ALL 10 permissions on resume, not just last asked |
