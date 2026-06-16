
package com.nlp.digitox.generics

import android.app.Service
import android.os.Binder

/**
 * ServiceBinder is a generic binder class used to provide a reference to a service.
 * It allows the client to retrieve the service instance that is bound to it.
 *
 * @param <T> The type of the service being bound.
</T> */
class ServiceBinder<T : Service?>(val service: T) : Binder() {
    companion object {
        const val ACTION_START_MINDFUL_SERVICE: String =
            "com.mindful.android.action.startMindfulService"

        const val ACTION_BIND_TO_MINDFUL: String =
            "com.mindful.android.action.bindToMindful"
    }
}
