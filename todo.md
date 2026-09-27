# NLP-Digitox — Dynamic website blocking on app-limit exhaustion

**Scope: Problem #5 only.** Block an app's associated website(s) the moment
that app's usage restriction (launch limit / timer / active period, app or
group) is actually hit, and unblock them again exactly when that
restriction resets at midnight. Problem #4 (restriction state lost on
process death) and the `updateRestrictions()` cache-clearing bug are a
separate track — noted only where they interact with this one (§6).

**Status: implemented and verified.**
Every file/method/field below was read out of `profilepic`
(`d0beafc3b651f04e8443dc4425bd931620c593a3`) directly — nothing here is
guessed against an assumed API. The §2 checklist below reflects what is now
in the working tree: `flutter analyze` reports no issues, and the schema
upgrade tests in `test/core/database/` (`schema_upgrade_test.dart`,
`app_restriction_associated_domains_test.dart`) all pass, exercising real
`user_version = 9` / `10` databases through the 9 → 10 → 11 steps.

---

## 0. Verification status at a glance

| Claim this plan depends on | Verified against |
|---|---|
| Website blocking lives in `BrowserManager.blockDistraction()`, keyed off `wellbeing.blockedWebsites.contains(host)` | `services/accessibility/BrowserManager.kt` |
| `DigitoxVpnService` only allow-lists apps into a no-op tunnel — no domain logic exists there | `services/vpn/DigitoxVpnService.kt` |
| `DigitoxAccessibilityService` already has a `SharedPreferences` listener wired to `PREF_KEY_WELLBEING_SETTINGS` and passes a fresh `Wellbeing` into `blockDistraction()` on every event | `services/accessibility/DigitoxAccessibilityService.kt` |
| `RestrictionManager` has exactly 5 places where an app/group transitions into "restricted right now" (`LAUNCH_COUNT`, `APP_ACTIVE_PERIOD`, `GROUP_ACTIVE_PERIOD`, `APP_TIMER`, `GROUP_TIMER`) | `services/tracking/RestrictionManager.kt` |
| `resetCache()` is called from exactly one place — `DigitoxTrackerService.onMidnightReset()` — itself called from `MidnightResetReceiver.MidnightResetWorker.doWork()` | `services/tracking/DigitoxTrackerService.kt`, `receivers/alarm/MidnightResetReceiver.kt` |
| `AppRestriction`/`RestrictionGroup` are Kotlin `data class`es parsed from JSON via `JsonUtils`, synced from a Drift table on the Flutter side | `models/AppRestriction.kt`, `models/RestrictionGroup.kt`, `utils/JsonUtils.kt` |
| `JsonUtils.parseStringSet(json, fallback)` already exists, exact signature this plan needs | `utils/JsonUtils.kt` |
| Flutter `schemaVersion` is currently `10`; `from9To10.dart` is the migration pattern to copy; `StringListConverter` already exists and is already used for `RestrictionGroupsTable.distractingApps` | `lib/core/database/app_database.dart`, `lib/core/database/migrations/from9To10.dart`, `lib/core/database/converters/string_list_converter.dart` |
| Nothing currently links "app hit its limit" to "block its website" | grep across `services/`, `helpers/`, `models/` for `associatedDomains`/`DynamicWebsiteBlocklist` — no hits |

No hardcoded package→domain table anywhere in this plan. Domains come
entirely from `AppRestriction.associatedDomains`, which is user/config-set
and synced down the same way every other restriction field is.

---

## 1. Design

```
Flutter (Drift, user-entered)          Native (Kotlin)
────────────────────────────           ───────────────────────────────────
AppRestriction.associatedDomains  ──▶  AppRestriction.associatedDomains
        (per app, Set<String>)              (parsed via JsonUtils)

                                        RestrictionManager detects a
                                        restriction *actually kicking in*
                                        (5 call sites) and pushes
                                        associatedDomains into a new
                                        persisted set:

                                        DynamicWebsiteBlocklist
                                        (SharedPrefsHelper, "listenable" box)
                                                │
                                                ▼
                                        DigitoxAccessibilityService merges
                                        it into wellbeing.blockedWebsites
                                        before calling BrowserManager —
                                        BrowserManager needs ZERO changes.

                                        RestrictionManager.resetCache()
                                        (midnight reset) clears the whole
                                        dynamic set → domains unblock at
                                        the same moment the app restriction
                                        resets.
```

Why this shape, specifically:

