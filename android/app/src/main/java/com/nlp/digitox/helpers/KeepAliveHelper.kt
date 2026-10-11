package com.nlp.digitox.helpers

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.util.Log
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequest
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkManager
import com.nlp.digitox.generics.ServiceBinder
import com.nlp.digitox.helpers.device.NotificationHelper
import com.nlp.digitox.helpers.device.PermissionsHelper
import com.nlp.digitox.helpers.device.TrackingHealth
import com.nlp.digitox.helpers.storage.SharedPrefsHelper
import com.nlp.digitox.services.accessibility.DigitoxAccessibilityService
import com.nlp.digitox.services.tracking.DigitoxTrackerService
import com.nlp.digitox.services.vpn.DigitoxVpnService
import com.nlp.digitox.utils.Utils
import com.nlp.digitox.workers.FlutterBgExecutionWorker
import com.nlp.digitox.workers.FlutterBgExecutionWorker.Companion.FLUTTER_TASK_ID
import com.nlp.digitox.workers.KeepAliveWorker

/**
 * Keeps the tracker / VPN / accessibility services alive after Android (or the
 * OEM) kills the app.
 *
 * Android cannot be made unkillable: a force-stop (user or OEM cleaner) removes
 * alarms, services and the accessibility grant, and no code survives that. What
 * these mechanisms *can* do is survive ordinary kills, restart fast, and make
 * the remaining gaps visible ([TrackingHealth]).
 *
 * Three mechanisms, because they cover three different failure modes:
 *
 *  - [scheduleKeepAlive] arms a *self-rescheduling one-shot* alarm, exact when
 *    the OS allows it. The old `setInexactRepeating` version could not re-arm
 *    itself after the process was killed, and Doze may defer a repeating alarm
 *    by hours.
 *
 *  - [scheduleImmediateRestart] is called from `onTaskRemoved()`. Swiping the
 *    app out of recents kills the process outright — `onDestroy()` is *not*
 *    called, so a service cannot restart itself from there. This alarm fires in
 *    ~2s instead of waiting for the next periodic tick.
 *
 *  - [KeepAliveWorker] is an independent WorkManager chain. If the alarm was
 *    dropped (some OEMs clear alarms on a swipe-away), the periodic worker still
 *    fires and re-arms the alarm chain. It is a safety net, not the primary
 *    restart path — on Android 12+ a background worker may be denied a
 *    foreground-service start, which [restartTrackerService] already handles.
 *
 * [tick] holds the actual work so both the alarm and the worker run the same
 * code.
 */
object KeepAliveHelper {
    private const val TAG = "Digitox.KeepAlive"

    private const val KEEP_ALIVE_REQUEST_CODE = 201
    private const val IMMEDIATE_RESTART_REQUEST_CODE = 202

    /** How often the self-rescheduling watchdog re-arms itself. */
    private const val KEEP_ALIVE_INTERVAL_MS = 10 * 60 * 1000L

    /** How soon after a swipe-from-recents kill we come back. */
    private const val IMMEDIATE_RESTART_DELAY_MS = 2_000L

    // SharedPrefs key: set to true when accessibility service is permitted but dead
    const val PREF_KEY_ACCESSIBILITY_SERVICE_PAUSED = "accessibility_service_paused"

    // SharedPrefs key: set to true when Device Admin permission was previously
    // granted but is now revoked (detected on keep-alive tick).
    const val PREF_KEY_DEVICE_ADMIN_REVOKED = "device_admin_revoked"

    // SharedPrefs key: tracks whether Device Admin was ever seen as active.
    // Set once when admin is first detected as active; never cleared.
    // Used to distinguish "never granted" from "was granted but revoked."
    const val PREF_KEY_DEVICE_ADMIN_WAS_SEEN_ACTIVE = "device_admin_was_seen_active"

    // SharedPrefs key: tracks whether the Accessibility grant was ever seen as
    // active, so a later disappearance can be told apart from "never granted".
    // Set once and never cleared, like the Device Admin flag above.
    const val PREF_KEY_ACCESSIBILITY_WAS_SEEN_ACTIVE = "accessibility_was_seen_active"

    // SharedPrefs key: epoch millis of the last "accessibility lost" warning, so
    // the notification is throttled instead of firing on every tick.
    const val PREF_KEY_ACCESSIBILITY_LOST_NOTIFIED_AT = "accessibility_lost_notified_at"

    /** Minimum gap between two "accessibility lost" warnings. */
    private const val ACCESSIBILITY_LOST_NOTIFY_INTERVAL_MS = 6 * 60 * 60 * 1000L

