package com.nlp.digitox.services.accessibility

import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.annotation.WorkerThread
import com.nlp.digitox.AppConstants.SYSTEM_UI_PACKAGE
import com.nlp.digitox.helpers.storage.SharedPrefsHelper


class TrackingManager(
    private val context: Context,
) {

    companion object {
        const val ACTION_ACCESSIBILITY_ACTIVE = "com.nlp.digitox.action.accessibilityActive"
        const val ACTION_ACCESSIBILITY_INACTIVE = "com.nlp.digitox.action.accessibilityInactive"
        const val ACTION_NEW_APP_LAUNCHED = "com.nlp.digitox.action.newAppLaunched"
        const val EXTRA_PACKAGE_NAME: String = "com.nlp.digitox.extra.packageName"
    }

    private var lastActiveApp: String = ""

    @WorkerThread
    fun onNewEvent(packageName: String) {
        if (lastActiveApp != packageName && packageName != SYSTEM_UI_PACKAGE) {
            lastActiveApp = packageName
            broadcastEvent(ACTION_NEW_APP_LAUNCHED, packageName)
        }
    }


    // Called when accessibility service is stopped
    fun startManualTracking() = broadcastEvent(ACTION_ACCESSIBILITY_INACTIVE)

    // Called when accessibility service is started
    fun stopManualTracking() = broadcastEvent(ACTION_ACCESSIBILITY_ACTIVE)


    private fun broadcastEvent(action: String, extraPackage: String? = null) {
        try {
            val intent = Intent(action).apply {
                setPackage(context.packageName)
                extraPackage?.let { putExtra(EXTRA_PACKAGE_NAME, it) }
            }
            context.sendBroadcast(intent)
        } catch (e: Exception) {
            Log.e(
                "Digitox.Accessibility.TrackingManager",
                "broadcastEvent: Failed to send broadcast for action:$action",
                e
            )
            SharedPrefsHelper.insertCrashLogToPrefs(context, e)
        }
    }
}