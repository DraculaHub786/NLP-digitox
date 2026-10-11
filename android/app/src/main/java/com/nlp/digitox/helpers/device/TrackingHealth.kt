package com.nlp.digitox.helpers.device

import android.content.Context
import android.util.Log
import com.nlp.digitox.helpers.storage.SharedPrefsHelper
import org.json.JSONArray
import org.json.JSONObject

/**
 * Records whether the tracking pipeline was actually alive, so the app can say
 * "tracking was off for 2 h 31 m today" instead of quietly under-reporting.
 *
 * The keep-alive chain is best-effort: Android cannot be made unkillable, and a
 * force-stop removes alarms, services and the Accessibility grant with no code
 * able to stop it. What *can* be done is make the gaps visible — a heartbeat is
 * written on every keep-alive tick, and a gap is recorded whenever the next
 * heartbeat arrives later than expected.
 *
 * Usage totals are not affected: they come from `UsageStatsManager`, which
 * Android maintains itself and which survives a dead service. Only
 * Accessibility-based blocking has real gaps, so this log is meant to qualify
 * that metric, not the whole dashboard.
 */
object TrackingHealth {
    private const val TAG = "Digitox.TrackingHealth"

    private const val PREF_KEY_LAST_HEARTBEAT_AT = "tracking_last_heartbeat_at"
    private const val PREF_KEY_GAPS_JSON = "tracking_gaps_json"

    /**
     * How long without a heartbeat counts as a gap. Comfortably longer than the
     * 10-minute watchdog so a single deferred alarm in Doze — which the system
     * is allowed to delay — is not reported as downtime.
     */
    private const val GAP_THRESHOLD_MS = 25 * 60 * 1000L

    /** Keep at most this many gaps; older ones are dropped. */
    private const val MAX_GAPS = 20

    /**
     * Records a heartbeat. If the previous one is older than [GAP_THRESHOLD_MS],
     * the interval in between is appended to the gap log before the heartbeat
     * is stored.
     *
     * Safe to call as often as the watchdog ticks: a normal tick simply moves
     * the timestamp forward.
     */
    fun markHeartbeat(context: Context) {
        val now = System.currentTimeMillis()
        val last = SharedPrefsHelper.getLong(context, PREF_KEY_LAST_HEARTBEAT_AT, 0L)

        if (last > 0L) {
            val gapMs = now - last
            if (gapMs >= GAP_THRESHOLD_MS) {
                recordGap(context, fromMs = last, toMs = now)
            }
        }

        SharedPrefsHelper.putLong(context, PREF_KEY_LAST_HEARTBEAT_AT, now)
    }

    /** Epoch millis of the most recent heartbeat, or 0 if none yet. */
    fun lastHeartbeatAt(context: Context): Long =
        SharedPrefsHelper.getLong(context, PREF_KEY_LAST_HEARTBEAT_AT, 0L)

    /**
     * The recorded gaps as a JSON array string, newest first. Each entry is
     * `{"from": <ms>, "to": <ms>, "durationMs": <ms>}`.
     */
    fun gapsJson(context: Context): String =
        SharedPrefsHelper.getString(context, PREF_KEY_GAPS_JSON, "[]")

    private fun recordGap(context: Context, fromMs: Long, toMs: Long) {
        try {
            val existing = JSONArray(gapsJson(context))
            val trimmed = JSONArray()

            // Newest first; keep only the most recent MAX_GAPS entries.
            trimmed.put(
                JSONObject()
                    .put("from", fromMs)
                    .put("to", toMs)
                    .put("durationMs", toMs - fromMs)
            )
            for (i in 0 until minOf(existing.length(), MAX_GAPS - 1)) {
                trimmed.put(existing.get(i))
            }

            SharedPrefsHelper.putString(context, PREF_KEY_GAPS_JSON, trimmed.toString())
            Log.w(TAG, "Tracked a ${(toMs - fromMs) / 60000}min gap in background tracking")
        } catch (e: Exception) {
            // Never let bookkeeping break the watchdog.
            Log.w(TAG, "recordGap failed (non-fatal)", e)
        }
    }
}
