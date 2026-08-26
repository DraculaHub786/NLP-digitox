# Task Brief: Split Leaderboard into weekly / monthly / lifetime + n8n-based reset + winners collection

Repo: `NLP-digitox`, branch `glitches`. Hand this whole file to your local coding
agent as the task spec. It's ordered so each step is independently testable —
don't skip the order.

**v2 change from the first draft:** the reset now runs from your existing
self-hosted **n8n instance** (`n8n.nlpdigitox.me`, on your own Google VM)
instead of Firebase Cloud Functions. This avoids the Blaze plan entirely —
Cloud Functions (any trigger type, not just scheduled) require Blaze because
deployment needs the Cloud Build API enabled, which requires a billing
account. n8n has none of that: it's your own server, own cron, own service
account calling Firestore directly. `functions/index.js` is no longer part
of this plan — you can leave it in the repo unused or delete it later.

---

## 0. Root cause (read this first — it changes what "fix" means)

I pulled the `glitches` branch and read `lib/core/services/leaderboard_service.dart`
and `functions/index.js` directly. Two separate problems are stacked on top of
each other:

**Problem A — resets never actually ran.** The stale
`leaderboard_config/weekly_reset` doc (`weekNumber: 1` since 24 Jul 2026,
despite several Mondays passing) has a `createdAt` field the Cloud Function
code never writes — that doc was hand-seeded at some point, not produced by
a real function run. Cloud Functions can't deploy at all on the Spark (free)
plan, so the scheduled reset in `functions/index.js` has likely never
executed on this project.

**Problem B — the weekly-vs-lifetime number mismatch is stale data, not a
live bug.** `addPoints()` in `leaderboard_service.dart` is the *only* place
in the app that writes points (confirmed — no other file writes to the
`leaderboard` collection), and it already increments `points`,
`monthlyPoints`, and `lifetimePoints` together, atomically, in one
transaction. The 3k-weekly-vs-800-lifetime numbers are leftover from before
resets were working / before `lifetimePoints` existed — they need a one-time
reconciliation (Step 2), not a code fix.

**Implication for the plan:** the point-tracking logic is sound. The work is
(1) reconcile existing bad data once, (2) restructure storage into three
separate collections, (3) move the reset + winner-recording cron from
(non-functional) Cloud Functions to your working n8n instance. Steps below
keep every public method on `LeaderboardService` the same name/signature, so
`leaderboard_screen.dart`, `profile_screen.dart`, and `achievements_screen.dart`
need **zero changes**. Only the service implementation changes, plus one new
n8n workflow.

---

## 1. One-time data reconciliation script

Run this **once**, manually, before deploying the new schema, to zero out
existing corrupted weekly/monthly numbers. Does **not** touch
`lifetimePoints` — that stays the trusted running total.

