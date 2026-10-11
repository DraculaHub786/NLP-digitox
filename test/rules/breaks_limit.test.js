// The `breaks` rule is what makes "over the cap" survive the server clamp. The
// client writes `min(count + 1, cap + 1)`, and the rule allows exactly `cap + 1`
// (three, for a cap of two). Anything the rule *refused* above the cap used to
// let a member who broke focus repeatedly be stored at the cap — which the
// completion webhook then credits — so the extra step is load-bearing, not
// cosmetic. These tests pin the boundary on the server.

const assert = require('node:assert/strict');
const { test } = require('node:test');
const {
  GUEST_UID,
  HOST_UID,
  createPayload,
  joinPayload,
  readRaw,
  withEnv,
} = require('./harness');

const SESSION_ID = 'sid_breaks_limit';
const CODE = 'BRK001';

// Mirrors `SessionLimits.maxBreaksPerRun` (2) plus the one-step cushion the
// store keeps for "over the cap".
const MAX_BREAKS_PER_RUN = 2;
const MAX_STORED_BREAKS = MAX_BREAKS_PER_RUN + 1;

/** Creates the room and puts the guest in it. */
const seedRoomWithGuest = async (env) => {
  const alice = env.authenticatedContext(HOST_UID).database();
  await alice.ref().update(
    createPayload({
      uid: HOST_UID,
      sessionId: SESSION_ID,
      code: CODE,
      name: 'Break Limit',
    }),
  );

  const bob = env.authenticatedContext(GUEST_UID).database();
  await bob
    .ref()
    .update(joinPayload({ uid: GUEST_UID, sessionId: SESSION_ID, code: CODE }));

  return bob;
};

test(`${MAX_STORED_BREAKS} breaks is accepted (the stored cap)`, async () => {
  await withEnv(async (env) => {
    const bob = await seedRoomWithGuest(env);

    await bob
      .ref(`sessions/${SESSION_ID}/members/${GUEST_UID}/breaks`)
      .set(MAX_STORED_BREAKS);

    assert.equal(
      await readRaw(env, `sessions/${SESSION_ID}/members/${GUEST_UID}/breaks`),
      MAX_STORED_BREAKS,
    );
  });
});

test(`a ${MAX_STORED_BREAKS + 1}th break is refused`, async () => {
  await withEnv(async (env) => {
    const bob = await seedRoomWithGuest(env);

    // Land on the cap first: the rule also refuses a *decrease*, so going
    // straight to a refused value from zero would prove the wrong clause.
    await bob
      .ref(`sessions/${SESSION_ID}/members/${GUEST_UID}/breaks`)
      .set(MAX_STORED_BREAKS);

    await assert.rejects(
      () =>
        bob
          .ref(`sessions/${SESSION_ID}/members/${GUEST_UID}/breaks`)
          .set(MAX_STORED_BREAKS + 1),
      /permission[_ ]denied/i,
    );

    // The write must not have landed.
    assert.equal(
      await readRaw(env, `sessions/${SESSION_ID}/members/${GUEST_UID}/breaks`),
      MAX_STORED_BREAKS,
    );
  });
});
