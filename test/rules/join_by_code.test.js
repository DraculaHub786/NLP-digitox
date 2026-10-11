// A code-join has to succeed on the *server*, not just in the client. The join
// write is the one the app makes most often and the one whose rejection is most
// confusing — it arrives as a bare `permission-denied` and the user is told to
// ask for a fresh code. These tests pin down which writes are actually allowed.

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

const SESSION_ID = 'sid_invite_join';
const CODE = 'AB3K7Q';

/** Creates the invite-only room the guest is about to join. */
const seedRoom = (alice) =>
  alice.ref().update(
    createPayload({
      uid: HOST_UID,
      sessionId: SESSION_ID,
      code: CODE,
      name: 'Morning Study Group',
    }),
  );

test('joining an invite room with its code succeeds', async () => {
  await withEnv(async (env) => {
    const alice = env.authenticatedContext(HOST_UID).database();
    await seedRoom(alice);

    const bob = env.authenticatedContext(GUEST_UID).database();
    await bob
      .ref()
      .update(joinPayload({ uid: GUEST_UID, sessionId: SESSION_ID, code: CODE }));

    const joined = await readRaw(
      env,
      `sessions/${SESSION_ID}/members/${GUEST_UID}`,
    );
    assert.ok(joined, 'the guest member node must exist');
    assert.equal(joined.displayName, 'Friend');
    assert.equal(joined.role, 'member');
    // The code is stamped on the node because that is what the rules read to
    // authorise the join — losing it would make a later re-join fail.
    assert.equal(joined.code, CODE);

    assert.equal(
      await readRaw(env, `users/${GUEST_UID}/sessions/${SESSION_ID}`),
      true,
    );
  });
});

test('joining an invite room without the code is rejected', async () => {
  await withEnv(async (env) => {
    const alice = env.authenticatedContext(HOST_UID).database();
    await seedRoom(alice);

    const bob = env.authenticatedContext(GUEST_UID).database();
    await assert.rejects(
      () =>
        bob
          .ref()
          .update(joinPayload({ uid: GUEST_UID, sessionId: SESSION_ID })),
      /permission[_ ]denied/i,
    );

    assert.equal(
      await readRaw(env, `sessions/${SESSION_ID}/members/${GUEST_UID}`),
      null,
    );
  });
});

test('a code that names a different room does not open this one', async () => {
  await withEnv(async (env) => {
    const alice = env.authenticatedContext(HOST_UID).database();
    await seedRoom(alice);

    // Another live invite, pointing somewhere else entirely. A forwarded code
    // must not work as a skeleton key for every room.
    await alice.ref('invites/ZZZZZZ').set({
      sid: 'some-other-session',
      hostUid: HOST_UID,
    });

    const bob = env.authenticatedContext(GUEST_UID).database();
    await assert.rejects(
      () =>
        bob.ref().update(
          joinPayload({
            uid: GUEST_UID,
            sessionId: SESSION_ID,
            code: 'ZZZZZZ',
          }),
        ),
      /permission[_ ]denied/i,
    );
  });
});

test('a stranger cannot join a running room', async () => {
  await withEnv(async (env) => {
    const alice = env.authenticatedContext(HOST_UID).database();
    await seedRoom(alice);
    // The host's own start write is allowed; the point here is the *guest*.
    await alice.ref(`sessions/${SESSION_ID}/state`).set('running');

    const bob = env.authenticatedContext(GUEST_UID).database();
    await assert.rejects(
      () =>
        bob.ref().update(
          joinPayload({ uid: GUEST_UID, sessionId: SESSION_ID, code: CODE }),
        ),
      /permission[_ ]denied/i,
    );
  });
});
