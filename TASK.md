# Task: Fix shorts-blocking / tamper-protection permissions resetting

## Root cause summary
1. **Confirmed code bug**: `PermissionsHelper.kt`'s
   `getAndAskAccessibilityPermission()` (line ~79) checks whether the
   `MindfulAccessibilityService` process happens to be alive right now
   (`Utils.isServiceRunning()`), not whether the user has actually granted
   the accessibility permission in Android Settings. OEMs (and Android's
   own Doze/App Standby) routinely kill idle background/accessibility
   services after a couple hours — the OS-level permission is untouched,
   but this check misreports it as revoked.
2. **Contributing factor**: battery-optimization exemption already exists
   in the app (`BatteryPermissionTile` / `haveIgnoreOptimizationPermission`)
   but is optional, not required during onboarding — most users never grant
   it, so OEM battery managers kill the service more often than they need
   to.
3. **Tamper protection (Device Admin)** is checked via the correct OS API
   (`isAdminActive()`), which isn't process-dependent — if this is
   genuinely resetting too, it's most likely real OEM-level revocation
   (common on Xiaomi/Oppo/Vivo/Samsung for apps without "Autostart"
   enabled), not an app logic bug. Needs mitigation/guidance, not a code
   fix to the check itself.

---

## TASK A — Fix the accessibility permission check (the definite bug)

### A.1 Replace the process-liveness check with a real permission check
File: `android/app/src/main/java/com/nlp/digitox/helpers/device/PermissionsHelper.kt`,
`getAndAskAccessibilityPermission()` (~line 79).

Replace the `Utils.isServiceRunning(...)` check with one that reads
Android's actual accessibility-services record, e.g.:
```kotlin
fun isAccessibilityServiceEnabled(context: Context): Boolean {
    val expectedComponentName = ComponentName(context, MindfulAccessibilityService::class.java)
    val enabledServicesSetting = Settings.Secure.getString(
        context.contentResolver,
        Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
    ) ?: return false

    val colonSplitter = TextUtils.SimpleStringSplitter(':')
    colonSplitter.setString(enabledServicesSetting)
    while (colonSplitter.hasNext()) {
        val componentName = ComponentName.unflattenFromString(colonSplitter.next())
        if (componentName != null && componentName == expectedComponentName) {
            return true
        }
    }
    return false
}
```
Use this (or the equivalent `AccessibilityManager.getEnabledAccessibilityServiceList()`
approach) in place of `Utils.isServiceRunning()` inside
`getAndAskAccessibilityPermission()`.

### A.2 Don't discard the liveness check entirely — use it for a different purpose
`isServiceRunning()` isn't useless — it's actually useful for detecting
"permission granted but service process is currently dead," which is a
real, different state from "permission not granted." Consider exposing
both signals separately (e.g. `haveAccessibilityPermission` vs a new
`isAccessibilityServiceActive`), so the app can distinguish:
- Not granted → show the grant flow (Settings.ACTION_ACCESSIBILITY_SETTINGS)
- Granted but currently killed → don't ask the user to re-grant anything;
  instead trigger Task B's restart logic, or at most show a lightweight
  "reconnecting protection..." indicator, not a re-permission prompt.

### A.3 Verify
Force-kill the accessibility service process manually (via ADB:
`adb shell am force-stop com.nlp.digitox` or by leaving the device idle for
a few hours on a real device, ideally a MIUI/ColorOS device since those are
the most aggressive), then reopen the app and confirm shorts blocking no
longer prompts for permission it already has.

---

## TASK B — Make the accessibility service more resilient to being killed

Fixing the check (Task A) stops the false "please re-grant" prompt, but if
the OS genuinely killed the service, shorts blocking is actually not
running until something rebinds it. Two complementary approaches:

