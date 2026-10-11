// Verifies the DEPLOYED Firestore rules for the leaderboard collections.
//
// The emulator suite (`test/firestore_rules/`) proves the rule *logic* is
// correct. This script answers the different question the bug actually turned
// on: is the corrected ruleset deployed, and does a real authenticated client
// write now pass?
//
//   node scripts/probe-live-leaderboard-rules.js
//
// It is read-mostly and self-cleaning:
//   1. reads the live ruleset from the Firebase Rules API and looks for the fix;
//   2. creates (or reuses) a throwaway auth user `mock-lb-probe@example.invalid`;
//   3. signs that user in through the Identity Toolkit REST API to get an ID
//      token — i.e. an ordinary client, not the Admin SDK, which bypasses rules;
//   4. replays the exact writes `LeaderboardService.addPoints` makes and reports
//      each HTTP status;
//   5. deletes the probe user's board docs and the auth user again.
//
// Requires `firebase-admin` and the Web API key (read from
// `android/app/google-services.json`).

const path = require('path');
const fs = require('fs');
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getAuth } = require('firebase-admin/auth');

const SERVICE_ACCOUNT = path.join(__dirname, 'service-account.json');
const GOOGLE_SERVICES = path.join(__dirname, '..', 'android', 'app', 'google-services.json');
const PROBE_EMAIL = 'mock-lb-probe@example.invalid';
const PROBE_PASSWORD = 'Probe!' + Math.random().toString(36).slice(2, 12) + '9';

const sa = require(SERVICE_ACCOUNT);
const PROJECT = sa.project_id;
const API_KEY = JSON.parse(fs.readFileSync(GOOGLE_SERVICES, 'utf8'))
  .client[0].api_key[0].current_key;

const FIRESTORE_BASE =
  `https://firestore.googleapis.com/v1/projects/${PROJECT}` +
  `/databases/(default)/documents`;

function tsField() {
  return { timestampValue: new Date().toISOString() };
}

/** Merges fields onto a doc via Firestore's REST PATCH (an update), or creates. */
async function patchDoc(idToken, collection, docId, fields) {
  const params = new URLSearchParams();
  for (const key of Object.keys(fields)) params.append('updateMask.fieldPaths', key);

  const res = await fetch(`${FIRESTORE_BASE}/${collection}/${docId}?${params}`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${idToken}`,
    },
    body: JSON.stringify({ fields }),
  });
  return { status: res.status, body: res.ok ? null : await res.text() };
}

async function getLiveRuleset() {
  let GoogleAuth;
  try {
    ({ GoogleAuth } = require('google-auth-library'));
  } catch (e) {
    return { error: 'google-auth-library not resolvable: ' + e.message };
  }
  const auth = new GoogleAuth({
    credentials: sa,
    scopes: ['https://www.googleapis.com/auth/cloud-platform'],
  });
  const client = await auth.getClient();
  const token = (await client.getAccessToken()).token;

  const releaseRes = await fetch(
    `https://firebaserules.googleapis.com/v1/projects/${PROJECT}/releases/cloud.firestore`,
    { headers: { Authorization: `Bearer ${token}` } },
  );
  if (!releaseRes.ok) {
    return { error: `release fetch ${releaseRes.status}: ${await releaseRes.text()}` };
  }
  const release = await releaseRes.json();

  const rulesetRes = await fetch(
    `https://firebaserules.googleapis.com/v1/${release.rulesetName}`,
    { headers: { Authorization: `Bearer ${token}` } },
  );
  const ruleset = await rulesetRes.json();
  const source = (ruleset.source && ruleset.source.files)
    ? ruleset.source.files.map((f) => f.content).join('\n')
    : '';
  return { source, rulesetName: release.rulesetName };
}

async function signIn() {
  const res = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: PROBE_EMAIL,
        password: PROBE_PASSWORD,
        returnSecureToken: true,
      }),
    },
  );
  const json = await res.json();
  if (!res.ok) throw new Error(`sign-in failed: ${JSON.stringify(json)}`);
  return json.idToken;
}