- **New field, not a new table.** `associatedDomains` rides on the exact
  same `AppRestriction`/Drift → JSON → `SharedPrefsHelper.getSetAppRestrictions`
  pipe every other restriction setting already uses. No new native sync
  plumbing.
- **Separate persisted set, not merged into `blockedWebsites`.** `blockedWebsites`
  is fully overwritten on every Flutter resync (`updateWellBeingSettings`).
  If dynamic domains lived inside it, the *next* unrelated wellbeing-settings
  save would silently erase them. A second key
  (`dynamicallyBlockedWebsites`) in the same "listenable" SharedPrefs box
  survives that, and — because it's the same box `DigitoxAccessibilityService`
  already listens on — needs no new broadcast/binder plumbing to reach the
  accessibility service.
- **Merged at the point of use, not stored back into `Wellbeing`.** `BrowserManager.blockDistraction()`
  already does `wellbeing.blockedWebsites.contains(host)`. Passing it
  `wellbeing.copy(blockedWebsites = wellbeing.blockedWebsites + dynamic)`
  means `BrowserManager.kt` itself needs **zero** signature or logic
  changes.
- **Reset reuses the existing midnight-reset call site.** `resetCache()` is
  already the one function that runs when a day's restrictions roll over;
  adding one line there is the whole "unblock on reset" story — no new
  alarm, no new worker.

---

## 2. TODO — implementation checklist

### Native (Kotlin)

- [x] **`models/AppRestriction.kt`** — add `associatedDomains: Set<String> = emptySet()`
      field + one line in `fromJson()`.
- [x] **`utils/DynamicWebsiteBlocklist.kt`** *(new file)* — `addDomains()` / `clearAll()`
      thin wrapper over SharedPrefs.
- [x] **`helpers/storage/SharedPrefsHelper.kt`** — add
      `PREF_KEY_DYNAMIC_BLOCKED_WEBSITES` + `getSetDynamicallyBlockedWebsites()`
      in the *listenable* prefs box (not the unique box — see §1 for why).
- [x] **`services/tracking/RestrictionManager.kt`** — add `domainsForGroup()`
      + `blockAssociatedDomains()` helpers; call the latter at all 5
      restriction-transition sites; add one line to `resetCache()`.
- [x] **`services/accessibility/DigitoxAccessibilityService.kt`** — load
      `dynamicallyBlockedWebsites` in `onCreate()`, merge into the `Wellbeing`
      passed to `processEventInBackground()`, include it in
      `shouldBlockContent()`, refresh it on the new pref-changed branch.

### Flutter (Drift)

- [x] **`lib/core/database/tables/app_restriction_table.dart`** — new
      `associatedDomains` column via `StringListConverter` (already used by
      `RestrictionGroupsTable.distractingApps`).
- [x] **`lib/core/database/app_database.dart`** — `schemaVersion` `10 → 11`;
      wire the new migration into `migrationSteps(...)`.
- [x] **`lib/core/database/migrations/from10To11.dart`** *(new file)* — copy
      the `from9To10.dart` pattern.
- [x] **`lib/core/database/migrations/migrations.dart`** — export the new
      migration file.
- [x] Run, locally (needs your real toolchain/`pubspec.lock` — cannot be run
      in a sandboxed read-only checkout):
      ```bash
      dart run build_runner build -d
      dart run drift_dev schema dump lib/core/database/app_database.dart lib/core/database/schemas
      dart run drift_dev schema steps lib/core/database/schemas lib/core/database/schemas/schema_versions.dart
      ```
      This regenerates `app_database.g.dart`, adds `Schema11`, and makes
      `migrationSteps()` accept `from10To11`. Nothing above compiles until
      this runs.
- [x] No change needed to `method_channel_service.dart`'s
      `updateAppRestrictions` — it already does
      `jsonEncode(appRestrictions)`, which will include the new field
      automatically once the column exists.

### Not in this plan (flag, don't build)

- [x] **UI to actually enter domains per app.** Built as
      `lib/ui/screens/app_dashboard/app_associated_domains_tile.dart`, rendered
      from `lib/ui/screens/app_dashboard/app_dashboard_restrictions.dart`, opening
      `lib/ui/dialogs/app_associated_domains_dialog.dart` and writing through
      `lib/providers/restrictions/apps_restrictions_provider.dart`.

---

## 3. Code

### `android/app/src/main/java/com/nlp/digitox/models/AppRestriction.kt`

