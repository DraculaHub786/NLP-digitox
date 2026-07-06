
package com.nlp.digitox.services.vpn

import android.content.Intent
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.IBinder
import android.os.ParcelFileDescriptor
import android.util.Log
import com.nlp.digitox.AppConstants
import com.nlp.digitox.R
import com.nlp.digitox.generics.ServiceBinder
import com.nlp.digitox.helpers.device.NotificationHelper
import com.nlp.digitox.helpers.storage.SharedPrefsHelper
import java.io.IOException
import java.net.InetSocketAddress
import java.net.SocketAddress
import java.net.SocketException
import java.nio.channels.DatagramChannel
import java.util.concurrent.atomic.AtomicReference


/**
 * A VPN service that manages internet access by blocking specified apps.
 */
class MindfulVpnService : VpnService() {
    companion object {
        private const val TAG = "Mindful.VpnService"
    }

    private val mBinder = ServiceBinder(this@MindfulVpnService)
    private val mAtomicVpnThread = AtomicReference<Thread?>(null)
    private var mBlockedApps: Set<String> = HashSet(0)
    private var mVpnInterface: ParcelFileDescriptor? = null
    private var mIsFgRunning = false

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (!mIsFgRunning) {
            startFgService()
        }
        restoreBlockedAppsFromPrefs()
        if (mBlockedApps.isNotEmpty()) {
            connectVpn()
        }
        Log.d(TAG, "onStartCommand: VPN service command received, staying alive (startId=$startId)")
        return START_STICKY
    }


    private fun startFgService() {
        if (mIsFgRunning) return
        try {
            startForeground(
                AppConstants.VPN_SERVICE_NOTIFICATION_ID,
                NotificationHelper.buildFgServiceNotification(
                    this,
                    getString(R.string.internet_blocker_running_notification_info)
                )
            )
            mIsFgRunning = true
            Log.d(TAG, "startFgService: VPN service started successfully as persistent foreground service")
        } catch (e: Exception) {
            Log.e(TAG, "startFgService: Failed to start VPN service", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this, e)
        }
    }

    /**
     * Restarts the VPN connection by disconnecting and then reconnecting the VPN.
     */
    private fun reconnectVpn() {
        disconnectVpn()
        connectVpn()
        Log.d(TAG, "reconnectVpn: VPN reconnected successfully")
    }

    /**
     * Establishes a VPN connection based on blocked apps.
     * The service stays alive even without blocked apps to maintain VPN presence.
     */
    private fun connectVpn() {
        if (mBlockedApps.isEmpty()) {
            Log.d(TAG, "connectVpn: No blocked apps - establishing passthrough VPN to maintain service")
            // Establish a passthrough VPN that blocks nothing, keeping service alive
        }

        val newThread = Thread(vpnThread, TAG)
        setVpnThread(newThread)
        newThread.start()
    }

    /**
     * Disconnects the VPN connection if established.
     */
    private fun disconnectVpn() {
        try {
            if (mVpnInterface != null) {
                mVpnInterface!!.close()
                setVpnThread(null)
                Log.d(TAG, "disconnectVpn: VPN disconnected successfully")
            }
        } catch (e: IOException) {
            Log.e(TAG, "disconnectVpn: Failed to disconnect VPN", e)
        }
    }

    /**
     * Returns a Runnable that configures and establishes the VPN connection.
     *
     * @return A Runnable that sets up the VPN connection.
     */
    private val vpnThread: Runnable
        get() = Runnable {
            try {
                DatagramChannel.open().use { tunnel ->
                    check(this@MindfulVpnService.protect(tunnel.socket())) { "Cannot protect the vpn socket tunnel" }
                    val serverAddress: SocketAddress = InetSocketAddress("localhost", 0)
                    tunnel.connect(serverAddress)
                    tunnel.configureBlocking(false)

                    val builder = this@MindfulVpnService.Builder()
                    builder.addAddress("192.168.0.0", 24)
                    builder.addRoute("0.0.0.0", 0)

                    if (mBlockedApps.isEmpty()) {
                        // Passthrough mode: no apps are blocked, just maintain the VPN
                        Log.d(TAG, "vpnThread: Establishing passthrough VPN (no blocked apps)")
                    } else {
                        // Add blocked app's packages
                        for (packageName in mBlockedApps) {
                            try {
                                builder.addAllowedApplication(packageName)
                            } catch (e: PackageManager.NameNotFoundException) {
                                Log.w(TAG, "getVpnThread: Cannot find app with package $packageName")
                            }
                        }
                    }
                    synchronized(this@MindfulVpnService) {
                        mVpnInterface = builder.establish()
                        Log.d(TAG, "getVpnThread: VPN connected successfully")
                    }
                }
            } catch (e: SocketException) {
                Log.e(TAG, "getVpnThread: Cannot use socket for VPN", e)
                SharedPrefsHelper.insertCrashLogToPrefs(this@MindfulVpnService, e)
            } catch (e: IOException) {
                Log.e(TAG, "getVpnThread: VPN connection failed, reconnecting in 5s", e)
                SharedPrefsHelper.insertCrashLogToPrefs(this@MindfulVpnService, e)
                // Wait and retry
                Thread.sleep(5000)
                connectVpn()
            } catch (e: IllegalArgumentException) {
                Log.e(TAG, "getVpnThread: VPN connection failed", e)
                SharedPrefsHelper.insertCrashLogToPrefs(this@MindfulVpnService, e)
            } catch (e: Exception) {
                Log.e(TAG, "getVpnThread: Something went wrong", e)
                SharedPrefsHelper.insertCrashLogToPrefs(this@MindfulVpnService, e)
            }
        }

    /**
     * Sets the current VPN thread, interrupting the previous thread if necessary.
     *
     * @param thread The new thread to be set.
     */
    private fun setVpnThread(thread: Thread?) {
        val oldThread = mAtomicVpnThread.getAndSet(thread)
        oldThread?.interrupt()
    }

    /**
     * Updates the list of blocked apps and restarts the VPN service if needed.
     */
    fun updateBlockedApps(blockedApps: Set<String>) {
        mBlockedApps = blockedApps
        Log.d(TAG, "updateBlockedApps: Internet blocked apps updated successfully")
        reconnectVpn()
    }

    private fun restoreBlockedAppsFromPrefs() {
        mBlockedApps = SharedPrefsHelper.getSetInternetBlockedApps(this, null)
    }

    override fun onDestroy() {
        disconnectVpn()
        Log.d(TAG, "onDestroy: VPN service destroyed - re-launching immediately")
        try {
            val restartIntent = Intent(this, MindfulVpnService::class.java)
                .setAction(ServiceBinder.ACTION_START_MINDFUL_SERVICE)
                .putExtra("isRestart", true)
            startForegroundService(restartIntent)
        } catch (e: Exception) {
            Log.w(TAG, "onDestroy: startForegroundService failed, fallback to startService", e)
            try {
                val restartIntent = Intent(this, MindfulVpnService::class.java)
                    .setAction(ServiceBinder.ACTION_START_MINDFUL_SERVICE)
                startService(restartIntent)
            } catch (e2: Exception) {
                SharedPrefsHelper.insertCrashLogToPrefs(this, e2)
            }
        }
        super.onDestroy()
    }

    override fun onBind(intent: Intent): IBinder? {
        return if (intent.action == ServiceBinder.ACTION_BIND_TO_MINDFUL) mBinder else null
    }
}