    /**
     * Arms (or re-arms) the periodic watchdog and the independent WorkManager
     * chain. Safe to call repeatedly: the PendingIntent is stable and the worker
     * is enqueued with `KEEP`, so nothing is duplicated.
     */
    fun scheduleKeepAlive(context: Context) {
        val appContext = context.applicationContext
        val alarmManager =
            appContext.getSystemService(Context.ALARM_SERVICE) as? AlarmManager

        if (alarmManager == null) {
            // Still (re-)enqueue the worker so we are not left with no chain.
            KeepAliveWorker.enqueuePeriodic(appContext)
            return
        }

        val pendingIntent = PendingIntent.getBroadcast(
            appContext,
            KEEP_ALIVE_REQUEST_CODE,
            Intent(appContext, KeepAliveReceiver::class.java)
                .setAction(KeepAliveReceiver.ACTION_KEEP_ALIVE),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val triggerAt = SystemClock.elapsedRealtime() + KEEP_ALIVE_INTERVAL_MS
        try {
            // Prefer an exact alarm when the user has allowed it — on Android
            // 12+ that also grants the foreground-service start exemption.
            // Otherwise fall back to setAndAllowWhileIdle, which the system
            // clamps to roughly once per 9-15 minutes in Doze.
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
                alarmManager.canScheduleExactAlarms()
            ) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    triggerAt,
                    pendingIntent,
                )
            } else {
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    triggerAt,
                    pendingIntent,
                )
            }
            Log.d(TAG, "scheduleKeepAlive: watchdog armed for +${KEEP_ALIVE_INTERVAL_MS / 60000}min")
        } catch (e: SecurityException) {
            // Exact alarms not permitted — the inexact variant still fires.
            runCatching {
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    triggerAt,
                    pendingIntent,
                )
            }
            Log.w(TAG, "scheduleKeepAlive: exact alarm denied, used inexact", e)
        } catch (e: Exception) {
            SharedPrefsHelper.insertCrashLogToPrefs(appContext, e)
            Log.e(TAG, "scheduleKeepAlive: failed to arm watchdog", e)
        }

        // Independent second chain. Cheap and idempotent.
        KeepAliveWorker.enqueuePeriodic(appContext)
    }

    /**
     * Fires a one-shot alarm that restarts the background services almost
     * immediately. Called from `onTaskRemoved()`.
     *
     * Uses a distinct request code and action so it never replaces the
     * periodic watchdog.
     */
    fun scheduleImmediateRestart(context: Context) {
        val appContext = context.applicationContext
        val alarmManager =
            appContext.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return

        val pendingIntent = PendingIntent.getBroadcast(
            appContext,
            IMMEDIATE_RESTART_REQUEST_CODE,
            Intent(appContext, KeepAliveReceiver::class.java)
                .setAction(KeepAliveReceiver.ACTION_RESTART_NOW),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val triggerAt = SystemClock.elapsedRealtime() + IMMEDIATE_RESTART_DELAY_MS
        try {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
                alarmManager.canScheduleExactAlarms()
            ) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    triggerAt,
                    pendingIntent,
                )
            } else {
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    triggerAt,
                    pendingIntent,
                )
            }
            Log.w(TAG, "scheduleImmediateRestart: restart armed for +${IMMEDIATE_RESTART_DELAY_MS}ms")
        } catch (e: SecurityException) {
            // Exact alarms not permitted on this device/build — the inexact
            // variant still fires, just later.
            runCatching {
                alarmManager.set(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    triggerAt,
                    pendingIntent,
                )
            }
            Log.w(TAG, "scheduleImmediateRestart: exact alarm denied, used inexact", e)
        } catch (e: Exception) {
            SharedPrefsHelper.insertCrashLogToPrefs(appContext, e)
            Log.e(TAG, "scheduleImmediateRestart: failed to arm restart", e)
        }
    }

    /**
     * Cancels the periodic watchdog. The immediate restart alarm is left alone —
     * it is a one-shot, and cancelling it could strand a recovering process.
     */
    fun cancelKeepAlive(context: Context) {
        try {
            val appContext = context.applicationContext
            val alarmManager =
                appContext.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
            val pendingIntent = PendingIntent.getBroadcast(
                appContext,
                KEEP_ALIVE_REQUEST_CODE,
                Intent(appContext, KeepAliveReceiver::class.java)
                    .setAction(KeepAliveReceiver.ACTION_KEEP_ALIVE),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            alarmManager.cancel(pendingIntent)
        } catch (_: Exception) {
        }
    }

    /**
     * One keep-alive tick: records a heartbeat, restarts any dead core service,
     * and checks the accessibility / device-admin state.
     *
     * Shared by [KeepAliveReceiver] (the alarm chain) and [KeepAliveWorker] (the
     * WorkManager chain) so the two never drift. Callers are responsible for
     * re-arming their own chain afterwards.
     */
    fun tick(context: Context) {
        val appContext = context.applicationContext
        try {
            // Proof of life first: if this tick arrives much later than the
            // previous one, the interval in between is recorded as a gap so the
            // UI can qualify Accessibility-based metrics.
            TrackingHealth.markHeartbeat(appContext)
            restartTrackerService(appContext)
            restartVpnService(appContext)
            monitorAccessibilityService(appContext)
            monitorDeviceAdminRevocation(appContext)
        } catch (e: Exception) {
            Log.e(TAG, "Keep-alive tick failed", e)
        }
    }

    /**
     * Starts the tracker service, falling back to an expedited WorkManager job
     * when Android refuses a background foreground-service start (Android 12+
     * `ForegroundServiceStartNotAllowedException`).
     */
    private fun restartTrackerService(context: Context) {
        if (Utils.isServiceRunning(context, DigitoxTrackerService::class.java)) return

        Log.w(TAG, "Tracker service down — restarting")
        val restartIntent = Intent(context, DigitoxTrackerService::class.java)
            .setAction(ServiceBinder.ACTION_START_DIGITOX_SERVICE)

        try {
            context.startForegroundService(restartIntent)
        } catch (e: Exception) {
            Log.w(TAG, "startForegroundService denied for tracker, using fallback", e)
            enqueueFallbackWorker(context)
            runCatching { context.startService(restartIntent) }
        }
    }

    /** Same contract as [restartTrackerService], for the internet blocker. */
    private fun restartVpnService(context: Context) {
        if (Utils.isServiceRunning(context, DigitoxVpnService::class.java)) return

        Log.w(TAG, "VPN service down — restarting")
        val restartIntent = Intent(context, DigitoxVpnService::class.java)
            .setAction(ServiceBinder.ACTION_START_DIGITOX_SERVICE)

        try {
            context.startForegroundService(restartIntent)
        } catch (e: Exception) {
            Log.w(TAG, "startForegroundService denied for VPN, using fallback", e)
            runCatching { context.startService(restartIntent) }
        }
    }

    /**
     * Detects "accessibility permission granted but service process dead"
     * — the state OEMs leave behind after killing an idle service.
     */
    private fun monitorAccessibilityService(context: Context) {
        val isPermitted = PermissionsHelper.isAccessibilityServiceEnabled(context)
        val isActive = Utils.isServiceRunning(context, DigitoxAccessibilityService::class.java)

        // Remember that the grant *was* held, so its later disappearance can
        // be told apart from "the user never granted it" — only the former
        // deserves a warning.
        if (isPermitted) markAccessibilityWasSeenActive(context)

        if (isPermitted && !isActive) {
            // Re-push settings so the service has the latest config the
            // moment the system rebinds it...
            SharedPrefsHelper.getSetWellBeingSettings(
                context,
                SharedPrefsHelper.getSetWellBeingSettingsAsJsonString(context),
            )

            // ...and nudge the process back up. This does not and cannot
            // grant the accessibility permission (only the user can); it
            // simply starts our own service component so the process
            // hosting it is brought back while the grant is still in place.
            runCatching {
                context.startService(Intent(context, DigitoxAccessibilityService::class.java))
            }.onFailure {
                Log.w(TAG, "Accessibility service process nudge failed (non-fatal)", it)
            }

            SharedPrefsHelper.putBoolean(
                context,
                PREF_KEY_ACCESSIBILITY_SERVICE_PAUSED,
                true,
            )
        } else if (isPermitted && isActive) {
            if (SharedPrefsHelper.getBoolean(
                    context,
                    PREF_KEY_ACCESSIBILITY_SERVICE_PAUSED,
                    false,
                )
            ) {
                SharedPrefsHelper.putBoolean(
                    context,
                    PREF_KEY_ACCESSIBILITY_SERVICE_PAUSED,
                    false,
                )
                Log.d(TAG, "Accessibility service is active again — cleared paused flag")
            }
        } else {
            // Not permitted. If we had it, the OS (or an OEM cleaner) took it
            // away — the one case where a warning is justified.
            notifyAccessibilityLostIfNeeded(context)
        }
    }

    private fun markAccessibilityWasSeenActive(context: Context) {
        if (!SharedPrefsHelper.getBoolean(
                context,
                PREF_KEY_ACCESSIBILITY_WAS_SEEN_ACTIVE,
                false,
            )
        ) {
            SharedPrefsHelper.putBoolean(
                context,
                PREF_KEY_ACCESSIBILITY_WAS_SEEN_ACTIVE,
                true,
            )
        }
    }

    /**
     * Warns the user that the Accessibility grant is gone, at most once per
     * [ACCESSIBILITY_LOST_NOTIFY_INTERVAL_MS].
     *
     * After a force-stop this tick never runs (the process and its alarm are
     * gone), so this only covers the OEM-kill and revocation-in-place cases; the
     * dashboard card covers the rest.
     */
    private fun notifyAccessibilityLostIfNeeded(context: Context) {
        val wasEverSeenActive = SharedPrefsHelper.getBoolean(
            context,
            PREF_KEY_ACCESSIBILITY_WAS_SEEN_ACTIVE,
            false,
        )
        if (!wasEverSeenActive) return

        val now = System.currentTimeMillis()
        val lastNotifiedAt = SharedPrefsHelper.getLong(
            context,
            PREF_KEY_ACCESSIBILITY_LOST_NOTIFIED_AT,
            0L,
        )
        if (now - lastNotifiedAt < ACCESSIBILITY_LOST_NOTIFY_INTERVAL_MS) return

        SharedPrefsHelper.putLong(context, PREF_KEY_ACCESSIBILITY_LOST_NOTIFIED_AT, now)
        runCatching { NotificationHelper.pushAccessibilityLostNotification(context) }
            .onFailure {
                Log.w(TAG, "Accessibility-lost notification failed (non-fatal)", it)
            }
        Log.w(TAG, "Accessibility grant has gone — warned the user")
    }

    /**
     * Flags Device Admin that was previously granted but has since been silently
     * revoked, so the UI can offer a one-tap re-enable.
     */
    private fun monitorDeviceAdminRevocation(context: Context) {
        val isAdminActive = PermissionsHelper.getAndAskAdminPermission(context, false)

        if (isAdminActive) {
            if (!SharedPrefsHelper.getBoolean(
                    context,
                    PREF_KEY_DEVICE_ADMIN_WAS_SEEN_ACTIVE,
                    false,
                )
            ) {
                SharedPrefsHelper.putBoolean(
                    context,
                    PREF_KEY_DEVICE_ADMIN_WAS_SEEN_ACTIVE,
                    true,
                )
            }
            if (SharedPrefsHelper.getBoolean(
                    context,
                    PREF_KEY_DEVICE_ADMIN_REVOKED,
                    false,
                )
            ) {
                SharedPrefsHelper.putBoolean(
                    context,
                    PREF_KEY_DEVICE_ADMIN_REVOKED,
                    false,
                )
                Log.d(TAG, "Device Admin is active again — cleared revocation flag")
            }
        } else {
            val wasEverSeenActive = SharedPrefsHelper.getBoolean(
                context,
                PREF_KEY_DEVICE_ADMIN_WAS_SEEN_ACTIVE,
                false,
            )
            if (wasEverSeenActive) {
                SharedPrefsHelper.putBoolean(context, PREF_KEY_DEVICE_ADMIN_REVOKED, true)
                Log.w(TAG, "Device Admin was enabled before but is now inactive — flagging revocation")
            }
        }
    }

    /**
     * Fallback used when a background foreground-service start is refused: an
     * expedited one-time job is permitted to start a foreground service.
     */
    private fun enqueueFallbackWorker(context: Context) {
        runCatching {
            WorkManager.getInstance(context).enqueueUniqueWork(
                "$TAG.restart",
                ExistingWorkPolicy.REPLACE,
                OneTimeWorkRequest
                    .Builder(FlutterBgExecutionWorker::class.java)
                    .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
                    .setInputData(
                        Data.Builder()
                            .putString(FLUTTER_TASK_ID, "onBootOrAppUpdate")
                            .build()
                    )
                    .build(),
            )
        }.onFailure {
            Log.w(TAG, "Fallback worker enqueue failed (non-fatal)", it)
        }
    }

    /**
     * Fires on each keep-alive tick and on the one-shot restart alarm: runs
     * [tick] and re-arms the watchdog.
     *
     * The re-arm in `finally` is what makes the chain survive a process kill: a
     * fresh process is started by this alarm and immediately schedules the next
     * one.
     */
    class KeepAliveReceiver : BroadcastReceiver() {
        companion object {
            const val ACTION_KEEP_ALIVE = "com.nlp.digitox.action.KEEP_ALIVE"
            const val ACTION_RESTART_NOW = "com.nlp.digitox.action.RESTART_NOW"
        }

        override fun onReceive(context: Context, intent: Intent) {
            val action = intent.action
            if (action != ACTION_KEEP_ALIVE && action != ACTION_RESTART_NOW) return

            val appContext = context.applicationContext
            try {
                tick(appContext)
            } finally {
                scheduleKeepAlive(appContext)
            }
        }
    }
}
