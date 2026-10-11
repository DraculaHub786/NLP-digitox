// Shared helpers for the Firestore rules tests.
//
// The payload builders below reproduce — field for field — what the app writes
// to the three leaderboard collections, taken from `LeaderboardService`
// (`addPoints`, `updateUserData`, `markActive`, `evaluateAndUpdateStreak`),
// `ProfileService._mirrorProfileImageUrl` and
// `NotificationSchedulerService._markScheduleCompleted`. That is the point of
// these tests: a payload that had drifted from the client would prove something
// about some other write, not about the app's.
//
// `firestore.rules` is loaded from the repository root and handed to the
// emulator by `initializeTestEnvironment`, so the copy Firebase would deploy is
// the copy under test. The Firestore emulator must already be running;
// `npm test` in this directory starts it via `firebase emulators:exec`
// (see package.json).

const fs = require('node:fs');
const path = require('node:path');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');

// `ctx.firestore()` hands back a *compat* Firestore instance, so the sentinel
// values the client writes — `FieldValue.serverTimestamp()` and
// `FieldValue.delete()` — have to come from the compat namespace. The
// rules-unit-testing package does not re-export them.
const firebase = require('firebase/compat/app');
require('firebase/compat/firestore');

const { FieldValue } = firebase.firestore;

const RULES_PATH = path.resolve(__dirname, '..', '..', 'firestore.rules');

const PROJECT_ID = 'demo-nlp-firestore';
const FIRESTORE_PORT = 8080;

const ALICE = 'alice';
const BOB = 'bob';

const LIFETIME = 'leaderboard';
const WEEKLY = 'weekly_leaderboard';
const MONTHLY = 'monthly_leaderboard';

/** The two avatar hosts `validAvatar()` accepts. */
const CLOUDINARY_AVATAR =
  'https://res.cloudinary.com/ucarrdxh/image/upload/v1/profile_pics/alice_1.jpg';
const GOOGLE_AVATAR =
  'https://lh3.googleusercontent.com/a/ACg8ocKsomething=s96-c';

/**
 * Runs [body] against a freshly-emptied Firestore under the real rules.
 *
 * The emulator is a long-lived process, so anything a previous run left behind
 * would let these tests pass for the wrong reason. Everything is cleared
 * through a rules-disabled context first.
 */
async function withEnv(body) {
  const env = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: fs.readFileSync(RULES_PATH, 'utf8'),
      host: '127.0.0.1',
      port: FIRESTORE_PORT,
    },
  });

  await env.clearFirestore();

  try {
    await body(env);
  } finally {
    await env.cleanup();
  }
}

/** Seeds a document with the rules bypassed, so a test can start mid-life. */
async function seedDoc(env, collection, docId, data) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await ctx.firestore().collection(collection).doc(docId).set(data);
  });
}

/** Reads a document with the rules bypassed, to assert what actually landed. */
async function readDoc(env, collection, docId) {
  let data = null;
  await env.withSecurityRulesDisabled(async (ctx) => {
    const snap = await ctx.firestore().collection(collection).doc(docId).get();
    data = snap.exists ? snap.data() : null;
  });
  return data;
}

// ---------------------------------------------------------------------------
// Payloads, mirroring the client
// ---------------------------------------------------------------------------

/**
 * The `leaderboard/{uid}` merge payload written by `LeaderboardService.addPoints`
 * when the lifetime doc already exists (so the seed-only `username` /
 * `avatarEmoji` / `email` keys are absent).
 */
const lifetimePointsUpdate = ({
  fromPoints,
  award,
  category = 'Wellbeing Activities',
  breakdown = {},
  avatarUrl = CLOUDINARY_AVATAR,
}) => ({
  ...(avatarUrl ? { profileImageUrl: avatarUrl } : {}),
  lifetimePoints: fromPoints + award,
  pointsBreakdown: {
    ...breakdown,
    [category]: (breakdown[category] ?? 0) + award,
  },
  lastUpdated: FieldValue.serverTimestamp(),
  lastActiveAt: FieldValue.serverTimestamp(),
});

/**
 * The `weekly_leaderboard/{uid}` (or monthly) merge payload written by
 * `LeaderboardService.addPoints` on an existing period doc.
 */
