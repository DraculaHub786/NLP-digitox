# Mindful App - Complete Customization Guide

## 📋 Project Overview
**Mindful** is a digital wellbeing and parental control app built with **Flutter** and **Android native code**. This guide will help you customize it to create your own version.

---

## ✅ Updates Applied

### 1. **NDK Version**
- ✅ Updated to **28.2.13676358** in `android/app/build.gradle`
- Compatible with latest Android development tools

### 2. **Dependencies**
- ✅ All Flutter dependencies verified and working
- ✅ Gradle dependencies updated (androidx.appcompat: 1.8.1)
- ✅ Project compiles successfully

### 3. **Emulator Compatibility**
- ✅ Min SDK: 24 (Android 7.0)
- ✅ Target SDK: Auto-set by Flutter
- ✅ **Pixel 7 compatible** - runs on Android 13 (API 33)

---

## 🗄️ DATABASE ARCHITECTURE

### **Database Technology: Drift (SQLite)**
The app uses **Drift** (formerly Moor) - a powerful, type-safe SQLite database for Flutter.

### **Location:**
- Database files: `lib/core/database/`
- Tables: `lib/core/database/tables/`
- DAOs: `lib/core/database/daos/`
- Migrations: `lib/core/database/migrations/`

### **Core Tables:**

#### 1. **MindfulSettingsTable**
- Stores global app settings
- Theme, language, authentication settings
- Usage history duration settings

#### 2. **AppRestrictionTable**
- Per-app restriction rules
- Time limits, launch timers
- Timer presets for each app

#### 3. **AppUsageTable**
- Daily app usage statistics
- Tracks screen time per app
- Network data usage (WiFi/Mobile)

#### 4. **FocusModeTable** & **FocusProfileTable**
- Focus mode configurations
- Custom focus profiles
- Whitelisted/blacklisted apps

#### 5. **FocusSessionsTable**
- Records of focus sessions
- Start/end times
- Session reflections

#### 6. **BedtimeScheduleTable**
- Bedtime mode schedules
- Daily scheduling
- Distracting apps during bedtime

#### 7. **ParentalControlsTable**
- Parental control PIN
- Child protection settings
- Invincible mode timer

#### 8. **RestrictionGroupsTable**
- Custom app groups
- Group-based time limits
- Distraction categories

#### 9. **WellbeingTable**
- Internet restrictions
- Blocked websites
- Platform feature blocks

#### 10. **NotificationsTable** & **NotificationSettingsTable**
- Notification management
- Per-app notification settings
- Notification filters

#### 11. **SharedUniqueDataTable**
- Shared app data
- Excluded apps list
- Batched app packages

#### 12. **CrashLogsTable**
- Error logging
- Crash reports for debugging

### **Database Schema Version: 9**
- Located in: `lib/core/database/app_database.dart`
- **CRITICAL**: Current schema is version 9

### **Making Database Changes:**

```dart
// Step 1: Modify tables in lib/core/database/tables/
// Step 2: Update schemaVersion in app_database.dart (from 9 to 10)
// Step 3: Rebuild Dart API
dart run build_runner build --delete-conflicting-outputs

// Step 4: Generate schema dump
dart run drift_dev schema dump lib/core/database/app_database.dart lib/core/database/schemas

// Step 5: Generate migration steps
dart run drift_dev schema steps lib/core/database/schemas lib/core/database/schemas/schema_versions.dart

// Step 6: Create migration file (e.g., from9To10.dart)
// Add migration logic in lib/core/database/migrations/
```

### **Data Access Objects (DAOs):**

1. **UniqueRecordsDao** (`lib/core/database/daos/unique_records_dao.dart`)
   - Manages single-record tables
   - Settings, focus mode, parental controls
   
2. **DynamicRecordsDao** (`lib/core/database/daos/dynamic_records_dao.dart`)
   - Manages multi-record tables
   - Usage data, restrictions, sessions

### **Database Service:**
- **DriftDbService** (`lib/core/services/drift_db_service.dart`)
- Singleton pattern
- Handles database initialization
- Database location: App's documents directory

