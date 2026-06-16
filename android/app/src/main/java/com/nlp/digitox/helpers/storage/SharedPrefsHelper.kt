
package com.nlp.digitox.helpers.storage

import android.content.Context
import android.content.SharedPreferences
import android.content.SharedPreferences.OnSharedPreferenceChangeListener
import android.util.Log
import com.nlp.digitox.enums.DndWakeLock
import com.nlp.digitox.models.AppRestriction
import com.nlp.digitox.models.RestrictionGroup
import com.nlp.digitox.models.Wellbeing
import com.nlp.digitox.utils.AppUtils
import com.nlp.digitox.utils.JsonUtils
import org.json.JSONArray
import org.json.JSONObject

/**
 * Helper class to manage SharedPreferences operations.
 * Provides methods to store and retrieve various application settings and data.
 */
object SharedPrefsHelper {
    private var mUniquePrefs: SharedPreferences? = null
    private const val UNIQUE_PREFS_BOX = "UniquePrefs"
    private const val PREF_KEY_NOTIFICATION_PERMISSION_COUNT = "notificationPermissionCount"
    private const val PREF_KEY_DEVICE_UNLOCK_COUNT = "deviceUnlockCount"
    private const val PREF_KEY_SHORTS_SCREEN_TIME = "shortsScreenTime"
    private const val PREF_KEY_DND_WAKE_LOCK = "dndWakeLock"
    private const val PREF_KEY_EXCLUDED_APPS = "excludedApps"
    private const val PREF_KEY_APP_RESTRICTIONS = "appRestrictions"
    private const val PREF_KEY_RESTRICTION_GROUPS = "restrictionGroups"
    private const val PREF_KEY_INTERNET_BLOCKED_APPS = "internetBlockedApps"

    private var mListenablePrefs: SharedPreferences? = null
    private const val LISTENABLE_PREFS_BOX = "UniquePrefs"
    const val PREF_KEY_WELLBEING_SETTINGS: String = "wellBeingSettings"

    private var mCrashLogPrefs: SharedPreferences? = null
    private const val CRASH_LOG_PREFS_BOX = "CrashLogPrefs"
    private const val PREF_KEY_CRASH_LOGS = "crashLogs"


    private fun checkAndInitializeUniquePrefs(context: Context) {
        if (mUniquePrefs != null) return
        mUniquePrefs =
            context.applicationContext.getSharedPreferences(UNIQUE_PREFS_BOX, Context.MODE_PRIVATE)
    }

    private fun checkAndInitializeListenablePrefs(context: Context) {
        if (mListenablePrefs != null) return
        mListenablePrefs =
            context.applicationContext.getSharedPreferences(
                LISTENABLE_PREFS_BOX,
                Context.MODE_PRIVATE
            )
    }

    private fun checkAndInitializeCrashLogPrefs(context: Context) {
        if (mCrashLogPrefs != null) return
        mCrashLogPrefs = context.applicationContext.getSharedPreferences(
            CRASH_LOG_PREFS_BOX,
            Context.MODE_PRIVATE
        )
    }


    /**
     * Registers or Unregister a listener to/from SharedPreferences changes.
     * To listenable prefs box
     *
     * @param context        The application context.
     * @param shouldRegister If TRUE the callback will be registered else unregistered.
     * @param callback       The listener to register.
     */
    fun registerUnregisterListenerToListenablePrefs(
        context: Context,
        shouldRegister: Boolean,
        callback: OnSharedPreferenceChangeListener?,
    ) {
        checkAndInitializeListenablePrefs(context)
        try {
            if (shouldRegister) {
                mListenablePrefs!!.registerOnSharedPreferenceChangeListener(callback)
            } else {
                mListenablePrefs!!.unregisterOnSharedPreferenceChangeListener(callback)
            }
        } catch (ignored: Exception) {
        }
    }

    /**
     * Fetches the well-being settings if jsonWellBeingSettings is null else store it's json.
     *
     * @param context               The application context.
     * @param jsonWellBeing The JSON string of well-being settings.
     */
    fun getSetWellBeingSettings(
        context: Context,
        jsonWellBeing: String?,
    ): Wellbeing {
        checkAndInitializeListenablePrefs(context)
        if (jsonWellBeing == null) {
            val json = mListenablePrefs!!.getString(PREF_KEY_WELLBEING_SETTINGS, "{}")!!
            return Wellbeing.fromJson(json)
        } else {
            mListenablePrefs!!.edit().putString(PREF_KEY_WELLBEING_SETTINGS, jsonWellBeing)
                .apply()
            return Wellbeing.fromJson(jsonWellBeing)
        }
    }

