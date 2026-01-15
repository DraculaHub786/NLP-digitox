/*
 *
 *  *
 *  *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *  *
 *  *  * This source code is licensed under the GPL-2.0 license license found in the
 *  *  * LICENSE file in the root directory of this source tree.
 *  *
 *
 */
package com.nlp.digitox.receivers.alarm

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.nlp.digitox.AppConstants
import com.nlp.digitox.R
import com.nlp.digitox.enums.DndWakeLock
import com.nlp.digitox.generics.SafeServiceConnection
import com.nlp.digitox.helpers.AlarmTasksSchedulingHelper.scheduleBedtimeRoutineTasks
import com.nlp.digitox.helpers.device.NotificationHelper
import com.nlp.digitox.helpers.storage.SharedPrefsHelper
import com.nlp.digitox.models.BedtimeSchedule
import com.nlp.digitox.services.tracking.MindfulTrackerService
import com.nlp.digitox.utils.AppUtils
import com.nlp.digitox.utils.DateTimeUtils
import com.nlp.digitox.utils.ThreadUtils

class BedtimeRoutineReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "Mindful.BedtimeRoutineReceiver"
        const val ACTION_ALERT_BEDTIME: String = "com.mindful.android.action.alertBedtime"
        const val ACTION_START_BEDTIME: String = "com.mindful.android.action.startBedtime"
        const val ACTION_STOP_BEDTIME: String = "com.mindful.android.action.stopBedtime"
        const val EXTRA_BEDTIME_SETTINGS_JSON = "com.mindful.android.extra.bedtimeSettingsJson"
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_ALERT_BEDTIME, ACTION_START_BEDTIME, ACTION_STOP_BEDTIME -> {
                /// Schedule worker
                WorkManager.getInstance(context).enqueueUniqueWork(
                    TAG,
                    ExistingWorkPolicy.KEEP,
                    OneTimeWorkRequest.Builder(BedtimeRoutineWorker::class.java)
                        .setInputData(
                            Data.Builder()
                                .putString("action", intent.action)
                                .putString(
                                    EXTRA_BEDTIME_SETTINGS_JSON,
                                    intent.extras?.getString(EXTRA_BEDTIME_SETTINGS_JSON) ?: ""
                                )
                                .build()
                        )
                        .build()
                )
            }
        }
    }


    class BedtimeRoutineWorker(
        private val context: Context,
        params: WorkerParameters,
    ) : Worker(context, params) {
        private val jsonBedtimeSettings = inputData.getString(EXTRA_BEDTIME_SETTINGS_JSON) ?: ""
        private val bedtimeSchedule = BedtimeSchedule.fromJson(jsonBedtimeSettings)
        private val canStartRoutineToday: Boolean =
            bedtimeSchedule.scheduleDays[DateTimeUtils.zeroIndexedDayOfWeek()]

        private val trackerServiceConn = SafeServiceConnection(
            context = context,
            serviceClass = MindfulTrackerService::class.java
        )


        override fun doWork(): Result {
            try {
                val action = inputData.getString("action")

                when (action) {
                    ACTION_ALERT_BEDTIME -> pushAlertNotification(context.getString(R.string.bedtime_upcoming_notification_info))
                    ACTION_START_BEDTIME -> startBedtimeRoutine()
                    ACTION_STOP_BEDTIME -> {
                        stopBedtimeRoutine()

                        // Reschedule bedtime tasks for next day
                        ThreadUtils.runOnMainThread(1000L) {
                            scheduleBedtimeRoutineTasks(
                                context,
                                jsonBedtimeSettings
                            )
                        }
                    }
                }
                return Result.success()
            } catch (e: Exception) {
                Log.e(TAG, "doWork: Error during work execution", e)
                SharedPrefsHelper.insertCrashLogToPrefs(context, e)
                return Result.failure()
            } finally {
                // Unbind service
                trackerServiceConn.unBindService()
            }
        }

        private fun startBedtimeRoutine() {
            if (!canStartRoutineToday) return
            trackerServiceConn.setOnConnectedCallback { service: MindfulTrackerService ->
                with(service) {
                    getRestrictionManager.updateBedtimeApps(bedtimeSchedule.distractingApps)
                    getLaunchTrackingManager.detectActiveAppForBedtime()
                }
            }
            trackerServiceConn.startAndBind()

            // Start DND if needed
            if (bedtimeSchedule.shouldStartDnd) NotificationHelper.toggleDnd(
                context,
                DndWakeLock.BEDTIME_MODE,
                true
            )
            pushAlertNotification(context.getString(R.string.bedtime_started_notification_info))
        }

        private fun stopBedtimeRoutine() {
            trackerServiceConn.setOnConnectedCallback { service: MindfulTrackerService ->
                service.getRestrictionManager.updateBedtimeApps(
                    null
                )
            }
            trackerServiceConn.bindService()

            // Stop DND if needed
            if (bedtimeSchedule.shouldStartDnd) NotificationHelper.toggleDnd(
                context,
                DndWakeLock.BEDTIME_MODE,
                false
            )
            pushAlertNotification(context.getString(R.string.bedtime_ended_notification_info))
        }


        private fun pushAlertNotification(alert: String) {
            val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.notify(
                AppConstants.BEDTIME_ROUTINE_NOTIFICATION_ID,
                NotificationCompat.Builder(
                    context,
                    NotificationHelper.BEDTIME_CHANNEL_ID
                )
                    .setSmallIcon(R.drawable.ic_mindful_notification)
                    .setOngoing(false)
                    .setOnlyAlertOnce(true)
                    .setContentIntent(
                        AppUtils.getPendingIntentForMindfulUri(
                            context,
                            "com.mindful.android://open/home?tab=3",
                        )
                    )
                    .setContentTitle(context.getString(R.string.app_name))
                    .setContentText(alert)
                    .setStyle(NotificationCompat.BigTextStyle().bigText(alert))
                    .build()
            )
        }
    }

}