---

## 🔐 AUTHENTICATION SYSTEM

### **Technology: Local Biometric Authentication**
Uses `local_auth` package for device biometrics.

### **Location:**
`lib/core/services/auth_service.dart`

### **Features:**
1. **Biometric Types Supported:**
   - Fingerprint
   - Face recognition
   - Iris scan
   - Any device-supported biometric

2. **Authentication Flow:**
```dart
// Check if biometrics available
bool? result = await AuthService.instance.authenticate();

// Returns:
// - true: Successfully authenticated
// - false: Authentication failed
// - null: No biometrics available on device
```

3. **Implementation Details:**
   - Singleton pattern (`AuthService.instance`)
   - Async authentication
   - Error handling included
   - Platform-specific (Android/iOS compatible)

### **Security Features:**
- Protected app access (optional setting)
- Parental controls PIN protection
- Invincible mode window protection
- Uninstall protection window

### **Customizing Authentication:**

**Add Password Authentication:**
```dart
// In lib/core/services/auth_service.dart
Future<bool> authenticateWithPassword(String password) async {
  // Compare with stored hash
  String storedHash = // Get from database
  return hashPassword(password) == storedHash;
}
```

**Add Remote Authentication:**
```dart
// Create lib/core/services/remote_auth_service.dart
import 'package:http/http.dart' as http;

class RemoteAuthService {
  Future<bool> authenticateWithServer(String token) async {
    final response = await http.post(
      Uri.parse('https://your-api.com/auth'),
      body: {'token': token},
    );
    return response.statusCode == 200;
  }
}
```

---

## 📱 APP CUSTOMIZATION STEPS

### **1. Change App Name & Package**

#### **App Name:**
Update in 3 places:

1. `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="Your App Name"
```

2. `android/app/build.gradle`:
```gradle
buildTypes {
    release {
        resValue "string", "app_name", "Your App Name"
    }
    debug {
        resValue "string", "app_name", "Your App Name Debug"
    }
}
```

3. `lib/config/app_constants.dart`:
```dart
static const defaultUsername = "Your Default Username";
```

#### **Package Name:**
```gradle
// android/app/build.gradle
android {
    namespace "com.yourcompany.yourapp"
    defaultConfig {
        applicationId "com.yourcompany.yourapp"
    }
}
```

**IMPORTANT**: Also update in:
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/` folder structure
- Rename package folders to match

### **2. Change App Icon**

Replace files in:
```
android/app/src/main/res/
  ├── mipmap-hdpi/ic_launcher.png
  ├── mipmap-mdpi/ic_launcher.png
  ├── mipmap-xhdpi/ic_launcher.png
  ├── mipmap-xxhdpi/ic_launcher.png
  └── mipmap-xxxhdpi/ic_launcher.png
```

Or use **flutter_launcher_icons** package:
```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  image_path: "assets/icon/app_icon.png"
```

Run: `dart run flutter_launcher_icons`

### **3. Change Theme & Colors**

Location: `lib/config/app_themes.dart`

```dart
// Change default color
static const defaultMaterialColor = "YourColor"; // Blue, Red, Green, etc.

// Customize light theme
static ThemeData lightTheme(String colorName) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.yourColor, // Change this
      brightness: Brightness.light,
    ),
    // Customize more...
  );
}
```

### **4. Add Your Branding URLs**

Location: `lib/config/app_constants.dart`

```dart
// Update URLs
static const githubUrl = "https://github.com/yourusername/yourapp/";
static const supportEmailUrl = "mailto:support@yourdomain.com";
static const privacyPolicyUrl = "https://yourdomain.com/privacy";
static const faqsUrl = "https://yourdomain.com/faqs";
```

### **5. Change Localization/Translations**

Location: `lib/l10n/`

- English: `app_en.arb`
- Spanish: `app_es.arb`
- French: `app_fr.arb`
- etc.

Edit JSON to change app text:
```json
{
  "appName": "Your App Name",
  "tagline": "Your Custom Tagline",
  ...
}
```

### **6. Modify Onboarding Screens**

Location: `lib/ui/onboarding/`

Replace images:
```
assets/illustrations/
  ├── onboarding_1.png
  ├── onboarding_2.png
  ├── onboarding_3.png
  └── onboarding_4.png
