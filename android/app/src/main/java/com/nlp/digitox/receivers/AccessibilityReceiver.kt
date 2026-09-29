package com.nlp.digitox.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import com.nlp.digitox.helpers.storage.SharedPrefsHelper
import com.nlp.digitox.services.accessibility.TrackingManager.Companion.ACTION_ACCESSIBILITY_ACTIVE
import com.nlp.digitox.services.accessibility.TrackingManager.Companion.ACTION_ACCESSIBILITY_INACTIVE
import com.nlp.digitox.services.accessibility.TrackingManager.Companion.ACTION_NEW_APP_LAUNCHED
import com.nlp.digitox.services.accessibility.TrackingManager.Companion.EXTRA_PACKAGE_NAME
import com.nlp.digitox.utils.Utils

class AccessibilityReceiver(
    private val onServiceStatusChanged: ((isActive: Boolean) -> Unit)? = null,
    private val onNewAppLaunched: ((packageName: String) -> Unit)? = null,

    ) : BroadcastReceiver() {

    private val TAG = "Digitox.AccessibilityReceiver"

    fun register(context: Context) {
        try {
            Utils.safelyRegisterReceiver(
                context,
                this,
                IntentFilter().apply {
                    addAction(ACTION_ACCESSIBILITY_ACTIVE)
                    addAction(ACTION_ACCESSIBILITY_INACTIVE)
                    addAction(ACTION_NEW_APP_LAUNCHED)
                },
            )
        } catch (e: Exception) {
            Log.e(TAG, "register: Failed to register receiver", e)
            SharedPrefsHelper.insertCrashLogToPrefs(context, e)
        }
    }

    fun unRegister(context: Context) {
        try {
            context.unregisterReceiver(this)
        } catch (e: Exception) {
            Log.e(TAG, "register: Failed to un-register receiver", e)
            SharedPrefsHelper.insertCrashLogToPrefs(context, e)
        }
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        intent?.let {
            when (it.action) {
                ACTION_ACCESSIBILITY_ACTIVE -> onServiceStatusChanged?.invoke(true)
                ACTION_ACCESSIBILITY_INACTIVE -> onServiceStatusChanged?.invoke(false)
                ACTION_NEW_APP_LAUNCHED -> it.getStringExtra(EXTRA_PACKAGE_NAME)
                    ?.let { packageName ->
                        onNewAppLaunched?.invoke(packageName)
                    }

                else -> return
            }
        }
    }
}