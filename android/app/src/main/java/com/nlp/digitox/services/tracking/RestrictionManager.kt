package com.nlp.digitox.services.tracking

import android.app.Service.USAGE_STATS_SERVICE
import android.app.usage.UsageStatsManager
import android.content.Context
import android.util.Log
import com.nlp.digitox.enums.RestrictionType
import com.nlp.digitox.helpers.storage.SharedPrefsHelper
import com.nlp.digitox.helpers.usages.ScreenUsageHelper
import com.nlp.digitox.models.AppRestriction
import com.nlp.digitox.models.RestrictionGroup
import com.nlp.digitox.models.RestrictionState
import com.nlp.digitox.utils.DateTimeUtils
import com.nlp.digitox.utils.DynamicWebsiteBlocklist
import org.json.JSONObject

class RestrictionManager(
    private val context: Context,
    private val usageStatsManager: UsageStatsManager = context.getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager,
) {
    private val TAG = "Digitox.RestrictionManager"

    private companion object {
        const val KEY_RESTRICTED_APPS = "restrictedApps"
        const val KEY_RESTRICTED_GROUPS = "restrictedGroups"
        const val KEY_LAUNCH_COUNTS = "launchCounts"
    }

    // Restrictions
    private var appsRestrictions = HashMap<String, AppRestriction>()
    private var restrictionGroups = HashMap<Int, RestrictionGroup>()

    // Focus
    private var focusedApps = setOf<String>()
    private var bedtimeApps = setOf<String>()

    //  Cache
    private val appsLaunchCount = HashMap<String, Int>(0)
    val getAppsLaunchCount: HashMap<String, Int> get() = appsLaunchCount

    private val alreadyRestrictedApps = HashMap<String, RestrictionState>(0)
    private val alreadyRestrictedGroups = HashMap<Int, RestrictionState>(0)

    /**
     * Set by [evaluateRestriction] whenever the in-memory caches above change, so the public
     * entry points can write the runtime state to disk exactly once per evaluation instead of
     * once per mutation.
     */
    private var runtimeStateDirty = false

    init {
        // Restore the configured restrictions first so the diff in updateRestrictions() can
        // recognise the config re-pushed by the service on start-up as "unchanged" and leave the
        // restored runtime state alone.
        appsRestrictions = SharedPrefsHelper.getSetAppRestrictions(context, null)
        restrictionGroups = SharedPrefsHelper.getSetRestrictionGroups(context, null)
        restoreRuntimeState()
    }

    fun resetCache() {
        alreadyRestrictedApps.clear()
        alreadyRestrictedGroups.clear()
        appsLaunchCount.clear()

        // Unblock every website that was blocked because its associated app hit a limit, at the
        // same moment the underlying app restrictions reset.
        DynamicWebsiteBlocklist.clearAll(context)

        // Clear the persisted copy too, otherwise the next process would restore the state this
        // reset just discarded.
        persistRuntimeState()
    }

    /**
     * Resolves the website domains associated with every app in [group], by
     * looking up each member app's own [AppRestriction.associatedDomains].
     * Nothing here is hardcoded - it's purely a lookup over whatever the
     * user has configured.
     */
    private fun domainsForGroup(group: RestrictionGroup): Set<String> =
        group.distractingApps
            .flatMap { appsRestrictions[it]?.associatedDomains ?: emptySet() }
            .toSet()

    /**
     * Registers [domains] as dynamically blocked because their associated app
     * just transitioned into "restricted right now". No-op for an empty set,
     * so apps without any configured [AppRestriction.associatedDomains] behave
     * exactly as they did before.
     */
    private fun blockAssociatedDomains(domains: Set<String>) {
        if (domains.isEmpty()) return
        DynamicWebsiteBlocklist.addDomains(context, domains)
    }

    fun updateRestrictions(
        appsRestrictionsMap: HashMap<String, AppRestriction>?,
        restrictionGroupsMap: HashMap<Int, RestrictionGroup>?,
    ) {
        // NOTE: every caller (DigitoxTrackerService.restoreRestrictionsFromPrefs() on each
        // service (re)start, FgMethodCallHandler.restoreAllSettingsOnReconnect() on each Flutter
        // reconnect, and the updateAppRestrictions/updateRestrictionsGroups handlers fed by the
        // Flutter provider which resends the FULL list on every single edit) passes the complete
        // config map rather than a delta. Clearing alreadyRestrictedApps/Groups wholesale
        // therefore threw away the runtime state restored from disk on every restart and wiped
        // App A's "already exhausted" flag whenever only App B was edited. Diffing against the
        // previous config so only genuinely changed/removed entries are invalidated fixes both.
        var changed = false

        appsRestrictionsMap?.let { newMap ->
            val affected = (appsRestrictions.keys + newMap.keys).filter { pkg ->
                appsRestrictions[pkg] != newMap[pkg]
            }
            affected.forEach { pkg ->
                alreadyRestrictedApps.remove(pkg)
                appsLaunchCount.remove(pkg)
            }
            appsRestrictions = newMap

            val orphanedStates = alreadyRestrictedApps.keys.filterNot { newMap.containsKey(it) }
            orphanedStates.forEach { alreadyRestrictedApps.remove(it) }
            val orphanedCounts = appsLaunchCount.keys.filterNot { newMap.containsKey(it) }
            orphanedCounts.forEach { appsLaunchCount.remove(it) }

            changed = changed || affected.isNotEmpty() ||
                    orphanedStates.isNotEmpty() || orphanedCounts.isNotEmpty()

            Log.d(
                TAG,
                "updateRestrictions: Apps restrictions updated " +
                        "(${affected.size} changed/removed, ${orphanedStates.size} orphaned)"
            )
        }

        restrictionGroupsMap?.let { newMap ->
            val affected = (restrictionGroups.keys + newMap.keys).filter { id ->
                restrictionGroups[id] != newMap[id]
            }
            affected.forEach { id -> alreadyRestrictedGroups.remove(id) }
            restrictionGroups = newMap

            val orphanedGroups = alreadyRestrictedGroups.keys.filterNot { newMap.containsKey(it) }
            orphanedGroups.forEach { alreadyRestrictedGroups.remove(it) }

            changed = changed || affected.isNotEmpty() || orphanedGroups.isNotEmpty()

            Log.d(
                TAG,
                "updateRestrictions: Restriction groups updated " +
                        "(${affected.size} changed/removed, ${orphanedGroups.size} orphaned)"
            )
        }

        // A restart that re-pushes an identical config performs zero extra SharedPrefs writes.
        if (changed) persistRuntimeState()
    }

    fun updateFocusedApps(apps: Set<String>?) {
        focusedApps = apps ?: emptySet()
        Log.d(TAG, "updateFocusedApps: Focus apps updated: $focusedApps")
    }

    fun updateBedtimeApps(apps: Set<String>?) {
        bedtimeApps = apps ?: emptySet()
        Log.d(TAG, "updateBedtimeApps: Bedtime apps updated: $bedtimeApps")
    }


    // returns nearest time stamp for rechecking
    fun isAppRestricted(packageName: String): RestrictionState? {
        runtimeStateDirty = false
        val state = evaluateRestriction(packageName)
        if (runtimeStateDirty) {
            runtimeStateDirty = false
            persistRuntimeState()
        }
        return state
    }

    private fun evaluateRestriction(packageName: String): RestrictionState? {
        // If already restricted by focus or bedtime or cached
        val alreadyRestrictedState = evaluateIfAlreadyRestricted(packageName)
        if (alreadyRestrictedState != null) {
            return alreadyRestrictedState
        }

        // If no restrictions
        val restriction = appsRestrictions[packageName] ?: return null

        // Increment and Check app launch count
        val launchCount = appsLaunchCount.getOrDefault(packageName, 0) + 1
        if ((restriction.launchLimit > 0) && (launchCount > restriction.launchLimit)) {
            alreadyRestrictedApps[packageName] = RestrictionState(type = RestrictionType.LAUNCH_COUNT)
            blockAssociatedDomains(restriction.associatedDomains)
            runtimeStateDirty = true
            return alreadyRestrictedApps[packageName]
        }
        appsLaunchCount[packageName] = launchCount
        runtimeStateDirty = true

        val futureStates: MutableSet<RestrictionState> = mutableSetOf()

        /// evaluate active periods
        evaluateActivePeriodLimit(restriction, futureStates)?.let { return it }

        /// Evaluate screen time
        evaluateScreenTimeLimit(restriction, futureStates)?.let { return it }

        /// Return the nearest expiration
        if (futureStates.isNotEmpty()) {
            val nearestFutureState = futureStates.minBy { it.timeLeftMillis }
            return nearestFutureState
        } else {
            return null
        }
    }

    private fun evaluateIfAlreadyRestricted(packageName: String): RestrictionState? {
        return when {
            focusedApps.contains(packageName) -> RestrictionState(
                type = RestrictionType.FOCUS
            )

            bedtimeApps.contains(packageName) -> RestrictionState(
                type = RestrictionType.BEDTIME,
            )

            alreadyRestrictedApps.containsKey(packageName) -> alreadyRestrictedApps[packageName]
            else -> null
        }
    }


    private fun evaluateActivePeriodLimit(
        restriction: AppRestriction,
        futureState: MutableSet<RestrictionState>,
    ): RestrictionState? {

        /// Check app's active period
        if (restriction.activePeriodStart != restriction.activePeriodEnd) {
            val state = RestrictionState(type = RestrictionType.APP_ACTIVE_PERIOD)

            /// Outside active period
            if (DateTimeUtils.isTimeOutsideTODs(
                    restriction.activePeriodStart,
                    restriction.activePeriodEnd
                )
            ) {
                Log.d(TAG, "evaluateActivePeriodLimit: App's active period is over")
                blockAssociatedDomains(restriction.associatedDomains)
                return state
            }
            /// Launched between active period calculate expiration time
            else {
                val willOverInMs = DateTimeUtils.todDifferenceFromNow(restriction.activePeriodEnd)
                futureState.add(state.copy(timeLeftMillis = willOverInMs))
            }
        }


        /// Check group's active period
        restrictionGroups[restriction.associatedGroupId]?.let {
            if (it.activePeriodStart != it.activePeriodEnd) {
                val state = RestrictionState(
                    type = RestrictionType.GROUP_ACTIVE_PERIOD,
                    groupName = it.groupName,
                )
                /// Outside active period
                if (DateTimeUtils.isTimeOutsideTODs(it.activePeriodStart, it.activePeriodEnd)) {
                    Log.d(
                        TAG,
                        "evaluateActivePeriodLimit: ${it.groupName} group's active period is over"
                    )
                    blockAssociatedDomains(domainsForGroup(it))
                    return state
                }
                /// Launched between active period calculate expiration time
                else {
                    val willOverInMs = DateTimeUtils.todDifferenceFromNow(it.activePeriodEnd)
                    futureState.add(state.copy(timeLeftMillis = willOverInMs))
                }
            }
        }

        return null
    }

    private fun evaluateScreenTimeLimit(
        restriction: AppRestriction,
        futureStates: MutableSet<RestrictionState>,
    ): RestrictionState? {
        // Usage map
        val screenUsage = ScreenUsageHelper.fetchAppUsageTodayTillNow(usageStatsManager)

        /// Check for app timer
        if (restriction.timerSec > 0) {
            val screenTimeSec: Long = screenUsage[restriction.appPackage] ?: 0

            /// App timer ran out
            if (screenTimeSec >= restriction.timerSec) {
                Log.d(TAG, "evaluateScreenTimeLimit: App's timer is over")
                val state = RestrictionState(
                    type = RestrictionType.APP_TIMER,
                    screenTimeUsed = screenTimeSec,
                    screenTimeLimit = restriction.timerSec.toLong(),
                    reminderType = restriction.reminderType,
                )

                alreadyRestrictedApps[restriction.appPackage] = state
                blockAssociatedDomains(restriction.associatedDomains)
                runtimeStateDirty = true
                return state
            } else {
                /// App timer left so add expiration timestamp
                val leftAppLimitMs = (restriction.timerSec - screenTimeSec) * 1000L
                futureStates.add(
                    RestrictionState(
                        type = RestrictionType.APP_TIMER,
                        timeLeftMillis = leftAppLimitMs,
                        screenTimeUsed = screenTimeSec,
                        screenTimeLimit = restriction.timerSec.toLong(),
                        reminderType = restriction.reminderType,
                    )
                )
            }
        }


        /// Check group's timer ran out
        restrictionGroups[restriction.associatedGroupId]?.let { group ->
            // If group is already restricted
            if (alreadyRestrictedGroups.containsKey(group.id)) {
                return alreadyRestrictedGroups[group.id]
            }

            if (group.timerSec > 0) {
                val groupScreenTimeSec = group.distractingApps.sumOf { screenUsage[it] ?: 0 }

                /// group timer ran out
                if (groupScreenTimeSec >= group.timerSec) {
                    Log.d(TAG, "evaluateScreenTimeLimit: App's timer is over")
                    val state = RestrictionState(
                        type = RestrictionType.GROUP_TIMER,
                        screenTimeUsed = groupScreenTimeSec,
                        screenTimeLimit = group.timerSec.toLong(),
                        reminderType = restriction.reminderType,
                        groupName = group.groupName,
                    )

                    alreadyRestrictedGroups[group.id] = state
                    blockAssociatedDomains(domainsForGroup(group))
                    runtimeStateDirty = true
                    return state
                } else {
                    /// group timer left so add expiration timestamp
                    val leftAppLimitMs = (group.timerSec - groupScreenTimeSec) * 1000L
                    futureStates.add(
                        RestrictionState(
                            type = RestrictionType.GROUP_TIMER,
                            timeLeftMillis = leftAppLimitMs,
                            screenTimeUsed = groupScreenTimeSec,
                            screenTimeLimit = group.timerSec.toLong(),
                            reminderType = restriction.reminderType,
                            groupName = group.groupName,
                        )
                    )
                }
            }
        }

        return null
    }

    /**
     * Serializes the derived caches so a process restart cannot silently drop them.
     */
    private fun persistRuntimeState() {
        try {
            val restrictedAppsJson = JSONObject()
            alreadyRestrictedApps.forEach { (packageName, state) ->
                restrictedAppsJson.put(packageName, state.toJson())
            }

            val restrictedGroupsJson = JSONObject()
            alreadyRestrictedGroups.forEach { (groupId, state) ->
                restrictedGroupsJson.put(groupId.toString(), state.toJson())
            }

            val launchCountsJson = JSONObject()
            appsLaunchCount.forEach { (packageName, count) ->
                launchCountsJson.put(packageName, count)
            }

            val root = JSONObject().apply {
                put(KEY_RESTRICTED_APPS, restrictedAppsJson)
                put(KEY_RESTRICTED_GROUPS, restrictedGroupsJson)
                put(KEY_LAUNCH_COUNTS, launchCountsJson)
            }

            SharedPrefsHelper.getSetRestrictionRuntimeState(context, root.toString())
        } catch (e: Exception) {
            Log.e(TAG, "persistRuntimeState: Failed to persist runtime state", e)
        }
    }

    /**
     * Reloads the caches written by [persistRuntimeState]. Individual corrupt entries are
     * skipped rather than discarding the whole payload.
     */
    private fun restoreRuntimeState() {
        try {
            val root = JSONObject(SharedPrefsHelper.getSetRestrictionRuntimeState(context, null))

            readStates(root.optJSONObject(KEY_RESTRICTED_APPS)).forEach { (packageName, state) ->
                alreadyRestrictedApps[packageName] = state
            }

            readStates(root.optJSONObject(KEY_RESTRICTED_GROUPS)).forEach { (groupId, state) ->
                groupId.toIntOrNull()?.let { alreadyRestrictedGroups[it] = state }
            }

            root.optJSONObject(KEY_LAUNCH_COUNTS)?.let { counts ->
                counts.keys().forEach { packageName ->
                    appsLaunchCount[packageName] = counts.optInt(packageName, 0)
                }
            }

            Log.d(
                TAG,
                "restoreRuntimeState: Restored ${alreadyRestrictedApps.size} restricted apps, " +
                        "${alreadyRestrictedGroups.size} restricted groups, " +
                        "${appsLaunchCount.size} launch counts"
            )
        } catch (e: Exception) {
            Log.e(TAG, "restoreRuntimeState: Failed to restore runtime state", e)
        }
    }

    private fun readStates(json: JSONObject?): Map<String, RestrictionState> {
        if (json == null) return emptyMap()

        val states = mutableMapOf<String, RestrictionState>()
        json.keys().forEach { key ->
            json.optJSONObject(key)?.let { stateJson ->
                RestrictionState.fromJson(stateJson)?.let { states[key] = it }
            }
        }
        return states
    }
}
