package com.nlp.digitox.services

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import com.nlp.digitox.activities.RestrictionOverlayActivity
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ConcurrentHashMap

class FocusAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "FocusAccessibilityService"
        private const val OVERLAY_COOLDOWN_MS = 2000L
        private const val CHECK_INTERVAL_MS = 500L
        
        var instance: FocusAccessibilityService? = null
        var methodChannel: MethodChannel? = null
    }

    private val handler = Handler(Looper.getMainLooper())
    private val lastOverlayTime = ConcurrentHashMap<String, Long>()
    private var currentPackage: String? = null
    private var isCheckingRestriction = false

    override fun onServiceConnected() {
        Log.d(TAG, "Accessibility service connected")
        instance = this

        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                    AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            notificationTimeout = 100
            flags = AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS or
                    AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
        }
        serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null || isCheckingRestriction) return

        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                val packageName = event.packageName?.toString() ?: return
                
                // Skip system apps and our own app
                if (packageName.startsWith("com.android") || 
                    packageName == "com.nlp.digitox" ||
                    packageName == currentPackage) {
                    return
                }

                currentPackage = packageName
                Log.d(TAG, "App launched: $packageName")

                // Check restriction with cooldown to prevent spam
                val now = System.currentTimeMillis()
                val lastCheck = lastOverlayTime[packageName] ?: 0
                
                if (now - lastCheck > OVERLAY_COOLDOWN_MS) {
                    checkAndBlockApp(packageName)
                }
            }

            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                // Content changes are tracked for heuristic detection
                // This could indicate scrolling, which may suggest anxious behavior
            }
        }
    }

    override fun onInterrupt() {
        Log.d(TAG, "Accessibility service interrupted")
        handler.removeCallbacksAndMessages(null)
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Accessibility service destroyed")
        handler.removeCallbacksAndMessages(null)
        instance = null
    }

    private fun checkAndBlockApp(packageName: String) {
        isCheckingRestriction = true
        
        // Use MethodChannel to communicate with Flutter side
        handler.post {
            methodChannel?.invokeMethod("checkAppRestriction", packageName, object : MethodChannel.Result {
                override fun success(result: Any?) {
                    isCheckingRestriction = false
                    
                    if (result is Boolean && result) {
                        showRestrictionOverlay(packageName)
                        lastOverlayTime[packageName] = System.currentTimeMillis()
                    }
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    isCheckingRestriction = false
                    Log.e(TAG, "Error checking restriction: $errorMessage")
                }

                override fun notImplemented() {
                    isCheckingRestriction = false
                    Log.w(TAG, "checkAppRestriction not implemented in Flutter")
                }
            })
        }
    }

    private fun showRestrictionOverlay(packageName: String) {
        Log.d(TAG, "Showing restriction overlay for: $packageName")
        
        try {
            val intent = Intent(this, RestrictionOverlayActivity::class.java).apply {
                putExtra("packageName", packageName)
                putExtra("timestamp", System.currentTimeMillis())
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or 
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_NO_HISTORY)
            }
            startActivity(intent)
            
            // Return to home screen
            handler.postDelayed({
                performGlobalAction(GLOBAL_ACTION_HOME)
            }, 300)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to show overlay", e)
        }
    }

    private fun acquireLockForApp(packageName: String) {
        methodChannel?.invokeMethod("acquireLock", packageName)
    }

    private fun releaseLockForApp(packageName: String) {
        methodChannel?.invokeMethod("releaseLock", packageName)
    }

    private fun logRestrictionEvent(packageName: String, reason: String) {
        val data = mapOf(
            "packageName" to packageName,
            "reason" to reason,
            "timestamp" to System.currentTimeMillis()
        )
        methodChannel?.invokeMethod("logRestrictionEvent", data)
    }
}
