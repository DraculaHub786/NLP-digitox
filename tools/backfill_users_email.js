/**
 * BACKFILL SCRIPT — one-time migration
 *
 * Adds the `email` field to any existing `users/{uid}` and `leaderboard/{uid}` doc
 * that is missing it, pulling it from the Firebase Auth user record.
 *
 * Usage:
 *   1. Download service account key from Firebase Console → Project Settings
 *      → Service accounts → "Generate new private key"
 *   2. Save as service-account.json in this directory
 *   3. npm install firebase-admin
 *   4. node tools/backfill_users_email.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('./service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const auth = admin.auth();
const firestore = admin.firestore();

async function backfillEmail() {
  console.log('Starting email backfill...\n');

  // Get all Auth users (paginated, max 1000 per call)
  let allUsers = [];
  let nextPageToken;

  do {
    const listUsersResult = await auth.listUsers(1000, nextPageToken);
    allUsers = allUsers.concat(listUsersResult.users);
    nextPageToken = listUsersResult.pageToken;
    console.log(`  Fetched ${listUsersResult.users.length} Auth users (total: ${allUsers.length})`);
  } while (nextPageToken);

  console.log(`\nTotal Auth users: ${allUsers.length}\n`);

  const emailMap = new Map();
  for (const user of allUsers) {
    if (user.email) {
      emailMap.set(user.uid, user.email);
    }
  }

  console.log(`Users with email in Auth: ${emailMap.size}\n`);

  // Build writes: one per user doc + one per leaderboard doc
  const writes = [];
  for (const [uid, email] of emailMap) {
    const userRef = firestore.collection('users').doc(uid);
    const leaderboardRef = firestore.collection('leaderboard').doc(uid);

    writes.push(
      userRef.set(
        { email, lastUpdated: admin.firestore.FieldValue.serverTimestamp() },
        { merge: true }
      )
    );
    writes.push(
      leaderboardRef.set(
        { email, lastUpdated: admin.firestore.FieldValue.serverTimestamp() },
        { merge: true }
      )
    );
  }

  console.log(`Total writes needed: ${writes.length} (${emailMap.size} users × 2 docs)\n`);

  // Firestore has no bulk write limit enforcement here, but we batch in groups of 500
  const BATCH_LIMIT = 500;
  let committed = 0;

  while (committed < writes.length) {
    const batch = firestore.batch();
    const end = Math.min(committed + BATCH_LIMIT, writes.length);

    // We can't use the writes array directly with batch since each write targets a different ref.
    // Instead, iterate through the remaining writes and add them to the batch.
    // But batch.set() returns void — we need to rebuild the operations.
    // Simpler approach: just execute writes in parallel with limits.
    const chunk = writes.slice(committed, end);
    await Promise.all(chunk);
    committed = end;
    console.log(`  Completed ${committed} / ${writes.length} writes`);
  }

  console.log(`\n✅ Backfill complete: ${emailMap.size} users updated (users + leaderboard docs)`);
}

backfillEmail().catch(console.error);