    /**
     * Retrieves the well-being settings JSON string from SharedPreferences.
     * Used to re-trigger SharedPrefs change listeners in the accessibility service
     * after a process restart.
     *
     * @param context The application context.
     * @return The JSON string of well-being settings, or "{}" if not set.
     */
    fun getSetWellBeingSettingsAsJsonString(context: Context): String {
        checkAndInitializeListenablePrefs(context)
        return mListenablePrefs!!.getString(PREF_KEY_WELLBEING_SETTINGS, "{}")!!
    }


    /**
     * Get the wake lock set for the dnd to modify it if lock is null else store it.
     *
     * @param context The application context.
     * @param lock   The lock type for dnd.
     */
    fun getSetDndWakeLock(context: Context, lock: DndWakeLock?): DndWakeLock {
        checkAndInitializeUniquePrefs(context)
        // store it
        lock?.let {
            mUniquePrefs!!.edit().putInt(PREF_KEY_DND_WAKE_LOCK, it.ordinal)
                .apply()
            return it
        }

        // fetch it
        return DndWakeLock.values()[mUniquePrefs!!.getInt(PREF_KEY_DND_WAKE_LOCK, 0)]
    }

    /**
     * Get the notification permission request count if count is null else store it.
     *
     * @param context The application context.
     * @param count   The number of requests.
     */
    fun getSetNotificationAskCount(context: Context, count: Int?): Int {
        checkAndInitializeUniquePrefs(context)
        // store it
        count?.let {
            mUniquePrefs!!.edit().putInt(PREF_KEY_NOTIFICATION_PERMISSION_COUNT, it).apply()
            return it
        }

        // fetch it
        return mUniquePrefs!!.getInt(PREF_KEY_NOTIFICATION_PERMISSION_COUNT, 0)
    }


    /**
     * Get the device unlock count if count is null else store it.
     *
     * @param context The application context.
     * @param count   The number of unlocks.
     */
    fun getSetDeviceUnlockCount(context: Context, count: Int?): Int {
        checkAndInitializeUniquePrefs(context)

        count?.let {
            mUniquePrefs!!.edit().putInt(PREF_KEY_DEVICE_UNLOCK_COUNT, it).apply()
            return it
        }

        return mUniquePrefs!!.getInt(PREF_KEY_DEVICE_UNLOCK_COUNT, 0)
    }


    /**
     * Fetches the hashset of excluded apps if jsonExcludedApps is null else store it's json.
     *
     * @param context          The application context.
     * @param jsonExcludedApps The JSON string of excluded apps.
     */
    fun getSetExcludedApps(context: Context, jsonExcludedApps: String?): Set<String> {
        checkAndInitializeUniquePrefs(context)
        if (jsonExcludedApps == null) {
            return JsonUtils.parseStringSet(
                mUniquePrefs!!.getString(PREF_KEY_EXCLUDED_APPS, "")
            )
        } else {
            mUniquePrefs!!.edit().putString(PREF_KEY_EXCLUDED_APPS, jsonExcludedApps).apply()
            return JsonUtils.parseStringSet(jsonExcludedApps)
        }
    }

    /**
     * Fetches the app restrictions map if jsonAppRestrictions is null else stores it as json.
     *
     * @param context             The application context.
     * @param jsonAppRestrictions The JSON string of app restrictions.
     */
    fun getSetAppRestrictions(
        context: Context,
        jsonAppRestrictions: String?,
    ): HashMap<String, AppRestriction> {
        checkAndInitializeUniquePrefs(context)
        if (jsonAppRestrictions == null) {
            return JsonUtils.parseAppRestrictionsMap(
                mUniquePrefs!!.getString(PREF_KEY_APP_RESTRICTIONS, "")
            )
        }

        mUniquePrefs!!.edit().putString(PREF_KEY_APP_RESTRICTIONS, jsonAppRestrictions).apply()
        return JsonUtils.parseAppRestrictionsMap(jsonAppRestrictions)
    }