```

Edit content: `lib/ui/onboarding/onboarding_screen.dart`

### **7. Add Remote Backend**

**Create API Service:**
```dart
// lib/core/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://your-api.com';
  
  Future<void> syncUsageData(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sync'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to sync data');
    }
  }
  
  Future<Map<String, dynamic>> fetchSettings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/settings'),
    );
    
    return jsonDecode(response.body);
  }
}
```

**Add to pubspec.yaml:**
```yaml
dependencies:
  http: ^1.2.0
  shared_preferences: ^2.2.0  # For storing auth tokens
```

**Integrate with existing code:**
```dart
// In your provider or service
import 'package:mindful/core/services/api_service.dart';

class YourProvider {
  final _apiService = ApiService();
  
  Future<void> saveUsageData(UsageModel data) async {
    // Save to local database
    await database.insertUsage(data);
    
    // Sync to server
    try {
      await _apiService.syncUsageData(data.toJson());
    } catch (e) {
      debugPrint('Sync failed: $e');
      // Handle offline scenario
    }
  }
}
```

### **8. Add Firebase Analytics**

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_analytics: ^10.8.0
```

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MindfulApp());
}

// Track events
FirebaseAnalytics.instance.logEvent(
  name: 'focus_session_started',
  parameters: {'duration': 30},
);
```

### **9. Monetization - Add Ads**

```yaml
# pubspec.yaml
dependencies:
  google_mobile_ads: ^4.0.0
```

```dart
// lib/core/services/ads_service.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }
  
  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: 'your-ad-unit-id',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(),
    )..load();
  }
}
```

### **10. Add In-App Purchases**

```yaml
# pubspec.yaml
dependencies:
  in_app_purchase: ^3.1.11
```

```dart
// lib/core/services/purchase_service.dart
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  
  Future<void> buyPremium() async {
    const ProductDetails premium = ...; // Get from store
    final PurchaseParam param = PurchaseParam(productDetails: premium);
    await _iap.buyNonConsumable(purchaseParam: param);
  }
}
```

---

## 🚀 BUILDING & RUNNING

### **For Pixel 7 Emulator:**

1. **Start Emulator:**
```bash
# List available emulators
emulator -list-avds

# Start Pixel 7
emulator -avd Pixel_7_API_33
```

2. **Run App:**
```bash
cd "c:\Users\afjal\Documents\Final destination\Mindful-main"
flutter run
```

3. **Build APK:**
```bash
# Debug APK
flutter build apk --debug

# Release APK (requires signing keys)
flutter build apk --release
```

### **App Signing (for Release):**

1. **Create Keystore:**
```bash
keytool -genkey -v -keystore c:\Users\afjal\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Create `android/key.properties`:**
```properties
storePassword=your_password
keyPassword=your_password
keyAlias=upload
storeFile=c:\\Users\\afjal\\upload-keystore.jks
```

3. **Update `android/app/build.gradle`:**
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

## 🔧 DEVELOPMENT COMMANDS

### **Essential Commands:**

```bash
# Get dependencies
flutter pub get

# Regenerate database code (after changing tables)
dart run build_runner build --delete-conflicting-outputs

# Check for outdated packages
flutter pub outdated

# Upgrade packages
flutter pub upgrade

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib/

# Clean build
flutter clean
```

### **Android Native Development:**

```bash
# Build Android only
flutter build apk

# Build App Bundle (for Play Store)
flutter build appbundle

# Check Android setup
flutter doctor -v
```

---

## 📊 MONITORING & ANALYTICS

### **Current App Usage Tracking:**
The app already tracks:
- Daily screen time per app
- App launches and usage duration
- Network data usage (WiFi/Mobile)
- Focus session duration and effectiveness
- Notification frequency per app

### **Data is stored locally in SQLite**

### **To Add Cloud Sync:**

