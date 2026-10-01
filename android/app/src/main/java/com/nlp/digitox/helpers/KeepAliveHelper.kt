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
import com.nlp.digitox.helpers.device.PermissionsHelper
import com.nlp.digitox.helpers.storage.SharedPrefsHelper
import com.nlp.digitox.services.accessibility.DigitoxAccessibilityService
import com.nlp.digitox.services.tracking.DigitoxTrackerService
import com.nlp.digitox.services.vpn.DigitoxVpnService
import com.nlp.digitox.utils.Utils
import com.nlp.digitox.workers.FlutterBgExecutionWorker
import com.nlp.digitox.workers.FlutterBgExecutionWorker.Companion.FLUTTER_TASK_ID

/**
 * Keeps the tracker / VPN / accessibility services alive after Android (or the
 * OEM) kills the app.
 *
 * Two mechanisms, because they solve two different problems:
 *
 *  - [scheduleKeepAlive] arms a *self-rescheduling one-shot* alarm. The old
 *    `setInexactRepeating` version could not re-arm itself after the process
 *    was killed, and Doze may defer a repeating alarm by hours.
 *
 *  - [scheduleImmediateRestart] is called from `onTaskRemoved()`. Swiping the
 *    app out of recents kills the process outright — `onDestroy()` is *not*
 *    called, so a service cannot restart itself from there. An AlarmManager
 *    alarm survives process death, so it is the only reliable way back up, and
 *    this one fires in ~2s instead of waiting for the next periodic tick.
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

    /**
     * Arms (or re-arms) the periodic watchdog. Safe to call repeatedly: the
     * PendingIntent is stable, so an existing alarm is replaced, not duplicated.
     */
    fun scheduleKeepAlive(context: Context) {
        val alarmManager =
            context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return

        val pendingIntent = PendingIntent.getBroadcast(
            context.applicationContext,
            KEEP_ALIVE_REQUEST_CODE,
            Intent(context.applicationContext, KeepAliveReceiver::class.java)
                .setAction(KeepAliveReceiver.ACTION_KEEP_ALIVE),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val triggerAt = SystemClock.elapsedRealtime() + KEEP_ALIVE_INTERVAL_MS
        try {
            // setAndAllowWhileIdle is the strongest variant that needs no
            // exact-alarm permission; the system clamps it to roughly once per
            // 9-15 minutes in Doze, which matches our cadence.
            alarmManager.setAndAllowWhileIdle(
                AlarmManager.ELAPSED_REALTIME_WAKEUP,
                triggerAt,
                pendingIntent,
            )
            Log.d(TAG, "scheduleKeepAlive: watchdog armed for +${KEEP_ALIVE_INTERVAL_MS / 60000}min")
        } catch (e: Exception) {
            SharedPrefsHelper.insertCrashLogToPrefs(context, e)
            Log.e(TAG, "scheduleKeepAlive: failed to arm watchdog", e)
        }
    }

    /**
     * Fires a one-shot alarm that restarts the background services almost
     * immediately. Called from `onTaskRemoved()`.
     *
     * Uses a distinct request code and action so it never replaces the
     * periodic watchdog.
     */
    fun scheduleImmediateRestart(context: Context) {
        val alarmManager =
            context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return

        val pendingIntent = PendingIntent.getBroadcast(
            context.applicationContext,
            IMMEDIATE_RESTART_REQUEST_CODE,
            Intent(context.applicationContext, KeepAliveReceiver::class.java)
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
            SharedPrefsHelper.insertCrashLogToPrefs(context, e)
            Log.e(TAG, "scheduleImmediateRestart: failed to arm restart", e)
        }
    }

    /**
     * Cancels the periodic watchdog. The immediate restart alarm is left alone —
     * it is a one-shot, and cancelling it could strand a recovering process.
     */
    fun cancelKeepAlive(context: Context) {
        try {
            val alarmManager =
                context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
            val pendingIntent = PendingIntent.getBroadcast(
                context.applicationContext,
                KEEP_ALIVE_REQUEST_CODE,
                Intent(context.applicationContext, KeepAliveReceiver::class.java)
                    .setAction(KeepAliveReceiver.ACTION_KEEP_ALIVE),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            alarmManager.cancel(pendingIntent)
        } catch (_: Exception) {
        }
    }

    /**
     * Fires on each keep-alive tick and on the one-shot restart alarm. Checks
     * whether the core services are running and restarts them if not.
     *
     * Also monitors the accessibility service: if permission is granted but the
     * service process is dead, it re-pushes settings, nudges the process back
     * up, and flags the state so the Flutter UI can show a lightweight "resume"
     * nudge instead of a full re-permission prompt.
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
                restartTrackerService(appContext)
                restartVpnService(appContext)
                monitorAccessibilityService(appContext)
                monitorDeviceAdminRevocation(appContext)
            } catch (e: Exception) {
                Log.e(TAG, "Keep-alive tick failed", e)
            } finally {
                // Re-arm the watchdog. This is what makes the chain survive a
                // process kill: a fresh process is started by this alarm and
                // immediately schedules the next one.
                scheduleKeepAlive(appContext)
            }
        }

        /**
         * Starts the tracker service, falling back to an expedited WorkManager
         * job when Android refuses a background foreground-service start
         * (Android 12+ `ForegroundServiceStartNotAllowedException`).
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

        /** Same contract as restartTrackerService, for the internet blocker. */
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
            }
        }

        /**
         * Flags Device Admin that was previously granted but has since been
         * silently revoked, so the UI can offer a one-tap re-enable.
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
         * Fallback used when a background foreground-service start is refused:
         * an expedited one-time job is permitted to start a foreground service.
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
    }
}
