package com.nlp.digitox

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.net.VpnService
import androidx.activity.result.ActivityResultLauncher
import com.nlp.digitox.enums.DndWakeLock
import com.nlp.digitox.generics.SafeServiceConnection
import com.nlp.digitox.generics.ServiceBinder
import com.nlp.digitox.helpers.AlarmTasksSchedulingHelper.cancelBedtimeRoutineTasks
import com.nlp.digitox.helpers.KeepAliveHelper
import com.nlp.digitox.helpers.AlarmTasksSchedulingHelper.cancelNotificationBatchTask
import com.nlp.digitox.helpers.AlarmTasksSchedulingHelper.scheduleBedtimeRoutineTasks
import com.nlp.digitox.helpers.AlarmTasksSchedulingHelper.scheduleNotificationBatchTask
import com.nlp.digitox.helpers.device.DeviceAppsHelper.getDeviceAppInfos
import com.nlp.digitox.helpers.device.NewActivitiesLaunchHelper
import com.nlp.digitox.helpers.device.NotificationHelper
import com.nlp.digitox.helpers.device.PermissionsHelper
import com.nlp.digitox.helpers.storage.SharedPrefsHelper
import com.nlp.digitox.helpers.usages.AppsUsageHelper.getAppsUsageForInterval
import com.nlp.digitox.models.AppRestriction
import com.nlp.digitox.models.BedtimeSchedule
import com.nlp.digitox.models.FocusSession
import com.nlp.digitox.models.Notification
import com.nlp.digitox.models.NotificationSettings
import com.nlp.digitox.models.RestrictionGroup
import com.nlp.digitox.services.notification.DigitoxNotificationListenerService
import com.nlp.digitox.services.timer.EmergencyPauseService
import com.nlp.digitox.services.timer.FocusSessionService
import com.nlp.digitox.services.tracking.DigitoxTrackerService
import com.nlp.digitox.services.vpn.DigitoxVpnService
import android.util.Log
import com.nlp.digitox.utils.AppUtils
import com.nlp.digitox.utils.JsonUtils
import com.nlp.digitox.utils.Utils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.util.Locale

