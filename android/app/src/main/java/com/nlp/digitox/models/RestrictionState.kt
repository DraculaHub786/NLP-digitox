package com.nlp.digitox.models

import com.nlp.digitox.enums.ReminderType
import com.nlp.digitox.enums.RestrictionType
import org.json.JSONObject


data class RestrictionState(
    /** The type of restriction that this state represents **/
    val type: RestrictionType,

    /** The group name if this restriction belongs to a group **/
    val groupName: String? = null,

    /** Time left in milliseconds before the restriction starts **/
    val timeLeftMillis: Long = -1,

    /** Total screen time used so far in seconds **/
    val screenTimeUsed: Long = -1L,

    /** Screen time limit or timer in seconds **/
    val screenTimeLimit: Long = -1L,

    /** The type of reminder to show during app usage **/
    val reminderType: ReminderType = ReminderType.NONE,
) {
    /**
     * Serializes this state so it can be persisted across process restarts.
     */
    fun toJson(): JSONObject = JSONObject().apply {
        put(KEY_TYPE, type.name)
        put(KEY_GROUP_NAME, groupName ?: JSONObject.NULL)
        put(KEY_TIME_LEFT_MILLIS, timeLeftMillis)
        put(KEY_SCREEN_TIME_USED, screenTimeUsed)
        put(KEY_SCREEN_TIME_LIMIT, screenTimeLimit)
        put(KEY_REMINDER_TYPE, reminderType.name)
    }

    companion object {
        private const val KEY_TYPE = "type"
        private const val KEY_GROUP_NAME = "groupName"
        private const val KEY_TIME_LEFT_MILLIS = "timeLeftMillis"
        private const val KEY_SCREEN_TIME_USED = "screenTimeUsed"
        private const val KEY_SCREEN_TIME_LIMIT = "screenTimeLimit"
        private const val KEY_REMINDER_TYPE = "reminderType"

        /**
         * Rebuilds a state previously written by [toJson].
         *
         * Returns `null` if the payload is malformed or references an unknown
         * enum constant, so a single corrupt entry cannot discard the rest of
         * the persisted runtime state.
         */
        fun fromJson(json: JSONObject): RestrictionState? = try {
            RestrictionState(
                type = RestrictionType.valueOf(json.getString(KEY_TYPE)),
                groupName = json.optString(KEY_GROUP_NAME)
                    .takeIf { !json.isNull(KEY_GROUP_NAME) && it.isNotEmpty() },
                timeLeftMillis = json.optLong(KEY_TIME_LEFT_MILLIS, -1L),
                screenTimeUsed = json.optLong(KEY_SCREEN_TIME_USED, -1L),
                screenTimeLimit = json.optLong(KEY_SCREEN_TIME_LIMIT, -1L),
                reminderType = runCatching {
                    ReminderType.valueOf(json.optString(KEY_REMINDER_TYPE, ReminderType.NONE.name))
                }.getOrDefault(ReminderType.NONE),
            )
        } catch (e: Exception) {
            null
        }
    }
}
