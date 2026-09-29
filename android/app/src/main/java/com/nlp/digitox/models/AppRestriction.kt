package com.nlp.digitox.models

import android.util.Log
import com.nlp.digitox.enums.ReminderType
import com.nlp.digitox.utils.JsonUtils
import org.json.JSONObject

/**
 * Represents app-level restriction configuration, such as usage time and access limits.
 */
data class AppRestriction(
    /**
     * Package name of the app.
     */
    val appPackage: String = "",

    /**
     * Daily timer limit for the app, in seconds.
     */
    val timerSec: Int = 0,

    /**
     * Launch limit per day.
     */
    val launchLimit: Int = 0,

    /**
     * Time of day (in minutes) from midnight when the app usage is allowed to start.
     */
    val activePeriodStart: Int = 0,

    /**
     * Time of day (in minutes) from midnight when the app usage is blocked.
     */
    val activePeriodEnd: Int = 0,

    /**
     * Type of usage reminders to show while using timed app.
     */
    val reminderType: ReminderType = ReminderType.NOTIFICATION,

    /**
     * ID of the restriction group this app belongs to (nullable).
     */
    val associatedGroupId: Int? = null,

    /**
     * Website domains associated with this app (e.g. "instagram.com" for
     * com.instagram.android). Never hardcoded in native code - populated
     * entirely from whatever the user/config sets on the Flutter side and synced
     * down like every other restriction field. Used to drive dynamic,
     * limit-triggered website blocking (see [com.nlp.digitox.utils.DynamicWebsiteBlocklist]).
     */
    val associatedDomains: Set<String> = emptySet(),
) {
    companion object {
        /**
         * Constructs an [AppRestriction] from a JSON string.
         */
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
