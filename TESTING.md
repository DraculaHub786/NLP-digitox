# Testing Guide - NLP-Digitox Task 5: Shared Quota, Primary Device & Lock Flows

## Overview
This document describes testing procedures for Task 5 implementation, which includes:
- Shared usage quota tracking across devices
- Primary device designation and claim/handoff flows
- Real-time locks with TTL and heartbeat refresh
- Cross-device quota and lock enforcement

## Unit Tests

### Running Unit Tests

Execute all service tests:
```bash
flutter test test/services/
```

Run specific service tests:
```bash
flutter test test/services/sync_service_test.dart
flutter test test/services/restriction_engine_test.dart
flutter test test/services/device_identity_test.dart
```

### Test Structure

#### SyncService Tests (`test/services/sync_service_test.dart`)

**Basic Functionality Group:**
- ✓ Singleton instance creation
- ✓ Initialization and multiple init() calls handling
- ✓ Quota stream listening
- ✓ Usage retrieval with default values
- ✓ Usage increment in stub mode
- ✓ Daily limit setting
- ✓ Device presence tracking
- ✓ Device inactive marking
- ✓ Daily usage reset
- ✓ Proper disposal and cleanup

**Primary Device Group:**
- `claimPrimaryDevice()`: Verify that a device can claim primary status
- `isPrimaryDevice()`: Check primary device status
- `releasePrimaryDevice()`: Release primary device status
- `listenPrimaryDevice()`: Stream of primary device changes
- `getAllDevices()`: Retrieve all devices for current user

**Lock Heartbeat Group:**
- `startLockHeartbeat()`: Start automatic lock TTL refresh
- `stopLockHeartbeat()`: Stop heartbeat for a specific app
- `stopLockHeartbeat() on non-existent app`: Graceful handling
- `multiple heartbeats`: Manage multiple concurrent heartbeats

**Shared Quota Workflow:**
- Set daily limits for apps
- Increment usage atomically
- Track usage across multiple apps
- Verify per-app isolation

**Lock Workflow:**
- Acquire locks
- Release locks
- Check lock status
- Test lock TTL refresh with heartbeat

#### RestrictionEngine Tests (`test/services/restriction_engine_test.dart`)

**Decision Making:**
- `RestrictionDecision.allow()`: Creates allow decision
- `RestrictionDecision.block()`: Creates block decision with reason

**Shared Quota Checks:**
- `canOpenApp()` respects shared quota
- `syncUsageToShared()` handles minute tracking
- Multiple concurrent restriction checks

**Cross-Device Lock Checks:**
- `canOpenApp()` checks for cross-device locks
- `onAppLaunchAttempt()` during lock scenarios
- Apps locked by other devices are properly blocked

**Complex Scenarios:**
- Unrestricted apps are always allowed
- Multiple concurrent app launch attempts
- Concurrent restriction checks across apps

## Integration Testing (Manual Multi-Device Testing)

### Prerequisites
- Two devices (physical or emulators) with same Firebase project
- Both devices logged in with same Google account
- Firebase Realtime Database properly configured

### Scenario 1: Shared Quota Decrement

1. **Setup:**
   - App 1 daily limit: 30 minutes
   - App 2 daily limit: 20 minutes

2. **Test on Device A:**
   - Open App 1 for 10 minutes
   - Wait for sync (observe logs for "incrementUsage")
   - Note usage on Device A dashboard

3. **Test on Device B:**
   - Open App 1
   - Verify remaining quota: 20 minutes (30 - 10)
   - Open App 1 for 15 minutes
   - Verify quota is now 5 minutes

4. **Back to Device A:**
   - App 1 now shows quota exceeded or near limit
   - Restriction prevents further access

### Scenario 2: Primary Device Designation

1. **Device A claims primary:**
   - Navigate to settings
   - Claim device as primary
   - Observe Firebase Realtime Database entry: `users/{userId}/primaryDevice = {deviceId_A}`