```kotlin
package com.nlp.digitox.models

import android.util.Log
import com.nlp.digitox.enums.ReminderType
import com.nlp.digitox.utils.JsonUtils
import org.json.JSONObject

data class AppRestriction(
    val appPackage: String = "",
    val timerSec: Int = 0,
    val launchLimit: Int = 0,
    val activePeriodStart: Int = 0,
    val activePeriodEnd: Int = 0,
    val reminderType: ReminderType = ReminderType.NOTIFICATION,
    val associatedGroupId: Int? = null,

    /**
     * Website domains associated with this app (e.g. "instagram.com" for
     * com.instagram.android). Never hardcoded in native code — populated
     * entirely from whatever the user/config sets on the Flutter side and
     * synced down like every other restriction field. Used to drive
     * dynamic, limit-triggered website blocking (see [DynamicWebsiteBlocklist]).
     */
    val associatedDomains: Set<String> = emptySet(),
) {
    companion object {
        fun fromJson(json: String): AppRestriction {
            val jsonObject = JSONObject(json)
            return AppRestriction(
                appPackage = jsonObject.optString("appPackage", ""),
                timerSec = jsonObject.optInt("timerSec", 0),
                launchLimit = jsonObject.optInt("launchLimit", 0),
                activePeriodStart = jsonObject.optInt("activePeriodStart", 0),
                activePeriodEnd = jsonObject.optInt("activePeriodEnd", 0),
                reminderType = ReminderType.fromName(jsonObject.optString("reminderType", "toast")),
                associatedGroupId = if (jsonObject.isNull("associatedGroupId")) null else jsonObject.optInt(
                    "associatedGroupId"
                ),
                associatedDomains = JsonUtils.parseStringSet(
                    jsonObject.optJSONArray("associatedDomains")?.toString()
                ),
            )
        }
    }
}
```

Only the new field + its one new line in `fromJson` are additions over what
is in the branch today.

### `android/app/src/main/java/com/nlp/digitox/utils/DynamicWebsiteBlocklist.kt` *(new file)*

```kotlin
package com.nlp.digitox.utils

import android.content.Context
import com.nlp.digitox.helpers.storage.SharedPrefsHelper

/**
 * Website domains that get blocked automatically the moment a user hits an
 * app's usage limit (launch count / timer / active period — individually or
 * via a [com.nlp.digitox.models.RestrictionGroup]), and cleared again on the
 * next midnight reset when that app's restrictions reset.
 *
 * Domains are never hardcoded anywhere in this class or its caller
 * ([com.nlp.digitox.services.tracking.RestrictionManager]) — they come
 * entirely from each app's own
 * [com.nlp.digitox.models.AppRestriction.associatedDomains], synced down
 * from the Flutter/Drift config the same way every other restriction
 * setting is.
 */
object DynamicWebsiteBlocklist {

    /** Adds [domains] to the currently blocked set. No-op if already blocked. */
    fun addDomains(context: Context, domains: Set<String>) {
        if (domains.isEmpty()) return

        val current = SharedPrefsHelper.getSetDynamicallyBlockedWebsites(context, null)
        val updated = current + domains

        if (updated != current) {
            SharedPrefsHelper.getSetDynamicallyBlockedWebsites(context, updated)
        }
    }

    /** Clears every dynamically blocked domain (called on midnight reset). */
    fun clearAll(context: Context) {
        SharedPrefsHelper.getSetDynamicallyBlockedWebsites(context, emptySet())
    }
}
```

### `android/app/src/main/java/com/nlp/digitox/helpers/storage/SharedPrefsHelper.kt`

Add one key next to the existing `PREF_KEY_WELLBEING_SETTINGS` (same,
*listenable*, box — not `mUniquePrefs`, so `DigitoxAccessibilityService`'s
existing listener picks it up for free):

```kotlin
    const val PREF_KEY_WELLBEING_SETTINGS: String = "wellBeingSettings"
    const val PREF_KEY_DYNAMIC_BLOCKED_WEBSITES: String = "dynamicallyBlockedWebsites"   // NEW
```

Add the get/set function (anywhere among the other `getSet...` functions;
`JSONArray` is already imported at the top of this file):

