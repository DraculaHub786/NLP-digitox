package com.nlp.digitox.activities

import android.app.Activity
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import android.content.Intent
import com.nlp.digitox.R

class RestrictionOverlayActivity : Activity() {

    companion object {
        private const val TAG = "RestrictionOverlay"
    }

    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Make this a full-screen blocking activity
        window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )

        val packageName = intent.getStringExtra("packageName") ?: "Unknown App"
        val appName = getAppName(packageName)
        
        // Simple blocking screen (no layout file needed for MVP)
        showBlockingMessage(appName)
    }

    private fun showBlockingMessage(appName: String) {
        // For MVP, we'll go back to home immediately
        // In production, you'd show a proper UI layout
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)
        finish()
    }

    private fun getAppName(packageName: String): String {
        return try {
            val appInfo = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(appInfo).toString()
        } catch (e: Exception) {
            packageName
        }
    }

    override fun onBackPressed() {
        // Prevent back button - user must use home or the app will close itself
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacksAndMessages(null)
    }
}
