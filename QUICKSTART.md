# 🚀 Quick Start Guide - Mindful App Customization

## ✅ What Has Been Done

### 1. Project Updates
- ✅ **NDK Updated:** Version `28.2.13676358` configured
- ✅ **Dependencies:** All Flutter packages installed and working
- ✅ **Build System:** Gradle and Kotlin dependencies updated
- ✅ **Code Generation:** Database code regenerated successfully
- ✅ **Pixel 7 Ready:** Min SDK 24, fully compatible with Pixel 7 emulator

### 2. Files Modified
- `android/app/build.gradle` - NDK version + appcompat library
- `pubspec.yaml` - Dependencies verified (no major upgrades to avoid breaking changes)

---

## 🎯 Run on Pixel 7 Emulator RIGHT NOW

### Option 1: Using VS Code
1. **Start your Pixel 7 emulator** in Android Studio
2. **In VS Code:** Press `F5` or click "Run" > "Start Debugging"
3. **Select your Pixel 7 device** from the list
4. **App will install and launch**

### Option 2: Using Terminal
```bash
# Navigate to project
cd "c:\Users\afjal\Documents\Final destination\Mindful-main"

# Run on connected device/emulator
flutter run
```

---

## 🗄️ DATABASE - Everything You Need to Know

### **Quick Facts:**
- **Technology:** Drift (SQLite) - type-safe, reactive database
- **Schema Version:** 9 (current)
- **Location:** `lib/core/database/`
- **Storage:** Local SQLite file in app documents directory

### **14 Main Tables:**

| Table | Purpose |
|-------|---------|
| **MindfulSettingsTable** | App-wide settings, theme, language |
| **AppRestrictionTable** | Per-app time limits and rules |
| **AppUsageTable** | Daily usage statistics per app |
| **FocusModeTable** | Focus mode configurations |
| **FocusProfileTable** | Custom focus profiles |
| **FocusSessionsTable** | History of focus sessions |
| **BedtimeScheduleTable** | Bedtime mode schedules |
| **ParentalControlsTable** | PIN and parental settings |
| **RestrictionGroupsTable** | App groups with shared limits |
| **WellbeingTable** | Internet and website restrictions |
| **NotificationsTable** | Notification logs |
| **NotificationSettingsTable** | Per-app notification settings |
| **SharedUniqueDataTable** | Shared app-wide data |
| **CrashLogsTable** | Error logs for debugging |

### **How Database Works:**

1. **Initialization:**
   - App starts → `DriftDbService.instance.database` is created
   - Database file: `{app_documents}/mindful_db.sqlite`
   - All tables created automatically if first launch

2. **Data Access:**
   - Use DAOs (Data Access Objects):
     - `UniqueRecordsDao` - for single-record tables (settings, etc.)
     - `DynamicRecordsDao` - for multi-record tables (usage, sessions)

3. **Example Usage:**
```dart
// Get settings
final settings = await database.uniqueRecordsDao.getMindfulSettings();

// Get today's app usage
final usage = await database.dynamicRecordsDao.fetchTodayUsageForAllApps();

// Add restriction
await database.dynamicRecordsDao.insertRestriction(restriction);
```

### **To Create Your Own Database:**

**Option 1: Keep Local SQLite (Current Setup)**
- No changes needed!
- Already fully implemented
- Data stays on device (privacy-first)

**Option 2: Add Cloud Database (Firebase, Supabase, etc.)**
See `CUSTOMIZATION_GUIDE.md` for complete implementation guide.

---

## 🔐 AUTHENTICATION - Complete Overview

### **Current System:**
- **Type:** Local Biometric Authentication
- **Package:** `local_auth` (v2.3.0)
- **Supported:** Fingerprint, Face ID, any device biometric

### **How It Works:**

1. **Location:** `lib/core/services/auth_service.dart`

2. **Usage:**
```dart
// Authenticate user
bool? authenticated = await AuthService.instance.authenticate();

if (authenticated == true) {
  // User verified ✅
} else if (authenticated == false) {
  // Authentication failed ❌
} else {
  // No biometrics available on device
}
```

3. **Where Used:**
   - Protect app access (optional in settings)
   - Parental controls unlock
   - Prevent uninstall during protection window
   - Focus mode bypass attempts

### **To Add Your Own Authentication:**

**Add Password/PIN:**
```dart
// 1. Add field to MindfulSettingsTable
// 2. Store hashed password
// 3. Create password verification method
Future<bool> verifyPassword(String password) async {
  final storedHash = await database.getPasswordHash();
  return hashPassword(password) == storedHash;
}
```

**Add Remote Authentication (Server-based):**
```dart
// Create new service
class RemoteAuthService {
  Future<String> loginWithEmail(String email, String password) async {
    final response = await http.post('your-api.com/login', {
      'email': email,
      'password': password,
    });
    // Return auth token
  }
}
```

---

## 📱 Make It Your Own - Essential Changes

### **Step 1: Change App Name (3 places)**

**1. android/app/build.gradle:**
```gradle
buildTypes {
    release {
        resValue "string", "app_name", "My Wellbeing App"  // ← Change this
    }
}
```