1. **Create backend API** (Firebase, custom server, etc.)
2. **Implement sync logic** in `DriftDbService`
3. **Add conflict resolution** for offline-first approach
4. **Implement data encryption** for privacy

Example structure:
```dart
class SyncService {
  Future<void> syncToCloud() async {
    // 1. Get local changes since last sync
    final changes = await database.getChangesSince(lastSyncTime);
    
    // 2. Send to server
    await apiService.uploadChanges(changes);
    
    // 3. Get server changes
    final serverChanges = await apiService.downloadChanges(lastSyncTime);
    
    // 4. Merge with local database
    await database.mergeChanges(serverChanges);
    
    // 5. Update sync timestamp
    await preferences.setLastSyncTime(DateTime.now());
  }
}
```

---

## 🛡️ PRIVACY & SECURITY

### **Current Privacy Features:**
1. **All data stored locally** - No cloud by default
2. **Biometric authentication** - Optional device lock
3. **Parental control PIN** - Prevent unauthorized changes
4. **No external data collection** - Privacy-first design

### **To Maintain Privacy:**
- Don't add analytics without user consent
- Encrypt database if storing sensitive data
- Implement proper data deletion
- Add export/delete user data features (GDPR compliance)

### **Add Database Encryption:**
```yaml
# pubspec.yaml
dependencies:
  sqflite_sqlcipher: ^2.2.1
```

Modify `DriftDbService` to use encrypted database.

---

## 📝 LICENSE & ATTRIBUTION

### **Original App:**
- **License:** GPL-2.0
- **Author:** Pawan Nagar (https://github.com/akaMrNagar)
- **Repository:** https://github.com/akaMrNagar/Mindful

### **Your Customized Version:**
Since GPL-2.0 is copyleft:
1. **Keep GPL-2.0 license** for your modified version
2. **Provide source code** to users
3. **Credit original author** in your app
4. **Document your changes**

Add this to your app's About screen:
```dart
"Based on Mindful by Pawan Nagar\n"
"Licensed under GPL-2.0\n"
"Source: https://github.com/your-repo"
```

---

## 🐛 TROUBLESHOOTING

### **Common Issues:**

1. **Build fails after dependency update:**
```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

2. **Database errors:**
- Check schema version
- Ensure migrations are properly defined
- Clear app data and reinstall

3. **Emulator not detected:**
```bash
flutter doctor
adb devices
adb kill-server
adb start-server
```

4. **NDK version issues:**
- Ensure `28.2.13676358` is installed via Android Studio SDK Manager
- Check `android/app/build.gradle` has correct version

---

## 📚 ADDITIONAL RESOURCES

### **Flutter Documentation:**
- Flutter Docs: https://docs.flutter.dev/
- Dart Docs: https://dart.dev/guides
- Drift Database: https://drift.simonbinder.eu/

### **Android Development:**
- Android Developer Guide: https://developer.android.com/
- Material Design: https://material.io/design

### **State Management (Riverpod):**
- Riverpod Docs: https://riverpod.dev/
- Used extensively in this app for reactive state

---

## ✅ FINAL CHECKLIST

Before releasing your customized version:

- [ ] Change app name and package ID
- [ ] Replace all branding (logo, colors, URLs)
- [ ] Set up signing keys for release builds
- [ ] Test on multiple devices/emulators
- [ ] Update privacy policy URL
- [ ] Add your support email
- [ ] Test all database migrations
- [ ] Verify authentication works
- [ ] Test parental controls
- [ ] Check all permissions are needed
- [ ] Review and update licenses
- [ ] Create Play Store listing
- [ ] Prepare app screenshots
- [ ] Write app description
- [ ] Set up crash reporting
- [ ] Test in-app purchases (if added)
- [ ] Verify ads work properly (if added)

---

## 🎯 NEXT STEPS

1. **Customize the app name and branding**
2. **Test on Pixel 7 emulator** 
3. **Add your backend features** (if needed)
4. **Build release APK**
5. **Submit to Play Store**

Good luck with your digital wellbeing app! 🚀

---

**Last Updated:** January 2026
**App Version:** 1.2.0
**Schema Version:** 9
