# Visual Guide: Android Package Migration

## 📂 Before Migration

```
android/
└── app/
    └── src/
        └── main/
            ├── java/
            │   ├── com/
            │   │   └── mindful/           ← OLD LOCATION
            │   │       └── android/        ← ALL .kt FILES HERE
            │   │           ├── MainActivity.kt
            │   │           ├── MindfulVpnService.kt
            │   │           ├── broadcastReceivers/
            │   │           ├── database/
            │   │           ├── finders/
            │   │           ├── models/
            │   │           ├── overlays/
            │   │           ├── permissions/
            │   │           ├── receivers/
            │   │           ├── services/
            │   │           ├── tiles/
            │   │           ├── utils/
            │   │           └── widgets/
            │   └── io/
            │       └── flutter/
            └── res/
                └── [resource files]
```

## 📂 After Migration

```
android/
└── app/
    └── src/
        └── main/
            ├── java/
            │   ├── com/
            │   │   └── nlp/               ← NEW LOCATION
            │   │       └── digitox/        ← ALL .kt FILES HERE
            │   │           ├── MainActivity.kt
            │   │           ├── MindfulVpnService.kt
            │   │           ├── broadcastReceivers/
            │   │           ├── database/
            │   │           ├── finders/
            │   │           ├── models/
            │   │           ├── overlays/
            │   │           ├── permissions/
            │   │           ├── receivers/
            │   │           ├── services/
            │   │           ├── tiles/
            │   │           ├── utils/
            │   │           └── widgets/
            │   └── io/
            │       └── flutter/
            └── res/
                └── [resource files]
```

---

## 🔄 Migration Process

### Step 1: Create New Folders
```
📁 android/app/src/main/java/com/
├── mindful/                    (exists - don't touch yet)
└── nlp/                        ← CREATE THIS
    └── digitox/                ← CREATE THIS
```

### Step 2: Copy Files
```
COPY from:  android/app/src/main/java/com/mindful/android/
PASTE to:   android/app/src/main/java/com/nlp/digitox/

Result: Files exist in BOTH locations now
```

### Step 3: Update Package Names ⚠️ CANNOT BE AUTOMATED

You must **manually** update EVERY `.kt` file. Open VS Code:

1. Press `Ctrl+Shift+H` (Find and Replace in Files)
2. **Find what:** `package com.mindful.android`
3. **Replace with:** `package com.nlp.digitox`
4. **Files to include:** `android/app/src/main/java/com/nlp/digitox/**/*.kt`
5. Click "Replace All" button

**Example changes:**
- `MainActivity.kt` → `package com.nlp.digitox`
- `services/AppShutdownService.kt` → `package com.nlp.digitox.services`
- `utils/Utils.kt` → `package com.nlp.digitox.utils`

**Important:** You'll see a preview of all changes. Review them before confirming!

### Step 4: Delete Old Folder
```
📁 android/app/src/main/java/com/
├── mindful/                    ← DELETE THIS ENTIRE FOLDER
└── nlp/                        ← KEEP THIS
    └── digitox/                ← KEEP THIS
```

### Step 5: Clean & Build
```powershell
flutter clean    # Removes all build cache
flutter pub get  # Refreshes dependencies
flutter run      # Builds and runs app
```

---

## 📝 Package Declaration Examples

### MainActivity.kt

**Before:**
```kotlin
package com.mindful.android

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
```

**After:**
```kotlin
package com.nlp.digitox

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
```

### services/AppShutdownService.kt

**Before:**
```kotlin
package com.mindful.android.services

import com.mindful.android.utils.Utils
```

**After:**
```kotlin
package com.nlp.digitox.services

import com.nlp.digitox.utils.Utils
```

### utils/Utils.kt

**Before:**
```kotlin
package com.mindful.android.utils

import com.mindful.android.models.SomeModel
```

**After:**
```kotlin
package com.nlp.digitox.utils

import com.nlp.digitox.models.SomeModel
```

---

## ⚠️ Common Mistakes to Avoid

### ❌ Mistake 1: Only updating MainActivity
```kotlin
// Don't just update MainActivity.kt!
// You need to update ALL .kt files in ALL subdirectories!
```

### ❌ Mistake 2: Forgetting imports
```kotlin
// Old imports also need updating:
import com.mindful.android.utils.Utils  ← WRONG

// Should be:
import com.nlp.digitox.utils.Utils      ← CORRECT
```

### ❌ Mistake 3: Not deleting old folder
```
// If you keep both folders, Android gets confused!
// DELETE the old com/mindful/ folder completely
```

### ❌ Mistake 4: Skipping flutter clean
```powershell
# Always run this after package migration:
flutter clean
```

---

## ✅ Success Indicators

You'll know it worked when:

1. **No compilation errors** - `flutter run` completes successfully
2. **No R class errors** - No "Unresolved reference 'R'" messages
3. **App launches** - App opens on emulator/device
4. **Features work** - All app functionality works normally

---

## 🚀 Manual Migration Steps (Cannot Be Automated)

**Step-by-step process:**

```powershell
# 1. Navigate to project
cd "c:\Users\afjal\Documents\Final destination\Mindful-main"

# 2. Open File Explorer to the Java directory
explorer "android\app\src\main\java"
```

**In File Explorer:**
- Inside `com` folder, create new folders: `nlp\digitox`
- Go to `com\mindful\android\`
- Select ALL files and folders
- Copy (Ctrl+C)
- Navigate to `com\nlp\digitox\`
- Paste (Ctrl+V)

**In VS Code:**
- Press `Ctrl+Shift+H` (Find and Replace)
- Find: `package com.mindful.android`
- Replace: `package com.nlp.digitox`
- Files to include: `android/app/src/main/java/com/nlp/digitox/**/*.kt`
- Click "Replace All"

**Back to File Explorer:**
- Delete entire `com\mindful\` folder

**Final commands:**
```powershell
cd "c:\Users\afjal\Documents\Final destination\Mindful-main"
flutter clean
flutter pub get
flutter run
```

---

**Remember:** This process requires manual steps in File Explorer and VS Code. The package declarations must be updated using VS Code's Find and Replace feature - PowerShell commands won't work reliably for this!