Create `scripts/reconcile-once.js` (anywhere locally — it's not deployed):

```js
// One-time script. Run with: node reconcile-once.js
// Needs a service account key with Firestore access — see §3 for how to
// generate one (you'll reuse the same key for the n8n workflow).
const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp({ credential: cert(require("./service-account.json")) });
const db = getFirestore();

async function main() {
  const snap = await db.collection("leaderboard").get();
  const batchSize = 400;
  let batch = db.batch();
  let count = 0;

  for (const doc of snap.docs) {
    batch.update(doc.ref, {
      points: 0,
      monthlyPoints: 0,
      pointsBreakdown: {},
      lastUpdated: FieldValue.serverTimestamp(),
    });
    count++;
    if (count % batchSize === 0) {
      await batch.commit();
      batch = db.batch();
    }
  }
  await batch.commit();
  console.log(`Reconciled ${count} users — points & monthlyPoints zeroed, lifetimePoints untouched.`);
}

main().catch(console.error);
```

Run it, confirm in the Firestore console that `lifetimePoints` is unchanged
and `points`/`monthlyPoints` are 0 for everyone, then delete the script and
the key file from your local machine (keep the key on the VM only — see §3).

---

## 2. New Firestore structure

Target end state — three collections instead of one:

| Collection | Doc ID | Purpose | Resets |
|---|---|---|---|
| `leaderboard` | `{uid}` | **Lifetime** record. `username`, `avatarEmoji`, `email`, `streak`, `lifetimePoints`, `pointsBreakdown` (lifetime), `lastActiveAt`. | Never |
| `weekly_leaderboard` | `{uid}` | This week's score only. `username`, `avatarEmoji`, `points`, `weekNumber`, `lastActiveAt`. | Every Monday 4 AM IST, via n8n |
| `monthly_leaderboard` | `{uid}` | This month's score only. `username`, `avatarEmoji`, `points`, `monthLabel`. | 1st of month 4 AM IST, via n8n |
| `winners` | auto-id | Historical record of each cycle's winner(s). See §5. | Never (append-only) |

`username`/`avatarEmoji` are denormalized onto the weekly/monthly docs so the
board reads with a single collection query + `orderBy('points', descending:
true)` — no more "fetch everything, sort client-side" workaround.

### `firestore.rules` additions

```
// Weekly leaderboard - all authenticated users can read; each user writes only their own doc
match /weekly_leaderboard/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && request.auth.uid == userId;
}

// Monthly leaderboard - same pattern
match /monthly_leaderboard/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && request.auth.uid == userId;
}

// Winners - readable by everyone signed in, never client-writable
match /winners/{winnerId} {
  allow read: if request.auth != null;
  allow write: if false; // n8n service account (Admin SDK) bypasses this rule
}
```

Leave `leaderboard` and `leaderboard_config` rules as-is — the existing
`allow write: if false` on `leaderboard_config` already correctly blocks
clients, since the n8n service account uses the Admin SDK and bypasses rules
entirely, exactly like a Cloud Function would.

---

## 3. Service account for n8n → Firestore access

n8n needs Admin-level Firestore access the same way a Cloud Function would
get it — via a service account key, since it's running outside Google's
managed Functions environment:

1. Google Cloud Console → your Firebase project → **IAM & Admin → Service
   Accounts → Create Service Account**. Name it e.g.
   `n8n-leaderboard-reset`.
2. Grant it the **Cloud Datastore User** role (covers Firestore read/write —
   this is the same role the Admin SDK effectively uses).
3. **Keys → Add Key → JSON** — download it.
4. Upload the JSON file to your n8n VM somewhere *outside* n8n's web-served
   directories, e.g. `/opt/n8n/secrets/firebase-service-account.json`, and
   lock it down: `chmod 600` and confirm it's owned by the user n8n runs as.
5. **Never** commit this file to the repo or expose it via any HTTP path.

---

## 4. `lib/core/services/leaderboard_service.dart` changes

(Same as before — this part doesn't depend on Cloud Functions vs n8n, it's
purely client-side.) Keep every public method name/signature exactly as-is.

**4.1 — `addPoints()`**: fan out the write to all three collections in one
transaction instead of one doc with three fields:

```dart
Future<void> addPoints(int points, String category) async {
  try {
    final userId = FirebaseAuthService.instance.userId;
    if (userId == null) return;

    final lifetimeRef = _firestore.collection('leaderboard').doc(userId);
    final weeklyRef = _firestore.collection('weekly_leaderboard').doc(userId);
    final monthlyRef = _firestore.collection('monthly_leaderboard').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final lifetimeSnap = await transaction.get(lifetimeRef);
      final weeklySnap = await transaction.get(weeklyRef);
      final monthlySnap = await transaction.get(monthlyRef);

      final currentLifetime = lifetimeSnap.exists
          ? (lifetimeSnap.data()?['lifetimePoints'] ?? 0) as int
          : 0;
      final currentBreakdown = lifetimeSnap.exists
          ? Map<String, int>.from(lifetimeSnap.data()?['pointsBreakdown'] ?? {})
          : <String, int>{};
      final currentWeekly = weeklySnap.exists ? (weeklySnap.data()?['points'] ?? 0) as int : 0;
      final currentMonthly = monthlySnap.exists ? (monthlySnap.data()?['points'] ?? 0) as int : 0;

      currentBreakdown[category] = (currentBreakdown[category] ?? 0) + points;

      final auth = FirebaseAuthService.instance;
      final baseIdentity = <String, dynamic>{
        'username': auth.userDisplayName ?? 'User',
        'avatarEmoji': '👤',
      };

      transaction.set(lifetimeRef, {
        if (!lifetimeSnap.exists) ...baseIdentity,
        if (!lifetimeSnap.exists) 'email': auth.userEmail,
        'lifetimePoints': currentLifetime + points,
        'pointsBreakdown': currentBreakdown,
        'lastUpdated': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(weeklyRef, {
        if (!weeklySnap.exists) ...baseIdentity,
        'points': currentWeekly + points,
        'lastUpdated': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(monthlyRef, {
        if (!monthlySnap.exists) ...baseIdentity,
        'points': currentMonthly + points,
        'lastUpdated': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });

    clearCache();
    debugPrint('Added $points points to $category (fanned out to 3 collections)');
  } catch (e) {
    debugPrint('Add points error: $e');
  }
}
```

**4.2 — `_collectionFor(period)` helper** — add near `LeaderboardPeriodX`:

```dart
extension LeaderboardPeriodCollectionX on LeaderboardPeriod {
  String get collectionName =>
      this == LeaderboardPeriod.weekly ? 'weekly_leaderboard' : 'monthly_leaderboard';
}
```

**4.3 — `getTopUsers()` / `streamTopUsers()`**: query `period.collectionName`
directly with a real `orderBy`, instead of pulling the whole `leaderboard`
collection and sorting client-side:

```dart
Future<List<LeaderboardUser>> getTopUsers({
  LeaderboardPeriod period = LeaderboardPeriod.weekly,
  int limit = 100,
}) async {
  try {
    final cached = _cachedLeaderboard[period];
    final fetchedAt = _lastFetchTime[period];
    if (cached != null && fetchedAt != null &&
        DateTime.now().difference(fetchedAt) < _cacheDuration) {
      return cached;
    }

    final currentUserId = FirebaseAuthService.instance.userId ?? '';
    final querySnapshot = await _firestore
        .collection(period.collectionName)
        .orderBy('points', descending: true)
        .limit(limit)
        .get();

    final users = querySnapshot.docs.asMap().entries.map((e) {
      return LeaderboardUser.fromFirestore(e.value, e.key + 1, currentUserId);
    }).toList();

    _cachedLeaderboard[period] = users;
    _lastFetchTime[period] = DateTime.now();
    return users;
  } catch (e) {
    debugPrint('Get leaderboard error (${period.label}): $e');
    return [];
  }
}
```

Do the equivalent for `streamTopUsers()` (same query, `.snapshots()` instead
of `.get()`), keeping its "always surface the signed-in user even if they
fell outside the fetch cap" fallback — just point that fallback read at
`period.collectionName` instead of `leaderboard`.

**4.4 — `LeaderboardUser.fromFirestore()`**: weekly/monthly docs only have a
`points` field; the lifetime doc only has `lifetimePoints`. Add a second
factory or branch so the model reads the right field per source doc — e.g.
`LeaderboardUser.fromPeriodDoc(doc, rank, currentUserId)` reading `points`
generically, and `LeaderboardUser.fromLifetimeDoc(...)` for
profile/achievements reading `lifetimePoints`. The UI already only ever
calls `scoreFor()` or `.lifetimePoints` off one object at a time, never both,
so this is safe.

**4.5 — `getCurrentUserData()`**: read from `period.collectionName` for the
score + rank (`.where('points', isGreaterThan: userScore).count()` as
today), and separately read `leaderboard/{uid}` for `lifetimePoints` if the
caller needs it — merge both into the returned `LeaderboardUser`.

**4.6 — `updateUserData()` / `updateStreak()` / `markActive()` /
`checkAndResetStreakIfNeeded()`**: streak lives on the lifetime doc (not a
period concept) — keep these writing to `leaderboard/{uid}` exactly as
today, no change needed.

---

## 5. n8n workflow: leaderboard reset + winner recording

Two workflows (or one workflow with two independent Schedule Trigger
branches — either is fine, two is simpler to monitor separately):
**Weekly Leaderboard Reset** and **Monthly Leaderboard Reset**.

### 5.1 Trigger

- **Weekly**: Schedule Trigger node, cron `0 4 * * 1`, timezone `Asia/Kolkata`.
- **Monthly**: Schedule Trigger node, cron `0 4 1 * *`, timezone `Asia/Kolkata`.

### 5.2 Reset logic — Code node

Since your n8n is self-hosted, the simplest and most reliable approach is a
single **Code node** using `firebase-admin` directly — this lets you reuse
almost the exact same logic that would've gone in `functions/index.js`,
just running on your VM's cron instead of Google's.

One-time VM setup:
```bash
# On the n8n host/container
cd /path/to/n8n/data   # wherever n8n's working dir is
npm install firebase-admin
```
Then set the environment variable n8n's process runs with:
```
NODE_FUNCTION_ALLOW_EXTERNAL=firebase-admin
```
(Restart n8n after this — self-hosted n8n needs `NODE_FUNCTION_ALLOW_EXTERNAL`
set to whitelist npm packages inside Code nodes.)

Code node contents (set this as the node's JS code, `Run Once for All Items`
mode):

```js
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');
const crypto = require('crypto');

const serviceAccount = require('/opt/n8n/secrets/firebase-service-account.json');

// n8n Code nodes re-run this file each execution — guard against
// "app already exists" errors if the node runs more than once in a process.
const admin = require('firebase-admin');
const app = admin.apps.length
  ? admin.app()
  : initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore(app);

// ---- CONFIGURE PER WORKFLOW ----
// Weekly workflow: period = 'weekly', collectionName = 'weekly_leaderboard'
// Monthly workflow: period = 'monthly', collectionName = 'monthly_leaderboard'
const period = 'weekly';
const collectionName = 'weekly_leaderboard';
const configDocId = 'weekly_reset';
const BATCH_LIMIT = 450;

function computeCycleLabel(now) {
  if (period === 'weekly') return `Week of ${now.toISOString().slice(0, 10)}`;
  return now.toLocaleString('en-US', { month: 'long', year: 'numeric' });
}

function computeNextResetDate(now) {
  if (period === 'weekly') {
    const next = new Date(now);
    next.setDate(now.getDate() + 7);
    return next;
  }
  return new Date(now.getFullYear(), now.getMonth() + 1, 1, 4, 0, 0);
}

async function recordWinner(docs, cycleLabel, cycleNumber) {
  if (docs.length === 0) return null;
  const winnerDoc = docs[0]; // highest points, already ordered desc
  const data = winnerDoc.data();
  if (!data.points || data.points <= 0) return null; // nobody scored this cycle

  const verificationCode = crypto.randomInt(100000, 999999).toString();

  const lifetimeSnap = await db.collection('leaderboard').doc(winnerDoc.id).get();
  const email = lifetimeSnap.exists ? lifetimeSnap.data().email : (data.email || null);

  await db.collection('winners').add({
    period,
    cycleLabel,
    cycleNumber,
    userId: winnerDoc.id,
    username: data.username || 'Anonymous',
    email,
    points: data.points,
    verificationCode,
    verified: false,
    createdAt: FieldValue.serverTimestamp(),
  });

  return { username: data.username || 'Anonymous', email, points: data.points, verificationCode, cycleLabel };
}

async function run() {
  const now = new Date();
  const configRef = db.collection('leaderboard_config').doc(configDocId);
  const configSnap = await configRef.get();
  const previousCycle = configSnap.exists ? (configSnap.data().cycleNumber || 0) : 0;

  const snapshot = await db.collection(collectionName).orderBy('points', 'desc').get();
  const docs = snapshot.docs;

  const cycleLabel = computeCycleLabel(now);
  const winner = await recordWinner(docs, cycleLabel, previousCycle + 1);

  for (let i = 0; i < docs.length; i += BATCH_LIMIT) {
    const chunk = docs.slice(i, i + BATCH_LIMIT);
    const batch = db.batch();
    for (const doc of chunk) {
      batch.update(doc.ref, { points: 0, lastUpdated: FieldValue.serverTimestamp() });
    }
    await batch.commit();
  }

  await configRef.set({
    lastResetDate: FieldValue.serverTimestamp(),
    nextResetDate: Timestamp.fromDate(computeNextResetDate(now)),
    cycleNumber: previousCycle + 1,
    cycleLabel,
    usersReset: docs.length,
  });

  return { usersReset: docs.length, cycleNumber: previousCycle + 1, cycleLabel, winner };
}

return [{ json: await run() }];
```

Duplicate this node for the monthly workflow with `period = 'monthly'`,
`collectionName = 'monthly_leaderboard'`, `configDocId = 'monthly_reset'`.

### 5.3 Notify the winner — reuse your existing email setup

The Code node's output includes a `winner` object (or `null` if nobody
scored). Add:

