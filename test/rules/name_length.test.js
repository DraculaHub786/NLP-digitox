// The `name` rule is the boundary between "the room is created" and "the user
// sees a bare permission-denied". `SessionLimits.maxNameLength` is the same
// number on the Dart side; `database.rules.json` repeats the literal because a
// rules file cannot import Dart, so this is the test that keeps the two honest.

const assert = require('node:assert/strict');
const { test } = require('node:test');
const { HOST_UID, createPayload, readRaw, withEnv } = require('./harness');

const SESSION_ID = 'sid_name_length';
const CODE = 'NAME01';

// Mirrors `SessionLimits.maxNameLength`.
const MAX_NAME_LENGTH = 80;

test(`a ${MAX_NAME_LENGTH}-character session name is accepted`, async () => {
  await withEnv(async (env) => {
    const alice = env.authenticatedContext(HOST_UID).database();
    const name = 'n'.repeat(MAX_NAME_LENGTH);

    await alice.ref().update(
      createPayload({ uid: HOST_UID, sessionId: SESSION_ID, code: CODE, name }),
    );

    const stored = await readRaw(env, `sessions/${SESSION_ID}/name`);
    assert.equal(stored, name);
  });
});

test(`a ${MAX_NAME_LENGTH + 1}-character session name is rejected`, async () => {
  await withEnv(async (env) => {
    const alice = env.authenticatedContext(HOST_UID).database();

    await assert.rejects(
      () =>
        alice.ref().update(
          createPayload({
            uid: HOST_UID,
            sessionId: SESSION_ID,
            code: CODE,
            name: 'n'.repeat(MAX_NAME_LENGTH + 1),
          }),
        ),
      /permission[_ ]denied/i,
    );

    // The refusal has to take the *whole* atomic write with it: a half-applied
    // create would leave a session whose owner link or invite never landed.
    assert.equal(await readRaw(env, `sessions/${SESSION_ID}`), null);
    assert.equal(await readRaw(env, `invites/${CODE}`), null);
    assert.equal(await readRaw(env, `users/${HOST_UID}/sessions/${SESSION_ID}`), null);
  });
});

test('an empty session name is rejected', async () => {
  await withEnv(async (env) => {
    const alice = env.authenticatedContext(HOST_UID).database();
    const payload = createPayload({
      uid: HOST_UID,
      sessionId: SESSION_ID,
      code: CODE,
      name: 'placeholder',
    });
    payload[`sessions/${SESSION_ID}`].name = '';

    await assert.rejects(() => alice.ref().update(payload), /permission[_ ]denied/i);
  });
});
