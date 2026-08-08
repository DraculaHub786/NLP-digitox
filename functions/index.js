/**
 * NLP-Digitox — Leaderboard reset functions
 *
 * Runs server-side via the Firebase Admin SDK, which bypasses firestore.rules
 * entirely — this is required because firestore.rules intentionally blocks
 * client writes to `leaderboard_config` and to other users' `leaderboard/{uid}`
 * docs (see firestore.rules comments: "Only n8n cron / admin writes").
 *
 * Two independent scheduled jobs:
 *   - resetWeeklyLeaderboard  → every Monday 04:00 Asia/Kolkata, zeroes `points`
 *   - resetMonthlyLeaderboard → 1st of month 04:00 Asia/Kolkata, zeroes `monthlyPoints`
 *
 * `streak` and `lifetimePoints` are never touched by either job.
 */

const {onSchedule} = require("firebase-functions/v2/scheduler");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
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
 * Resets one numeric field to 0 across every doc in `leaderboard`, in
 * chunked batches, then records the reset in `leaderboard_config/{configDocId}`.
 *
 * @param {string} field - 'points' (weekly) or 'monthlyPoints' (monthly)
 * @param {string} configDocId - 'weekly_reset' or 'monthly_reset'
 * @param {string} cycleLabel - human-readable label for this cycle
 * @param {Date} nextResetDate - when the *next* reset is expected (for UI display)
 */
async function resetLeaderboardField({field, configDocId, cycleLabel, nextResetDate}) {
  const configRef = db.collection("leaderboard_config").doc(configDocId);
  const configSnap = await configRef.get();
  const previousCycle = configSnap.exists ? (configSnap.data().cycleNumber || 0) : 0;

  const snapshot = await db.collection("leaderboard").get();
  const docs = snapshot.docs;
  logger.info(`[${configDocId}] Resetting '${field}' for ${docs.length} users`);

  for (let i = 0; i < docs.length; i += BATCH_LIMIT) {
    const chunk = docs.slice(i, i + BATCH_LIMIT);
    const batch = db.batch();
    for (const doc of chunk) {
      const update = {
        [field]: 0,
        lastUpdated: FieldValue.serverTimestamp(),
      };
      // Only the weekly job also clears the category breakdown — that
      // breakdown is a weekly-scoped view in the current UI.
      if (field === "points") {
        update.pointsBreakdown = {};
      }
      batch.update(doc.ref, update);
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

      await resetLeaderboardField({
        field: "points",
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

      await resetLeaderboardField({
        field: "monthlyPoints",
        configDocId: "monthly_reset",
        cycleLabel: now.toLocaleString("en-US", {month: "long", year: "numeric"}),
        nextResetDate: nextMonth,
      });
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
        await resetLeaderboardField({
          field: "monthlyPoints",
          configDocId: "monthly_reset",
          cycleLabel: `${now.toLocaleString("en-US", {month: "long", year: "numeric"})} (forced)`,
          nextResetDate: nextMonth,
        });
      } else {
        const nextMonday = new Date(now);
        nextMonday.setDate(now.getDate() + 7);
        await resetLeaderboardField({
          field: "points",
          configDocId: "weekly_reset",
          cycleLabel: `Week of ${now.toISOString().slice(0, 10)} (forced)`,
          nextResetDate: nextMonday,
        });
      }

      return {success: true, period};
    },
);
