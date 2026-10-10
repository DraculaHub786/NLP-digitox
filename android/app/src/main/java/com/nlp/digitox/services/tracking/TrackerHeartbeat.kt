package com.nlp.digitox.services.tracking

import android.content.Context
import android.util.Log
import com.nlp.digitox.helpers.device.TrackingHealth
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.ScheduledFuture
import java.util.concurrent.TimeUnit

/**
 * Writes a [TrackingHealth] heartbeat while the tracker service is alive.
 *
 * The keep-alive watchdog ([com.nlp.digitox.helpers.KeepAliveHelper.tick]) also
 * marks a heartbeat, but that runs on an `AlarmManager` chain: Doze can defer it
 * by up to an hour, and some OEMs drop the alarm entirely on a swipe-away. The
 * card would then report "last heartbeat 40 min ago" on a device where tracking
 * is running perfectly.
 *
 * This ticker is owned by the foreground tracker service itself, so its beat
 * means "the tracking process is running right now". The two together make the
 * gap log mean what the card says it means — neither the tracker nor the
 * watchdog was alive — instead of "the alarm was late".
 *
 * The interval is deliberately well below [TrackingHealth]'s 25-minute gap
 * threshold, so a healthy service refreshes the timestamp long before a gap
 * could be recorded. Only a genuinely dead process lets it go stale.
 */
class TrackerHeartbeat(private val context: Context) {

    companion object {
        private const val TAG = "Digitox.TrackerHeartbeat"

        /**
         * How often the tracker proves it is alive. Five minutes is a
         * compromise: frequent enough that the card is never badly stale after
         * one missed tick, rare enough that these are trivial SharedPreferences
         * writes (roughly 288 a day).
         *
         * Must stay below `TrackingHealth.GAP_THRESHOLD_MS` (25 min), or a
         * healthy service would record gaps against itself.
         */
        private const val BEAT_INTERVAL_MS = 5 * 60 * 1000L
    }

    private val executor: ScheduledExecutorService =
        Executors.newSingleThreadScheduledExecutor { runnable ->
            // Daemon: if this object is ever leaked, the thread must not be the
            // reason the process stays resident.
            Thread(runnable, "digitox-tracker-heartbeat").apply { isDaemon = true }
        }

    private var handle: ScheduledFuture<*>? = null

    /**
     * Starts beating: once immediately, then every [BEAT_INTERVAL_MS].
     *
     * Idempotent — the service can be created more than once in a process, and
     * two overlapping tickers would be pure waste.
     */
    fun start() {
        if (handle != null && handle?.isCancelled == false) return

        // Beat before scheduling so the first gap is measured from "the service
        // started", not from the last time the watchdog happened to run.
        executor.execute { beat() }

        try {
            handle = executor.scheduleWithFixedDelay(
                { beat() },
                BEAT_INTERVAL_MS,
                BEAT_INTERVAL_MS,
                TimeUnit.MILLISECONDS,
            )
        } catch (e: Exception) {
            // A rejected executor means the service is already going down.
            Log.w(TAG, "start: could not schedule heartbeat (non-fatal)", e)
        }
    }

    /** Stops beating and releases the thread. Safe to call twice. */
    fun stop() {
        handle?.cancel(true)
        handle = null
        runCatching { executor.shutdownNow() }
            .onFailure { Log.w(TAG, "stop: shutdown failed (non-fatal)", it) }
    }

    /**
     * One heartbeat. Bookkeeping must never take the tracker service down, so
     * every failure is swallowed — the worst case is a stale timestamp.
     */
    private fun beat() {
        try {
            TrackingHealth.markHeartbeat(context.applicationContext)
        } catch (e: Exception) {
            Log.w(TAG, "beat: heartbeat write failed (non-fatal)", e)
        }
    }
}
