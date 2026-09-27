/**
 * NLP-Digitox — Leaderboard reset functions
 *
 * Runs server-side via the Firebase Admin SDK, which bypasses firestore.rules
 * entirely — this is required because firestore.rules intentionally blocks
 * client writes to `leaderboard_config` and to other users' leaderboard docs
 * (see firestore.rules comments: "Only n8n cron / admin writes").
 *
 * Two independent scheduled jobs:
 *   - resetWeeklyLeaderboard  → every Monday 04:00 Asia/Kolkata, zeroes `points` in `weekly_leaderboard`
 *   - resetMonthlyLeaderboard → 1st of month 04:00 Asia/Kolkata, zeroes `points` in `monthly_leaderboard`
 *
 * The `leaderboard` collection (lifetime) is never reset by these jobs.
 * `streak` and `lifetimePoints` in the `leaderboard` collection are never touched.
 */

const {onSchedule} = require("firebase-functions/v2/scheduler");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {onDocumentWritten} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue, Timestamp} = require("firebase-admin/firestore");
const logger = require("firebase-functions/logger");

initializeApp();
const db = getFirestore();

const TIMEZONE = "Asia/Kolkata";
const REGION = "asia-south1"; // matches firestore location in firebase.json
// Firestore batch writes cap at 500 — stay comfortably under that.
const BATCH_LIMIT = 450;

/**
 * Resets the `points` field to 0 across every doc in the given period collection
 * (`weekly_leaderboard` or `monthly_leaderboard`), in chunked batches, then
 * records the reset in `leaderboard_config/{configDocId}`.
 *
 * @param {string} collectionName - 'weekly_leaderboard' or 'monthly_leaderboard'
 * @param {string} configDocId - 'weekly_reset' or 'monthly_reset'
 * @param {string} cycleLabel - human-readable label for this cycle
 * @param {Date} nextResetDate - when the *next* reset is expected (for UI display)
 */
