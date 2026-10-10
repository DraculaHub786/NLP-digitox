package com.nlp.digitox.helpers.device

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import com.nlp.digitox.helpers.storage.SharedPrefsHelper

/**
 * Opens the manufacturer-specific "auto-start / background activity" screen.
 *
 * These are not part of the public Android SDK — the components below are
 * best-effort deep links into the OEM Settings apps, and each one is wrapped so
 * a missing activity degrades into the system app-details page rather than a
 * crash. This is deliberately *advisory*: nothing here gates onboarding or the
 * dashboard, it only gives the user one tap to the switch their OEM hid.
 *
 * Keeping the tracker alive is a known-hard problem on Android; the honest
 * framing is "make the grant easy to give", not "survive a force-stop".
 */
object OemKeepAlive {
    private const val TAG = "Digitox.OemKeepAlive"

    /**
     * Opens the OEM background/auto-start settings screen.
     *
     * @return true when an OEM-specific screen was opened, false when we fell
     *         back to the generic app-details page or nothing could be opened —
     *         so the caller can decide whether to show a hint instead.
     */
    fun openBackgroundSettings(context: Context): Boolean {
        val manufacturer = Build.MANUFACTURER.lowercase()
        val intent = when {
            manufacturer.contains("xiaomi") -> Intent().apply {
                component = ComponentName(
                    "com.miui.securitycenter",
                    "com.miui.permcenter.autostart.AutoStartManagementActivity",
                )
            }

            manufacturer.contains("oppo") ||
                manufacturer.contains("realme") -> Intent().apply {
                component = ComponentName(
                    "com.coloros.safecenter",
                    "com.coloros.safecenter.permission.startup.StartupAppListActivity",
                )
            }

            manufacturer.contains("vivo") -> Intent().apply {
                component = ComponentName(
                    "com.vivo.permissionmanager",
                    "com.vivo.permissionmanager.activity.BgStartUpManagerActivity",
                )
            }

            manufacturer.contains("samsung") -> Intent().apply {
                component = ComponentName(
                    "com.samsung.android.lool",
                    "com.samsung.android.sm.ui.battery.BatteryActivity",
                )
            }

            manufacturer.contains("huawei") ||
                manufacturer.contains("honor") -> Intent().apply {
                component = ComponentName(
                    "com.huawei.systemmanager",
                    "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity",
                )
            }

            else -> null
        }

        if (intent != null) {
            try {
                context.startActivity(intent)
                Log.d(TAG, "Opened OEM background settings for $manufacturer")
                return true
            } catch (e: Exception) {
                Log.w(TAG, "OEM background screen unavailable for $manufacturer", e)
                SharedPrefsHelper.insertCrashLogToPrefs(context, e)
            }
        }

        // Fallback: the app's own details page, where battery restrictions live
        // on stock Android.
        return try {
            context.startActivity(
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                    .setData(Uri.parse("package:${context.packageName}"))
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
            false
        } catch (e: Exception) {
            Log.e(TAG, "Could not open app details settings either", e)
            false
        }
    }
}
