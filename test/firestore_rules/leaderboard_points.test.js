// What the leaderboard collections actually allow.
//
// Every case below writes a payload reproduced from the client — see
// `harness.js` for which method each builder mirrors. The rules under test are
// the real `firestore.rules` at the repository root.
//
// Why this file exists: `match /leaderboard/{userId}` used to permit an
// existing document to change only `profileImageUrl`, `profileImagePublicId`
// and `username`. `LeaderboardService.addPoints` writes `lifetimePoints`,
// `pointsBreakdown`, `lastUpdated` and `lastActiveAt` in the same transaction
// that touches the weekly and monthly docs, so every award was refused and —
// because a transaction is all-or-nothing — none of the three documents moved.
// The suite below pins both halves of that: the writes the app performs are
// allowed, and the ones it must never be able to perform are refused.

const assert = require('node:assert/strict');
const { test } = require('node:test');

const {
  ALICE,
  BOB,
  CLOUDINARY_AVATAR,
  LIFETIME,
  MONTHLY,
  WEEKLY,
  assertFails,
  assertSucceeds,
  backfillAvatarPayload,
  clearAvatarPayload,
  evaluateStreakPayload,
  lifetimeDocSeed,
  lifetimePointsUpdate,
  markActivePayload,
  mirrorAvatarPayload,
  periodDocSeed,
  periodPointsUpdate,
  readDoc,
  seedDoc,
  updateStreakPayload,
  updateUserDataPayload,
  withEnv,
} = require('./harness');

/** A lifetime doc for [uid] that already holds [lifetimePoints]. */
const seededLifetime = async (env, uid, lifetimePoints, extra = {}) =>
  seedDoc(env, LIFETIME, uid, {
    username: 'Alice',
    avatarEmoji: '👤',
    email: `${uid}@example.com`,
    profileImageUrl: CLOUDINARY_AVATAR,
    lifetimePoints,
    pointsBreakdown: { 'Wellbeing Activities': lifetimePoints },
    ...extra,
  });

/** A period doc for [uid] that already holds [points]. */
const seededPeriod = async (env, collection, uid, points, extra = {}) =>
  seedDoc(env, collection, uid, {
    username: 'Alice',
    avatarEmoji: '👤',
    profileImageUrl: CLOUDINARY_AVATAR,
    points,
    ...extra,
  });

// ---------------------------------------------------------------------------
// The lifetime doc
// ---------------------------------------------------------------------------

test('the habit award the app performs is allowed and lands', async () => {
  await withEnv(async (env) => {
    await seededLifetime(env, ALICE, 30);
    const alice = env.authenticatedContext(ALICE).firestore();

    await assertSucceeds(
      alice.collection(LIFETIME).doc(ALICE).set(
        lifetimePointsUpdate({
          fromPoints: 30,
          award: 30,
          breakdown: { 'Wellbeing Activities': 30 },
        }),
        { merge: true },
      ),
    );

    const stored = await readDoc(env, LIFETIME, ALICE);
    assert.equal(stored.lifetimePoints, 60);
    assert.equal(stored.pointsBreakdown['Wellbeing Activities'], 60);
  });
});

test('a single write cannot add more than the largest award', async () => {
  await withEnv(async (env) => {
    await seededLifetime(env, ALICE, 30);
    const alice = env.authenticatedContext(ALICE).firestore();

    // 101 is one above the biggest clamp in the app (`awardPointsForFocusSession`
    // clamps to 100), so a normal award can never be refused by this bound.
    await assertFails(
      alice.collection(LIFETIME).doc(ALICE).set(
        lifetimePointsUpdate({ fromPoints: 30, award: 101 }),
        { merge: true },
      ),
    );

    assert.equal((await readDoc(env, LIFETIME, ALICE)).lifetimePoints, 30);
  });
});

test('the lifetime total can never be walked backwards', async () => {
  await withEnv(async (env) => {
    await seededLifetime(env, ALICE, 60);
    const alice = env.authenticatedContext(ALICE).firestore();

    await assertFails(
      alice
        .collection(LIFETIME)
        .doc(ALICE)
        .set({ lifetimePoints: 30 }, { merge: true }),
    );

    assert.equal((await readDoc(env, LIFETIME, ALICE)).lifetimePoints, 60);
  });
});

