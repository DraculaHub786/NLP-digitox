// The `completedAt` rule is what stops a member claiming a run before it has
// actually ended. `runStartAt` is a server timestamp and the rule denies any
// `completedAt` that is not the server's own clock *and* at or past
// `runStartAt + countdownSec + durationSec`, so an edited client cannot award
// itself a finished run it never served.
//
// The end instant is derived from `runStartAt`, which only the owner may set —
// and only to `now`. To test both sides of the boundary the seeded room's
// `runStartAt` is written with the rules *bypassed*, so the two cases differ
// only in whether that single stored value is in the past or the future.

const assert = require('node:assert/strict');
const { test } = require('node:test');
const { serverTimestamp } = require('firebase/database');
const {
  GUEST_UID,
  HOST_UID,
  createPayload,
  joinPayload,
  readRaw,
  withEnv,
} = require('./harness');

const SESSION_ID = 'sid_completion_time';
const CODE = 'CMP001';

// Matches the `createPayload` session: countdown 5s + duration 1500s.
const COUNTDOWN_SEC = 5;
const DURATION_SEC = 1500;
const RUN_SPAN_MS = (COUNTDOWN_SEC + DURATION_SEC) * 1000;

/** Creates the room and puts the guest in it, returning the guest handle. */
const seedRoomWithGuest = async (env) => {
  const alice = env.authenticatedContext(HOST_UID).database();
  await alice.ref().update(
    createPayload({
      uid: HOST_UID,
      sessionId: SESSION_ID,
      code: CODE,
      name: 'Completion Time',
    }),
  );

  const bob = env.authenticatedContext(GUEST_UID).database();
  await bob
    .ref()
    .update(joinPayload({ uid: GUEST_UID, sessionId: SESSION_ID, code: CODE }));

  return bob;
};

/** Pins `runStartAt` to an exact instant, bypassing the rules. */
const forceRunStartAt = (env, runStartAtMs) =>
  env.withSecurityRulesDisabled(async (ctx) => {
    await ctx.database().ref(`sessions/${SESSION_ID}/runStartAt`).set(runStartAtMs);
  });

test('a completion before the end time is refused', async () => {
  await withEnv(async (env) => {
    const bob = await seedRoomWithGuest(env);

    // The run has not even started yet, so its end is far in the future: a
    // member claiming completion now is claiming a run they have not served.
    await forceRunStartAt(env, Date.now() + 10 * 60 * 1000);

    await assert.rejects(
      () =>
        bob
          .ref(`sessions/${SESSION_ID}/members/${GUEST_UID}`)
          .update({ completedAt: serverTimestamp() }),
      /permission[_ ]denied/i,
    );

    assert.equal(
      await readRaw(
        env,
        `sessions/${SESSION_ID}/members/${GUEST_UID}/completedAt`,
      ),
      null,
    );
  });
});

test('a completion after the end time is accepted', async () => {
  await withEnv(async (env) => {
    const bob = await seedRoomWithGuest(env);

    // The run started (and ended) a few seconds ago, so the server clock is
    // now past `endAt` and the same write is legitimate.
    await forceRunStartAt(env, Date.now() - RUN_SPAN_MS - 5000);

    await bob
      .ref(`sessions/${SESSION_ID}/members/${GUEST_UID}`)
      .update({ completedAt: serverTimestamp() });

    const stored = await readRaw(
      env,
      `sessions/${SESSION_ID}/members/${GUEST_UID}/completedAt`,
    );
    assert.equal(
      typeof stored,
      'number',
      'completedAt must be stored as a resolved server timestamp',
    );
  });
});