**2. android/app/src/main/AndroidManifest.xml:**
```xml
<application
    android:label="My Wellbeing App"  <!-- ← Change this -->
```

**3. lib/l10n/app_en.arb:**
```json
{
  "appName": "My Wellbeing App"  // ← Change this
}
```

### **Step 2: Change Package Name**

**android/app/build.gradle:**
```gradle
android {
    namespace "com.mycompany.wellbeingapp"  // ← Change
    defaultConfig {
        applicationId "com.mycompany.wellbeingapp"  // ← Change
    }
}
```

**Also rename folder:**
```
android/app/src/main/kotlin/com/mindful/android/
→
android/app/src/main/kotlin/com/mycompany/wellbeingapp/
```

### **Step 3: Change App Icon**

Replace these files with your icon:
```
android/app/src/main/res/
  ├── mipmap-hdpi/ic_launcher.png     (72x72)
  ├── mipmap-mdpi/ic_launcher.png     (48x48)
  ├── mipmap-xhdpi/ic_launcher.png    (96x96)
  ├── mipmap-xxhdpi/ic_launcher.png   (144x144)
  └── mipmap-xxxhdpi/ic_launcher.png  (192x192)
```

### **Step 4: Update Branding URLs**

**lib/config/app_constants.dart:**
```dart
static const githubUrl = "https://github.com/YOUR-USERNAME/YOUR-APP/";
static const supportEmailUrl = "mailto:support@yourdomain.com";
static const privacyPolicyUrl = "https://yourdomain.com/privacy";
```

### **Step 5: Change Theme Color**

**lib/config/app_themes.dart:**
```dart
// Change from Indigo to your color
static const defaultMaterialColor = "Blue";  // Blue, Red, Green, Purple, etc.
```

---

## 🔨 Common Development Tasks

### **Test the App:**
```bash
flutter run
```

### **Build Release APK:**
```bash
flutter build apk --release
```

### **After Changing Database:**
```bash
# 1. Update schema version in app_database.dart (9 → 10)
# 2. Regenerate code:
dart run build_runner build --delete-conflicting-outputs

# 3. Generate schema:
dart run drift_dev schema dump lib/core/database/app_database.dart lib/core/database/schemas

# 4. Generate migration steps:
dart run drift_dev schema steps lib/core/database/schemas lib/core/database/schemas/schema_versions.dart

# 5. Create migration file: lib/core/database/migrations/from9To10.dart
```

### **Fix Build Issues:**
```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### **Check for Updates:**
```bash
flutter pub outdated
```

---

## 🎨 Customization Ideas

### **Easy Customizations:**
1. ✅ Change colors and themes
2. ✅ Modify onboarding screens
3. ✅ Update text translations
4. ✅ Change default settings
5. ✅ Add your logo/branding

### **Medium Difficulty:**
1. 🔧 Add new database tables
2. 🔧 Implement cloud sync
3. 🔧 Add new restriction types
4. 🔧 Custom focus modes
5. 🔧 Enhanced analytics

### **Advanced Features:**
1. 🚀 Multi-user support (family accounts)
2. 🚀 AI-powered insights
3. 🚀 Cross-platform sync
4. 🚀 Social features (challenges, etc.)
5. 🚀 Enterprise/School management

---

## 📦 Required Files for Your Own Backend

If you want to add server-side features, create:

```
lib/core/services/
  ├── api_service.dart        # HTTP API calls
  ├── sync_service.dart       # Data synchronization
  └── auth_backend.dart       # Remote authentication

lib/models/api/
  ├── user_model.dart         # User account
  ├── sync_response.dart      # API responses
  └── api_error.dart          # Error handling
```

Example structure provided in full guide.

---

## 🐛 Known Issues & Solutions

### **Issue: Build fails after updating dependencies**
**Solution:**
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### **Issue: App won't run on emulator**
**Solution:**
```bash
flutter doctor -v  # Check for issues
adb devices       # Verify emulator is detected
flutter run       # Try again
```

### **Issue: Database errors on app start**
**Solution:**
- Uninstall app from emulator
- Clear app data
- Reinstall: `flutter run`

### **Issue: Can't find NDK 28.2.13676358**
**Solution:**
1. Open Android Studio
2. Tools → SDK Manager
3. SDK Tools tab
4. Check "Show Package Details"
5. Install NDK 28.2.13676358

---

## 📚 Complete Documentation

For detailed guides on:
- Database customization
- Authentication systems
- Adding monetization
- Firebase integration
- Cloud sync
- And much more...

**See:** `CUSTOMIZATION_GUIDE.md` (created in your project root)

---

## ✅ Your Project is Ready!

**Everything you need to start customizing:**
- ✅ NDK updated to 28.2.13676358
- ✅ All dependencies working
- ✅ Code generated successfully
- ✅ Database architecture documented
- ✅ Authentication explained
- ✅ Ready for Pixel 7 emulator

**Next Steps:**
1. Run `flutter run` to test on emulator
2. Read `CUSTOMIZATION_GUIDE.md` for detailed instructions
3. Start customizing (app name, colors, features)
4. Build and release your own version!

---

**Questions?** Check the full `CUSTOMIZATION_GUIDE.md` for answers!

**Happy Coding! 🚀**
