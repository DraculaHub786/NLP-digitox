package com.nlp.digitox.helpers

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.util.Log
import com.nlp.digitox.generics.ServiceBinder
import com.nlp.digitox.helpers.storage.SharedPrefsHelper
import com.nlp.digitox.services.tracking.MindfulTrackerService
import com.nlp.digitox.services.vpn.MindfulVpnService
import com.nlp.digitox.utils.Utils

/**
 * Schedules periodic inexact alarms to check and restart background services
 * if they have been killed by the system. This is the primary defense against
 * Android/OEM process killing when the app is removed from recents.
 *
 * Uses inexact repeating alarms (battery-friendly) at a 10-minute interval.
 */
object KeepAliveHelper {
    private const val TAG = "Mindful.KeepAlive"
    private const val KEEP_ALIVE_REQUEST_CODE = 201
    private const val KEEP_ALIVE_INTERVAL_MS = 10 * 60 * 1000L // 10 minutes

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
     */
    class KeepAliveReceiver : BroadcastReceiver() {
        companion object {
            const val ACTION_KEEP_ALIVE = "com.mindful.android.action.KEEP_ALIVE"
        }

        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action != ACTION_KEEP_ALIVE) return

            try {
                // Re-start tracker (screen-usage / app-blocker) service if dead
                if (!Utils.isServiceRunning(context, MindfulTrackerService::class.java)) {
                    Log.w(TAG, "Tracker service down - restarting")
                    context.startForegroundService(
                        Intent(context, MindfulTrackerService::class.java)
                            .setAction(ServiceBinder.ACTION_START_MINDFUL_SERVICE)
                    )
                }

                // Re-start VPN (internet-blocker) service if dead
                if (!Utils.isServiceRunning(context, MindfulVpnService::class.java)) {
                    Log.w(TAG, "VPN service down - restarting")
                    context.startForegroundService(
                        Intent(context, MindfulVpnService::class.java)
                            .setAction(ServiceBinder.ACTION_START_MINDFUL_SERVICE)
                    )
                }
            } catch (e: Exception) {
                Log.e(TAG, "Keep-alive tick failed", e)
            }
        }
    }
}
