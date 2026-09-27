package com.nlp.digitox.utils

import android.content.Context
import com.nlp.digitox.helpers.storage.SharedPrefsHelper

/**
 * Website domains that get blocked automatically the moment a user hits an
 * app's usage limit (launch count / timer / active period - individually or
 * via a [com.nlp.digitox.models.RestrictionGroup]), and cleared again on the
 * next midnight reset when that app's restrictions reset.
 *
 * Domains are never hardcoded anywhere in this class or its caller
 * ([com.nlp.digitox.services.tracking.RestrictionManager]) - they come
 * entirely from each app's own
 * [com.nlp.digitox.models.AppRestriction.associatedDomains], synced down
 * from the Flutter/Drift config the same way every other restriction
 * setting is.
 *
 * The set is persisted in the *listenable* prefs box, so
 * [com.nlp.digitox.services.accessibility.DigitoxAccessibilityService] - which
 * is already registered as a listener on that box - is notified reactively
 * when it changes, with no extra broadcast/binder plumbing.
 */
object DynamicWebsiteBlocklist {

    /**
     * Adds [domains] to the currently blocked set. A no-op when [domains] is
     * empty or already fully contained in the current set.
     *
     * @param context The application context.
     * @param domains The domains to add.
     */
    fun addDomains(context: Context, domains: Set<String>) {
        if (domains.isEmpty()) return

        val current = SharedPrefsHelper.getSetDynamicallyBlockedWebsites(context, null)
        val updated = current + domains

        if (updated != current) {
            SharedPrefsHelper.getSetDynamicallyBlockedWebsites(context, updated)
        }
    }

    /**
     * Clears every dynamically blocked domain (called on the midnight reset,
     * at the same moment the underlying app restrictions reset).
     *
     * @param context The application context.
     */
    fun clearAll(context: Context) {
        SharedPrefsHelper.getSetDynamicallyBlockedWebsites(context, emptySet())
    }
}
