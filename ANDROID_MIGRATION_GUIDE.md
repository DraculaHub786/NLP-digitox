# Android Kotlin Package Migration Guide

## 📋 Overview

This guide will help you migrate the Android Kotlin source code from package `com.mindful.android` to `com.nlp.digitox`.

**Time Required:** 15-20 minutes  
**Difficulty:** Medium  
**Tools Needed:** File Explorer + Text Editor (VS Code)

---

## 🎯 Step-by-Step Instructions

### Step 1: Locate the Kotlin Source Directory

1. Open File Explorer
2. Navigate to:
   ```
   C:\Users\afjal\Documents\Final destination\Mindful-main\android\app\src\main\kotlin
   ```
3. You should see a folder structure: `com/mindful/android/`

---

### Step 2: Create New Package Directory Structure

1. In the same `kotlin` folder, create new folders:
   ```
   kotlin/
   └── com/
       └── nlp/
           └── digitox/
   ```

**How to do it:**
- Right-click in the `kotlin/com/` folder
- Select `New` → `Folder`
- Name it: `nlp`
- Inside `nlp`, create another folder: `digitox`

---

### Step 3: Move All Kotlin Files

1. Open two File Explorer windows side by side:
   - **Left:** `kotlin/com/mindful/android/`
   - **Right:** `kotlin/com/nlp/digitox/`

2. Select ALL files and folders from `kotlin/com/mindful/android/`
3. **Cut** them (Ctrl+X or right-click → Cut)
4. Paste into `kotlin/com/nlp/digitox/`

**Expected structure after move:**
```
kotlin/
├── com/
│   ├── nlp/
│   │   └── digitox/
│   │       ├── MainActivity.kt
│   │       ├── MindfulVpnService.kt
│   │       ├── foss/
│   │       ├── receivers/
│   │       ├── services/
│   │       ├── utils/
│   │       └── widgets/
│   └── mindful/    ← This folder should now be EMPTY
│       └── android/  ← EMPTY
```

---

### Step 4: Update Package Declarations in ALL Kotlin Files

Now you need to update the package declaration at the top of EVERY `.kt` file.

#### Option A: Using PowerShell (Automated - RECOMMENDED)

1. Open PowerShell in VS Code (Terminal → New Terminal)
2. Copy and paste this command:

```powershell
# Navigate to the Kotlin source directory
cd "C:\Users\afjal\Documents\Final destination\Mindful-main\android\app\src\main\kotlin\com\nlp\digitox"

# Find and replace package declarations in all Kotlin files
Get-ChildItem -Recurse -Filter "*.kt" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace 'package com\.mindful\.android', 'package com.nlp.digitox'
    Set-Content $_.FullName -Value $newContent -NoNewline
    Write-Host "Updated: $($_.Name)"
}

Write-Host "`nDone! All package declarations updated."
```

3. Press Enter and wait for completion

#### Option B: Using VS Code Find & Replace (Manual)

1. Open VS Code
2. Press `Ctrl+Shift+H` (Find and Replace in Files)
3. Click on the "folder icon" to limit search to a specific folder
4. Select: `C:\Users\afjal\Documents\Final destination\Mindful-main\android\app\src\main\kotlin\com\nlp\digitox`
5. In the "Find" box, enter:
   ```
   package com.mindful.android
   ```
6. In the "Replace" box, enter:
   ```
   package com.nlp.digitox
   ```
7. Click "Replace All" button
8. Confirm the replacements

---

### Step 5: Update Import Statements (If Any)

Some Kotlin files might import classes from other files in the package. Update these too:

```powershell
cd "C:\Users\afjal\Documents\Final destination\Mindful-main\android\app\src\main\kotlin\com\nlp\digitox"

Get-ChildItem -Recurse -Filter "*.kt" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace 'import com\.mindful\.android', 'import com.nlp.digitox'
    Set-Content $_.FullName -Value $newContent -NoNewline
    Write-Host "Updated imports: $($_.Name)"
}
```

---

### Step 6: Delete Old Empty Directories

1. Navigate to: `kotlin/com/mindful/`
2. Verify the `android` folder inside is **completely empty**
3. Delete the entire `mindful` folder (Right-click → Delete)

**Final structure should be:**
```
kotlin/
└── com/
    └── nlp/
        └── digitox/
            ├── MainActivity.kt
            ├── MindfulVpnService.kt
            └── ... (all other files)