test('a field outside the allow-list is refused', async () => {
  await withEnv(async (env) => {
    await seededLifetime(env, ALICE, 30);
    const alice = env.authenticatedContext(ALICE).firestore();

    // The bound on `lifetimePoints` alone would let this through on points;
    // the `hasOnly` list is what stops a board doc growing new fields.
    await assertFails(
      alice.collection(LIFETIME).doc(ALICE).set(
        { lifetimePoints: 35, isAdmin: true },
        { merge: true },
      ),
    );
  });
});

test('one user cannot write another user\'s board doc', async () => {
  await withEnv(async (env) => {
    await seededLifetime(env, ALICE, 30);
    const bob = env.authenticatedContext(BOB).firestore();

    await assertFails(
      bob
        .collection(LIFETIME)
        .doc(ALICE)
        .set({ lifetimePoints: 9999 }, { merge: true }),
    );

    assert.equal((await readDoc(env, LIFETIME, ALICE)).lifetimePoints, 30);
  });
});

test('the other writes the app makes are allowed', async () => {
  await withEnv(async (env) => {
    await seededLifetime(env, ALICE, 30);
    const alice = env.authenticatedContext(ALICE).firestore();
    const doc = () => alice.collection(LIFETIME).doc(ALICE);

    // LeaderboardService.markActive
    await assertSucceeds(doc().set(markActivePayload(), { merge: true }));
    // LeaderboardService.updateStreak
    await assertSucceeds(doc().set(updateStreakPayload(4), { merge: true }));
    // LeaderboardService.evaluateAndUpdateStreak
    await assertSucceeds(
      doc().set(evaluateStreakPayload(5), { merge: true }),
    );
    // ProfileService._mirrorProfileImageUrl(url)
    await assertSucceeds(
      doc().set(mirrorAvatarPayload(CLOUDINARY_AVATAR), { merge: true }),
    );
    // LeaderboardService._backfillMissingAvatars
    await assertSucceeds(
      doc().set(backfillAvatarPayload(CLOUDINARY_AVATAR), { merge: true }),
    );
    // The old rule's own field list must keep working.
    await assertSucceeds(
      doc().set({ username: 'Alice', profileImagePublicId: 'abc' }, {
        merge: true,
      }),
    );

    const stored = await readDoc(env, LIFETIME, ALICE);
    assert.equal(stored.streak, 5);
    assert.equal(stored.username, 'Alice');
  });
});

test('clearing the avatar is allowed and leaves the field absent', async () => {
  await withEnv(async (env) => {
    await seededLifetime(env, ALICE, 30);
    const alice = env.authenticatedContext(ALICE).firestore();

    await assertSucceeds(
      alice.collection(LIFETIME).doc(ALICE).set(clearAvatarPayload(), {
        merge: true,
      }),
    );

    const stored = await readDoc(env, LIFETIME, ALICE);
    assert.equal('profileImageUrl' in stored, false);
  });
});

test('an avatar from an untrusted host is refused', async () => {
  await withEnv(async (env) => {
    await seededLifetime(env, ALICE, 30);
    const alice = env.authenticatedContext(ALICE).firestore();

    await assertFails(
      alice
        .collection(LIFETIME)
        .doc(ALICE)
        .set(mirrorAvatarPayload('https://evil.example.com/pic.png'), {
          merge: true,
        }),
    );
  });
});

test('updateUserData\'s full map is allowed, on an existing doc and on a new one', async () => {
  await withEnv(async (env) => {
    await seededLifetime(env, ALICE, 30, {
      points: 30,
      monthlyPoints: 30,
      streak: 2,
      pointsBreakdown: { 'Task Completion': 30 },
    });
    const alice = env.authenticatedContext(ALICE).firestore();

    await assertSucceeds(
      alice.collection(LIFETIME).doc(ALICE).set(
        updateUserDataPayload({
          points: 30,
          monthlyPoints: 30,
          lifetimePoints: 30,
          streak: 2,
          breakdown: { 'Task Completion': 30 },
        }),
        { merge: true },
      ),
    );

    // The sign-up path: a brand-new account with nothing earned yet. Written by
    // bob's own context — the doc id must match the caller, which is the whole
    // point of the rule (see the cross-user case below).
    const bob = env.authenticatedContext(BOB).firestore();
    await assertSucceeds(
      bob
        .collection(LIFETIME)
        .doc(BOB)
        .set(updateUserDataPayload({ email: 'bob@example.com' }), {
          merge: true,
        }),
    );

    const fresh = await readDoc(env, LIFETIME, BOB);
    assert.equal(fresh.lifetimePoints, 0);
  });
});

