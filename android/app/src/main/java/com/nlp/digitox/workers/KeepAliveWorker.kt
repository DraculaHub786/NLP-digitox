package com.nlp.digitox.workers

import android.content.Context
import android.util.Log
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.nlp.digitox.helpers.KeepAliveHelper
import java.util.concurrent.TimeUnit

/**
 * Independent, second keep-alive chain built on WorkManager.
 *
 * `KeepAliveHelper.scheduleKeepAlive` re-arms an AlarmManager alarm from inside
 * the alarm's own receiver. That chain is the primary one, but a few OEM ROMs
 * drop app alarms when the app is swiped away — and then nothing fires and the
 * chain is dead. WorkManager's job scheduler is managed by the system, so a
 * periodic worker keeps running even when our alarms were cleared; this worker
 * simply runs the same [KeepAliveHelper.tick] and then re-arms the alarm chain.
 *
 * It is a safety net, not the primary restart path: on Android 12+ a background
 * worker may be refused a foreground-service start, which
 * [KeepAliveHelper.restartTrackerService] already handles by falling back to an
 * expedited job.
 *
 * Minimum periodic interval on Android is 15 minutes; in Doze it may run less
 * often, which is exactly why the 10-minute alarm chain remains the primary
 * mechanism.
 */
class KeepAliveWorker(
    private val context: Context,
    workerParams: WorkerParameters,
) : Worker(context, workerParams) {

    companion object {
        private const val TAG = "Digitox.KeepAliveWorker"
        private const val UNIQUE_WORK_NAME = "com.nlp.digitox.keepAliveWorker"
        private const val INTERVAL_MINUTES = 15L

        /**
         * Enqueues the periodic worker, keeping any existing registration.
         *
         * Idempotent: callers invoke this on every app start and on every tick
         * (see [KeepAliveHelper.scheduleKeepAlive]) without it stacking up —
         * `KEEP` leaves a pending schedule untouched.
         */
        fun enqueuePeriodic(context: Context) {
            try {
                val request = PeriodicWorkRequestBuilder<KeepAliveWorker>(
                    INTERVAL_MINUTES,
                    TimeUnit.MINUTES,
                )
                    .setConstraints(
                        Constraints.NONE // must run even on a low battery / idle device
                    )
                    .build()

                WorkManager.getInstance(context.applicationContext)
                    .enqueueUniquePeriodicWork(
                        UNIQUE_WORK_NAME,
                        ExistingPeriodicWorkPolicy.KEEP,
                        request,
                    )
            } catch (e: Exception) {
                // Never let scheduling bookkeeping break the caller.
                Log.w(TAG, "enqueuePeriodic failed (non-fatal)", e)
            }
        }
    }

    override fun doWork(): Result {
        return try {
            KeepAliveHelper.tick(context)
            // Re-arm the alarm chain: if the swipe-away dropped our alarms,
            // this is what brings the fast (10-minute) chain back.
            KeepAliveHelper.scheduleKeepAlive(context)
            Result.success()
        } catch (e: Exception) {
            Log.e(TAG, "doWork failed", e)
            Result.retry()
        }
    }
}
