
package com.nlp.digitox.services.timer

import android.app.Service
import android.content.ComponentName
import android.content.Intent
import android.os.IBinder
import android.service.quicksettings.TileService
import android.util.Log
import com.nlp.digitox.AppConstants.FOCUS_SESSION_SERVICE_NOTIFICATION_ID
import com.nlp.digitox.R
import com.nlp.digitox.enums.DndWakeLock
import com.nlp.digitox.generics.SafeServiceConnection
import com.nlp.digitox.generics.ServiceBinder
import com.nlp.digitox.helpers.device.NotificationHelper
import com.nlp.digitox.helpers.device.NotificationHelper.FOCUS_CHANNEL_ID
import com.nlp.digitox.helpers.storage.SharedPrefsHelper
import com.nlp.digitox.models.FocusSession
import com.nlp.digitox.services.quickTiles.FocusQuickTileService
import com.nlp.digitox.services.tracking.MindfulTrackerService
import com.nlp.digitox.utils.AppUtils
import com.nlp.digitox.utils.DateTimeUtils
import java.util.Calendar
import kotlin.math.max

class FocusSessionService : Service() {
    private val mBinder = ServiceBinder(this@FocusSessionService)
    private lateinit var mTrackerServiceConn: SafeServiceConnection<MindfulTrackerService>
    private lateinit var mNotificationTimer: NotificationTimer


    private var session: FocusSession? = null

    override fun onCreate() {
        mTrackerServiceConn = SafeServiceConnection(
            context = this,
            serviceClass = MindfulTrackerService::class.java
        )
        super.onCreate()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ServiceBinder.ACTION_START_MINDFUL_SERVICE) {
            return START_STICKY
        }

        stopSelf()
        return START_NOT_STICKY
    }


    /**
     * Starts a countdown timer for a focus session. Configures notifications to show the remaining time
     * and handles DND mode if needed.
     */
    fun startFocusSession(focusSession: FocusSession) {
        try {
            if (focusSession.distractingApps.isEmpty()) {
                stopSelf()
                return
            }

            session = focusSession
            initializeSessionTimer(focusSession)

            startForeground(
                FOCUS_SESSION_SERVICE_NOTIFICATION_ID,
                mNotificationTimer.getInitialNotification
            )

            /// Start and bind tracking service
            mTrackerServiceConn.setOnConnectedCallback { service: MindfulTrackerService ->
                service.getRestrictionManager.updateFocusedApps(
                    focusSession.distractingApps
                )
            }
            mTrackerServiceConn.startAndBind()

            // Toggle DND according to the session configurations
            if (focusSession.toggleDnd) NotificationHelper.toggleDnd(
                this,
                DndWakeLock.FOCUS_MODE,
                true
            )

            mNotificationTimer.startTimer()

            /// Update focus quick tile
            TileService.requestListeningState(
                this,
                ComponentName(this, FocusQuickTileService::class.java)
            )
            Log.d(TAG, "startFocusSession: FOCUS service started successfully")
        } catch (e: Exception) {
            Log.d(TAG, "startFocusSession: Failed to start FOCUS service", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this, e)
            stopSelf()
        }
    }

    private fun initializeSessionTimer(session: FocusSession) {
        val isFiniteSession = session.durationSecs > 0
        val elapsedTimeMs = System.currentTimeMillis() - session.startTimeMsEpoch

        val timerDuration: Long = if (isFiniteSession) {
            session.durationSecs.toLong()
        } else {
            val cal = DateTimeUtils.todToTodayCal(0)
            cal.add(Calendar.HOUR, 24)
            cal.timeInMillis / 1000L
        }


        mNotificationTimer = NotificationTimer(
            context = this,
            ongoingPendingIntent = AppUtils.getPendingIntentForMindfulUri(
                this,
                "com.mindful.android://open/activeSession"
            ),
            finishedPendingIntent = AppUtils.getPendingIntentForMindfulUri(
                this,
                "com.mindful.android://open/focus?tab=1"
            ),
            isFinite = isFiniteSession,
            title = getString(R.string.focus_session_notification_title),
            timerDurationSeconds = timerDuration,
            alreadyElapsedTimeSecond = max(0, elapsedTimeMs / 1000L),
            notificationId = FOCUS_SESSION_SERVICE_NOTIFICATION_ID,
            notificationChannelId = FOCUS_CHANNEL_ID,
            onTicked = { remainingTime ->
                getString(
                    if (isFiniteSession) R.string.focus_session_notification_info
                    else R.string.focus_session_infinite_notification_info,
                    DateTimeUtils.secondsToTimeStr(remainingTime)
                )
            },
            onFinished = { getString(R.string.focus_session_success_notification_info) },
            onDispose = { stopSelf() },
        )
    }


    fun updateFocusSession(session: FocusSession) {
        mTrackerServiceConn.service?.getRestrictionManager?.updateFocusedApps(session.distractingApps)
        Log.d(
            TAG,
            "updateDistractingApps: Focus session's distracting app's list updated successfully"
        )
    }


    fun giveUpOrStopFocusSession(isTheSessionSuccessful: Boolean) {
        if (session?.toggleDnd == true) {
            NotificationHelper.toggleDnd(this, DndWakeLock.FOCUS_MODE, false)
        }

        mNotificationTimer.forceDisposeTimer(
            getString(
                if (isTheSessionSuccessful) R.string.focus_session_success_notification_info
                else R.string.focus_session_giveup_notification_info
            )
        )
    }


    override fun onDestroy() {
        mTrackerServiceConn.service?.getRestrictionManager?.updateFocusedApps(null)
        mTrackerServiceConn.unBindService()
        stopForeground(STOP_FOREGROUND_REMOVE)
        Log.d(TAG, "onDestroy: FOCUS service destroyed successfully")

        /// Update focus quick tile
        TileService.requestListeningState(
            this,
            ComponentName(this, FocusQuickTileService::class.java)
        )
        super.onDestroy()
    }


    override fun onBind(intent: Intent): IBinder? {
        return if (intent.action == ServiceBinder.ACTION_BIND_TO_MINDFUL) mBinder
        else null
    }

    companion object {
        private const val TAG = "Mindful.FocusSessionService"
    }
}