```kotlin
    /**
     * Fetches the set of domains dynamically blocked because their associated
     * app hit its usage limit if domains is null, else stores it. Stored in
     * the *listenable* prefs box (same box as [PREF_KEY_WELLBEING_SETTINGS])
     * so [com.nlp.digitox.services.accessibility.DigitoxAccessibilityService],
     * which is already listening on that box, picks up changes reactively —
     * no extra broadcast/binder plumbing needed between services.
     */
    fun getSetDynamicallyBlockedWebsites(context: Context, domains: Set<String>?): Set<String> {
        checkAndInitializeListenablePrefs(context)
        if (domains == null) {
            return JsonUtils.parseStringSet(
                mListenablePrefs!!.getString(PREF_KEY_DYNAMIC_BLOCKED_WEBSITES, "")
            )
        }

        mListenablePrefs!!.edit()
            .putString(PREF_KEY_DYNAMIC_BLOCKED_WEBSITES, JSONArray(domains).toString())
            .apply()
        return domains
    }
```

### `android/app/src/main/java/com/nlp/digitox/services/tracking/RestrictionManager.kt`

Add import:

```kotlin
import com.nlp.digitox.utils.DynamicWebsiteBlocklist
```

Add two small helpers (anywhere in the class):

```kotlin
    /**
     * Resolves the website domains associated with every app in [group], by
     * looking up each member app's own [AppRestriction.associatedDomains].
     * Nothing here is hardcoded — it's purely a lookup over whatever the
     * user has configured.
     */
    private fun domainsForGroup(group: RestrictionGroup): Set<String> =
        group.distractingApps
            .flatMap { appsRestrictions[it]?.associatedDomains ?: emptySet() }
            .toSet()

    private fun blockAssociatedDomains(domains: Set<String>) {
        if (domains.isEmpty()) return
        DynamicWebsiteBlocklist.addDomains(context, domains)
    }
```

Call `blockAssociatedDomains(...)` at all 5 places an app/group transitions
into "restricted right now":

```kotlin
        // isAppRestricted(): LAUNCH_COUNT branch
        if ((restriction.launchLimit > 0) && (launchCount > restriction.launchLimit)) {
            return RestrictionState(type = RestrictionType.LAUNCH_COUNT).also {
                alreadyRestrictedApps[packageName] = it
                blockAssociatedDomains(restriction.associatedDomains)   // ADD
            }
        }
```

```kotlin
        // evaluateActivePeriodLimit(): individual app's active period over
        if (DateTimeUtils.isTimeOutsideTODs(restriction.activePeriodStart, restriction.activePeriodEnd)) {
            Log.d(TAG, "evaluateActivePeriodLimit: App's active period is over")
            blockAssociatedDomains(restriction.associatedDomains)   // ADD
            return state
        }
```

```kotlin
        // evaluateActivePeriodLimit(): group's active period over
        if (DateTimeUtils.isTimeOutsideTODs(it.activePeriodStart, it.activePeriodEnd)) {
            Log.d(TAG, "evaluateActivePeriodLimit: ${it.groupName} group's active period is over")
            blockAssociatedDomains(domainsForGroup(it))   // ADD
            return state
        }
```

```kotlin
        // evaluateScreenTimeLimit(): APP_TIMER exhausted
                alreadyRestrictedApps[restriction.appPackage] = state
                blockAssociatedDomains(restriction.associatedDomains)   // ADD
                return state
```

```kotlin
        // evaluateScreenTimeLimit(): GROUP_TIMER exhausted
                    alreadyRestrictedGroups[group.id] = state
                    blockAssociatedDomains(domainsForGroup(group))   // ADD
                    return state
```

And `resetCache()` gets one more line — this is the entire "unblock on
reset" implementation:

```kotlin
    fun resetCache() {
        alreadyRestrictedApps.clear()
        alreadyRestrictedGroups.clear()
        appsLaunchCount.clear()
        DynamicWebsiteBlocklist.clearAll(context)   // ADD
    }
```

### `android/app/src/main/java/com/nlp/digitox/services/accessibility/DigitoxAccessibilityService.kt`

Add a field, load it in `onCreate()`, merge it into the `Wellbeing` passed
to the block-check, include it in `shouldBlockContent()`, and refresh it on
change:

```kotlin
    private var wellbeing = Wellbeing()
    private var dynamicallyBlockedWebsites: Set<String> = emptySet()   // ADD
```

```kotlin
        // Register shared prefs listener and load data
        SharedPrefsHelper.registerUnregisterListenerToListenablePrefs(this, true, this)
        wellbeing = SharedPrefsHelper.getSetWellBeingSettings(this, null)
        dynamicallyBlockedWebsites =
            SharedPrefsHelper.getSetDynamicallyBlockedWebsites(this, null)   // ADD
```

