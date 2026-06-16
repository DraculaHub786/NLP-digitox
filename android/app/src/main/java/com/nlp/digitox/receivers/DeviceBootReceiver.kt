
package com.nlp.digitox.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequest
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkManager
import com.nlp.digitox.generics.ServiceBinder
import com.nlp.digitox.helpers.AlarmTasksSchedulingHelper
import com.nlp.digitox.helpers.device.NotificationHelper
import com.nlp.digitox.helpers.storage.SharedPrefsHelper
import com.nlp.digitox.services.tracking.MindfulTrackerService
import com.nlp.digitox.services.vpn.MindfulVpnService
import com.nlp.digitox.workers.FlutterBgExecutionWorker
import com.nlp.digitox.workers.FlutterBgExecutionWorker.Companion.FLUTTER_TASK_ID

/**
 * BroadcastReceiver that listens for device boot and package replacement events
 * to restart required services and reschedule any pending alarms.
 */
class DeviceBootReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "Mindful.DeviceBootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            -> {
                Log.d(
                    TAG,
                    "onReceive: Device reboot broadcast received, initializing necessary services and tasks."
                )

                try {
                    // Register channels before starting foreground services
                    NotificationHelper.registerNotificationChannels(context.applicationContext)

                    // Reschedule midnight reset task
                    AlarmTasksSchedulingHelper.scheduleMidnightResetTask(context, false)

                    // *** DIRECTLY START FOREGROUND SERVICES ***
                    // Start tracker service immediately as a persistent foreground service
                    // This ensures app blocking and usage tracking resume right after boot
                    val trackerIntent = Intent(context.applicationContext, MindfulTrackerService::class.java)
                        .setAction(ServiceBinder.ACTION_START_MINDFUL_SERVICE)
                    context.applicationContext.startService(trackerIntent)
                    Log.d(TAG, "onReceive: MindfulTrackerService started on boot")

                    // Start VPN service immediately if internet blocking was enabled
                    // (the service will restore its config from SharedPrefs)
                    val blockedApps = SharedPrefsHelper.getSetInternetBlockedApps(context, null)
                    if (blockedApps.isNotEmpty()) {
                        val vpnIntent = Intent(context.applicationContext, MindfulVpnService::class.java)
                            .setAction(ServiceBinder.ACTION_START_MINDFUL_SERVICE)
                        context.applicationContext.startService(vpnIntent)
                        Log.d(TAG, "onReceive: MindfulVpnService started on boot")
                    }

                    // Queue a one-time work request to execute BootWorker tasks
                    // This initializes Flutter-side services (database, notifications, etc.)
                    WorkManager.getInstance(context).enqueueUniqueWork(
                        TAG, ExistingWorkPolicy.KEEP,
                        OneTimeWorkRequest
                            .Builder(FlutterBgExecutionWorker::class.java)
                            .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
                            .setInputData(
                                Data.Builder().putString(FLUTTER_TASK_ID, "onBootOrAppUpdate")
                                    .build()
                            ).build()
                    )
                } catch (e: Exception) {
                    SharedPrefsHelper.insertCrashLogToPrefs(context, e)
                    Log.e(TAG, "onReceive: Something went wrong!", e)
                }
            }
        }
    }
}