- An **IF node** after the Code node: `{{$json.winner}}` is not empty.
- On the true branch, whatever node/credential you're already using to send
  the OTP emails (Send Email node, or an HTTP Request to your transactional
  email provider) — send the winner their `username`, `points`, `cycleLabel`,
  and `verificationCode`.

This is the same email-sending capability your forgot-password flow already
proves works, just triggered from a different workflow.

### 5.4 Error handling

Add an **Error Trigger** workflow (or a node connected to "On Error" for
this workflow) that posts a message somewhere you'll see it (email to
yourself, a Slack/Telegram webhook, whatever you already use) — a silent
failure here is exactly the kind of thing that produced the stale doc you
started with.

---

## 6. Deploy & test order

1. Run the reconciliation script (§1) — do this **before** the app update
   ships, while data is still on the old single-collection schema.
2. Deploy rules: `firebase deploy --only firestore:rules`.
3. Ship the Flutter changes (§4). `weekly_leaderboard`/`monthly_leaderboard`
   are new, empty collections — they populate naturally as users earn
   points post-deploy, no backfill needed (only `leaderboard`/lifetime
   carries forward, which reconciliation already left correct).
4. Create the service account and upload the key to the VM (§3).
5. Build the two n8n workflows (§5). **Before turning on the schedule**,
   trigger each manually from n8n's editor ("Execute Workflow" button) once
   the app has some real weekly/monthly data in Firestore, and confirm:
   - `weekly_leaderboard` docs' `points` all go to 0.
   - `leaderboard_config/weekly_reset` updates with a real `cycleNumber`
     and `usersReset` count (no more stale placeholder doc).
   - A `winners` doc appears with a `verificationCode`, if anyone scored.
   - The notification step (§5.3) actually sends, if wired up.
6. Repeat for the monthly workflow.
7. Activate both Schedule Triggers. From here the resets run on their own —
   no Firebase billing plan involved anywhere in this path.