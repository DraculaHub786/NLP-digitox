// Shared helpers for the Realtime Database rules tests.
//
// The payload builders below reproduce — field for field — what
// `SessionService.createSession`, `SessionService._joinAsMember` and
// `SessionService.startSession` actually write. That is the whole point of
// these tests: a payload that had drifted from the client would prove that some
// other write is allowed, not that the app's is.
//
// The Realtime Database emulator must already be running; `npm test` in this
// directory starts it via `firebase emulators:exec` (see package.json).

const fs = require('node:fs');
const path = require('node:path');
const { initializeTestEnvironment } = require('@firebase/rules-unit-testing');

const RULES_PATH = path.resolve(__dirname, '..', '..', 'database.rules.json');

const PROJECT_ID = 'demo-nlp';
const DATABASE_PORT = 9000;

const HOST_UID = 'alice';
const GUEST_UID = 'bob';

// Fixed timestamps for the payloads. The rules compare nothing here against
// `now` except `runStartAt`, which is sent as `serverTimestamp()` by the one
// test that writes it (the Dart client's `ServerValue.timestamp` is the same
// sentinel; the JS SDK only exports the `serverTimestamp()` form).
const CREATED_AT = '2026-01-01T00:00:00.000Z';
const EXPIRES_AT = '2026-01-02T00:00:00.000Z';

/** One member node, shaped exactly like `SessionMember.toMap()`. */
const member = (uid, role, code) => ({
  userId: uid,
  deviceId: `device-${uid}`,
  displayName: role === 'host' ? 'You' : 'Friend',
  photoUrl: null,
  role,
  status: 'joined',
  joinedAt: CREATED_AT,
  isActive: true,
  lastActive: CREATED_AT,
  leftAt: null,
  breaks: 0,
  completedAt: null,
  code: code ?? null,
});

const settings = () => ({
  sharedDailyLimit: null,
  focusApps: null,
  blockedApps: null,
  showMemberActivity: true,
  enforceSync: false,
});

/** The atomic multi-path update `SessionService.createSession` performs. */
const createPayload = ({ uid, sessionId, code, name, isPublic = false }) => {
  if (typeof name !== 'string' || name.length === 0) {
    throw new Error('createPayload needs a non-empty name');
  }

  return {
    [`sessions/${sessionId}`]: {
      id: sessionId,
      name,
      ownerId: uid,
      maxMembers: 10,
      members: { [uid]: member(uid, 'host') },
      visibility: isPublic ? 'public' : 'invite',
      isPublic,
      createdAt: CREATED_AT,
      isActive: true,
      settings: settings(),
      type: 'study',
      durationSec: 1500,
      countdownSec: 5,
      state: 'lobby',
      inviteCode: code,
    },
    [`users/${uid}/sessions/${sessionId}`]: true,
    [`invites/${code}`]: {
      sid: sessionId,
      hostUid: uid,
      title: name,
      type: 'study',
      durationSec: 1500,
      hostName: 'You',
      createdAt: CREATED_AT,
      expiresAt: EXPIRES_AT,
    },
  };
};

/** The single update `SessionService._joinAsMember` performs. */
const joinPayload = ({ uid, sessionId, code }) => ({
  [`sessions/${sessionId}/members/${uid}`]: member(uid, 'member', code),
  [`users/${uid}/sessions/${sessionId}`]: true,
});

/**
 * Runs [body] against a freshly-emptied database under the real rules.
 *
 * The emulator is a long-lived process, so anything a previous run left behind
 * would let these tests pass for the wrong reason. Everything is cleared through
 * a rules-disabled context first.
 */
async function withEnv(body) {
  const env = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    database: {
      rules: fs.readFileSync(RULES_PATH, 'utf8'),
      host: '127.0.0.1',
      port: DATABASE_PORT,
    },
  });

  await env.withSecurityRulesDisabled(async (ctx) => {
    await ctx.database().ref().remove();
  });

  try {
    await body(env);
  } finally {
    await env.cleanup();
  }
}

/**
 * Reads a path with the rules bypassed — used to assert what actually landed.
 *
 * The value has to be captured in an outer variable: `withSecurityRulesDisabled`
 * is typed `Promise<void>` and drops whatever its callback returns, so returning
 * the snapshot straight from the callback made every read `undefined` — which
 * failed assertions for a reason that had nothing to do with the write.
 */
const readRaw = async (env, path_) => {
  let value;
  await env.withSecurityRulesDisabled(async (ctx) => {
    const snapshot = await ctx.database().ref(path_).get();
    value = snapshot.val() ?? null;
  });
  return value;
};

module.exports = {
  CREATED_AT,
  DATABASE_PORT,
  EXPIRES_AT,
  GUEST_UID,
  HOST_UID,
  PROJECT_ID,
  createPayload,
  joinPayload,
  member,
  readRaw,
  settings,
  withEnv,
};