class FgMethodCallHandler(
    private val context: Context,
    private val activity: Activity? = null,
    private val vpnPermLauncher: ActivityResultLauncher<Intent>? = null,
) : MethodCallHandler {

    private val focusServiceConn =
        SafeServiceConnection(
            context = context,
            serviceClass = FocusSessionService::class.java
        )

    private val trackerServiceConn =
        SafeServiceConnection(
            context = context,
            serviceClass = DigitoxTrackerService::class.java
        )

    private val vpnServiceConn =
        SafeServiceConnection(
            context = context,
            serviceClass = DigitoxVpnService::class.java
        )

    private val notificationServiceConn =
        SafeServiceConnection(
            context = context,
            serviceClass = DigitoxNotificationListenerService::class.java
        )


    init {
        // Start all services and bind to them
        ensureAllServicesRunning()
    }


    fun dispose() {
        // Unbind all services
        trackerServiceConn.unBindService()
        vpnServiceConn.unBindService()
        notificationServiceConn.unBindService()
        focusServiceConn.unBindService()
    }

    /**
     * Ensures all background services are running and bound.
     * Called when activity restarts or on service recovery.
     * Also restores all settings to native services to ensure accessibility and
     * other services have the latest configuration after a process restart.
     */
    fun ensureAllServicesRunning() {
        // Start tracker service if not running - it will run as persistent foreground
        if (!Utils.isServiceRunning(context, DigitoxTrackerService::class.java)) {
            trackerServiceConn.startAndBind()
        } else {
            trackerServiceConn.bindService()
        }

        // Start VPN service if not running - foreground persistent
        if (!Utils.isServiceRunning(context, DigitoxVpnService::class.java)) {
            vpnServiceConn.startAndBind()
        } else {
            vpnServiceConn.bindService()
        }

        // Bind to already running services
        notificationServiceConn.bindService()
        focusServiceConn.bindService()

        // Schedule periodic keep-alive alarm to restart services if killed
        KeepAliveHelper.scheduleKeepAlive(context)

        // Restore all settings to native services - this triggers accessibility service
        // to reload shorts/feature blocking configuration from SharedPrefs
        restoreAllSettingsOnReconnect()

        Log.d("Digitox.FgMethodCallHandler", "ensureAllServicesRunning: All services running, settings restored")
    }

    /**
     * Restores all settings to native services. Called on activity restart to
     * ensure accessibility service and other native components have the latest config
     * even if Flutter process was killed and recreated.
     *
     * This triggers SharedPrefs change listeners, so the accessibility service
     * will reload its Wellbeing/shorts blocking configuration automatically.
     */
    fun restoreAllSettingsOnReconnect() {
        // Re-push wellbeing settings - this triggers SharedPrefs listener in DigitoxAccessibilityService
        // which will call refreshServiceConfig() and restore shorts/feature blocking
        SharedPrefsHelper.getSetWellBeingSettings(
            context,
            SharedPrefsHelper.getSetWellBeingSettingsAsJsonString(context)
        )

        // Re-push app restrictions to tracker service
        val appRestrictions = SharedPrefsHelper.getSetAppRestrictions(context, null)
        val restrictionGroups = SharedPrefsHelper.getSetRestrictionGroups(context, null)
        if (appRestrictions.isNotEmpty() || restrictionGroups.isNotEmpty()) {
            updateTrackerServiceRestrictions(appRestrictions, restrictionGroups)
        }

        // Re-push internet blocked apps to VPN service
        val blockedApps = SharedPrefsHelper.getSetInternetBlockedApps(context, null)
        if (blockedApps.isNotEmpty() && vpnServiceConn.isActive) {
            vpnServiceConn.service?.updateBlockedApps(blockedApps)
        }

        Log.d("Digitox.FgMethodCallHandler", "restoreAllSettingsOnReconnect: All settings restored to native services")
    }

    private fun updateLocale(languageCode: String) {
        if (languageCode.isNotEmpty()) {
            val newLocale = Locale(languageCode)
            Locale.setDefault(newLocale)
            val config = Configuration()
            config.setLocale(newLocale)
            context.resources.updateConfiguration(config, context.resources.displayMetrics)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // ==============================================================================================================
            // ====================================== SYSTEM =================================================================
            // ==============================================================================================================

            "updateLocale" -> {
                updateLocale(call.arguments() ?: "en")
                result.success(true)
            }

            "updateExcludedApps" -> {
                SharedPrefsHelper.getSetExcludedApps(context, call.arguments() ?: "")
                result.success(true)
            }

            "getDeviceInfo" -> {
                result.success(AppUtils.getDeviceInfoMap(context))
            }

            "getDeviceAppsInfo" -> {
                getDeviceAppInfos(
                    context = context,
                    onSuccess = { data -> result.success(data) }
                )
            }

            "getAppsUsageForInterval" -> {
                getAppsUsageForInterval(
                    context = context,
                    startMsEpoch = call.argument("startDateTime"),
                    endMsEpoch = call.argument("endDateTime"),
                    onSuccess = { data -> result.success(data) }
                )
            }

            "getAppsLaunchCount" -> {
                result.success(
                    trackerServiceConn.service?.getRestrictionManager?.getAppsLaunchCount
                        ?: mapOf<String, Int>()
                )
            }

            "getShortsScreenTimeMs" -> {
                result.success(SharedPrefsHelper.getSetShortsScreenTimeMs(context, null))
            }

            "getDeviceUnlockCount" -> {
                result.success(SharedPrefsHelper.getSetDeviceUnlockCount(context, null))
            }

            "getNativeCrashLogs" -> {
                result.success(SharedPrefsHelper.getCrashLogsArrayJsonString(context))
            }

            "clearNativeCrashLogs" -> {
                SharedPrefsHelper.clearCrashLogs(context)
                result.success(true)
            }

            // ==============================================================================================================
            // ====================================== SERVICES =================================================================
            // ==============================================================================================================

            "updateAppRestrictions" -> {
                val appRestrictions = SharedPrefsHelper.getSetAppRestrictions(
                    context,
                    call.arguments() ?: ""
                )
                updateTrackerServiceRestrictions(appRestrictions, null)
                result.success(true)
            }

            "updateRestrictionsGroups" -> {
                val restrictionGroups = SharedPrefsHelper.getSetRestrictionGroups(
                    context,
                    call.arguments() ?: ""
                )
                updateTrackerServiceRestrictions(null, restrictionGroups)
                result.success(true)
            }

            "updateInternetBlockedApps" -> {
                val blockedApps = SharedPrefsHelper.getSetInternetBlockedApps(
                    context,
                    call.arguments() ?: ""
                )
                if (vpnServiceConn.isActive) {
                    vpnServiceConn.service?.updateBlockedApps(blockedApps)
                } else if (blockedApps.isNotEmpty() && getAndAskVpnPermission(false)) {
                    vpnServiceConn.setOnConnectedCallback { service ->
                        service.updateBlockedApps(
                            blockedApps
                        )
                    }
                    vpnServiceConn.startAndBind()
                }
                result.success(true)
            }

            "updateWellBeingSettings" -> {
                // NOTE: Only updating shared prefs because accessibility service have onSharedPrefsChange listener registered which will eventually reload needed data
                SharedPrefsHelper.getSetWellBeingSettings(
                    context,
                    call.arguments() ?: ""
                )
                result.success(true)
            }

            "updateBedtimeSchedule" -> {
                val jsonBedtimeSettings = call.arguments() ?: ""
                val bedtimeSettings = BedtimeSchedule.fromJson(jsonBedtimeSettings)
                if (bedtimeSettings.isScheduleOn) {
                    scheduleBedtimeRoutineTasks(context, jsonBedtimeSettings)
                } else {
                    cancelBedtimeRoutineTasks(context)
                    if (bedtimeSettings.shouldStartDnd) {
                        NotificationHelper.toggleDnd(context, DndWakeLock.BEDTIME_MODE, false)
                    }
                }
                result.success(true)
            }

            "activeEmergencyPause" -> {
                if (!Utils.isServiceRunning(context, EmergencyPauseService::class.java)
                    && Utils.isServiceRunning(context, DigitoxTrackerService::class.java)
                ) {
                    context.startService(
                        Intent(context, EmergencyPauseService::class.java).setAction(
                            ServiceBinder.ACTION_START_DIGITOX_SERVICE
                        )
                    )
                    result.success(true)
                } else {
                    result.success(false)
                }
            }

            "updateFocusSession" -> {
                val focusSession = FocusSession.fromJson(call.arguments() ?: "")
                if (focusServiceConn.isActive) {
                    focusServiceConn.service?.updateFocusSession(focusSession)
                } else {
                    focusServiceConn.setOnConnectedCallback { service: FocusSessionService ->
                        service.startFocusSession(
                            focusSession
                        )
                    }
                    focusServiceConn.startAndBind()
                }
                result.success(true)
            }

            "giveUpOrFinishFocusSession" -> {
                if (focusServiceConn.isActive) {
                    focusServiceConn.service?.giveUpOrStopFocusSession(call.arguments() ?: false)
                    focusServiceConn.unBindService()
                }
                result.success(true)
            }

            "updateNotificationSettings" -> {
                val settingsJson = call.arguments() ?: ""
                val settings = NotificationSettings.fromJson(settingsJson)

                /// Update service
                if (notificationServiceConn.isActive) {
                    notificationServiceConn.service?.updateNotificationSettings(settings)
                } else if (settings.batchedApps.isNotEmpty() || settings.storeNonBatchedToo) {
                    notificationServiceConn.setOnConnectedCallback { service: DigitoxNotificationListenerService ->
                        service.updateNotificationSettings(settings)
                    }
                    notificationServiceConn.bindService()
                }

                /// Schedule batches
                if (settings.schedules.isNotEmpty()) {
                    scheduleNotificationBatchTask(context, settingsJson)
                } else {
                    cancelNotificationBatchTask(context)
                }

                result.success(true)
            }

            // ==============================================================================================================
            // ===================================== PERMISSIONS ============================================================
            // ==============================================================================================================

            "getAndAskAccessibilityPermission" -> {
                result.success(
                    PermissionsHelper.getAndAskAccessibilityPermission(
                        context,
                        call.arguments() ?: false
                    )
                )
            }

            "getAndAskAdminPermission" -> {
                result.success(
                    PermissionsHelper.getAndAskAdminPermission(
                        context,
                        call.arguments() ?: false
                    )
                )
            }

            "getAndAskUsageAccessPermission" -> {
                result.success(
                    PermissionsHelper.getAndAskUsageAccessPermission(
                        context,
                        call.arguments() ?: false
                    )
                )
            }

            "getAndAskIgnoreBatteryOptimizationPermission" -> {
                result.success(
                    PermissionsHelper.getAndAskIgnoreBatteryOptimizationPermission(
                        context,
                        call.arguments() ?: false
                    )
                )
            }

            "getAndAskDisplayOverlayPermission" -> {
                result.success(
                    PermissionsHelper.getAndAskDisplayOverlayPermission(
                        context,
                        call.arguments() ?: false
                    )
                )
            }

            "getAndAskExactAlarmPermission" -> {
                result.success(
                    PermissionsHelper.getAndAskExactAlarmPermission(
                        context,
                        call.arguments() ?: false
                    )
                )
            }

            "getAndAskNotificationPermission" -> {
                result.success(
                    activity?.let {
                        return@let PermissionsHelper.getAndAskNotificationPermission(
                            it,
                            call.arguments() ?: false
                        )
                    } ?: false
                )
            }

            "getAndAskDndPermission" -> {
                result.success(
                    PermissionsHelper.getAndAskDndPermission(
                        context,
                        call.arguments() ?: false
                    )
                )
            }

            "getAndAskNotificationAccessPermission" -> {
                result.success(
                    PermissionsHelper.getAndAskNotificationAccessPermission(
                        context,
                        call.arguments() ?: false
                    )
                )
            }

            "getAndAskVpnPermission" -> {
                result.success(getAndAskVpnPermission(call.arguments() ?: false))
            }

            // ==============================================================================================================
            // ============================== ACCESSIBILITY SERVICE STATUS ==================================================
            // ==============================================================================================================

            "isAccessibilityServiceActive" -> {
                result.success(PermissionsHelper.isAccessibilityServiceActive(context))
            }

            "isAccessibilityServicePaused" -> {
                result.success(
                    SharedPrefsHelper.getBoolean(
                        context,
                        KeepAliveHelper.PREF_KEY_ACCESSIBILITY_SERVICE_PAUSED,
                        false
                    )
                )
            }

            "clearAccessibilityServicePausedFlag" -> {
                SharedPrefsHelper.putBoolean(
                    context,
                    KeepAliveHelper.PREF_KEY_ACCESSIBILITY_SERVICE_PAUSED,
                    false
                )
                result.success(true)
            }

            "isDeviceAdminRevoked" -> {
                result.success(
                    SharedPrefsHelper.getBoolean(
                        context,
                        KeepAliveHelper.PREF_KEY_DEVICE_ADMIN_REVOKED,
                        false
                    )
                )
            }

            "clearDeviceAdminRevokedFlag" -> {
                SharedPrefsHelper.putBoolean(
                    context,
                    KeepAliveHelper.PREF_KEY_DEVICE_ADMIN_REVOKED,
                    false
                )
                result.success(true)
            }

            // ==============================================================================================================
            // ====================================== UTILS =================================================================
            // ==============================================================================================================

            "disableDeviceAdmin" -> {
                NewActivitiesLaunchHelper.disableDeviceAdmin(context)
                result.success(true)
            }

            "promptForQuickTile" -> {
                NewActivitiesLaunchHelper.promptForQuickFocusTile(context, result)
            }

            "openAppWithPackage" -> {
                NewActivitiesLaunchHelper.openAppWithPackage(
                    context,
                    call.arguments() ?: ""
                )
                result.success(true)
            }

            "openAppWithNotificationThread" -> {
                val notification = Notification.fromJson(call.arguments() ?: "")
                NewActivitiesLaunchHelper.openAppWithNotificationThread(
                    context = context,
                    notification = notification,
                    pendingIntent = notificationServiceConn.service?.getPendingIntentForKey(
                        notification.key
                    ),
                )
                result.success(true)
            }

            "openAppSettingsForPackage" -> {
                NewActivitiesLaunchHelper.openSettingsForPackage(
                    context,
                    call.arguments() ?: ""
                )
                result.success(true)
            }

            "openDeviceDndSettings" -> {
                NewActivitiesLaunchHelper.openDeviceDndSettings(context)
                result.success(true)
            }

            "openAutoStartSettings" -> {
                result.success(NewActivitiesLaunchHelper.openAutoStartSettings(context))
            }

            "restartApp" -> {
                activity?.let {
                    NewActivitiesLaunchHelper.restartDigitox(it)
                }
                result.success(true)
            }

            "launchUrl" -> {
                NewActivitiesLaunchHelper.launchUrl(context, call.arguments() ?: "")
                result.success(true)
            }

            "parseHostFromUrl" -> {
                result.success(Utils.parseHostNameFromUrl(call.arguments() ?: "") ?: "")
            }

            else -> result.notImplemented()
        }
    }


    /**
     * Updates app and group restrictions in the tracker service.
     * If the service is connected, sends updates directly; otherwise,
     * sets a callback to update once the connection is established and starts the service.
     *
     * @param appRestrictions   a map of app package names to their respective restrictions,
     * or null if only group restrictions are being updated.
     * @param restrictionGroups a map of restriction group IDs to their respective restrictions,
     * or null if only app-specific restrictions are being updated.
     */
    private fun updateTrackerServiceRestrictions(
        appRestrictions: HashMap<String, AppRestriction>?,
        restrictionGroups: HashMap<Int, RestrictionGroup>?,
    ) {
        if (trackerServiceConn.isActive) {
            trackerServiceConn.service?.getRestrictionManager?.updateRestrictions(
                appRestrictions,
                restrictionGroups
            )
        } else if (appRestrictions?.isNotEmpty() == true || restrictionGroups?.isNotEmpty() == true) {
            trackerServiceConn.setOnConnectedCallback { service ->
                service.getRestrictionManager.updateRestrictions(
                    appRestrictions,
                    restrictionGroups
                )
            }
            trackerServiceConn.startAndBind()
        }
    }

    /**
     * Checks if the Create VPN permission is granted and optionally asks for it if not granted.
     *
     * @param askPermissionToo Whether to prompt the user to enable Create VPN permission if not granted.
     * @return True if Create VPN permission is granted, false otherwise.
     */
    private fun getAndAskVpnPermission(askPermissionToo: Boolean): Boolean {
        val intent = VpnService.prepare(context)
        if (askPermissionToo && intent != null) {
            vpnPermLauncher?.launch(intent)
        }
        return intent == null
    }

}
