
package com.nlp.digitox.services.timer

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log
import com.nlp.digitox.AppConstants.EMERGENCY_PAUSE_SERVICE_NOTIFICATION_ID
import com.nlp.digitox.R
import com.nlp.digitox.generics.SafeServiceConnection
import com.nlp.digitox.generics.ServiceBinder
import com.nlp.digitox.helpers.device.NotificationHelper.CRITICAL_CHANNEL_ID
import com.nlp.digitox.helpers.storage.SharedPrefsHelper
import com.nlp.digitox.services.tracking.DigitoxTrackerService
import com.nlp.digitox.utils.AppUtils
import com.nlp.digitox.utils.DateTimeUtils

class EmergencyPauseService : Service() {
    private lateinit var mNotificationTimer: NotificationTimer
    private lateinit var mTrackerServiceConn: SafeServiceConnection<DigitoxTrackerService>

    override fun onCreate() {
        mTrackerServiceConn = SafeServiceConnection(
            context = this,
            serviceClass = DigitoxTrackerService::class.java
        )
        mNotificationTimer = NotificationTimer(
            context = this,
            ongoingPendingIntent = AppUtils.getPendingIntentForDigitoxUri(this),
            title = getString(R.string.emergency_pause_notification_title),
            timerDurationSeconds = DEFAULT_EMERGENCY_PASS_PERIOD_SECONDS,
            notificationId = EMERGENCY_PAUSE_SERVICE_NOTIFICATION_ID,
            notificationChannelId = CRITICAL_CHANNEL_ID,
            onTicked = { remainingTime ->
                getString(
                    R.string.emergency_pause_notification_info,
                    DateTimeUtils.secondsToTimeStr(remainingTime)
                )
            },
            onFinished = { getString(R.string.emergency_pause_ended_notification_info) },
            onDispose = {
                Log.d(
                    TAG,
                    "startEmergencyTimer: Emergency pause is over. App blocker is resumed successfully"
                )
                stopSelf()
            }
        )
        super.onCreate()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ServiceBinder.ACTION_START_DIGITOX_SERVICE) {
            startEmergencyTimer()
            return START_STICKY
        }

        stopSelf()
        return START_NOT_STICKY
    }

    private fun startEmergencyTimer() {
        try {
            startForeground(
                EMERGENCY_PAUSE_SERVICE_NOTIFICATION_ID,
                mNotificationTimer.getInitialNotification
            )

            mTrackerServiceConn.setOnConnectedCallback { service: DigitoxTrackerService ->
                service.getLaunchTrackingManager.pauseResumeTracking(true)
            }
            mTrackerServiceConn.bindService()
            mNotificationTimer.startTimer()
            Log.d(TAG, "startEmergencyTimer: EMERGENCY service started successfully")
        } catch (e: Exception) {
            Log.d(TAG, "startEmergencyTimer: Failed to start EMERGENCY service: ", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this, e)
            stopSelf()
        }
    }


    override fun onDestroy() {
        mTrackerServiceConn.service?.getLaunchTrackingManager?.pauseResumeTracking(false)
        mTrackerServiceConn.unBindService()
        stopForeground(STOP_FOREGROUND_REMOVE)
        Log.d(TAG, "onDestroy: EMERGENCY service destroyed successfully")
        super.onDestroy()
    }

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    companion object {
        private const val DEFAULT_EMERGENCY_PASS_PERIOD_SECONDS: Long = 5 * 60L
        private const val TAG = "Digitox.EmergencyPauseService"
    }
}