# iOS MDM Integration Guide

This document explains how to deploy NLP-Digitox with Mobile Device Management (MDM) for enterprise-grade iOS app restriction enforcement.

---

## Overview

iOS does not allow third-party apps to programmatically block other apps due to platform security restrictions. However, for enterprise and organizational deployments, you can achieve hard enforcement through:

1. **Apple Screen Time API** (limited, family-focused)
2. **Mobile Device Management (MDM)** (enterprise-grade)
3. **Supervised Device Mode** (full control)

This guide focuses on **MDM deployment** for organizations that need strict app blocking on iOS.

---

## Limitations on Standard iOS Devices

On consumer iOS devices (non-supervised), the app can only provide:

- **Soft-lock overlays** (in-app blocking UI that can be dismissed)
- **Usage tracking and analytics**
- **Notifications and reminders**
- **Focus mode suggestions**

For true enforcement, you need MDM or device supervision.

---

## MDM Deployment Options

### Option 1: Apple Business Manager + MDM Server

**Best for:** Organizations with 10+ devices

**Requirements:**
- Apple Business Manager account
- MDM server (Jamf, Microsoft Intune, VMware Workspace ONE, SimpleMDM, etc.)
- Supervised iOS devices (iOS 13+)

**Steps:**

1. **Enroll in Apple Business Manager**
   - Visit [business.apple.com](https://business.apple.com)
   - Register your organization
   - Add devices to Apple Business Manager

2. **Set up MDM server**
   - Choose an MDM provider (Jamf, Intune, etc.)
   - Configure MDM server with Apple Business Manager
   - Create device enrollment profiles

3. **Configure Restrictions Profile**

   Create a configuration profile with the following restrictions:

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
               <key>PayloadIdentifier</key>
               <string>com.nlp.digitox.restrictions</string>
               <key>PayloadUUID</key>
               <string>UNIQUE-UUID-HERE</string>
               <key>PayloadDisplayName</key>
               <string>NLP-Digitox App Restrictions</string>
               
               <!-- Block specific apps -->
               <key>blacklistedAppBundleIDs</key>
               <array>
                   <string>com.facebook.Facebook</string>
                   <string>com.instagram.Instagram</string>
                   <string>com.twitter.twitter</string>
                   <string>com.tiktok.TikTok</string>
                   <!-- Add more bundle IDs as needed -->
               </array>
               
               <!-- Allow only specific apps (if using whitelist mode) -->
               <key>whitelistedAppBundleIDs</key>
               <array>
                   <string>com.apple.mobilephone</string>
                   <string>com.apple.MobileSMS</string>
                   <string>com.nlp.digitox</string>
                   <!-- Add approved apps -->
               </array>
           </dict>
       </array>
       <key>PayloadDisplayName</key>
       <string>NLP-Digitox Restrictions</string>
       <key>PayloadIdentifier</key>
       <string>com.nlp.digitox.profile</string>
       <key>PayloadType</key>
       <string>Configuration</string>
       <key>PayloadUUID</key>
       <string>UNIQUE-UUID-HERE</string>
       <key>PayloadVersion</key>
       <integer>1</integer>
   </dict>
   </plist>
   ```

4. **Deploy NLP-Digitox via MDM**
   - Upload the app IPA to your MDM server
   - Create app deployment policy
   - Push to enrolled devices

5. **Configure Dynamic Restrictions**
   - Use MDM API to update restrictions based on NLP-Digitox settings
   - Sync restriction changes from Firebase to MDM

### Option 2: Apple Configurator (Small Scale)

**Best for:** Schools or small organizations (1-10 devices)

**Requirements:**
- Mac computer
- Apple Configurator 2 app
- USB cable for device connection

**Steps:**

1. Install Apple Configurator 2 from Mac App Store
2. Connect iOS device via USB
3. Supervise the device (requires device wipe)
4. Create and apply restriction profile
5. Install NLP-Digitox app

---

## Integration with NLP-Digitox

### Server-Side Integration

To sync NLP-Digitox restrictions with your MDM:

```dart
// Example: Push restrictions to MDM when user changes settings
import 'package:http/http.dart' as http;

class MDMIntegrationService {
  static const String _mdmApiUrl = 'https://your-mdm-server.com/api';
  static const String _apiKey = 'YOUR_MDM_API_KEY';

  Future<void> updateDeviceRestrictions({
    required String deviceId,
    required List<String> blockedAppBundleIds,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_mdmApiUrl/devices/$deviceId/restrictions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'blacklistedAppBundleIDs': blockedAppBundleIds,
          'effectiveFrom': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('MDM restrictions updated successfully');
      } else {
        debugPrint('MDM update failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('MDM integration error: $e');
    }
  }
}
```

### Firebase Cloud Function for MDM Sync

Deploy a Cloud Function to sync restrictions:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

exports.syncRestrictionsToMDM = functions.firestore
  .document('users/{userId}/restrictions/{restrictionId}')
  .onWrite(async (change, context) => {
    const userId = context.params.userId;
    const restriction = change.after.data();

    if (!restriction) return; // Deletion

    // Get user's device info
    const deviceDoc = await admin.firestore()
      .collection('users').doc(userId)
      .collection('devices').get();

    for (const device of deviceDoc.docs) {
      const deviceData = device.data();
      if (deviceData.platform === 'ios' && deviceData.mdmEnrolled) {
        // Push to MDM
        await axios.post(`${process.env.MDM_API_URL}/restrictions`, {
          deviceId: deviceData.mdmDeviceId,
          restrictions: restriction.blockedApps,
        }, {
          headers: {
            'Authorization': `Bearer ${process.env.MDM_API_KEY}`,
          },
        });
      }
    }
  });
```

---

## Screen Time API Integration (Alternative)

For family-focused deployments, you can use Apple's Screen Time API:

```swift
// iOS Native Code (AppDelegate.swift or similar)
import FamilyControls
import ManagedSettings

class ScreenTimeManager {
    static let shared = ScreenTimeManager()
    private let center = AuthorizationCenter.shared
    
    func requestAuthorization() async throws {
        try await center.requestAuthorization(for: .individual)
    }
    
    func blockApps(_ bundleIds: [String]) {
        let store = ManagedSettingsStore()
        let applications = bundleIds.compactMap { ApplicationToken(bundleId: $0) }
        
        store.shield.applications = Set(applications)
        store.shield.applicationCategories = .all(except: .health)
    }
}
```

**Note:** Screen Time API requires user authorization and cannot be enforced silently.

---

## Supervised Device Mode

### What is Supervision?

Device supervision gives organizations full control over iOS devices, including:
- Silent app installation/removal
- Non-removable restrictions
- Remote management
- Advanced configuration options

### How to Supervise Devices

**During Setup:**
1. Use Apple Configurator or MDM enrollment
2. Device will be wiped and enrolled as supervised

**For Existing Devices:**
1. Backup device data
2. Wipe device
3. Restore via Apple Configurator with supervision

---

## Best Practices

1. **Test on a Single Device First**
   - Verify restrictions work as expected
   - Test emergency unlock scenarios

2. **Provide Escape Hatch**
   - Always include a way for users to contact IT support
   - Consider time-based temporary unlocks for emergencies

3. **Communicate with Users**
   - Explain why restrictions are in place
   - Provide clear documentation

4. **Monitor Compliance**
   - Track device enrollment status
   - Alert IT when devices become non-compliant

5. **Regular Updates**
   - Keep restriction profiles updated
   - Sync with latest app versions

---

## Troubleshooting

### Issue: Restrictions not applying

**Solution:**
- Verify device is supervised
- Check MDM profile installation status
- Ensure bundle IDs are correct (case-sensitive)

### Issue: Users can remove restrictions

**Solution:**
- Device must be supervised
- Use MDM-pushed profiles (not manual installation)

### Issue: App crashes after restriction

**Solution:**
- Verify profile XML is valid
- Check iOS version compatibility
- Review device logs via Apple Configurator

---

## Cost Considerations

### MDM Providers (Approximate Monthly Costs)

- **Jamf Now:** $2-4 per device/month
- **Microsoft Intune:** $6-8 per user/month (Microsoft 365 bundle)
- **VMware Workspace ONE:** $5-10 per device/month
- **SimpleMDM:** $2-4 per device/month
- **Kandji:** $4-8 per device/month

### Apple Business Manager

- **Free** for organizations
- Requires DUNS number (free to obtain)

---

## Compliance and Legal

Ensure your deployment complies with:

1. **User Consent**
   - Corporate devices: Usually employer-owned consent is sufficient
   - BYOD: Requires explicit user consent

2. **Privacy Laws**
   - GDPR (Europe)
   - CCPA (California)
   - Local data protection regulations

3. **Company Policies**
   - Document acceptable use policies
   - Provide opt-out for personal devices

---

## Support and Resources

- **Apple Developer Documentation:** [developer.apple.com/documentation/devicemanagement](https://developer.apple.com/documentation/devicemanagement)
- **MDM Protocol Reference:** [developer.apple.com/business/documentation](https://developer.apple.com/business/documentation)
- **NLP-Digitox Support:** support@nlp-digitox.com

---

## Next Steps

1. Choose your MDM provider
2. Enroll devices in Apple Business Manager
3. Create test restriction profile
4. Deploy to pilot group
5. Scale to full organization

For assistance with MDM integration, contact our enterprise support team.

---

**Document Version:** 1.0  
**Last Updated:** April 2, 2026  
**Maintained By:** NLP-Digitox Platform Team