    /**
     * Fetches the restriction groups map if jsonRestrictionGroups is null else stores it as json.
     *
     * @param context                The application context.
     * @param jsonRestrictionGroups  The JSON string of restriction groups.
     */
    fun getSetRestrictionGroups(
        context: Context,
        jsonRestrictionGroups: String?,
    ): HashMap<Int, RestrictionGroup> {
        checkAndInitializeUniquePrefs(context)
        if (jsonRestrictionGroups == null) {
            return JsonUtils.parseRestrictionGroupsMap(
                mUniquePrefs!!.getString(PREF_KEY_RESTRICTION_GROUPS, "")
            )
        }

        mUniquePrefs!!.edit().putString(PREF_KEY_RESTRICTION_GROUPS, jsonRestrictionGroups).apply()
        return JsonUtils.parseRestrictionGroupsMap(jsonRestrictionGroups)
    }

    /**
     * Fetches the set of internet blocked apps if jsonBlockedApps is null else stores it as json.
     *
     * @param context         The application context.
     * @param jsonBlockedApps The JSON string of blocked apps.
     */
    fun getSetInternetBlockedApps(
        context: Context,
        jsonBlockedApps: String?,
    ): Set<String> {
        checkAndInitializeUniquePrefs(context)
        if (jsonBlockedApps == null) {
            return JsonUtils.parseStringSet(
                mUniquePrefs!!.getString(PREF_KEY_INTERNET_BLOCKED_APPS, "")
            )
        }

        mUniquePrefs!!.edit().putString(PREF_KEY_INTERNET_BLOCKED_APPS, jsonBlockedApps).apply()
        return JsonUtils.parseStringSet(jsonBlockedApps)
    }

    /**
     * Fetches the short content's screen time if screenTime is null else store it's json.
     *
     * @param context    The application context.
     * @param screenTime The short content's screen time.
     */
    fun getSetShortsScreenTimeMs(context: Context, screenTime: Long?): Long {
        checkAndInitializeUniquePrefs(context)

        // store it
        screenTime?.let {
            mUniquePrefs!!.edit().putLong(PREF_KEY_SHORTS_SCREEN_TIME, it).apply()
            return it

        }

        // fetch it
        return mUniquePrefs!!.getLong(PREF_KEY_SHORTS_SCREEN_TIME, 0L)
    }


    /**
     * Creates and Inserts a new crash log into SharedPreferences based on the passed exception.
     *
     * @param context   The application context used to retrieve app version and store the log.
     * @param exception The exception that was thrown, which will be logged in the crash log.
     */
    fun insertCrashLogToPrefs(context: Context, exception: Throwable) {
        checkAndInitializeCrashLogPrefs(context)

        // Create new object
        val currentLog = JSONObject()
        try {
            currentLog.put("appVersion", AppUtils.getAppVersion(context))
            currentLog.put("timeStamp", System.currentTimeMillis())
            currentLog.put("error", exception.toString())
            currentLog.put("stackTrace", Log.getStackTraceString(exception))
        } catch (ignored: Exception) {
        }

        // Get existing crash logs
        val crashLogsJson = mCrashLogPrefs!!.getString(PREF_KEY_CRASH_LOGS, "[]")
        val crashLogsArray = try {
            JSONArray(crashLogsJson)
        } catch (e1: Exception) {
            JSONArray()
        }

        // Insert current log and update prefs
        crashLogsArray.put(currentLog)

        mCrashLogPrefs!!.edit().putString(PREF_KEY_CRASH_LOGS, crashLogsArray.toString()).apply()
    }


    /**
     * Retrieves the crash logs from SharedPreferences as a JSON Array string.
     *
     * @param context The application context used to access SharedPreferences.
     * @return A JSON string representing the stored crash logs array.
     */
    fun getCrashLogsArrayJsonString(context: Context): String {
        checkAndInitializeCrashLogPrefs(context)
        return mCrashLogPrefs!!.getString(PREF_KEY_CRASH_LOGS, "[]")!!
    }

    /**
     * Clears all the stored crash logs from shared prefs.
     *
     * @param context The application context used to access SharedPreferences.
     */
    fun clearCrashLogs(context: Context) {
        checkAndInitializeCrashLogPrefs(context)
        mCrashLogPrefs!!.edit().putString(PREF_KEY_CRASH_LOGS, "[]").apply()
    }
}
