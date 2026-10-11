// Dumps the currently DEPLOYED Firestore ruleset to tmp_live_firestore.rules so
// it can be diffed against the repo's `firestore.rules`:
//
//   node scripts/dump-live-rules.js
//   git diff --no-index firestore.rules tmp_live_firestore.rules
const fs = require('fs');
const path = require('path');
const { GoogleAuth } = require('google-auth-library');

const sa = require(path.join(__dirname, 'service-account.json'));
const PROJECT = sa.project_id;

async function main() {
  const auth = new GoogleAuth({
    credentials: sa,
    scopes: ['https://www.googleapis.com/auth/cloud-platform'],
  });
  const client = await auth.getClient();
  const token = (await client.getAccessToken()).token;

  const relRes = await fetch(
    `https://firebaserules.googleapis.com/v1/projects/${PROJECT}/releases/cloud.firestore`,
    { headers: { Authorization: `Bearer ${token}` } },
  );
  if (!relRes.ok) throw new Error(`release fetch ${relRes.status}: ${await relRes.text()}`);
  const rel = await relRes.json();

  const rsRes = await fetch(`https://firebaserules.googleapis.com/v1/${rel.rulesetName}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  const rs = await rsRes.json();
  const files = (rs.source && rs.source.files) || [];
  const content = files.map((f) => f.content).join('\n');

  const out = path.join(__dirname, '..', 'tmp_live_firestore.rules');
  fs.writeFileSync(out, content);

  console.log(`ruleset:  ${rel.rulesetName}`);
  console.log(`file:     ${files.length ? files[0].name : '?'}`);
  console.log(`lines:    ${content.split('\n').length}`);
  console.log(`wrote:    ${out}`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