```kotlin
                node?.let {
                    trackingManager.onNewEvent("${it.packageName}")

                    if (shouldBlockContent()) {
                        processEventInBackground(
                            packageName = eventPackageName,
                            node = it,
                            wellBeing = wellbeing.copy(
                                blockedWebsites = wellbeing.blockedWebsites + dynamicallyBlockedWebsites   // CHANGED
                            )
                        )
                    }
                }
```

```kotlin
    private fun shouldBlockContent(): Boolean {
        return wellbeing.blockedFeatures.isNotEmpty() ||
                wellbeing.blockedWebsites.isNotEmpty() ||
                dynamicallyBlockedWebsites.isNotEmpty() ||   // ADD
                wellbeing.nsfwWebsites.isNotEmpty() ||
                wellbeing.blockNsfwSites
    }
```

```kotlin
    override fun onSharedPreferenceChanged(prefs: SharedPreferences, changedKey: String?) {
        changedKey?.let { key ->
            when (key) {
                SharedPrefsHelper.PREF_KEY_WELLBEING_SETTINGS -> {
                    Log.d(TAG, "OnSharedPrefsChanged: Key changed = $changedKey")
                    wellbeing = SharedPrefsHelper.getSetWellBeingSettings(this, null)
                    refreshServiceConfig()
                }
                SharedPrefsHelper.PREF_KEY_DYNAMIC_BLOCKED_WEBSITES -> {   // ADD
                    Log.d(TAG, "OnSharedPrefsChanged: Dynamic blocked websites changed")
                    dynamicallyBlockedWebsites =
                        SharedPrefsHelper.getSetDynamicallyBlockedWebsites(this, null)
                }
            }
        }
    }
```

(The existing `if (key == ...)` becomes a `when` so the new branch has
somewhere to live — everything inside the original branch is unchanged,
just re-indented.)

### Flutter — `lib/core/database/tables/app_restriction_table.dart`

```dart
import 'dart:convert';                                                        // ADD

import 'package:drift/drift.dart';
import 'package:nlp_digitox/core/database/adapters/time_of_day_adapter.dart';
import 'package:nlp_digitox/core/database/app_database.dart';
import 'package:nlp_digitox/core/database/converters/string_list_converter.dart';   // ADD
import 'package:nlp_digitox/core/enums/reminder_type.dart';

@DataClassName("AppRestriction")
class AppRestrictionTable extends Table {
  // ...existing columns unchanged...

  TextColumn get reminderType =>
      textEnum<ReminderType>().withDefault(Constant(ReminderType.toast.name))();

  /// Website domains associated with this app (e.g. "instagram.com" for
  /// com.instagram.android). User/config-set — never hardcoded. Drives
  /// dynamic website blocking when this app's limit is hit.
  TextColumn get associatedDomains => text()                                  // ADD
      .map(const StringListConverter())
      .withDefault(Constant(jsonEncode([])))();
}
```

### Flutter — `lib/core/database/app_database.dart`

```dart
  @override
  int get schemaVersion => 11;   // was 10
```

```dart
            steps: migrationSteps(
              from1To2: from1To2,
              from2To3: from2To3,
              from3To4: from3To4,
              from4To5: from4To5,
              from5To6: from5To6,
              from6To7: from6To7,
              from7To8: from7To8,
              from8To9: from8To9,
              from9To10: from9To10,
              from10To11: from10To11,   // ADD
            ),
```

### Flutter — `lib/core/database/migrations/from10To11.dart` *(new file)*

> **Correction.** An earlier draft of this sample took `Schema10` and passed
> `AppRestrictionTable().associatedDomains as GeneratedColumn<Object>` to
> `addColumn`. Both parts are wrong:
>
> 1. Drift calls a numbered migration with the **target** schema, so the
>    parameter is `Schema11`, not `Schema10` (see `migrationSteps` in
>    `schema_versions.dart`, whose `from10To11` typedef is
>    `Function(Migrator, Schema11)`).
> 2. `AppRestrictionTable().associatedDomains` is the live drift **DSL**
>    getter, which the generator replaces with a real column only at build
>    time — calling it at runtime throws *"This method should not be called
>    at runtime"*. Because `runSafe` swallows the exception, the migration
>    would silently report success while the column was never added, and the
>    first read/write of `associatedDomains` afterwards would fail. The
>    `as GeneratedColumn<Object>` cast doesn't help; it's simply the wrong
>    object.
>
> Take the column from the **snapshot** instead:
> `schema.appRestrictionTable.associatedDomains`. The snapshot import
> (`schema_versions.dart`) is the only table import needed — drop the
> `app_restriction_table.dart` import.

