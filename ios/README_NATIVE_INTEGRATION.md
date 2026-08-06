# iOS Native Integration Guide - NLP-Digitox

This document describes the iOS implementation strategy, platform limitations, and MDM deployment guidelines for NLP-Digitox.

## Overview

iOS has significant platform limitations for app-level restriction enforcement compared to Android. The app implements a "soft-lock" UX strategy that respects iOS privacy and security constraints.

## iOS Limitations

### Hard Restrictions Not Available

Unlike Android, iOS does NOT provide:
- ❌ System-level app blocking without MDM
- ❌ Accessibility service equivalent
- ❌ Screen overlay for app launch interception
- ❌ System-level VPN or DNS filtering
- ❌ Device admin policies
- ❌ App usage statistics API (limited to screen time)

### What IS Available

- ✅ Screen Time framework (iOS 12+)
- ✅ MDM (Mobile Device Management) for enterprise
- ✅ App Groups for data sharing
- ✅ Background App Refresh controls
- ✅ App Shortcuts for automation
- ✅ HomeKit/Device management features
- ✅ WidgetKit for dashboard

## iOS Strategy: Soft-Lock UX

Since hard restrictions are not possible, NLP-Digitox on iOS uses a "soft-lock" approach:

### 1. In-App Soft-Lock

When user attempts to open restricted content in-app:

```
User action → Detect in app context
                ↓
         Check RestrictionEngine.canOpenApp()
                ↓
         If restricted:
           ├─ Show modal blocking UI
           ├─ Display reason (quota, cross-device lock)
           ├─ Offer emergency override
           └─ Log violation
         Else:
           ├─ Allow action
           └─ Track usage
```

### 2. Screen Time Integration

For apps on home screen that user tries to open:

```
User taps app on home screen
                ↓
         iOS attempts to launch app
                ↓
         App launches (we can't prevent this)
                ↓
         App contacts our backend/local state
                ↓
         If restricted, show splash screen:
           ├─ "This app is blocked"
           ├─ Display reason
           ├─ Show timer if time-limited
           └─ Offer emergency unlock
```

### 3. Cross-Device Coordination

Soft-lock checks sync state from Firebase:
- Primary device status
- Active lock status
- Shared quota usage
- User emergency credits

### 4. Dashboard & Reflection

iOS emphasizes positive reinforcement:
- Daily gratitude + reflection prompts
- Focus session completions
- Weekly/monthly reports with insights
- Achievement badges
- Streaks

## Implementation for iOS

### Swift API Stubs

**File:** `ios/Runner/Services/RestrictionSoftLockService.swift`

```swift
// PLACEHOLDER - Implement:
// 1. Query app usage from MethodChannel (Flutter)
// 2. Display soft-lock sheet modally
// 3. Track soft-block violations
// 4. Sync with backend for cross-device state
// 5. Handle emergency unlocks
```

**File:** `ios/Runner/UI/SoftLockViewController.swift`

```swift
// PLACEHOLDER - Implement:
// 1. UIViewController for blocking sheet
// 2. Display app icon, restriction reason
// 3. Show timer for time-limited apps
// 4. Emergency unlock button with authentication
// 5. Dismiss detection to prevent bypass
```

### MethodChannel (Objective-C/Swift)

**File:** `ios/Runner/GeneratedPluginRegistrant.swift`

Stub MethodChannel handlers for iOS:

```swift
// iOS MethodChannel handlers:
// 1. getSoftLockStatus(appPackage) -> bool
// 2. logSoftBlockEvent(appPackage, reason)
// 3. requestEmergencyUnlock(password, reason) -> bool
// 4. getSyncServiceState() -> CrossDeviceState
// 5. getScreenTimeStats() -> ScreenTimeData
```

### Privacy & User Consent

iOS demands transparent privacy practices:

```
App Privacy Policy must include:
├─ What data is collected (usage stats, app names)
├─ How data is used (local restrictions, Firebase sync)
├─ Data retention (local: permanent, Firebase: user-controlled)
├─ Cross-device sync opt-in
├─ Parental controls transparency
└─ User data deletion rights
```

### Screen Time Framework (Optional)

For compliance, enterprises can deploy via Screen Time:

```swift
// For enterprise deployment:
import DeviceCheck
import AppKit

// Limitations:
// - Only available on supervised devices
// - Requires MDM configuration
// - Cannot target specific apps easily
// - No real-time enforcement
```

### Widget Kit Dashboard

Create a widget showing:
- Daily usage summary
- Remaining quota for key apps
- Focus session timer
- Notes/reflections

```swift
// ios/Runner/Widgets/DailyUsageWidget.swift
// PLACEHOLDER - Implement daily widget with:
// 1. Top 3 most-used apps
// 2. Total screen time
// 3. Focus sessions completed
// 4. Next focus session time
```

## MDM Deployment (Enterprise)

For organizations requiring hard enforcement on iOS:

### ABM (Apple Business Manager)

1. **Enrollment**
   - Enterprise enrolls devices via ABM
   - MDM server pushes configuration profiles

2. **Configuration**
   ```xml
   <!-- Restrict app installation -->
   <dict>
       <key>AppInstallations</key>
       <array>
           <string>com.example.restrictedapp</string>
       </array>
   </dict>

   <!-- Enable Screen Time -->
   <dict>
       <key>ScreenTimeSettings</key>
       <dict>
           <key>DailyLimit</key>
           <integer>14400</integer> <!-- 4 hours in seconds -->
       </dict>
   </dict>
   ```

3. **MDM Server Integration**
   - Push restrictions to managed devices
   - Monitor compliance
   - Report usage statistics
   - Enforce updates

### Supervised Mode (Schools/Organizations)