test('a user cannot create another user\'s board doc', async () => {
  await withEnv(async (env) => {
    const alice = env.authenticatedContext(ALICE).firestore();

    await assertFails(
      alice
        .collection(LIFETIME)
        .doc(BOB)
        .set(updateUserDataPayload({ email: 'bob@example.com' }), {
          merge: true,
        }),
    );

    assert.equal(await readDoc(env, LIFETIME, BOB), null);
  });
});

test('an account cannot be created already holding a large total', async () => {
  await withEnv(async (env) => {
    const alice = env.authenticatedContext(ALICE).firestore();
    const bob = env.authenticatedContext(BOB).firestore();

    await assertSucceeds(
      alice
        .collection(LIFETIME)
        .doc(ALICE)
        .set(lifetimeDocSeed({ lifetimePoints: 100 }), { merge: true }),
    );

    // Written by bob's own context, so the only thing refusing this is the cap.
    await assertFails(
      bob
        .collection(LIFETIME)
        .doc(BOB)
        .set(lifetimeDocSeed({ lifetimePoints: 101 }), { merge: true }),
    );

    assert.equal(await readDoc(env, LIFETIME, BOB), null);
  });
});

// ---------------------------------------------------------------------------
// The period boards — the scores the winner emails are picked from
// ---------------------------------------------------------------------------

for (const collection of [WEEKLY, MONTHLY]) {
  test(`${collection}: the award the app makes is allowed and lands`, async () => {
    await withEnv(async (env) => {
      await seededPeriod(env, collection, ALICE, 20);
      const alice = env.authenticatedContext(ALICE).firestore();

      await assertSucceeds(
        alice
          .collection(collection)
          .doc(ALICE)
          .set(periodPointsUpdate({ fromPoints: 20, award: 50 }), {
            merge: true,
          }),
      );

      assert.equal((await readDoc(env, collection, ALICE)).points, 70);
    });
  });

  test(`${collection}: one write cannot add more than 100`, async () => {
    await withEnv(async (env) => {
      await seededPeriod(env, collection, ALICE, 20);
      const alice = env.authenticatedContext(ALICE).firestore();
      const doc = () => alice.collection(collection).doc(ALICE);

      await assertSucceeds(
        doc().set(periodPointsUpdate({ fromPoints: 20, award: 100 }), {
          merge: true,
        }),
      );
      await assertFails(
        doc().set(periodPointsUpdate({ fromPoints: 120, award: 101 }), {
          merge: true,
        }),
      );

      assert.equal((await readDoc(env, collection, ALICE)).points, 120);
    });
  });

  test(`${collection}: the score can never be walked backwards`, async () => {
    await withEnv(async (env) => {
      await seededPeriod(env, collection, ALICE, 120);
      const alice = env.authenticatedContext(ALICE).firestore();

      await assertFails(
        alice
          .collection(collection)
          .doc(ALICE)
          .set({ points: 10 }, { merge: true }),
      );

      assert.equal((await readDoc(env, collection, ALICE)).points, 120);
    });
  });

  test(`${collection}: a new doc may be created up to the cap and no further`, async () => {
    await withEnv(async (env) => {
      const alice = env.authenticatedContext(ALICE).firestore();
      const bob = env.authenticatedContext(BOB).firestore();

      await assertSucceeds(
        alice
          .collection(collection)
          .doc(ALICE)
          .set(periodDocSeed({ points: 30 }), { merge: true }),
      );

      // Bob writes his own row, so the cap is the only reason this is refused.
      await assertFails(
        bob
          .collection(collection)
          .doc(BOB)
          .set(periodDocSeed({ points: 101 }), { merge: true }),
      );

      assert.equal(await readDoc(env, collection, BOB), null);
    });
  });

  test(`${collection}: a stranger cannot write your row`, async () => {
    await withEnv(async (env) => {
      await seededPeriod(env, collection, ALICE, 20);
      const bob = env.authenticatedContext(BOB).firestore();

      await assertFails(
        bob
          .collection(collection)
          .doc(ALICE)
          .set({ points: 5000 }, { merge: true }),
      );

      assert.equal((await readDoc(env, collection, ALICE)).points, 20);
    });
  });

  test(`${collection}: the avatar mirror and its removal are allowed`, async () => {
    await withEnv(async (env) => {
      await seededPeriod(env, collection, ALICE, 20);
      const alice = env.authenticatedContext(ALICE).firestore();
      const doc = () => alice.collection(collection).doc(ALICE);

      await assertSucceeds(
        doc().set(mirrorAvatarPayload(CLOUDINARY_AVATAR), { merge: true }),
      );
      await assertSucceeds(doc().set(clearAvatarPayload(), { merge: true }));

      const stored = await readDoc(env, collection, ALICE);
      assert.equal('profileImageUrl' in stored, false);
      assert.equal(stored.points, 20);
    });
  });
}