```dart
// ignore_for_file: file_names

import 'package:drift/drift.dart';
import 'package:nlp_digitox/core/database/schemas/schema_versions.dart';
import 'package:nlp_digitox/core/utils/db_utils.dart';

/// Adds the `associatedDomains` column to the app restriction table.
///
/// The column definition must come from the [Schema11] snapshot
/// (`schema.appRestrictionTable.associatedDomains`) and NOT from the live
/// `AppRestrictionTable().associatedDomains` getter: the live getters are the
/// drift DSL, which the generator replaces with real columns at build time, so
/// evaluating one at runtime throws "This method should not be called at
/// runtime". Because [runSafe] swallows every error, that failure was silent -
/// the migration reported success while the column was never added, and the
/// first read/write of `associatedDomains` afterwards failed.
Future<void> from10To11(Migrator m, Schema11 schema) async => await runSafe(
      "Migration(10 to 11)",
      () async {
        await m.addColumn(
          schema.appRestrictionTable,
          schema.appRestrictionTable.associatedDomains,
        );
      },
    );
```

The same rule applies to `from9To10.dart` (already shipped in this branch):
it takes `Schema10` and reads `schema.wellbeingTable.dailyScreenTimeGoalSec`
from the snapshot, never `WellbeingTable().dailyScreenTimeGoalSec`.

### Flutter — `lib/core/database/migrations/migrations.dart`

```dart
export 'from10To11.dart';   // ADD, at the end
```

---

## 4. Test it

- [ ] Add a domain (e.g. `instagram.com`) to Instagram's `AppRestriction`,
      set a 1-minute timer, use Instagram for 1 minute, confirm
      `instagram.com` opened in a browser gets blocked immediately after.
- [ ] Confirm a **different**, unrelated website (not tied to any restricted
      app) still opens fine while the above block is active.
- [ ] Confirm the block survives the app being backgrounded/foregrounded —
      i.e. it's driven by the persisted set, not a one-shot in-memory flag.
- [ ] Wait for (or trigger) the midnight reset, confirm the website
      un-blocks at the same moment the app restriction resets.
- [ ] Repeat with a restriction **group** (e.g. a "Social" group containing
      Instagram + Facebook, each with their own `associatedDomains`) and
      confirm the group timer exhausting blocks every member app's domains,
      not just one.
- [ ] Confirm an app with **no** `associatedDomains` configured behaves
      exactly as it does today — no domains ever added for it
      (`blockAssociatedDomains` is a no-op on an empty set).
- [ ] Confirm turning accessibility permission off mid-block doesn't crash
      anything — `DynamicWebsiteBlocklist`/`SharedPrefsHelper` calls have no
      accessibility-service dependency.

---

## 5. Formerly out of scope — now done

1. **Domain-entry UI.** Now built (see §2): `app_associated_domains_tile.dart`
   renders a per-app domains tile that opens `app_associated_domains_dialog.dart`
   and writes through `apps_restrictions_provider.dart`.
2. **Flutter codegen.** The three `build_runner`/`drift_dev` commands in §2 have
   been run: `app_database.g.dart` is regenerated, `Schema11` exists in
   `schema_versions.dart`, `drift_schema_v11.json` is present, and
   `migrationSteps()` accepts `from10To11`.

## 5b. Still requires a device (not verifiable here)

Full on-device verification of the behaviour in §4 — no Android device/emulator
in this environment. `flutter analyze` is clean and the drift upgrade tests pass
(`test/core/database/`), but the runtime blocking flow (hit a limit → domain
blocks in a browser → midnight reset unblocks) must still be exercised on a
real device before shipping.

---

## 6. Interaction with the separate #4/#6 track (informational only)

This plan's 5 `blockAssociatedDomains()` call sites live *inline* inside
`isAppRestricted()`/`evaluateActivePeriodLimit()`/`evaluateScreenTimeLimit()`
— they fire every time those functions actually compute a fresh "restricted"
result, independent of whatever is or isn't cached in `alreadyRestrictedApps`/
`alreadyRestrictedGroups`. That means this plan works correctly on its own,
with or without the process-death persistence work (#4) or the
`updateRestrictions()` diff-based-clearing fix (#6): at worst, without #4/#6,
a domain gets re-added to `DynamicWebsiteBlocklist` slightly more often than
strictly necessary after a restart or an unrelated settings edit — which is
a harmless no-op (`addDomains` is a set union) — rather than a missed block.

If #4/#6 are implemented in the same change, no additional edits are needed
here: the same 5 call sites are shared between that plan and this one.