2. **Device B attempts claim:**
   - Try to claim as primary (should succeed, overriding A's claim)
   - Database updates: `primaryDevice = {deviceId_B}`
   - Device A is no longer primary

3. **Handoff:**
   - Device B releases primary status
   - Database entry removes or clears
   - Device A can claim again

### Scenario 3: Cross-Device Lock (TTL Refresh)

1. **Device A acquires lock:**
   - Open an app (lock auto-acquired with ~5 min TTL)
   - Keep app in foreground
   - Observe heartbeat refresh every 2 minutes (logs: "Refreshed lock TTL")
   - Lock expiry time extends continuously

2. **Device B attempts access:**
   - Try to open same app
   - Should be blocked with message: "App is being used on another device"
   - Restriction type: `crossDeviceLock`

3. **Device A closes app:**
   - Lock is released
   - Device B can now open app

4. **Device A background:**
   - Keep app open
   - Move to background
   - Heartbeat stops (or slows down)
   - After ~5 minutes, lock expires
   - Device B can now open app

### Scenario 4: Quota + Lock Combined

1. **Setup:**
   - Set App limit to 5 minutes
   - Device A claims primary

2. **Device A opens App:**
   - Lock acquired
   - Quota starts decrementing
   - Heartbeat maintains lock

3. **Device B attempts App:**
   - Blocked with "App is being used on another device"
   - (Or "Shared daily quota exceeded" if quota hit first)

4. **Device B tries different quota-limited App:**
   - If quota already near limit, blocked with quota message
   - Lock doesn't prevent this check

## Firebase Schema Verification

### Expected Data Structure

After completing Task 5, Firebase Realtime Database should contain:

```json
{
  "users": {
    "{userId}": {
      "usage": {
        "com.social.app": {
          "dailyMinutes": 45,
          "dailyLimit": 120,
          "lastReset": 1704067200000
        },
        "com.entertainment.app": {
          "dailyMinutes": 120,
          "dailyLimit": 180,
          "lastReset": 1704067200000
        }
      },
      "devices": {
        "{deviceId_A}": {
          "name": "Samsung Galaxy S21",
          "lastSeen": 1704153600000,
          "isPrimary": true,
          "isActive": true,
          "claimedAt": 1704150000000
        },
        "{deviceId_B}": {
          "name": "iPhone 13",
          "lastSeen": 1704153500000,
          "isPrimary": false,
          "isActive": false,
          "claimedAt": null
        }
      },
      "primaryDevice": "{deviceId_A}",
      "locks": {
        "com.social.app": {
          "lockedBy": "{deviceId_A}",
          "expiresAt": 1704153900000,
          "acquiredAt": 1704153600000
        }
      }
    }
  }
}
```

### Verification Checklist

- [ ] `usage/{appPackage}/dailyMinutes` increments atomically
- [ ] `usage/{appPackage}/dailyLimit` enforces maximum
- [ ] `devices/{deviceId}/isPrimary` reflects primary status
- [ ] `primaryDevice` references only one device
- [ ] `locks/{appPackage}/lockedBy` identifies lock holder
- [ ] `locks/{appPackage}/expiresAt` is future timestamp
- [ ] Lock entries are removed when released

## Debugging Tips

### Enable Debug Logging

The services use `debugPrint()` for logging. Enable verbose logging:

```bash
flutter run -v 2>&1 | grep -i "syncservice\|restrictionengine"
```

### Common Issues

1. **Firebase Not Configured**
   - Stubs will run, but cross-device features won't sync
   - Set up Firebase Realtime Database before production
   - See `// TODO: firebase` comments in code

2. **Device Not Registered**
   - Check device identity is initialized
   - Verify `DeviceIdentityService.instance.deviceId` is not null

3. **Locks Not Being Released**
   - Ensure app properly calls `SyncService.stopLockHeartbeat()`
   - Check app lifecycle handlers call `markDeviceInactive()`

4. **Quota Not Syncing**
   - Firebase Realtime Database must be accessible
   - `FirebaseAuthService.instance.userId` must be set
   - Usage increments are atomic via transactions

## Test Report Template

Use this template to document test results:

```markdown
## Test Execution Report - Task 5

**Date:** YYYY-MM-DD
**Tester:** [Your Name]
**Environment:** Android/iOS, Device/Emulator, Firebase Status

### Unit Tests
- [ ] SyncService basic functionality: PASS/FAIL
- [ ] SyncService primary device: PASS/FAIL
- [ ] SyncService lock heartbeat: PASS/FAIL
- [ ] SyncService shared quota workflow: PASS/FAIL
- [ ] SyncService lock workflow: PASS/FAIL
- [ ] RestrictionEngine decisions: PASS/FAIL
- [ ] RestrictionEngine shared quota: PASS/FAIL
- [ ] RestrictionEngine cross-device locks: PASS/FAIL

### Integration Tests
- [ ] Scenario 1 - Shared Quota Decrement: PASS/FAIL
- [ ] Scenario 2 - Primary Device Designation: PASS/FAIL
- [ ] Scenario 3 - Cross-Device Lock (TTL Refresh): PASS/FAIL
- [ ] Scenario 4 - Quota + Lock Combined: PASS/FAIL

### Firebase Verification
- [ ] Schema matches expected structure
- [ ] All data types correct
- [ ] Timestamps accurate
- [ ] Atomic transactions working

### Issues Found
- [Issue 1]: [Description]
- [Issue 2]: [Description]

### Recommendations
- [Recommendation 1]
- [Recommendation 2]
```

## Next Steps (Task 6+)

Once Task 5 is validated:
- [ ] Implement permissions & native integration (Task 6)
- [ ] Add content filtration primitives (Task 7)
- [ ] Implement on-device ML sentiment filter (Task 8)
- [ ] Build shared sessions & groups (Task 9)
- [ ] Add persona-based onboarding (Task 10)
- [ ] Finalize privacy & opt-in UI (Task 11)

## Related Files

- Core Implementation:
  - `lib/core/services/sync_service.dart` - Sync & quota management
  - `lib/core/services/restriction_engine.dart` - Enforcement logic
  - `lib/core/services/device_identity.dart` - Device identification

- Tests:
  - `test/services/sync_service_test.dart`
  - `test/services/restriction_engine_test.dart`
  - `test/services/device_identity_test.dart`

- Configuration:
  - `pubspec.yaml` - Dependencies (firebase_database, device_info_plus, etc.)

---

For questions or issues, see `AGENT_PROMPT.md` and `IMPLEMENTATION_PLAN.md`.