```

---

### Step 7: Update AndroidManifest.xml (If Needed)

Check if the manifest has any hardcoded references:

1. Open: `android/app/src/main/AndroidManifest.xml`
2. Search for `com.mindful.android.MainActivity`
3. Replace with: `com.nlp.digitox.MainActivity`

**Example:**
```xml
<!-- Before -->
<activity android:name="com.mindful.android.MainActivity">

<!-- After -->
<activity android:name="com.nlp.digitox.MainActivity">
```

---

### Step 8: Clean Build Cache

In PowerShell, run these commands:

```powershell
# Navigate to project root
cd "C:\Users\afjal\Documents\Final destination\Mindful-main"

# Clean Flutter build
flutter clean

# Delete Android build cache
Remove-Item -Recurse -Force "android\app\build" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "android\.gradle" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "android\build" -ErrorAction SilentlyContinue

# Get dependencies again
flutter pub get
```

---

### Step 9: Test the Build

Try building the app:

```powershell
flutter build apk --debug
```

If successful, you should see:
```
✓ Built build\app\outputs\flutter-apk\app-debug.apk (XX.XMB)
```

---

### Step 10: Run the App

```powershell
flutter run
```

---

## 🔍 Verification Checklist

After migration, verify:

- [ ] All `.kt` files moved to `kotlin/com/nlp/digitox/`
- [ ] All package declarations updated to `package com.nlp.digitox.*`
- [ ] All import statements updated (if any)
- [ ] Old `kotlin/com/mindful/` directory deleted
- [ ] AndroidManifest.xml updated
- [ ] Build cache cleaned
- [ ] App builds successfully
- [ ] App runs without crashes

---

## ❌ Common Issues & Solutions

### Issue 1: "Unresolved reference 'R'"
**Solution:** Clean build cache and rebuild:
```powershell
flutter clean
flutter pub get
flutter build apk --debug
```

### Issue 2: "Cannot find MainActivity"
**Solution:** Check AndroidManifest.xml has correct package:
```xml
<activity android:name=".MainActivity">
```
The dot (.) means it will use the namespace from `android:namespace` in build.gradle.

### Issue 3: Build still fails with old package references
**Solution:** Search for any remaining references:
```powershell
cd "C:\Users\afjal\Documents\Final destination\Mindful-main\android"
Get-ChildItem -Recurse -Include "*.kt","*.xml" | Select-String "com.mindful.android" | Select-Object Path, LineNumber, Line
```

### Issue 4: Files not moving
**Solution:** Make sure no files are open in any editor, close Android Studio if running.

---

## 🎯 Quick Command Summary

For those who want to copy-paste all commands at once:

```powershell
# 1. Navigate to project
cd "C:\Users\afjal\Documents\Final destination\Mindful-main"

# 2. Create new directory structure (manual - see Step 2 above)

# 3. Move files (manual - see Step 3 above)

# 4. Update package declarations
cd "android\app\src\main\kotlin\com\nlp\digitox"
Get-ChildItem -Recurse -Filter "*.kt" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace 'package com\.mindful\.android', 'package com.nlp.digitox'
    Set-Content $_.FullName -Value $newContent -NoNewline
}

# 5. Update imports
Get-ChildItem -Recurse -Filter "*.kt" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace 'import com\.mindful\.android', 'import com.nlp.digitox'
    Set-Content $_.FullName -Value $newContent -NoNewline
}

# 6. Delete old directory (manual - see Step 6 above)

# 7. Clean and rebuild
cd "C:\Users\afjal\Documents\Final destination\Mindful-main"
flutter clean
Remove-Item -Recurse -Force "android\app\build" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "android\.gradle" -ErrorAction SilentlyContinue
flutter pub get

# 8. Build
flutter build apk --debug

# 9. Run
flutter run
```

---

## 📞 Need Help?

If you encounter issues not covered here:
1. Check the error message carefully
2. Search for the specific error online
3. Verify all steps were completed in order
4. Try cleaning the build cache again

---

**Good luck! 🚀**

Once completed, your app will be fully migrated to the new package name `com.nlp.digitox`!
