// Two boundaries around the member node: who owns the room, and what a member
// may change about themselves.
//
// `ownerId` is written once, at creation, and is what authorises every
// owner-only action (start, cancel, kick). If another member could rewrite it,
// they would inherit all of those. A member's own presence, by contrast, is
// theirs to update — the ready toggle and the presence heartbeat both write it,
// and a room where members could not publish their own readiness would never
// start.

const assert = require('node:assert/strict');
const { test } = require('node:test');
const {
  CREATED_AT,
  GUEST_UID,
  HOST_UID,
  createPayload,
  joinPayload,
  readRaw,
  withEnv,
} = require('./harness');

const SESSION_ID = 'sid_member_write';
const CODE = 'MEM001';

/** Creates the room and puts the guest in it, returning the guest handle. */
const seedRoomWithGuest = async (env) => {
  const alice = env.authenticatedContext(HOST_UID).database();
  await alice.ref().update(
    createPayload({
      uid: HOST_UID,
      sessionId: SESSION_ID,
      code: CODE,
      name: 'Member Write',
    }),
  );

  const bob = env.authenticatedContext(GUEST_UID).database();
  await bob
    .ref()
    .update(joinPayload({ uid: GUEST_UID, sessionId: SESSION_ID, code: CODE }));

  return bob;
};

test('a non-owner cannot change ownerId', async () => {
  await withEnv(async (env) => {
    const bob = await seedRoomWithGuest(env);

    await assert.rejects(
      () =>
        bob
          .ref(`sessions/${SESSION_ID}/ownerId`)
          .set(GUEST_UID),
      /permission[_ ]denied/i,
    );

    // The room still belongs to its real owner.
    assert.equal(
      await readRaw(env, `sessions/${SESSION_ID}/ownerId`),
      HOST_UID,
    );
  });
});

test('a member updating their own presence is accepted', async () => {
  await withEnv(async (env) => {
    const bob = await seedRoomWithGuest(env);

    // Exactly what the ready toggle / presence heartbeat publish for the
    // signed-in member on their own node.
    await bob.ref(`sessions/${SESSION_ID}/members/${GUEST_UID}`).update({
      status: 'ready',
      isActive: true,
      lastActive: CREATED_AT,
    });

    const stored = await readRaw(
      env,
      `sessions/${SESSION_ID}/members/${GUEST_UID}`,
    );
    assert.equal(stored.status, 'ready');
    assert.equal(stored.isActive, true);
    // The join identity is untouched — presence updates never rewrite it.
    assert.equal(stored.displayName, 'Friend');
    assert.equal(stored.joinedAt, CREATED_AT);
  });
});