### B.1 Rely on Android's own service reconnection where possible
`AccessibilityService` is meant to be automatically rebound by the system
`AccessibilityManager` framework when needed. Confirm
`MindfulAccessibilityService`'s manifest declaration
(`android:canRetrieveWindowContent`, service `<intent-filter>`, and the
`accessibilityservice` XML config) don't have flags that would prevent
normal auto-rebind — read the manifest entry and the accessibility service
config XML and compare against Android's documented requirements for
reliable rebinding.

### B.2 Add a lightweight heartbeat/restart nudge
Where feasible, add a periodic check (e.g. via `WorkManager` or the
existing alarm/receiver infrastructure already used elsewhere in this repo
— see `lib/core/database/tables/bedtime_schedule_table.dart`'s alarm
patterns for a precedent) that detects "permission granted but service not
currently active" and prompts the system to rebind it, or at minimum
surfaces a clear, low-friction in-app nudge ("Shorts blocking paused —
tap to resume") rather than the current full re-permission flow.

---

## TASK C — Make battery-optimization exemption part of the guided setup

### C.1 Surface it earlier and more prominently
Right now `BatteryPermissionTile` is optional and easy to miss. Since it
directly reduces how often OEMs kill the accessibility service, move it
into the flow the user sees when first enabling Shorts Blocking (or
Tamper Protection) — not necessarily into the hard-required onboarding gate
(that's a bigger decision), but at minimum a clear "recommended" prompt
right when the user turns on either feature for the first time.

### C.2 Add OEM-specific "autostart"/background permission guidance
Battery optimization exemption alone doesn't cover every OEM's extra
restrictions (Xiaomi's "Autostart," Oppo/Vivo's "Startup Manager," etc.).
Consider adding manufacturer-specific deep-link guidance (there are known
Intent actions per-OEM for these settings screens, or a package like
`disable_battery_optimization` on pub.dev already catalogs them) so users
on the most aggressive OEMs get pointed at the right screen instead of
generic Android battery settings that don't actually cover it.

---

## TASK D — Harden tamper protection (Device Admin) against OEM revocation

### D.1 Confirm this is actually happening, and how often
Since the check itself (`isAdminActive()`) is correct, first confirm
whether Device Admin is genuinely being revoked (test on a Xiaomi/Oppo
device with Autostart disabled, left idle for a few hours) versus the user
conflating it with the Shorts Blocking issue because both live on the same
permissions screen. This changes how much engineering effort D.2 deserves.

### D.2 If confirmed, mitigate rather than "fix" (there's no code bug to fix)
- Point users toward disabling battery optimization + enabling Autostart
  for this app (same guidance as Task C.2) — the leading cause of OEMs
  revoking Device Admin registration.
- Add a periodic check (app open, or a background heartbeat) that detects
  Device Admin has been silently revoked and shows a clear one-tap way to
  re-enable it, rather than the user discovering it's broken only when
  tamper protection fails silently.

---

## Suggested execution order
1. Task A (fix the definite false-negative bug — biggest, most reliable win)
2. Task C (battery optimization guidance — reduces how often the OS kills
   the service in the first place, benefits both A and D)
3. Task B (resilience/auto-restart — deeper fix, more effort)
4. Task D (Device Admin hardening — only worth deep investment once D.1
   confirms it's a real, frequent issue and not just perception)

## Acceptance checklist
- [ ] Accessibility permission check reads the real OS permission record,
      not process liveness
- [ ] Force-killing the accessibility service process no longer triggers a
      false "please grant permission" prompt
- [ ] Battery optimization exemption is surfaced clearly when Shorts
      Blocking / Tamper Protection are first enabled
- [ ] (If pursued) OEM-specific autostart guidance added for at least
      Xiaomi/Oppo/Vivo
- [ ] (If pursued) Lightweight restart/reconnect nudge exists instead of a
      full re-permission flow when the service is found killed but still
      permitted
- [ ] Confirmed whether Device Admin revocation is real and frequent
      before investing further engineering time in Task D
- [ ] Tested on at least one aggressive OEM device (Xiaomi/Oppo/Vivo), not
      just a stock/Pixel emulator — this class of bug won't reproduce on
      stock Android