async function main() {
  initializeApp({ credential: cert(sa) });
  const db = getFirestore();
  const authAdmin = getAuth();

  console.log(`project: ${PROJECT}\n`);

  // --- 1. Is the fixed rule deployed? -------------------------------------
  console.log('== deployed ruleset ==');
  const live = await getLiveRuleset();
  if (live.error) {
    console.log(`  could not read live ruleset: ${live.error}`);
  } else if (!live.source) {
    console.log('  ruleset source was empty');
  } else {
    const hasFunction = live.source.includes('function validAvatar');
    const hasBound = /lifetimePoints[\s\S]{0,120}<=\s*100/.test(live.source);
    const hasPeriodBound = (live.source.match(/points[\s\S]{0,120}<=\s*100/g) || []).length;
    console.log(`  ruleset: ${live.rulesetName}`);
    console.log(`  contains validAvatar():     ${hasFunction}`);
    console.log(`  contains lifetime <=100 cap: ${hasBound}`);
    console.log(`  period 'points <= 100' caps: ${hasPeriodBound}`);
    console.log(
      `  VERDICT: ${hasFunction && hasBound ? 'FIX IS DEPLOYED' : 'FIX IS *NOT* DEPLOYED (old rules live)'}`,
    );
  }

  // --- 2. Ensure the probe user exists ------------------------------------
  let uid;
  try {
    const existing = await authAdmin.getUserByEmail(PROBE_EMAIL);
    uid = existing.uid;
    await authAdmin.updateUser(uid, { password: PROBE_PASSWORD });
  } catch (e) {
    const created = await authAdmin.createUser({
      email: PROBE_EMAIL,
      password: PROBE_PASSWORD,
      displayName: 'Probe',
    });
    uid = created.uid;
  }
  console.log(`\n== authenticated client write (uid=${uid}) ==`);

  const idToken = await signIn();

  // --- 3. Replay the addPoints writes as a normal client ------------------
  // The weekly/monthly docs only carry `points`; the lifetime doc carries
  // `lifetimePoints`. The lifetime update is the write the old rules refused.
  const weeklyCreate = await patchDoc(idToken, 'weekly_leaderboard', uid, {
    points: { integerValue: '30' },
    lastUpdated: tsField(),
    lastActiveAt: tsField(),
  });
  report('create weekly_leaderboard points=30', weeklyCreate, 200);

  const lifetimeCreate = await patchDoc(idToken, 'leaderboard', uid, {
    lifetimePoints: { integerValue: '0' },
    lastUpdated: tsField(),
    lastActiveAt: tsField(),
  });
  report('create leaderboard lifetimePoints=0', lifetimeCreate, 200);

  const lifetimeGrow = await patchDoc(idToken, 'leaderboard', uid, {
    lifetimePoints: { integerValue: '30' },
    lastUpdated: tsField(),
    lastActiveAt: tsField(),
  });
  report('update leaderboard lifetimePoints=0 -> 30 (+30)', lifetimeGrow, 200);

  const lifetimeCheat = await patchDoc(idToken, 'leaderboard', uid, {
    lifetimePoints: { integerValue: '5030' },
    lastUpdated: tsField(),
  });
  report('update leaderboard lifetimePoints 30 -> 5030 (should be REFUSED)', lifetimeCheat, 403);

  // --- 4. Clean up --------------------------------------------------------
  for (const collection of ['leaderboard', 'weekly_leaderboard', 'monthly_leaderboard']) {
    await db.collection(collection).doc(uid).delete().catch(() => {});
  }
  await authAdmin.deleteUser(uid).catch(() => {});
  console.log('\ncleaned up probe docs + auth user.');
}

function report(label, { status, body }, expected) {
  const verdict = status === expected ? 'PASS' : 'FAIL';
  console.log(`  [${verdict}] ${label}  -> HTTP ${status} (expected ${expected})`);
  if (body) console.log(`        ${body.split('\n')[0].slice(0, 200)}`);
}

main().catch((err) => {
  console.error('probe failed:', err);
  process.exit(1);
});
