# Task

# Coding Agent Tasks — Leaderboard Split

Repo: `NLP-digitox`, branch `glitches`. Hand **this file only** to your local
coding agent — everything in it is a change to a file in the repo. Nothing
here needs a browser, a cloud console, or n8n; that's all in the separate
`2_HUMAN_TASKS.md` file, which the agent should not attempt.

Do the tasks in order. Each one is a self-contained file change.

---

## Context (for the agent to understand *why*, not to act on)

I pulled the `glitches` branch and read `lib/core/services/leaderboard_service.dart`
and `functions/index.js` directly before writing this.

- `addPoints()` is the only place in the app that writes leaderboard points,
  and it already increments weekly/monthly/lifetime together atomically — so
  the point-tracking logic is sound. The visible bugs (weekly ≠ lifetime,
  resets not firing) come from a data/infrastructure problem, not a logic
  bug in this function.
- `functions/index.js` (Firebase Cloud Functions) is **no longer part of the
  plan** — the reset now runs from an external n8n workflow instead (that's
  entirely a human/UI task, see the other file). The agent does not need to
  touch `functions/index.js`. Leave it in the repo as-is (dead code, harmless)
  unless asked to delete it.
- Every task below keeps all public method names/signatures on
  `LeaderboardService` unchanged, so `leaderboard_screen.dart`,
  `profile_screen.dart`, and `achievements_screen.dart` need **zero changes**.
- The human also shared their real n8n workflow exports. Two of them —
  `[Digitox] Weekly Leaderboard Winner` and `[Digitox] Monthly Leaderboard
  Winner` — are already live and already implement the "winners database"
  (badges + verification codes + email) that was originally planned as a
  new `winners` collection. That collection has been dropped from this plan
  entirely — don't recreate it.

---

## Task 1 — Create the one-time reconciliation script

Create `scripts/reconcile-once.js`:

```js
// One-time script. Run with: node reconcile-once.js
// Needs a service account key with Firestore access (the human running this
// will supply a service-account.json file in the same folder).
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

This zeroes the corrupted `points`/`monthlyPoints` fields on the existing
single `leaderboard` collection, without touching `lifetimePoints` (the
trusted running total). It is **not** meant to be run by the agent — it
needs a real service-account key and Firestore access, which is a human
step. The agent's job here is just to create the file correctly.

---

## Task 2 — Update `firestore.rules`

**Update from the first draft:** no `winners` collection is needed. The
n8n side already has a working winners/badges system —
`badges/{uid}_{period}_{periodId}` and `badge_verification/{verificationId}`
— live in two active workflows (`[Digitox] Weekly/Monthly Leaderboard
Winner`), complete with a `DTX-XXXXXX` verification ID format and email
delivery. **Update:** the `badges` collection will start holding winners' email
addresses (see `N8N_LEADERBOARD_WORKFLOWS_GUIDE.md` Part D — an n8n change,
not a repo change, but it does mean `firestore.rules` needs to lock down
who can read `badges`). If `firestore.rules` already has a `match
/badges/{badgeId}` block that allows any authenticated user to read, tighten
it to owner-only, since badge doc IDs already encode the owner
(`{uid}_{period}_{periodId}`):

```
match /badges/{badgeId} {
  allow read: if request.auth != null &&
    badgeId.matches(request.auth.uid + '_.*');
  allow write: if false; // n8n service account only
}
```

Leave `badge_verification` rules as-is (or, if absent, `allow read: if
request.auth != null; allow write: if false;`) — that collection stays
public-safe on purpose, since it never gets an email field.

If `firestore.rules` doesn't already have rules for `badges` and
`badge_verification`, check with the human before adding any — they may
already exist (this codebase was pulled at one point in time and the rules
file wasn't fully visible when this task was written). Don't add a
duplicate `match` block for a collection that already has one.

Add these two rule blocks (new collections — don't change the existing
`leaderboard` or `leaderboard_config` rules, they're already correct):

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
```

Target schema this supports:

| Collection | Doc ID | Purpose | Resets |
|---|---|---|---|
| `leaderboard` | `{uid}` | **Lifetime** record. `username`, `avatarEmoji`, `email`, `streak`, `lifetimePoints`, `pointsBreakdown` (lifetime), `lastActiveAt`. | Never |
| `weekly_leaderboard` | `{uid}` | This week's score only. `username`, `avatarEmoji`, `points`, `lastActiveAt`. | Weekly, via n8n |
| `monthly_leaderboard` | `{uid}` | This month's score only. `username`, `avatarEmoji`, `points`. | Monthly, via n8n |
| `badges` / `badge_verification` | `{uid}_{period}_{periodId}` / `{verificationId}` | Already exists — winner records, unchanged by this task. | Never |

---

## Task 3 — Update `lib/core/services/leaderboard_service.dart`

Keep every public method name/signature exactly as-is
(`getTopUsers`, `streamTopUsers`, `getCurrentUserData`, `updateUserData`,
`addPoints`, `updateStreak`, `getResetInfo`, `clearCache`, streak methods).
Only change the bodies.

### 3.1 — `addPoints()`

Fan out the write to all three collections in one transaction instead of
one doc with three fields:

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

### 3.2 — `_collectionFor(period)` helper

Add near `LeaderboardPeriodX`:

```dart
extension LeaderboardPeriodCollectionX on LeaderboardPeriod {
  String get collectionName =>
      this == LeaderboardPeriod.weekly ? 'weekly_leaderboard' : 'monthly_leaderboard';
}
```

### 3.3 — `getTopUsers()` / `streamTopUsers()`

Query `period.collectionName` directly with a real `orderBy`, instead of
pulling the whole `leaderboard` collection and sorting client-side:

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

### 3.4 — `LeaderboardUser.fromFirestore()`

Weekly/monthly docs only have a `points` field; the lifetime doc only has
`lifetimePoints`. Add a second factory or branch so the model reads the
right field per source doc — e.g. `LeaderboardUser.fromPeriodDoc(doc, rank,
currentUserId)` reading `points` generically, and
`LeaderboardUser.fromLifetimeDoc(...)` for profile/achievements reading
`lifetimePoints`. The UI already only ever calls `scoreFor()` or
`.lifetimePoints` off one object at a time, never both, so this is safe.

### 3.5 — `getCurrentUserData()`

Read from `period.collectionName` for the score + rank
(`.where('points', isGreaterThan: userScore).count()` as today), and
separately read `leaderboard/{uid}` for `lifetimePoints` if the caller needs
it — merge both into the returned `LeaderboardUser`.

### 3.6 — `updateUserData()` / `updateStreak()` / `markActive()` / `checkAndResetStreakIfNeeded()`

Streak lives on the lifetime doc (not a period concept) — keep these writing
to `leaderboard/{uid}` exactly as today, no change needed.

---

## Task 4 — Nothing else in the repo needs to change

Do not touch `functions/index.js`, `leaderboard_screen.dart`,
`profile_screen.dart`, or `achievements_screen.dart` — they either aren't
part of this plan anymore (Cloud Functions) or don't need changes because
`LeaderboardService`'s public API stayed the same.

When these four tasks are done, hand the repo back for the human steps in
`2_HUMAN_TASKS.md` (reconciliation run, rules deploy, n8n workflow, app
release, testing).
# Done