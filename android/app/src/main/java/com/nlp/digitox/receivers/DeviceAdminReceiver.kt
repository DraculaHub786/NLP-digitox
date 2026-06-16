
package com.nlp.digitox.receivers

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent
import android.widget.Toast
import com.nlp.digitox.services.accessibility.MindfulAccessibilityService
import com.nlp.digitox.services.accessibility.MindfulAccessibilityService.Companion.ACTION_TAMPER_PROTECTION_CHANGED
import com.nlp.digitox.utils.Utils

/**
 * A DeviceAdminReceiver for handling device administration events for the Mindful app.
 */
class DeviceAdminReceiver : DeviceAdminReceiver() {
    override fun onEnabled(context: Context, intent: Intent) {
        Toast.makeText(context, "Tamper protection enabled", Toast.LENGTH_LONG).show()
        refreshWellbeingSettings(context)
        super.onEnabled(context, intent)
    }

    override fun onDisabled(context: Context, intent: Intent) {
        Toast.makeText(context, "Tamper protection disabled", Toast.LENGTH_LONG).show()
        refreshWellbeingSettings(context)
        super.onDisabled(context, intent)
    }

    private fun refreshWellbeingSettings(context: Context) {
        if (Utils.isServiceRunning(context, MindfulAccessibilityService::class.java)) {
            val serviceIntent = Intent(
                context.applicationContext,
                MindfulAccessibilityService::class.java
            ).setAction(ACTION_TAMPER_PROTECTION_CHANGED)

            context.startService(serviceIntent)
        }
    }
}

