// Seeds mock users into the live leaderboard collections so the real
// `weekly_leaderboard` / `monthly_leaderboard` / `leaderboard` reads can be
// eyeballed end to end (the board screens query
// `orderBy('points', descending: true)`).
//
// Run with a service-account key beside this file:
//
//   node scripts/seed-mock-leaderboard.js            # write the mock rows
//   node scripts/seed-mock-leaderboard.js --verify   # read them back only
//   node scripts/seed-mock-leaderboard.js --cleanup  # delete them again
//
// Every row it writes has a document id beginning with `mock_lb_`, so the
// cleanup pass can never touch a real user, and it never modifies an existing
// non-mock document. The Admin SDK bypasses firestore.rules, so this proves
// the collections are writable and that the live board query returns the rows —
// it does NOT exercise the client rules path (that is what
// `test/firestore_rules/leaderboard_points.test.js` covers).

const path = require('path');
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

const SERVICE_ACCOUNT = path.join(__dirname, 'service-account.json');
const ID_PREFIX = 'mock_lb_';
const LIFETIME = 'leaderboard';
const WEEKLY = 'weekly_leaderboard';
const MONTHLY = 'monthly_leaderboard';

// A spread of scores so the podium, the mid-table and the tail are all
// populated. `weekly`/`monthly` are the period scores the board reads;
// `lifetime` is only shown on the profile/achievement cards.
const MOCK_USERS = [
  { slug: 'aria',  name: 'Aria',   weekly: 480, monthly: 1320, lifetime: 5410, streak: 21, emoji: '🦉' },
  { slug: 'ben',   name: 'Ben',    weekly: 430, monthly: 1180, lifetime: 4980, streak: 17, emoji: '🐢' },
  { slug: 'chen',  name: 'Chen',   weekly: 375, monthly: 1010, lifetime: 4520, streak: 14, emoji: '🦊' },
  { slug: 'dara',  name: 'Dara',   weekly: 320, monthly:  890, lifetime: 3990, streak: 11, emoji: '🐝' },
  { slug: 'elif',  name: 'Elif',   weekly: 265, monthly:  760, lifetime: 3410, streak:  9, emoji: '🌸' },
  { slug: 'farid', name: 'Farid',  weekly: 210, monthly:  610, lifetime: 2870, streak:  7, emoji: '🛠️' },
  { slug: 'gita',  name: 'Gita',   weekly: 165, monthly:  470, lifetime: 2260, streak:  5, emoji: '📚' },
  { slug: 'hugo',  name: 'Hugo',   weekly: 120, monthly:  330, lifetime: 1580, streak:  4, emoji: '🚴' },
  { slug: 'ines',  name: 'Ines',   weekly:  75, monthly:  210, lifetime:  980, streak:  2, emoji: '🎧' },
  { slug: 'juno',  name: 'Juno',   weekly:  30, monthly:   90, lifetime:  430, streak:  1, emoji: '🌱' },
];

/** Builds the four `pointsBreakdown` buckets a real week would produce. */
function breakdownFor(total) {
  const wellbeing = Math.round(total * 0.4);
  const focus = Math.round(total * 0.3);
  const tasks = Math.round(total * 0.2);
  const streaks = total - wellbeing - focus - tasks;
  return {
    'Wellbeing Activities': wellbeing,
    'Focus Session': focus,
    'Task Completion': tasks,
    'Daily Streaks': streaks,
  };
}

const docIdFor = (slug) => `${ID_PREFIX}${slug}`;
const emailFor = (slug) => `${ID_PREFIX}${slug}@example.invalid`;

function seedPayloads(user, now) {
  const id = docIdFor(user.slug);

  const lifetime = {
    username: user.name,
    avatarEmoji: user.emoji,
    email: emailFor(user.slug),
    points: user.weekly,
    monthlyPoints: user.monthly,
    lifetimePoints: user.lifetime,
    pointsBreakdown: breakdownFor(user.lifetime),
    streak: user.streak,
    lastUpdated: now,
    lastActiveAt: now,
  };

  const period = (points) => ({
    username: user.name,
    avatarEmoji: user.emoji,
    points,
    lastUpdated: now,
    lastActiveAt: now,
  });

  return {
    id,
    lifetime,
    weekly: period(user.weekly),
    monthly: period(user.monthly),
  };
}

async function writeAll(db, now) {
  const batch = db.batch();
  for (const user of MOCK_USERS) {
    const p = seedPayloads(user, now);
    batch.set(db.collection(LIFETIME).doc(p.id), p.lifetime, { merge: true });
    batch.set(db.collection(WEEKLY).doc(p.id), p.weekly, { merge: true });
    batch.set(db.collection(MONTHLY).doc(p.id), p.monthly, { merge: true });
  }
  await batch.commit();
  console.log(`Wrote ${MOCK_USERS.length} mock users to ${LIFETIME}, ${WEEKLY}, ${MONTHLY}`);
}

async function verify(db) {
  for (const [collection, field] of [
    [WEEKLY, 'points'],
    [MONTHLY, 'points'],
    [LIFETIME, 'lifetimePoints'],
  ]) {
    const snap = await db
      .collection(collection)
      .orderBy(field, 'desc')
      .limit(5)
      .get();
    const rows = snap.docs.map((d) => {
      const data = d.data();
      const value = data[field] ?? 0;
      const mock = d.id.startsWith(ID_PREFIX) ? 'mock' : 'real';
      return `  #${d.id} (${mock})  ${field}=${value}  user=${data.username ?? '?'}`;
    });
    console.log(`\n${collection} top 5 by ${field}:`);
    console.log(rows.length ? rows.join('\n') : '  (empty)');
  }
}

async function cleanup(db) {
  const ids = MOCK_USERS.map((u) => docIdFor(u.slug));
  for (const collection of [LIFETIME, WEEKLY, MONTHLY]) {
    const batch = db.batch();
    for (const id of ids) batch.delete(db.collection(collection).doc(id));
    await batch.commit();
    console.log(`Deleted ${ids.length} mock rows from ${collection}`);
  }
}

async function main() {
  const mode = process.argv.includes('--cleanup')
    ? 'cleanup'
    : process.argv.includes('--verify')
      ? 'verify'
      : 'seed';

  initializeApp({ credential: cert(require(SERVICE_ACCOUNT)) });
  const db = getFirestore();

  console.log(`project: ${require(SERVICE_ACCOUNT).project_id}  mode: ${mode}\n`);

  if (mode === 'seed') {
    await writeAll(db, FieldValue.serverTimestamp());
    await verify(db);
  } else if (mode === 'verify') {
    await verify(db);
  } else {
    await cleanup(db);
  }

  console.log('\nDone.');
}

main().catch((err) => {
  console.error('seeder failed:', err);
  process.exit(1);
});
