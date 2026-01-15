/*
 *




































































































































































































































































































































































































































































































































5. Build and release!4. Add profile management screen3. Customize branding and colors2. Test login/signup functionality1. Complete Firebase setup following this guide**Next Steps:****Your app now has enterprise-level authentication and cloud database!** 🎉---5. Check Flutter doctor: `flutter doctor -v`4. Ensure all SHA-1 fingerprints are added3. Verify `google-services.json` is correct2. Review Firestore security rules1. Check Firebase Console for errorsCommon issues and solutions:## 🆘 Need Help?---- [Firebase YouTube Channel](https://www.youtube.com/firebase)- [Firebase Console](https://console.firebase.google.com/)- [FlutterFire Documentation](https://firebase.flutter.dev/)- [Firebase Documentation](https://firebase.google.com/docs)## 📚 Additional Resources---- [ ] Release SHA-1 added- [ ] Production security rules set- [ ] User logout works- [ ] Data reading from Firestore works- [ ] Data saving to Firestore works- [ ] App tested with Google Sign-In- [ ] App tested with email/password- [ ] SHA-1 fingerprints added- [ ] Security rules configured- [ ] Firestore database created- [ ] Authentication methods enabled- [ ] Build.gradle files updated- [ ] `google-services.json` added- [ ] Firebase project createdBefore releasing:## ✅ Verification Checklist---```});  }    print('App: ${doc.id}, Usage: ${doc.data()}');  for (var doc in snapshot.docs) {FirestoreService.instance.getAppUsageStream(DateTime.now()).listen((snapshot) {// Listen to app usage updatesprint('Theme: ${settings['themeMode']}');final settings = await FirestoreService.instance.getUserSettings();// Get settings```dart### Get Data from Firestore```);  },    'isBlocked': false,    'timeLimit': 3600, // seconds  restriction: {  packageName: 'com.example.app',await FirestoreService.instance.saveAppRestriction(// Save app restrictionimport 'package:nlp_digitox/core/services/firestore_service.dart';```dart### Save Data to Firestore```});  }    print('User logged in: ${user.email}');    // User logged in  } else {    Navigator.pushReplacementNamed(context, AppRoutes.loginPath);    // User logged out  if (user == null) {FirebaseAuthService.instance.authStateChanges.listen((user) {```dart### Listen to Auth State Changes```print('Name: ${user?.displayName}');print('Email: ${user?.email}');print('User ID: ${user?.uid}');final user = FirebaseAuthService.instance.currentUser;import 'package:nlp_digitox/core/services/firebase_auth_service.dart';```dart### Get Current User Data## 📝 Code Examples---```flutter runcd .../gradlew cleancd androidflutter pub getflutter clean```bash**Solution:**### Error: "Dependencies conflict"- Verify userId matches in rules- Ensure user is authenticated- Check Firestore security rules**Solution:**### Error: "Permission denied" in Firestore- Enable Google Sign-In in Authentication- Download updated `google-services.json`- Add SHA-1 to Firebase Console**Solution:**### Error: "Google Sign-In failed"- Run `flutter clean && flutter pub get`- Check `build.gradle` has Google services plugin- Ensure `google-services.json` is in `android/app/`**Solution:**### Error: "Default FirebaseApp is not initialized"## 🐛 Troubleshooting---Server-side logic, scheduled tasks### 6. **Firebase Cloud Functions**Store user profile pictures, backups### 5. **Firebase Storage**Update app features without app update### 4. **Firebase Remote Config**Push notifications for reminders### 3. **Firebase Cloud Messaging (FCM)**Automatic crash reporting and analysis### 2. **Firebase Crashlytics**Track user behavior, app usage, screen views### 1. **Firebase Analytics**## 📊 Firebase Features You Can Add---Add SMS or authenticator app for extra security.### 4. **Two-Factor Authentication**```}  // Show "Please verify your email" screen  await user.sendEmailVerification();if (!user.emailVerified) {```dartRequire users to verify email before accessing app:### 3. **Email Verification**Enable in Firebase Console → Authentication → Settings### 2. **Rate Limiting**```}  static const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');  static const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');class FirebaseConfig {// lib/config/firebase_config.dart```dartStore sensitive data in environment variables:### 1. **Environment Variables**## 🔐 Security Best Practices---- Export data (GDPR)- Delete account- Update email- Change password- Display user infoCreate `lib/ui/auth/profile_screen.dart`:### Add Profile Screen```# Implement SMS OTP login# Already available in firebase_auth```bash**Phone Authentication:**```flutter pub add sign_in_with_apple```bash**Apple Sign-In:**```flutter pub add flutter_facebook_auth```bash**Facebook Login:**### Add More Login Options```),  textAlign: TextAlign.center,  fontWeight: FontWeight.bold,  fontSize: 32,  'Your App Name',  // ← Change nameStyledText(// Change app name),  color: Theme.of(context).colorScheme.primary,  size: 64.h,  FluentIcons.your_icon_here,  // ← Change iconIcon(// Change app icon```dartEdit: `lib/ui/auth/login_screen.dart`### Change Login Screen Branding## 🎨 Customization Options---Good for tracking user behavior and app performance.#### 5. **Enable Firebase Analytics (Optional)**Configure password requirements in Authentication settings.#### 4. **Set up Password Policy**In Authentication settings, enable email verification for better security.#### 3. **Enable Email Verification (Optional)**Add this SHA-1 to Firebase Console```keytool -list -v -keystore c:\Users\afjal\upload-keystore.jks -alias upload```bash#### 2. **Generate Release SHA-1**```}  }    }      }        allow read, write: if request.auth != null && request.auth.uid == userId;      match /{document=**} {            allow read, write: if request.auth != null && request.auth.uid == userId;    match /users/{userId} {  match /databases/{database}/documents {service cloud.firestore {rules_version = '2';```#### 1. **Update Firestore Rules (Production Mode)**### Before Releasing Your App:## 🚀 Production Setup---4. You should see a `users` collection with your user data3. Go to **Firestore Database**2. You should see your test user(s)1. Go to **Authentication** → **Users**### Verify in Firebase Console3. You should be logged in2. Select Google account1. Click **"Continue with Google"**### Test Google Sign-In5. You should be logged in4. Click **"Sign Up"**3. Enter name, email, password2. Click **"Sign Up"**1. Run the app### Test Email/Password Signup## 🧪 Testing---4. Store data in Firestore3. Allow Google Sign-In2. Allow you to sign up with email/password1. Show login screen on first launchThe app should now:```flutter run```bash### Test Firebase Connection```flutter pub getcd "c:\Users\afjal\Documents\Final destination\Mindful-main"```bash### Install Dependencies## 🔧 Development Setup---Click **"Publish"**```}  }    }      allow read, write: if false;    match /{document=**} {    // Deny all other access        }      }        allow read, write: if request.auth != null && request.auth.uid == userId;      match /{document=**} {      // Allow access to subcollections            allow read, write: if request.auth != null && request.auth.uid == userId;    match /users/{userId} {    // User can only access their own data  match /databases/{database}/documents {service cloud.firestore {rules_version = '2';```Go to **Firestore Database** → **Rules** and paste:### Step 8: Configure Firestore Security Rules5. Click **"Enable"**4. Choose a location (closest to your users)   - **Important:** Change to production mode before release3. Select **"Start in test mode"** (for development)2. Click **"Create database"**1. In Firebase Console, go to **Firestore Database**### Step 7: Set up Cloud Firestore4. **Download updated `google-services.json`** and replace the old one   - Click **Save**   - Paste SHA-1   - Click **"Add fingerprint"**   - Go to **Project Settings** → **Your apps** → **Android app**3. In Firebase Console:2. Copy the **SHA-1** fingerprint```keytool -list -v -keystore C:\Users\YOUR_USERNAME\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android# For Windows:keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android# Debug certificate (for development)```bash1. Get your **SHA-1** certificate fingerprint:### Step 6: Configure Google Sign-In (Android)   - Click **Save**   - Enter support email   - Toggle **Enable**   - Click on "Google"3. Enable **Google Sign-In:**   - Click **Save**   - Toggle **Enable**   - Click on "Email/Password"2. Enable **Email/Password:**1. In Firebase Console, go to **Authentication** → **Sign-in method**### Step 5: Enable Authentication Methods```}    implementation 'com.google.firebase:firebase-analytics'              // ← Add (optional)    implementation platform('com.google.firebase:firebase-bom:32.7.0')  // ← Add    implementation 'androidx.appcompat:appcompat:1.8.1'    implementation 'androidx.work:work-runtime:2.10.1'dependencies {```gradleAlso ensure you have these dependencies:```apply plugin: 'com.google.gms.google-services'  // ← Add this line at the very end```gradleAdd at the **bottom** of the file:#### **2. App-level `android/app/build.gradle`**```}    }        classpath 'com.google.gms:google-services:4.4.0'  // ← Add this        classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0'        classpath 'com.android.tools.build:gradle:8.1.0'    dependencies {    }        mavenCentral()        google()    repositories {buildscript {```gradleAdd Google services classpath:#### **1. Project-level `android/build.gradle`**### Step 4: Update Android Configuration```      └── google-services.json  ← Place here  └── app/android/```2. Place it in: `android/app/google-services.json`1. **Download `google-services.json`**### Step 3: Download Configuration File5. Click **"Register app"**4. **Debug signing certificate SHA-1:** Leave empty for now3. **App nickname:** Mindful (optional)   - (Or your custom package if you changed it)2. Enter Android package name: `com.mindful.android`1. In Firebase Console, click **Android icon** (Add App)### Step 2: Add Android App5. Click **"Create project"**4. **Disable Google Analytics** (optional, can enable later)3. Enter project name: `mindful-app` (or your custom name)2. Click **"Add project"**1. Go to [Firebase Console](https://console.firebase.google.com/)### Step 1: Create Firebase Project## 📋 Firebase Console Setup---- ✅ Signup screen (`lib/ui/auth/signup_screen.dart`)- ✅ Login screen (`lib/ui/auth/login_screen.dart`)### 3. **New Screens**- ✅ Works offline with automatic sync- ✅ Automatic backups- ✅ User data isolation (each user has their own data)- ✅ Real-time data synchronization### 2. **Cloud Database (Firestore)**- ✅ Biometric lock (kept as secondary authentication)- ✅ Account management (update email, password, delete account)- ✅ Password reset functionality- ✅ Google Sign-In- ✅ Email/Password login and signup### 1. **Authentication System**## ✅ Features Added---Your Mindful app now uses **Firebase** for authentication and database instead of local SQLite. This guide will help you configure Firebase for your project.## Overview *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/bg_executor_service.dart';
import 'package:nlp_digitox/core/services/crash_log_service.dart';
import 'package:nlp_digitox/core/services/drift_db_service.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/mindful_app.dart';

/// Dart background
@pragma('vm:entry-point')
Future<void> initBgExecutorService() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BgExecutorService.instance.init();
}

/// Flutter main app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  /// Initialize method channel and drift Database
  await MethodChannelService.instance.init();
  await DriftDbService.instance.init();

  FlutterError.onError = (errorDetails) {
    CrashLogService.instance.recordCrashError(
      errorDetails.exception.toString(),
      errorDetails.stack.toString(),
    );

    if (kDebugMode) {
      FlutterError.presentError(errorDetails);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    CrashLogService.instance.recordCrashError(
      error.toString(),
      stack.toString(),
    );
    return !kDebugMode;
  };

  /// Scale app from edge-edge behind system ui
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  /// run main app
  runApp(
    const ProviderScope(
      child: MindfulApp(),
    ),
  );
}