async function resetLeaderboardCollection({collectionName, configDocId, cycleLabel, nextResetDate}) {
  const configRef = db.collection("leaderboard_config").doc(configDocId);
  const configSnap = await configRef.get();
  const previousCycle = configSnap.exists ? (configSnap.data().cycleNumber || 0) : 0;

  const snapshot = await db.collection(collectionName).get();
  const docs = snapshot.docs;
  logger.info(`[${configDocId}] Resetting 'points' for ${docs.length} users in ${collectionName}`);

  for (let i = 0; i < docs.length; i += BATCH_LIMIT) {
    const chunk = docs.slice(i, i + BATCH_LIMIT);
    const batch = db.batch();
    for (const doc of chunk) {
      batch.update(doc.ref, {
        points: 0,
        lastUpdated: FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    logger.info(
        `[${configDocId}] Committed ${Math.min(i + BATCH_LIMIT, docs.length)}/${docs.length}`,
    );
  }

  await configRef.set({
    lastResetDate: FieldValue.serverTimestamp(),
    nextResetDate: Timestamp.fromDate(nextResetDate),
    cycleNumber: previousCycle + 1,
    cycleLabel,
    usersReset: docs.length,
  });

  logger.info(
      `[${configDocId}] Done — cycle ${previousCycle + 1}, ${docs.length} users reset`,
  );
}

exports.resetWeeklyLeaderboard = onSchedule(
    {schedule: "0 4 * * 1", timeZone: TIMEZONE, region: REGION},
    async () => {
      const now = new Date();
      const nextMonday = new Date(now);
      nextMonday.setDate(now.getDate() + 7);

      await resetLeaderboardCollection({
        collectionName: "weekly_leaderboard",
        configDocId: "weekly_reset",
        cycleLabel: `Week of ${now.toISOString().slice(0, 10)}`,
        nextResetDate: nextMonday,
      });
    },
);

exports.resetMonthlyLeaderboard = onSchedule(
    {schedule: "0 4 1 * *", timeZone: TIMEZONE, region: REGION},
    async () => {
      const now = new Date();
      const nextMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1, 4, 0, 0);

      await resetLeaderboardCollection({
        collectionName: "monthly_leaderboard",
        configDocId: "monthly_reset",
        cycleLabel: now.toLocaleString("en-US", {month: "long", year: "numeric"}),
        nextResetDate: nextMonth,
      });
    },
);

/**
 * Syncs profileImageUrl from users/{uid} to all leaderboard collections.
 * This ensures avatars are always in sync regardless of client state
 * (app killed, offline, etc.). Triggered on any write to users/{uid}.
 */
exports.syncProfileImageToLeaderboards = onDocumentWritten(
    {document: "users/{uid}", region: REGION},
    async (event) => {
      const before = event.data.before.exists ? event.data.before.data().profileImageUrl : undefined;
      const after = event.data.after.exists ? event.data.after.data().profileImageUrl : undefined;
      if (before === after) return; // no picture change, nothing to do

      const uid = event.params.uid;
      const boards = ["leaderboard", "weekly_leaderboard", "monthly_leaderboard"];
      const batch = db.batch();
      for (const col of boards) {
        const ref = db.collection(col).doc(uid);
        batch.set(ref, {
          profileImageUrl: after ?? FieldValue.delete(),
        }, {merge: true});
      }
      await batch.commit();
      logger.info(`Synced profileImageUrl for ${uid} to leaderboard boards`);
    },
);

/**
 * Manual/admin trigger for testing — NOT wired into the app UI.
 * Callable only by UIDs listed in the `LEADERBOARD_ADMIN_UIDS` env var
 * (comma-separated). Configure with:
 *   firebase functions:secrets:set LEADERBOARD_ADMIN_UIDS
 * Invoke from the Firebase console "Test function" tab, or via the
 * `firebase functions:shell`, while developing/QAing the reset — do not
 * expose a button for this in the shipped app.
 */
exports.debugForceLeaderboardReset = onCall(
    {region: REGION},
    async (request) => {
      const adminUids = (process.env.LEADERBOARD_ADMIN_UIDS || "")
          .split(",")
          .map((s) => s.trim())
          .filter(Boolean);

      if (!request.auth || !adminUids.includes(request.auth.uid)) {
        throw new HttpsError("permission-denied", "Not authorized to force a leaderboard reset.");
      }

      const period = request.data && request.data.period === "monthly" ? "monthly" : "weekly";
      const now = new Date();

      if (period === "monthly") {
        const nextMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1, 4, 0, 0);
        await resetLeaderboardCollection({
          collectionName: "monthly_leaderboard",
          configDocId: "monthly_reset",
          cycleLabel: `${now.toLocaleString("en-US", {month: "long", year: "numeric"})} (forced)`,
          nextResetDate: nextMonth,
        });
      } else {
        const nextMonday = new Date(now);
        nextMonday.setDate(now.getDate() + 7);
        await resetLeaderboardCollection({
          collectionName: "weekly_leaderboard",
          configDocId: "weekly_reset",
          cycleLabel: `Week of ${now.toISOString().slice(0, 10)} (forced)`,
          nextResetDate: nextMonday,
        });
      }

      return {success: true, period};
    },
);
/**
 * Monthly AI wellbeing report trigger.
 *
 * Runs at 00:05 on the 1st of every month (Asia/Kolkata). It deliberately does
 * NOT generate the report: the report is built from 30-day sentiment scores
 * (Firestore, readable here) PLUS the chat transcripts (SharedPreferences) and
 * the per-app usage rows (Drift) — the last two live only on the user's device
 * and are unreachable from a server. So this function only drops a request
 * marker; the client polls it on launch/resume and runs the generation locally
 * with the real Firebase uid.
 *
 * The marker is written to `public/monthly_wellbeing_report_request` because
 * `public/{document=**}` is the one collection firestore.rules grants
 * authenticated clients read access to, while the Admin SDK used here bypasses
 * rules entirely on the write side.
 *
 * The client ignores a marker whose `month` does not match its own
 * `yyyy-MM`, so a stale marker left over from a previous cycle can never
 * trigger a spurious regeneration.
 */
const KOLKATA_UTC_OFFSET_MINUTES = 330; // IST = UTC+5:30, no DST

/**
 * Formats [date] as the `yyyy-MM` key for the Asia/Kolkata calendar month.
 *
 * The scheduler's `timeZone` option only decides WHEN the function fires; the
 * Node runtime clock stays UTC, so the month has to be derived by shifting the
 * instant into IST explicitly rather than reading the local getters.
 *
 * @param {Date} date
 * @return {string} e.g. "2026-09"
 */
function kolkataMonthKey(date) {
  const shifted = new Date(date.getTime() + KOLKATA_UTC_OFFSET_MINUTES * 60 * 1000);
  const year = shifted.getUTCFullYear();
  const month = String(shifted.getUTCMonth() + 1).padStart(2, "0");
  return `${year}-${month}`;
}

exports.requestMonthlyWellbeingReport = onSchedule(
    {schedule: "5 0 1 * *", timeZone: TIMEZONE, region: REGION},
    async () => {
      const month = kolkataMonthKey(new Date());
      await db.collection("public").doc("monthly_wellbeing_report_request").set({
        month,
        requestedAt: FieldValue.serverTimestamp(),
      });
      logger.info(`[monthly_wellbeing_report_request] Requested report for ${month}`);
    },
);
