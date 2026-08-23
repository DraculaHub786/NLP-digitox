package com.nlp.digitox.helpers

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.util.Log
import com.nlp.digitox.generics.ServiceBinder
import com.nlp.digitox.helpers.device.PermissionsHelper
import com.nlp.digitox.helpers.storage.SharedPrefsHelper
import com.nlp.digitox.services.accessibility.DigitoxAccessibilityService
import com.nlp.digitox.services.tracking.DigitoxTrackerService
import com.nlp.digitox.services.vpn.DigitoxVpnService
import com.nlp.digitox.utils.Utils

/**
 * Schedules periodic inexact alarms to check and restart background services
 * if they have been killed by the system. This is the primary defense against
 * Android/OEM process killing when the app is removed from recents.
 *
 * Uses inexact repeating alarms (battery-friendly) at a 10-minute interval.
 *
 * Also monitors the accessibility service for Task B resilience:
 * if permission is granted but the service process is dead, this re-pushes
 * settings to SharedPrefs so the service picks them up on rebind, and flags
 * the state so the Flutter UI can show a lightweight "paused — tap to resume"
 * nudge instead of a full re-permission prompt.
 */
object KeepAliveHelper {
    private const val TAG = "Digitox.KeepAlive"
    private const val KEEP_ALIVE_REQUEST_CODE = 201
    private const val KEEP_ALIVE_INTERVAL_MS = 10 * 60 * 1000L // 10 minutes

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
     * Schedules a repeating inexact keep-alive alarm.
     * Inexact = battery-friendly (Android can flex the timing).
     */
    fun scheduleKeepAlive(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, KeepAliveReceiver::class.java)
            .setAction(KeepAliveReceiver.ACTION_KEEP_ALIVE)

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            KEEP_ALIVE_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        alarmManager.setInexactRepeating(
            AlarmManager.ELAPSED_REALTIME_WAKEUP,
            SystemClock.elapsedRealtime() + KEEP_ALIVE_INTERVAL_MS,
            KEEP_ALIVE_INTERVAL_MS,
            pendingIntent
        )
        Log.d(TAG, "scheduleKeepAlive: Scheduled every ${KEEP_ALIVE_INTERVAL_MS / 60000}min")
    }

    /**
     * Cancels the keep-alive alarm.
     */
    fun cancelKeepAlive(context: Context) {
        try {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, KeepAliveReceiver::class.java)
                .setAction(KeepAliveReceiver.ACTION_KEEP_ALIVE)

            val pendingIntent = PendingIntent.getBroadcast(
                context,
                KEEP_ALIVE_REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(pendingIntent)
        } catch (_: Exception) { }
    }

    /**
     * BroadcastReceiver that fires on each keep-alive tick.
     * Checks if core services are running and restarts them if not.
     *
     * Task B: Also monitors accessibility service. If permission is granted
     * but the service process is dead, re-pushes settings and flags the state
     * so the Flutter UI can show a lightweight "resume" nudge.
     */
    class KeepAliveReceiver : BroadcastReceiver() {
        companion object {
            const val ACTION_KEEP_ALIVE = "com.mindful.android.action.KEEP_ALIVE"
        }

        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action != ACTION_KEEP_ALIVE) return

            try {
                // ── Re-start tracker (screen-usage / app-blocker) service if dead ──
                if (!Utils.isServiceRunning(context, DigitoxTrackerService::class.java)) {
                    Log.w(TAG, "Tracker service down - restarting")
                    context.startForegroundService(
                        Intent(context, DigitoxTrackerService::class.java)
                            .setAction(ServiceBinder.ACTION_START_DIGITOX_SERVICE)
                    )
                }

                // ── Re-start VPN (internet-blocker) service if dead ──
                if (!Utils.isServiceRunning(context, DigitoxVpnService::class.java)) {
                    Log.w(TAG, "VPN service down - restarting")
                    context.startForegroundService(
                        Intent(context, DigitoxVpnService::class.java)
                            .setAction(ServiceBinder.ACTION_START_DIGITOX_SERVICE)
                    )
                }

                // ═══════════════════════════════════════════════════════════════════
                // Task B: Accessibility service resilience monitoring
                // ═══════════════════════════════════════════════════════════════════
                val isAccessibilityPermitted =
                    PermissionsHelper.isAccessibilityServiceEnabled(context)
                val isAccessibilityActive =
                    Utils.isServiceRunning(context, DigitoxAccessibilityService::class.java)

                if (isAccessibilityPermitted && !isAccessibilityActive) {
                    // Permission granted but service process is dead (killed by OEM).
                    // Re-push wellbeing settings to SharedPrefs so that when the system
                    // rebinds the service (on next app open or system-triggered rebind),
                    // it immediately has the latest config without waiting for the next
                    // SharedPrefs change.
                    Log.w(TAG, "Accessibility service is permitted but NOT running — re-pushing settings")
                    SharedPrefsHelper.getSetWellBeingSettings(
                        context,
                        SharedPrefsHelper.getSetWellBeingSettingsAsJsonString(context)
                    )

                    // Flag this state for the Flutter UI to show a reconnect nudge
                    SharedPrefsHelper.putBoolean(
                        context,
                        PREF_KEY_ACCESSIBILITY_SERVICE_PAUSED,
                        true
                    )
                } else if (isAccessibilityPermitted && isAccessibilityActive) {
                    // Service is alive and well — clear the paused flag
                    if (SharedPrefsHelper.getBoolean(context, PREF_KEY_ACCESSIBILITY_SERVICE_PAUSED, false)) {
                        SharedPrefsHelper.putBoolean(
                            context,
                            PREF_KEY_ACCESSIBILITY_SERVICE_PAUSED,
                            false
                        )
                        Log.d(TAG, "Accessibility service is active again — cleared paused flag")
                    }
                }
                // ═══════════════════════════════════════════════════════════════════
                // Task D: Device Admin revocation monitoring
                // ═══════════════════════════════════════════════════════════════════
                // Check if admin was previously granted but is now revoked by OEM.
                // Uses two flags:
                //   _WAS_SEEN_ACTIVE  → set once when admin is first detected active, never cleared
                //   _REVOKED          → set when admin was active but no longer is
                val isAdminActive = PermissionsHelper.getAndAskAdminPermission(context, false)

                // If admin is active right now, note that we've seen it active at least once
                if (isAdminActive) {
                    if (!SharedPrefsHelper.getBoolean(context, PREF_KEY_DEVICE_ADMIN_WAS_SEEN_ACTIVE, false)) {
                        SharedPrefsHelper.putBoolean(context, PREF_KEY_DEVICE_ADMIN_WAS_SEEN_ACTIVE, true)
                    }
                    // Clear any revocation flag
                    if (SharedPrefsHelper.getBoolean(context, PREF_KEY_DEVICE_ADMIN_REVOKED, false)) {
                        SharedPrefsHelper.putBoolean(context, PREF_KEY_DEVICE_ADMIN_REVOKED, false)
                        Log.d(TAG, "Device Admin is active again — cleared revocation flag")
                    }
                } else {
                    // Admin is not active. Flag as revoked only if we've ever seen it active before.
                    val wasEverSeenActive = SharedPrefsHelper.getBoolean(
                        context, PREF_KEY_DEVICE_ADMIN_WAS_SEEN_ACTIVE, false
                    )
                    if (wasEverSeenActive) {
                        SharedPrefsHelper.putBoolean(context, PREF_KEY_DEVICE_ADMIN_REVOKED, true)
                        Log.w(TAG, "Device Admin was previously enabled but is now inactive — flagging revocation")
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Keep-alive tick failed", e)
            }
        }
    }
}
