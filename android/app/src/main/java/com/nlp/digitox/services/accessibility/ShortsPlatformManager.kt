package com.nlp.digitox.services.accessibility

import android.content.Context
import android.util.Log
import android.view.accessibility.AccessibilityNodeInfo
import com.nlp.digitox.AppConstants.FACEBOOK_PACKAGE
import com.nlp.digitox.AppConstants.INSTAGRAM_PACKAGE
import com.nlp.digitox.AppConstants.REDDIT_PACKAGE
import com.nlp.digitox.AppConstants.SNAPCHAT_PACKAGE
import com.nlp.digitox.AppConstants.THREADS_PACKAGE
import com.nlp.digitox.AppConstants.X_PACKAGE
import com.nlp.digitox.AppConstants.YOUTUBE_CLIENT_PACKAGE_SUFFIX
import com.nlp.digitox.AppConstants.YOUTUBE_PACKAGE
import com.nlp.digitox.enums.PlatformFeatures
import com.nlp.digitox.helpers.storage.SharedPrefsHelper
import com.nlp.digitox.models.Wellbeing
import org.jetbrains.annotations.Contract


class ShortsPlatformManager(
    private val context: Context,
    private val blockedContentGoBack: () -> Unit,
) {

    private var lastTimeShortsEvent = 0L
    private var lastTimeSaved = 0L
    private var shortContentScreenTime = SharedPrefsHelper.getSetShortsScreenTimeMs(context, null)

    fun resetShortsScreenTime() {
        shortContentScreenTime = 0L
        SharedPrefsHelper.getSetShortsScreenTimeMs(context, 0L)
    }

    /**
     * Checks if a blocked short-form content feature is open and applies restrictions.
     *
     * @param packageName The package name of the current app in focus.
     * @param node The root `AccessibilityNodeInfo` of the current screen.
     * @param wellbeing The user's `WellBeingSettings`, including blocked features and time limits.
     */
    fun blockDistraction(
        packageName: String,
        node: AccessibilityNodeInfo,
        wellbeing: Wellbeing,
    ) {
        // Use default youtube package for unofficial clients too
        val resolvedPackage =
            if (packageName.contains(YOUTUBE_CLIENT_PACKAGE_SUFFIX)) YOUTUBE_PACKAGE
            else packageName

        val blockedFeatures = wellbeing.blockedFeatures

        /// Check if blocking is enabled for platforms
        val isFeatureOpen = when (resolvedPackage) {
            INSTAGRAM_PACKAGE -> isInstagramFeatureOpen(node, blockedFeatures)
            SNAPCHAT_PACKAGE -> isSnapchatFeatureOpen(node, blockedFeatures)
            FACEBOOK_PACKAGE -> isFacebookFeatureOpen(node, blockedFeatures)
            REDDIT_PACKAGE -> isRedditFeatureOpen(node, blockedFeatures)
            YOUTUBE_PACKAGE -> isYoutubeFeatureOpen(node, blockedFeatures)
            X_PACKAGE -> isXFeatureOpen(node, blockedFeatures)
            THREADS_PACKAGE -> isThreadsFeatureOpen(node, blockedFeatures)
            else -> false
        }

        if (isFeatureOpen) {
            maxAllowedDuration[resolvedPackage]?.let {
                updateShortsScreenTime(wellbeing.allowedShortsTimeMs, it)
            }
        }
    }

    /**
     * Checks if a short-form content website is open in the browser based on WellBeingSettings.
     *
     * @param wellbeing The WellBeingSettings model indicating which platforms are blocked.
     * @param url      The URL text from the browser.
     * @return True if a blocked short-form content website is open, false otherwise.
     */
    fun checkAndBlockShortsOnBrowser(wellbeing: Wellbeing, url: String): Boolean {
        when {
            PlatformFeatures.INSTAGRAM_REELS in wellbeing.blockedFeatures
                    && doesUrlContainsAnyElement(mInstaReelUrls, url) -> true

            PlatformFeatures.INSTAGRAM_EXPLORE in wellbeing.blockedFeatures
                    && doesUrlContainsAnyElement(mInstaExploreUrls, url) -> true

            PlatformFeatures.YOUTUBE_SHORTS in wellbeing.blockedFeatures
                    && doesUrlContainsAnyElement(mYtShortUrls, url) -> true

            PlatformFeatures.FACEBOOK_REELS in wellbeing.blockedFeatures
                    && doesUrlContainsAnyElement(mFbReelUrls, url) -> true

            PlatformFeatures.SNAPCHAT_SPOTLIGHT in wellbeing.blockedFeatures
                    && doesUrlContainsAnyElement(mSnapSpotlightUrls, url) -> true

            PlatformFeatures.SNAPCHAT_DISCOVER in wellbeing.blockedFeatures
                    && doesUrlContainsAnyElement(mSnapDiscoverUrls, url) -> true

            else -> false
        }.let {
            if (it) {
                updateShortsScreenTime(wellbeing.allowedShortsTimeMs)
                return true
            }
        }

        return false
    }

    /**
     * Updates the total screen time spent on short-form content and blocks access if the allowed time is exceeded.
     *
     * @param allowedShortContentTimeMs The maximum time allowed for short-form content.
     * @param maxAllowedDuration The maximum duration considered for a single short-form content session.
     */
    private fun updateShortsScreenTime(
        allowedShortContentTimeMs: Long,
        maxAllowedDuration: Long = 30 * 1000L,
    ) {
        // Check if limit is exhausted
        if (allowedShortContentTimeMs < 0 || shortContentScreenTime > (allowedShortContentTimeMs + SAVING_INTERVAL_MS)) {
            blockedContentGoBack.invoke()
            return
        }

        // Calculate screen time since last check
        val currentTime = System.currentTimeMillis()
        val elapsedTime = if (lastTimeShortsEvent != 0L) currentTime - lastTimeShortsEvent else 0

        // Update only if elapsedTime is less than MAX_ALLOWED_DURATION otherwise user may have closed short content,
        shortContentScreenTime += (if (elapsedTime <= maxAllowedDuration) elapsedTime else 0)
        lastTimeShortsEvent = currentTime

        // Check if the minimum interval has passed before calling shared preferences
        if ((currentTime - lastTimeSaved) > SAVING_INTERVAL_MS) {
            SharedPrefsHelper.getSetShortsScreenTimeMs(context, shortContentScreenTime)
            lastTimeSaved = currentTime
            Log.d(
                TAG,
                "checkTimerAndBlockShortContent: shorts time saved: " + (shortContentScreenTime / 1000L) + " seconds"
            )
        }
    }


    companion object {
        private const val TAG = "Mindful.ShortsPlatformManager"

        // The minimum interval between saving short content's screen time in shared preferences
        private const val SAVING_INTERVAL_MS = (30 * 1000L)

        // How often the debug view-ID capture walker may run (see
        // logCandidateVideoViewIds) — keeps Logcat readable while the
        // X/Threads video surface is open with the toggle enabled.
        private const val VIEW_ID_DUMP_INTERVAL_MS = (5 * 1000L)

        // Last time the candidate view-ID walker ran, for throttling.
        private var lastViewIdDumpTime = 0L

        // View-ID substrings that suggest a video-player container. The
        // real X/Threads surface ID is one of these — see
        // logCandidateVideoViewIds.
        private val VIDEO_KEYWORDS = listOf("video", "player", "reel", "clip", "media", "immersive")

        /**
         * Max allowed duration for each short content platform (based on the highest short length or duration)
         * If the interval between two short content block event is <= DURATION then it is considered that user is watching short content
         **/
        private val maxAllowedDuration = mapOf(
            INSTAGRAM_PACKAGE to (90 * 1000L),
            SNAPCHAT_PACKAGE to (60 * 1000L),
            FACEBOOK_PACKAGE to (90 * 1000L),
            REDDIT_PACKAGE to (60 * 1000L),
            YOUTUBE_PACKAGE to (3 * 60 * 1000L),
            X_PACKAGE to (90 * 1000L),
            THREADS_PACKAGE to (60 * 1000L),
        )

        // Possible URLs of different short-form content platforms
        private val mInstaReelUrls = listOf("instagram.com/reels/", "m.instagram.com/reels/")
        private val mInstaExploreUrls = listOf("instagram.com/explore/", "m.instagram.com/explore/")

        private val mYtShortUrls = listOf("youtube.com/shorts/", "m.youtube.com/shorts/")
        private val mFbReelUrls = listOf("facebook.com/reel/", "m.facebook.com/reel/")
        private val mSnapSpotlightUrls = listOf(
            "snapchat.com/spotlight/",
            "m.snapchat.com/spotlight/",
            "web.snapchat.com/spotlight/"
        )
        private val mSnapDiscoverUrls = listOf(
            "snapchat.com/discover/",
            "m.snapchat.com/discover/",
            "web.snapchat.com/discover/"
        )

        private val mFbNodeTexts = listOf("Add a comment", "कमेंट जोड़ें…")


        /**
         * Checks if Instagram features (Reels or Search Feed) are open.
         */
        private fun isInstagramFeatureOpen(
            node: AccessibilityNodeInfo,
            blockedFeatures: Set<PlatformFeatures>,
        ): Boolean {
            return when {
                PlatformFeatures.INSTAGRAM_REELS in blockedFeatures &&
                        doesNodeByIdExists(node, "com.instagram.android:id/clips_video_container")
                -> true

                PlatformFeatures.INSTAGRAM_EXPLORE in blockedFeatures &&
                        doesNodeByIdExists(node, "com.instagram.android:id/action_bar_search_edit_text")
                -> true

                else -> false
            }
        }

        /**
         * Checks if YouTube Shorts is currently open.
         */
        private fun isYoutubeFeatureOpen(
            node: AccessibilityNodeInfo,
            blockedFeatures: Set<PlatformFeatures>,
        ): Boolean {
            return PlatformFeatures.YOUTUBE_SHORTS in blockedFeatures &&
                    doesNodeByIdExists(node, "${node.packageName}:id/reel_player_underlay")
        }

        /**
         * Checks if Snapchat Spotlight or Discover is open.
         */
        private fun isSnapchatFeatureOpen(
            node: AccessibilityNodeInfo,
            blockedFeatures: Set<PlatformFeatures>,
        ): Boolean {

            return when {
                PlatformFeatures.SNAPCHAT_SPOTLIGHT in blockedFeatures &&
                        doesNodeByIdExists(
                            node,
                            "com.snapchat.android:id/spotlight_card_static_thumbnail"
                        )
                -> true

                PlatformFeatures.SNAPCHAT_DISCOVER in blockedFeatures &&
                        doesNodeByIdExists(node, "com.snapchat.android:id/df_large_story")
                -> true

                else -> false
            }
        }

        /**
         * Checks if Facebook Reels is currently open.
         */
        private fun isFacebookFeatureOpen(
            node: AccessibilityNodeInfo,
            blockedFeatures: Set<PlatformFeatures>,
        ): Boolean {
            // TODO: Add more string translated from different languages for the node text
            //  as user may have set different language for facebook app

            if (PlatformFeatures.FACEBOOK_REELS in blockedFeatures) {
                for (text in mFbNodeTexts) {
                    if (node.findAccessibilityNodeInfosByText(text).isNotEmpty()) {
                        return true
                    }
                }
            }

            return false
        }

        /**
         * Checks if Reddit Shorts is open.
         */
        private fun isRedditFeatureOpen(
            node: AccessibilityNodeInfo,
            blockedFeatures: Set<PlatformFeatures>,
        ): Boolean {
            return PlatformFeatures.REDDIT_SHORTS in blockedFeatures && node.viewIdResourceName == "feed_vertical_pager"
        }

        /**
         * Checks if X's video/"For you" video surface is open.
         *
         * The candidate ID was NOT confirmed against a live device — X
         * shipped a full app rewrite (new Kotlin/Compose codebase) in July
         * 2026, and its short-video surface is the full-screen vertical
         * player. While detection returns false, this method logs any
         * video-looking view IDs it finds (throttled) so the real ID can be
         * pasted in below without needing uiautomator. Capture procedure:
         *
         *   1. Enable the X toggle in Shorts Blocking.
         *   2. Open a video in X.
         *   3. `adb logcat -s Mindful.ShortsPlatformManager` and look for
         *      "X video view candidates".
         *   4. Replace the placeholder below with the reported ID.
         */
        private fun isXFeatureOpen(
            node: AccessibilityNodeInfo,
            blockedFeatures: Set<PlatformFeatures>,
        ): Boolean {
            if (PlatformFeatures.X_VIDEOS !in blockedFeatures) return false

            val confirmedMatch = doesNodeByIdExists(node, "com.twitter.android:id/immersive_video_player")
            if (confirmedMatch) return true

            logCandidateVideoViewIds(node, "X")
            return false
        }

        /**
         * Checks if Threads' video/Reels-like surface is open.
         *
         * NOTE: Threads is built on Instagram's codebase, so it may reuse
         * Instagram's `clips_video_container` — or not. As with X, while
         * detection returns false the candidate-walker logs video-looking
         * view IDs (tag `Mindful.ShortsPlatformManager`, "Threads video
         * view candidates") that can be pasted in below after a quick
         * on-device check.
         */
        private fun isThreadsFeatureOpen(
            node: AccessibilityNodeInfo,
            blockedFeatures: Set<PlatformFeatures>,
        ): Boolean {
            if (PlatformFeatures.THREADS_REELS !in blockedFeatures) return false

            val confirmedMatch = doesNodeByIdExists(node, "com.instagram.barcelona:id/clips_video_container")
            if (confirmedMatch) return true

            logCandidateVideoViewIds(node, "Threads")
            return false
        }

        /**
         * Throttled debug helper: walks the current accessibility tree and
         * logs the resource IDs of views whose IDs look like a video
         * container. Intended to be removed once the real X/Threads IDs are
         * confirmed and hard-coded above.
         *
         * @param node The root AccessibilityNodeInfo of the current screen.
         * @param platformName "X" or "Threads" — used in the log tag line.
         */
        private fun logCandidateVideoViewIds(
            node: AccessibilityNodeInfo,
            platformName: String,
        ) {
            val now = System.currentTimeMillis()
            if (now - lastViewIdDumpTime < VIEW_ID_DUMP_INTERVAL_MS) return
            lastViewIdDumpTime = now

            val matched = ArrayList<String>()
            collectVideoViewIds(node, matched)
            if (matched.isNotEmpty()) {
                Log.d(
                    TAG,
                    "$platformName video view candidates: $matched — paste the matching ID into " +
                            "is${platformName}FeatureOpen to enable blocking."
                )
            }
        }

        /**
         * Depth-first traversal collecting resource IDs that contain a
         * video-related keyword. Recursion is bounded by the accessibility
         * tree depth, which Android caps (~thousands of nodes max).
         */
        private fun collectVideoViewIds(
            node: AccessibilityNodeInfo,
            output: MutableList<String>,
        ) {
            val viewId = node.viewIdResourceName ?: ""
            for (keyword in VIDEO_KEYWORDS) {
                if (viewId.contains(keyword, ignoreCase = true)) {
                    output.add(viewId)
                    break
                }
            }

            for (i in 0 until node.childCount) {
                val child = node.getChild(i) ?: continue
                collectVideoViewIds(child, output)
                child.recycle()
            }
        }

        /**
         * Checks if the URL contains any of the elements from the provided list of URLs.
         *
         * @param urlList The list of URL substrings to check against.
         * @param url     The URL to check.
         * @return True if the URL contains any element from the list, false otherwise.
         */
        @Contract(pure = true)
        private fun doesUrlContainsAnyElement(urlList: List<String>, url: String): Boolean {
            for (element in urlList) {
                if (url.contains(element)) return true
            }
            return false
        }

        /**
         * Checks whether an AccessibilityNodeInfo with the specified view ID exists as a descendant
         * of the given node.
         *
         * @param node   The parent AccessibilityNodeInfo to search within. This parameter must not be null.
         * @param viewId The ID of the view to look for.
         * @return `true` if a node with the specified view ID exists, `false` otherwise.
         */
        private fun doesNodeByIdExists(node: AccessibilityNodeInfo, viewId: String): Boolean {
            return node.findAccessibilityNodeInfosByViewId(viewId).isNotEmpty()
        }
    }
}
