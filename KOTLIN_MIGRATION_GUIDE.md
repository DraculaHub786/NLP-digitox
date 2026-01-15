# Android Kotlin Package Migration Guide

## 📍 Current Situation

Your Kotlin/Java files are located in:
```
android/app/src/main/java/com/mindful/android/
```

But the app's namespace in `build.gradle` is now:
```
com.nlp.digitox
```

This mismatch causes all the compilation errors because Android generates the `R` class in the new package (`com.nlp.digitox.R`), but your Kotlin code is still in the old package trying to reference it.

---

## 🎯 Goal

Move all Kotlin files from:
```
OLD: android/app/src/main/java/com/mindful/android/
NEW: android/app/src/main/java/com/nlp/digitox/
```

---

## 📋 Step-by-Step Instructions

### **Step 1: Open File Explorer**

Navigate to your project folder:
```
c:\Users\afjal\Documents\Final destination\Mindful-main
```

### **Step 2: Locate the Current Kotlin Files**

1. Navigate to: `android\app\src\main\java`
2. You'll see folders: `com` and `io`
3. Go into: `com\mindful\android`
4. This folder contains all your Kotlin (.kt) files

### **Step 3: Create the New Package Structure**

Still in the `java` folder (`android\app\src\main\java`):

1. **Inside the existing `com` folder**, create a new folder: `nlp`
2. **Inside the `nlp` folder**, create a new folder: `digitox`

Your structure should now look like:
```
android/app/src/main/java/
├── com/
│   ├── mindful/
│   │   └── android/          ← OLD (files still here)
│   └── nlp/                  ← NEW
│       └── digitox/          ← NEW (empty for now)
└── io/
    └── flutter/
```

### **Step 4: Copy All Files to New Location**

1. Go back to: `com\mindful\android`
2. **Select ALL files and folders** inside (select everything you see)
3. **Copy** them (Ctrl+C)
4. Navigate to: `com\nlp\digitox`
5. **Paste** everything here (Ctrl+V)

Now both old and new locations have the same files (we'll delete the old ones later).

### **Step 5: Update Package Declarations in All Kotlin Files**

### **Step 5: Update Package Declarations in All Kotlin Files** ⚠️

This is the most important step! You need to update the `package` declaration at the top of every `.kt` file.

**Using VS Code Find & Replace (RECOMMENDED):**

1. Open VS Code
2. Press `Ctrl+Shift+H` (Find and Replace in Files)
3. **Find:** `package com.mindful.android`
4. **Replace:** `package com.nlp.digitox`
5. In "files to include" field, enter: `android/app/src/main/java/com/nlp/digitox/**/*.kt`
6. Click "Replace All"
7. Review the changes in the preview panel
8. Confirm the replacement

This will update package declarations in ALL subdirectories:
- `package com.nlp.digitox` (MainActivity.kt)
- `package com.nlp.digitox.services` (files in services/)
- `package com.nlp.digitox.utils` (files in utils/)
- And all other subdirectories

### **Step 6: Verify MainActivity**

Open: `android\app\src\main\java\com\nlp\digitox\MainActivity.kt`

Confirm the first line reads:
```kotlin
package com.nlp.digitox
```

### **Step 7: Delete the Old Package Directory**

1. Navigate to: `android\app\src\main\java\com`
2. **Delete the entire `mindful` folder**
3. This removes all the old files (you've already copied them to the new location)

Your structure should now be:
```
android/app/src/main/java/
├── com/
│   └── nlp/                  ← ONLY THIS NOW
│       └── digitox/
│           └── [all your .kt files]
└── io/
    └── flutter/
```

### **Step 8: Clean Build**

Open PowerShell in your project root:

```powershell
cd "c:\Users\afjal\Documents\Final destination\Mindful-main"

# Clean all build artifacts
flutter clean

# Get dependencies
flutter pub get

# Try building
flutter build apk --debug
```

### **Step 9: Run the App**

```powershell
flutter run
```

---

## ✅ Verification Checklist

After completing all steps, verify:

- [ ] New directory exists: `android/app/src/main/java/com/nlp/digitox/`
- [ ] All `.kt` files are in the new location
- [ ] All `.kt` files have `package com.nlp.digitox.*` at the top
- [ ] Old directory `android/app/src/main/java/com/mindful/` is deleted
- [ ] `flutter clean` completed successfully
- [ ] `flutter pub get` completed successfully
- [ ] App builds without Kotlin compilation errors

---

## 🔧 Troubleshooting

### Problem: "Unresolved reference 'R'"

**Solution:** Make sure you've updated ALL package declarations in ALL `.kt` files. Even one file with the old package will cause issues.

### Problem: PowerShell command doesn't work

**Solution:** Use VS Code's Find & Replace (Option B in Step 5).

### Problem: Build still fails with "package does not exist"

**Solution:** 
1. Make sure the old `mindful` folder is completely deleted
2. Run `flutter clean` again
3. Restart VS Code
4. Run `flutter pub get`

### Problem: Files didn't copy correctly

**Solution:**
1. Delete the `nlp` folder you created
2. Start over from Step 3
3. Make sure to copy the CONTENTS of `android` folder, not the folder itself

---

## 📝 Quick Command Summary

```powershell
# 1. Navigate to project
cd "c:\Users\afjal\Documents\Final destination\Mindful-main"

# 2. Open File Explorer
explorer "android\app\src\main\java"
```

**In File Explorer:**
- Create folders: `com/nlp/digitox/`
- Copy from: `com/mindful/android/` (select all → Ctrl+C)
- Paste to: `com/nlp/digitox/` (Ctrl+V)

**In VS Code:**
- Press `Ctrl+Shift+H`
- Find: `package com.mindful.android`
- Replace: `package com.nlp.digitox`
- Files to include: `android/app/src/main/java/com/nlp/digitox/**/*.kt`
- Click "Replace All"

**Back in File Explorer:**
- Delete folder: `com/mindful/`

**Final build:**
```powershell
cd "c:\Users\afjal\Documents\Final destination\Mindful-main"
flutter clean
flutter pub get
flutter run
```

---

## 🎯 Expected Result

After successful migration:
- App builds without Kotlin compilation errors
- App launches on emulator/device
- All features work correctly
- No "Unresolved reference 'R'" errors

---

**Need Help?** If you get stuck at any step, let me know which step number you're on and what error you're seeing!