const periodPointsUpdate = ({
  fromPoints,
  award,
  avatarUrl = CLOUDINARY_AVATAR,
}) => ({
  ...(avatarUrl ? { profileImageUrl: avatarUrl } : {}),
  points: fromPoints + award,
  lastUpdated: FieldValue.serverTimestamp(),
  lastActiveAt: FieldValue.serverTimestamp(),
});

/**
 * The first-ever write of a board doc, as `addPoints` performs it: a `set` with
 * merge onto a document that does not exist yet, which the rules see as a
 * create, carrying the identity fields plus the score.
 */
const periodDocSeed = ({
  username = 'Alice',
  avatarEmoji = '👤',
  points = 0,
  avatarUrl = CLOUDINARY_AVATAR,
}) => ({
  username,
  avatarEmoji,
  ...(avatarUrl ? { profileImageUrl: avatarUrl } : {}),
  points,
  lastUpdated: FieldValue.serverTimestamp(),
  lastActiveAt: FieldValue.serverTimestamp(),
});

/** The first-ever write of the lifetime doc, as `addPoints` performs it. */
const lifetimeDocSeed = ({
  username = 'Alice',
  avatarEmoji = '👤',
  email = 'alice@example.com',
  lifetimePoints = 0,
  category = 'Wellbeing Activities',
  avatarUrl = CLOUDINARY_AVATAR,
}) => ({
  username,
  avatarEmoji,
  email,
  ...(avatarUrl ? { profileImageUrl: avatarUrl } : {}),
  lifetimePoints,
  pointsBreakdown: { [category]: lifetimePoints },
  lastUpdated: FieldValue.serverTimestamp(),
  lastActiveAt: FieldValue.serverTimestamp(),
});

/**
 * The full merge payload `LeaderboardService.updateUserData` writes through
 * `LeaderboardUser.toMap()`. Called at sign-up and at login for accounts that
 * have no board doc yet.
 */
const updateUserDataPayload = ({
  username = 'Alice',
  points = 0,
  monthlyPoints = 0,
  lifetimePoints = 0,
  streak = 0,
  breakdown = {},
  email = 'alice@example.com',
  avatarUrl = CLOUDINARY_AVATAR,
}) => ({
  username,
  points,
  streak,
  avatarEmoji: '👤',
  pointsBreakdown: breakdown,
  lifetimePoints,
  monthlyPoints,
  email,
  ...(avatarUrl ? { profileImageUrl: avatarUrl } : {}),
  lastUpdated: FieldValue.serverTimestamp(),
  lastActiveAt: FieldValue.serverTimestamp(),
});

/** `LeaderboardService.markActive` — one field, the heartbeat. */
const markActivePayload = () => ({
  lastActiveAt: FieldValue.serverTimestamp(),
});

/** `LeaderboardService.updateStreak`. */
const updateStreakPayload = (streak) => ({
  streak,
  lastUpdated: FieldValue.serverTimestamp(),
});

/** `LeaderboardService.evaluateAndUpdateStreak`. */
const evaluateStreakPayload = (streak) => ({
  streak,
  lastStreakEvalDate: FieldValue.serverTimestamp(),
  lastUpdated: FieldValue.serverTimestamp(),
});

/** `ProfileService._mirrorProfileImageUrl(url)` — mirror a new picture. */
const mirrorAvatarPayload = (url) => ({ profileImageUrl: url });

/** `ProfileService._mirrorProfileImageUrl(null)` — clear the picture. */
const clearAvatarPayload = () => ({ profileImageUrl: FieldValue.delete() });

/** The mirror write `LeaderboardService._backfillMissingAvatars` performs. */
const backfillAvatarPayload = (url) => ({ profileImageUrl: url });

module.exports = {
  ALICE,
  BOB,
  CLOUDINARY_AVATAR,
  FIRESTORE_PORT,
  GOOGLE_AVATAR,
  LIFETIME,
  MONTHLY,
  PROJECT_ID,
  RULES_PATH,
  WEEKLY,
  assertFails,
  assertSucceeds,
  backfillAvatarPayload,
  clearAvatarPayload,
  evaluateStreakPayload,
  lifetimeDocSeed,
  lifetimePointsUpdate,
  markActivePayload,
  mirrorAvatarPayload,
  periodDocSeed,
  periodPointsUpdate,
  readDoc,
  seedDoc,
  updateStreakPayload,
  updateUserDataPayload,
  withEnv,
};
