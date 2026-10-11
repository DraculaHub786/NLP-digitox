// Who may start the run, and what a start must look like.
//
// `SessionService.startSession` writes exactly two fields — `state: 'running'`
// and `runStartAt: ServerValue.timestamp` — and that single write is what every
// device derives its countdown from. If anyone but the owner could make it, a
// member could move the clock under the whole room; if `runStartAt` could be
// anything but the server's own time, two phones would finish minutes apart.

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

const SESSION_ID = 'sid_owner_start';
const CODE = 'START1';

/** Creates the room both principals are about to write into. */
const seedRoom = (alice) =>
  alice.ref().update(
    createPayload({
      uid: HOST_UID,
      sessionId: SESSION_ID,
      code: CODE,
      name: 'Evening Focus',
    }),
  );

test('the owner can start the run', async () => {
  await withEnv(async (env) => {
    const alice = env.authenticatedContext(HOST_UID).database();
    await seedRoom(alice);

    await alice.ref(`sessions/${SESSION_ID}`).update({
      state: 'running',
      // Resolved by the server, never by this device's clock — which is exactly
      // what `runStartAt`'s rule insists on (`newData.val() === now`).
      runStartAt: serverTimestamp(),
    });

    const started = await readRaw(env, `sessions/${SESSION_ID}`);
    assert.equal(started.state, 'running');
    assert.equal(
      typeof started.runStartAt,
      'number',
      'runStartAt must have been resolved to a server timestamp',
    );
  });
});

test('a non-owner cannot start the run', async () => {
  await withEnv(async (env) => {
    const alice = env.authenticatedContext(HOST_UID).database();
    await seedRoom(alice);

    const bob = env.authenticatedContext(GUEST_UID).database();
    // The guest has to be *in* the room for the start attempt to be a start
    // attempt rather than a stranger's write being refused for being a
    // stranger's write.
    await bob
      .ref()
      .update(
        joinPayload({ uid: GUEST_UID, sessionId: SESSION_ID, code: CODE }),
      );

    await assert.rejects(
      () => bob.ref(`sessions/${SESSION_ID}/state`).set('running'),
      /permission[_ ]denied/i,
    );

    // The room must still be joinable after the attempt: a start that half
    // landed would strand everyone with a moving clock.
    assert.equal(await readRaw(env, `sessions/${SESSION_ID}/state`), 'lobby');
  });
});

test('the host cannot backdate the run to a client clock', async () => {
  await withEnv(async (env) => {
    const alice = env.authenticatedContext(HOST_UID).database();
    await seedRoom(alice);

    // A hand-rolled timestamp is not `now`, so the rule refuses it. That is
    // what stops an edited client from giving itself a head start.
    await assert.rejects(
      () =>
        alice.ref(`sessions/${SESSION_ID}`).update({
          state: 'running',
          runStartAt: Date.now() - 60 * 60 * 1000,
        }),
      /permission[_ ]denied/i,
    );
  });
});