In supervised mode, additional controls available:
- App installation restrictions
- Managed Open In
- Autonomous Single App Mode
- Device restrictions (camera, screenshots)

### Deployment Steps

```
1. Set up Apple School Manager or Apple Business Manager
2. Deploy NLP-Digitox via VPP (Volume Purchase Program)
3. Configure MDM profile with restrictions
4. Enroll devices (supervised or unsupervised)
5. Push soft-lock UX via app updates
6. Monitor compliance reports
```

## Testing Strategy for iOS

### Unit Tests

```swift
// Tests needed:
// 1. SoftLockService permission checks
// 2. Soft-block event logging
// 3. Cross-device state sync
// 4. Emergency unlock logic
// 5. Mock MethodChannel responses
```

### Integration Tests

```swift
// Manual testing:
// 1. Open restricted app → soft-lock sheet appears
// 2. Emergency unlock → works with correct password
// 3. Cross-device lock → prevents access from secondary device
// 4. Quota exceeded → shows countdown and reason
// 5. Switch to primary device → access granted
```

### Simulator vs Device

- Simulator: Limited to basic functionality
- Device: Full Screen Time integration and capabilities

## Code Structure Recommendations

```
ios/
├── Runner/
│   ├── GeneratedPluginRegistrant.swift
│   ├── Services/
│   │   ├── RestrictionSoftLockService.swift (PLACEHOLDER)
│   │   └── CrossDeviceSyncService.swift (PLACEHOLDER)
│   ├── UI/
│   │   ├── SoftLockViewController.swift (PLACEHOLDER)
│   │   └── BlockingSheetView.swift (PLACEHOLDER)
│   ├── Models/
│   │   ├── AppRestriction.swift
│   │   └── CrossDeviceState.swift
│   └── Widgets/
│       └── DailyUsageWidget.swift (PLACEHOLDER)
├── Info.plist (configuration)
└── README_NATIVE_INTEGRATION_IOS.md
```

## Flutter-to-iOS Communication

### MethodChannel Example

```dart
// Flutter side (lib/core/services/method_channel_service.dart)
Future<bool> getAndAskAccessibilityPermission({
  bool askPermissionToo = false
}) async =>
    await _methodChannel.invokeMethod(
      'getAndAskAccessibilityPermission',
      askPermissionToo,
    );

// iOS side (Swift)
// On iOS, this returns false (no accessibility service)
// and skips permission request
```

### Native Error Handling

```swift
// Handle MethodNotImplemented for iOS:
func dummyMethodToEnforceBundling() {
    // Ensures methods are available even if not fully implemented
    generatedChannel.invokeMethod("getAndAskAccessibilityPermission", arguments: nil)
    generatedChannel.invokeMethod("getSoftLockStatus", arguments: nil)
}
```

## Platform-Specific Considerations

| Feature | Android | iOS | Strategy |
|---------|---------|-----|----------|
| Hard app blocking | ✅ Yes | ❌ No | Use AccessibilityService; iOS uses soft-lock |
| Cross-device lock | ✅ Yes | ✅ Yes* | Firebase sync for both; enforcement differs |
| Quota tracking | ✅ Yes | ⚠️ Limited | Both use Firebase; iOS shows in-app only |
| Overlay UI | ✅ Yes | ❌ No | Android overlay; iOS modal sheet |
| Emergency unlock | ✅ Yes | ✅ Yes | Both support with password |
| Device restrictions | ✅ Yes | ⚠️ MDM only | Android: immediate; iOS: via MDM profile |

*iOS requires user cooperation; hard lock only via MDM

## Recommended Onboarding for iOS Users

```
iOS User Flow
└─ Onboarding explains soft-lock model
   ├─ "We can't block apps on iOS"
   ├─ "But we'll remind you when time's up"
   ├─ "Emergency unlock with password available"
   └─ "For hard blocking, ask your org about MDM"
```

## Data Privacy & GDPR Compliance

iOS implementation must highlight:
- All usage data stored locally or in user's Firebase project
- No personal data sold to third parties
- User can delete all data any time
- Cross-device sync is opt-in
- Family sharing is transparent

## Next Steps for iOS Implementation

1. Implement `RestrictionSoftLockService` with full state management
2. Create `SoftLockViewController` with native UI
3. Build `DailyUsageWidget` for dashboard
4. Test with multiple apps in restricted state
5. Implement emergency unlock with biometric auth
6. Create MDM deployment guide for enterprises
7. Add comprehensive logging for soft-block events

## Related Flutter Code

- `lib/core/services/method_channel_service.dart` - iOS method channel stubs
- `lib/core/services/sync_service.dart` - Cross-device sync (works on iOS)
- `lib/core/services/restriction_engine.dart` - In-app soft-lock logic (works on iOS)
- `lib/providers/system/permissions_provider.dart` - Permission mgmt (iOS-adapted)

## References

- [Apple Developer: ScreenTime Framework](https://developer.apple.com/documentation/screentime)
- [MDM Protocol Reference](https://developer.apple.com/business/documentation/MDM-Protocol-Reference.pdf)
- [Device Management Security](https://support.apple.com/en-us/HT207948)
- [App Privacy & Security Implementation](https://developer.apple.com/app-privacy-and-security/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios)

## Deployment Timeline

- **Phase 1 (MVP):** Soft-lock UX + Firebase sync
- **Phase 2 (v2):** Widget dashboard, biometric auth
- **Phase 3 (v3):** MDM deployment guide, enterprise features
- **Phase 4 (Enterprise):** Full MDM integration and supervised mode

---

**Note for Developers:** iOS implementation is significantly more limited than Android. Focus on excellent UX for soft-lock flows, transparency with users, and enterprise MDM guidance where applicable.

