
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
        const val ACTION_START_DIGITOX_SERVICE: String =
            "com.nlp.digitox.action.startDigitoxService"

        const val ACTION_BIND_TO_DIGITOX: String =
            "com.nlp.digitox.action.bindToDigitox"
    }
}
