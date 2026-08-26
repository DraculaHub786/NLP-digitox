
package com.nlp.digitox.receivers.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequest
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.nlp.digitox.generics.SafeServiceConnection
import com.nlp.digitox.helpers.AlarmTasksSchedulingHelper.scheduleMidnightResetTask
import com.nlp.digitox.helpers.storage.SharedPrefsHelper
import com.nlp.digitox.services.accessibility.DigitoxAccessibilityService
import com.nlp.digitox.services.accessibility.DigitoxAccessibilityService.Companion.ACTION_MIDNIGHT_ACCESSIBILITY_RESET
import com.nlp.digitox.services.tracking.DigitoxTrackerService
import com.nlp.digitox.utils.Utils
import com.nlp.digitox.workers.FlutterBgExecutionWorker
import com.nlp.digitox.workers.FlutterBgExecutionWorker.Companion.FLUTTER_TASK_ID

class MidnightResetReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "Digitox.MidnightResetReceiver"
        const val ACTION_START_MIDNIGHT_RESET = "com.mindful.android.action.startMidnightReset"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION_START_MIDNIGHT_RESET) {
            WorkManager.getInstance(context).let {

                /// Enqueue midnight worker for services
                it.enqueueUniqueWork(
                    "Digitox.MidnightResetReceiver.Native",
                    ExistingWorkPolicy.KEEP,
                    OneTimeWorkRequest.Builder(MidnightResetWorker::class.java).build()
                )

                /// Enqueue flutter bg worker to backup apps usage
                it.enqueueUniqueWork(
                    "Digitox.MidnightResetReceiver.FlutterBg",
                    ExistingWorkPolicy.KEEP,
                    OneTimeWorkRequest
                        .Builder(FlutterBgExecutionWorker::class.java)
                        .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
                        .setInputData(
                            Data.Builder().putString(FLUTTER_TASK_ID, "onMidnightReset")
                                .build()
                        ).build()
                )
            }
        }
    }

    class MidnightResetWorker(
        private val context: Context,
        params: WorkerParameters,
    ) : Worker(context, params) {
        private val mTrackerServiceConn = SafeServiceConnection(
            context = context,
            serviceClass = DigitoxTrackerService::class.java,
        )


        override fun doWork(): Result {
            try {
                // Let tracking service know about midnight reset
                mTrackerServiceConn.setOnConnectedCallback { service: DigitoxTrackerService -> service.onMidnightReset() }
                mTrackerServiceConn.bindService()

                // Let accessibility service know about midnight reset
                if (Utils.isServiceRunning(context, DigitoxAccessibilityService::class.java)) {
                    val serviceIntent = Intent(
                        context.applicationContext,
                        DigitoxAccessibilityService::class.java
                    ).setAction(ACTION_MIDNIGHT_ACCESSIBILITY_RESET)
                    context.startService(serviceIntent)
                } else {
                    // Else at least reset short content screen time
                    SharedPrefsHelper.getSetShortsScreenTimeMs(context, 0L)
                }

                // Reset daily unlock tracking.
                SharedPrefsHelper.getSetDeviceUnlockCount(context, 0)

                Log.d(TAG, "doWork: Midnight reset work completed successfully")
                return Result.success()
            } catch (e: Exception) {
                Log.e(TAG, "doWork: Error during work execution", e)
                SharedPrefsHelper.insertCrashLogToPrefs(context, e)
                return Result.failure()
            } finally {
                // Unbind service and schedule task for the next day
                mTrackerServiceConn.unBindService()
                scheduleMidnightResetTask(context, false)
            }
        }
    }
}