# iOS Native Integration Guide - Soft Lock Implementation

## Overview
iOS does not allow third-party apps to block system-level app access without Mobile Device Management (MDM) profiles. This guide covers the soft-lock approach for consumer devices and MDM options for enterprise deployment.

## Soft-Lock Strategy (Consumer Devices)

### How It Works
1. **In-App Awareness**: Show soft-lock overlays within the NLP-Digitox app
2. **Notifications**: Send reminders when restricted apps are opened
3. **Screen Time Integration**: Use Screen Time API (iOS 12+) for usage tracking
4. **Voluntary Compliance**: Rely on user commitment rather than hard enforcement

### Implementation Steps

#### 1. Screen Time API Integration

Add to your `ios/Runner/Info.plist`:
```xml
<key>NSScreenTimeUsageDescription</key>
<string>We need access to screen time data to help you manage your digital wellbeing</string>
<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>screen-time</string>
</array>
```

#### 2. Family Controls Framework (iOS 15+)

For parental control features:
```swift
import FamilyControls
import ManagedSettings

// Request authorization
AuthorizationCenter.shared.requestAuthorization { result in
    switch result {
    case .success:
        print("Family Controls authorized")
    case .failure(let error):
        print("Authorization failed: \(error)")
    }
}
```

#### 3. Soft-Lock Overlay

The Flutter `SoftLockOverlay` widget (in `lib/features/soft_lock/`) provides:
- Visual blocking overlay
- Motivational messaging
- Timer countdown for time-based restrictions
- Emergency unlock option

### Limitations
- ❌ Cannot prevent app launches at system level
- ❌ Cannot intercept home button or app switcher
- ❌ Cannot force-quit other apps
- ✅ Can track usage via Screen Time API
- ✅ Can show notifications
- ✅ Can provide in-app overlays

## MDM/Enterprise Deployment

### Mobile Device Management Setup

For schools, organizations, or strict parental control:

#### 1. Create MDM Profile

Use Apple Configurator or an MDM solution (Jamf, Intune, etc.) to:
- Restrict app installations
- Block specific apps by bundle ID
- Set screen time limits
- Enforce content filtering

#### 2. App Configuration

Create a configuration profile (`.mobileconfig` file):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>PayloadContent</key>
    <array>
        <dict>
            <key>PayloadType</key>
            <string>com.apple.applicationaccess</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
            <key>allowedApps</key>
            <array>
                <!-- List of allowed app bundle IDs -->
                <string>com.nlp.digitox</string>
            </array>
        </dict>
    </array>
    <key>PayloadDisplayName</key>
    <string>NLP-Digitox Restrictions</string>
    <key>PayloadIdentifier</key>
    <string>com.nlp.digitox.restrictions</string>
</dict>
</plist>
```

#### 3. Deployment Options

**Option A: Apple School Manager / Apple Business Manager**
- Distribute via VPP (Volume Purchase Program)
- Deploy configuration profiles
- Manage via MDM console

**Option B: Parent-Installed Profile**
- Email .mobileconfig file to parent
- Parent installs via Settings > General > Profiles
- Requires device passcode to remove

**Option C: Supervised Devices**
- Use Apple Configurator 2
- Supervise device (factory reset required)
- Full restriction capabilities

### Testing MDM Integration

1. Create test MDM profile with Apple Configurator
2. Install on test device
3. Verify restrictions are enforced
4. Test emergency unlock procedures
5. Validate with different iOS versions (15+, 16+, 17+)

## Hybrid Approach (Recommended)

Combine soft-lock with optional MDM for best user experience:

1. **Default (Soft-Lock)**: 
   - All users get motivational overlays
   - Notification reminders
   - Usage tracking

2. **Enhanced (MDM)**: 
   - Optional for users who want strict enforcement
   - Setup wizard guides parent through MDM installation
   - Requires separate parental consent

## Code Integration

### Flutter Side

```dart
import 'package:nlp_digitox/features/soft_lock/soft_lock_overlay.dart';

// Show soft lock when app restriction detected
void showSoftLockForApp(String packageName, String appName, String reason) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => SoftLockOverlay(
      appName: appName,
      packageName: packageName,
      reason: reason,
      onDismiss: () => Navigator.pop(context),
    ),
  );
}
```

### iOS Method Channel

For future native iOS implementation:

```swift
// In AppDelegate.swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "com.nlp.digitox/soft_lock",
            binaryMessenger: controller.binaryMessenger
        )
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "showSoftLock" {
                // Handle soft lock display
                result(true)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

## Future Enhancements

- Screen Time API integration for usage statistics
- Focus Mode integration (iOS 15+)
- Shortcuts app automation for custom workflows
- HealthKit integration for wellbeing metrics

## Support Resources

- [Apple Screen Time API](https://developer.apple.com/documentation/screentime)
- [Family Controls Framework](https://developer.apple.com/documentation/familycontrols)
- [MDM Protocol Reference](https://developer.apple.com/documentation/devicemanagement)
