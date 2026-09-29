package com.nlp.digitox.services.tracking

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log
import androidx.annotation.WorkerThread
import com.nlp.digitox.AppConstants
import com.nlp.digitox.R
import com.nlp.digitox.generics.ServiceBinder
import com.nlp.digitox.helpers.device.NotificationHelper
import com.nlp.digitox.helpers.storage.SharedPrefsHelper

class DigitoxTrackerService : Service() {
    companion object {
        private const val TAG = "Digitox.DigitoxTrackerService"
    }

    private val mBinder = ServiceBinder(this@DigitoxTrackerService)
    private var isFgRunning = false

    private lateinit var overlayManager: OverlayManager
    private lateinit var reminderManager: ReminderManager

    private lateinit var restrictionManager: RestrictionManager
    val getRestrictionManager get() = restrictionManager

    private lateinit var launchTrackingManager: LaunchTrackingManager
    val getLaunchTrackingManager get() = launchTrackingManager

    override fun onCreate() {
        overlayManager = OverlayManager(this)
        reminderManager = ReminderManager(overlayManager, ::onNewAppLaunch)
        restrictionManager = RestrictionManager(this)
        launchTrackingManager = LaunchTrackingManager(
            context = this,
            onNewAppLaunched = ::onNewAppLaunch,
            dismissOverlay = { overlayManager.dismissSheetOverlay() },
            cancelReminders = { reminderManager.cancelReminders() },
        )
        super.onCreate()
        restoreRestrictionsFromPrefs()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (!isFgRunning) {
            startFgService()
        }
        restoreRestrictionsFromPrefs()
        Log.d(TAG, "onStartCommand: TRACKER service command received, staying alive (startId=$startId)")
        return START_STICKY
    }

    private fun startFgService() {
        if (isFgRunning) return
        try {
            val notification = NotificationHelper.buildFgServiceNotification(
                this,
                getString(R.string.app_blocker_running_notification_info)
            )
            startForeground(AppConstants.TRACKER_SERVICE_NOTIFICATION_ID, notification)
            isFgRunning = true
            Log.d(TAG, "startFgService: TRACKER service started successfully as persistent foreground service")
        } catch (e: Exception) {
            Log.e(TAG, "startFgService: Failed to start TRACKER service", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this, e)
        }
    }

    fun onMidnightReset() {
        restrictionManager.resetCache()
        overlayManager.dismissSheetOverlay()
        val reminderAwaiting = reminderManager.cancelReminders()

        // Means app is active but timer is not over and now it is reset so re-launch same event again
        if (reminderAwaiting) launchTrackingManager.reInvokeLastLaunchEvent()
    }


    @WorkerThread
    private fun onNewAppLaunch(packageName: String) {
        try {
            reminderManager.cancelReminders()
            overlayManager.dismissSheetOverlay()

            /// check current restrictions
            val currentOrFutureState = restrictionManager.isAppRestricted(packageName)
            Log.d(TAG, "onNewAppLaunch: $packageName's evaluated state => $currentOrFutureState")

            currentOrFutureState?.let {
                /// Already restricted
                if (it.timeLeftMillis <= 0L) {
                    overlayManager.showSheetOverlay(
                        packageName = packageName,
                        restrictionState = it,
                    )
                }
                /// Under limit but will be exhausted in some time
                else {
                    reminderManager.scheduleReminders(
                        packageName = packageName,
                        state = it,
                    )
                }
            }
        } catch (e: Exception) {
            SharedPrefsHelper.insertCrashLogToPrefs(this, e)
            Log.e(TAG, "onNewAppLaunch: Failed to process new app launch event", e)
        }
    }

    private fun restoreRestrictionsFromPrefs() {
        val appRestrictions = SharedPrefsHelper.getSetAppRestrictions(this, null)
        val restrictionGroups = SharedPrefsHelper.getSetRestrictionGroups(this, null)
        if (appRestrictions.isNotEmpty() || restrictionGroups.isNotEmpty()) {
            restrictionManager.updateRestrictions(appRestrictions, restrictionGroups)
        }
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy: TRACKER service destroyed - re-launching immediately")
        // Use startForegroundService for Android 12+ compatibility (it's a foreground service)
        try {
            val restartIntent = Intent(this, DigitoxTrackerService::class.java)
                .setAction(ServiceBinder.ACTION_START_DIGITOX_SERVICE)
                .putExtra("isRestart", true)
            startForegroundService(restartIntent)
        } catch (e: Exception) {
            Log.w(TAG, "onDestroy: startForegroundService failed, fallback to startService", e)
            try {
                val restartIntent = Intent(this, DigitoxTrackerService::class.java)
                    .setAction(ServiceBinder.ACTION_START_DIGITOX_SERVICE)
                startService(restartIntent)
            } catch (e2: Exception) {
                SharedPrefsHelper.insertCrashLogToPrefs(this, e2)
            }
        }
        super.onDestroy()
    }


    override fun onBind(intent: Intent): IBinder? {
        return if (intent.action == ServiceBinder.ACTION_BIND_TO_DIGITOX) mBinder else null
    }
}
