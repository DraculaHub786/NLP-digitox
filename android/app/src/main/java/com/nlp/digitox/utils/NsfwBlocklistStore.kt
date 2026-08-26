package com.nlp.digitox.utils

import android.content.Context
import android.util.Log
import java.io.BufferedInputStream
import java.util.zip.GZIPInputStream

/**
 * Compact runtime store for the generated NSFW domain blocklist.
 *
 * Format (produced by tools/update_nsfw_blocklist.py):
 *   - gzip-compressed payload
 *   - payload = sorted 64-bit FNV-1a hashes of every normalized domain,
 *     delta-encoded as unsigned LEB128 varints
 *
 * Lookup: hash(host) -> binary search over LongArray. O(log n), no false
 * negatives; false-positive probability ~ n/2^64 (negligible).
 *
 * Memory: ~8 bytes per domain (~7.3 MB for 950k domains) vs >100 MB for a
 * HashMap<String, Boolean>.
 */
object NsfwBlocklistStore {
    private const val ASSET_PATH = "nsfw/nsfw_hashes.bin"

    private var sortedHashes: LongArray = LongArray(0)

    val isLoaded: Boolean get() = sortedHashes.isNotEmpty()
    val size: Int get() = sortedHashes.size

    /**
     * Loads and decodes the asset on a background thread.
     * Safe to call multiple times; subsequent calls are no-ops once loaded.
     */
    @Synchronized
    fun loadAsync(context: Context) {
        if (isLoaded) return
        val appContext = context.applicationContext
        val runnable = Runnable {
            runCatching { loadBlocking(appContext) }
                .onFailure { t -> Log.e(TAG, "loadAsync: failed to load NSFW blocklist", t) }
        }
        Thread(runnable, "NsfwBlocklistLoad").start()
    }

    /** Blocking variant; prefer [loadAsync] from UI threads. */
    @Synchronized
    fun loadBlocking(context: Context) {
        if (isLoaded) return

        context.assets.open(ASSET_PATH).use { raw ->
            GZIPInputStream(BufferedInputStream(raw, 64 * 1024)).use { gz ->
                // Decompress fully; varint stream is read sequentially.
                val bytes = gz.readBytes()

                var count = 0
                // First pass: count deltas to pre-size array.
                run {
                    var i = 0
                    while (i < bytes.size) {
                        if ((bytes[i].toInt() and 0x80) == 0) count++
                        i++
                    }
                }

                val out = LongArray(count)
                var idx = 0
                var prev = 0L
                var i = 0
                while (i < bytes.size && idx < count) {
                    var shift = 0
                    var value = 0L
                    while (true) {
                        val b = bytes[i++].toInt() and 0xFF
                        value = value or ((b and 0x7F).toLong() shl shift)
                        if ((b and 0x80) == 0) break
                        shift += 7
                        require(shift <= 63) { "Malformed varint in $ASSET_PATH" }
                    }
                    prev += value
                    out[idx++] = prev
                }

                sortedHashes = out
                Log.d(TAG, "loadBlocking: loaded $count NSFW domain hashes")
            }
        }
    }

    fun clear() {
        synchronized(this) { sortedHashes = LongArray(0) }
    }

    /**
     * Returns true if [host] is present in the generated blocklist.
     *
     * The host is lowercased so lookups match the normalized form used by
     * the generator. On a miss, leftmost labels are progressively stripped
     * (e.g. "de.pornhub.com" -> "pornhub.com"), so any subdomain of a
     * listed domain is also blocked. Stripping stops at two labels so a
     * bare TLD ("uk", "com") is never matched.
     */
    fun contains(host: String): Boolean {
        if (!isLoaded || host.isEmpty()) return false

        val h = host.lowercase()
        if (binarySearch(fnv1a64(h)) >= 0) return true

        // Subdomain fallback: try parent labels while >= 2 labels remain.
        var dot = h.indexOf('.')
        while (dot != -1 && h.indexOf('.', dot + 1) != -1) {
            val candidate = h.substring(dot + 1)
            if (binarySearch(fnv1a64(candidate)) >= 0) return true
            dot = h.indexOf('.', dot + 1)
        }
        return false
    }

    private fun binarySearch(key: Long): Int {
        var lo = 0
        var hi = sortedHashes.size - 1
        while (lo <= hi) {
            val mid = (lo + hi).ushr(1)
            val midVal = sortedHashes[mid]
            // 64-bit FNV-1a hashes are treated as unsigned; the array is stored
            // in unsigned ascending order, so signed comparison breaks for
            // hashes >= 2^63. Use unsigned comparison.
            val cmp = java.lang.Long.compareUnsigned(midVal, key)
            when {
                cmp < 0 -> lo = mid + 1
                cmp > 0 -> hi = mid - 1
                else -> return mid
            }
        }
        return -(lo + 1)
    }

    private fun fnv1a64(value: String): Long {
        var h = -0x340d631b7bdddcdbL // 0xCBF29CE484222325 as signed Long
        for (ch in value) {
            h = h xor ch.code.toLong()
            h *= 0x100000001B3L // FNV-1a 64-bit prime (positive)
        }
        return h
    }

    private const val TAG = "Digitox.NsfwBlocklist"
}
