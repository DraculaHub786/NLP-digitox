package com.nlp.digitox.services.quickTiles

import android.annotation.SuppressLint
import android.content.ComponentName
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.util.Log
import com.nlp.digitox.R
import com.nlp.digitox.helpers.storage.SharedPrefsHelper
import com.nlp.digitox.services.timer.FocusSessionService
import com.nlp.digitox.utils.AppUtils
import com.nlp.digitox.utils.Utils


class FocusQuickTileService : TileService() {
    private val TAG = "Digitox.FocusQuickTileService"


    override fun onTileAdded() {
        super.onTileAdded()

        // Request listening to setup initial state
        requestListeningState(
            this,
            ComponentName(this, FocusQuickTileService::class.java)
        )
    }

    override fun onStartListening() {
        try {
            // Check focus session status
            val isFocusActive = Utils.isServiceRunning(this, FocusSessionService::class.java)
            val tile: Tile? = qsTile

            // Set state
            tile?.state = if (isFocusActive) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE

            // Set on click on android 14 and above
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                val uriString = if (isFocusActive) "com.mindful.android://open/activeSession"
                else "com.mindful.android://open/focus"
                tile?.activityLaunchForClick = AppUtils.getPendingIntentForDigitoxUri(this, uriString)
            }

            // Set subtitle on android 10 and above
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                tile?.subtitle =
                    getString(
                        if (isFocusActive) R.string.focus_quick_tile_status_active
                        else R.string.app_name
                    )
            }

            // Update tile
            tile?.updateTile()
        } catch (e: Exception) {
            Log.e(TAG, "onStartListening: Failed to update focus quick tile", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this, e)
        }
        super.onStartListening()
    }


    @SuppressLint("StartActivityAndCollapseDeprecated")
    override fun onClick() {
        super.onClick()

        try {
            // Check focus session status
            val isFocusActive = Utils.isServiceRunning(this, FocusSessionService::class.java)
            val uriString = if (isFocusActive) "com.mindful.android://open/activeSession"
            else "com.mindful.android://open/focus"
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                startActivityAndCollapse(
                    AppUtils.getPendingIntentForDigitoxUri(this, uriString)
                )
            } else {
                startActivityAndCollapse(
                    AppUtils.getIntentForDigitoxUri(this, uriString)
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "onClick: Failed to launch activity", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this, e)
        }
    }
}