// ---------------------------------------------------------------------------
// The transaction `LeaderboardService.addPoints` runs
// ---------------------------------------------------------------------------

/** Runs the client's `addPoints` shape: read three docs, write three docs. */
async function addPointsTransaction(db, uid, { award, lifetimeAward = award }) {
  const lifetime = db.collection(LIFETIME).doc(uid);
  const weekly = db.collection(WEEKLY).doc(uid);
  const monthly = db.collection(MONTHLY).doc(uid);

  await db.runTransaction(async (tx) => {
    const [lifetimeSnap, weeklySnap, monthlySnap] = await Promise.all([
      tx.get(lifetime),
      tx.get(weekly),
      tx.get(monthly),
    ]);

    const currentLifetime = lifetimeSnap.data()?.lifetimePoints ?? 0;
    const currentWeekly = weeklySnap.data()?.points ?? 0;
    const currentMonthly = monthlySnap.data()?.points ?? 0;

    tx.set(
      lifetime,
      {
        lifetimePoints: currentLifetime + lifetimeAward,
        pointsBreakdown: {
          ...(lifetimeSnap.data()?.pointsBreakdown ?? {}),
          'Wellbeing Activities': currentLifetime + lifetimeAward,
        },
        lastUpdated: new Date(),
        lastActiveAt: new Date(),
      },
      { merge: true },
    );
    tx.set(
      weekly,
      {
        points: currentWeekly + award,
        lastUpdated: new Date(),
        lastActiveAt: new Date(),
      },
      { merge: true },
    );
    tx.set(
      monthly,
      {
        points: currentMonthly + award,
        lastUpdated: new Date(),
        lastActiveAt: new Date(),
      },
      { merge: true },
    );
  });
}

test('the addPoints transaction lands on all three collections', async () => {
  await withEnv(async (env) => {
    await seededLifetime(env, ALICE, 0);
    await seededPeriod(env, WEEKLY, ALICE, 0);
    await seededPeriod(env, MONTHLY, ALICE, 0);

    const alice = env.authenticatedContext(ALICE).firestore();
    await assertSucceeds(addPointsTransaction(alice, ALICE, { award: 30 }));

    assert.equal((await readDoc(env, LIFETIME, ALICE)).lifetimePoints, 30);
    assert.equal((await readDoc(env, WEEKLY, ALICE)).points, 30);
    assert.equal((await readDoc(env, MONTHLY, ALICE)).points, 30);
  });
});

test('a refused write takes all three documents down with it', async () => {
  await withEnv(async (env) => {
    await seededLifetime(env, ALICE, 0);
    await seededPeriod(env, WEEKLY, ALICE, 0);
    await seededPeriod(env, MONTHLY, ALICE, 0);

    const alice = env.authenticatedContext(ALICE).firestore();

    // The lifetime jump is over the cap, so that one write is refused. The
    // weekly and monthly writes in the same transaction are individually
    // legal — which is exactly why the transaction's all-or-nothing behaviour
    // mattered when the lifetime rule was the broken one.
    await assertFails(
      addPointsTransaction(alice, ALICE, { award: 30, lifetimeAward: 5000 }),
    );

    assert.equal((await readDoc(env, LIFETIME, ALICE)).lifetimePoints, 0);
    assert.equal((await readDoc(env, WEEKLY, ALICE)).points, 0);
    assert.equal((await readDoc(env, MONTHLY, ALICE)).points, 0);
  });
});

// ---------------------------------------------------------------------------
// Reads
// ---------------------------------------------------------------------------

test('any signed-in user may read the board, and only signed-in users may', async () => {
  await withEnv(async (env) => {
    await seededLifetime(env, ALICE, 30);

    const bob = env.authenticatedContext(BOB).firestore();
    await assertSucceeds(bob.collection(LIFETIME).doc(ALICE).get());

    const anonymous = env.unauthenticatedContext().firestore();
    await assertFails(anonymous.collection(LIFETIME).doc(ALICE).get());
  });
});

test('an unauthenticated write is refused', async () => {
  await withEnv(async (env) => {
    const anonymous = env.unauthenticatedContext().firestore();

    await assertFails(
      anonymous
        .collection(LIFETIME)
        .doc(ALICE)
        .set({ lifetimePoints: 10 }, { merge: true }),
    );
  });
});
