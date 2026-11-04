// Runs firestore.rules against the local emulator with the reads, queries
// and writes the app makes. Each test names the Dart code it mirrors.
//
//   cd tool/firestore_rules && npm install && npm test

import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  addDoc,
  collection,
  deleteDoc,
  deleteField,
  doc,
  documentId,
  getDoc,
  getDocs,
  limit,
  orderBy,
  query,
  runTransaction,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
  where,
  writeBatch,
} from 'firebase/firestore';

const ALICE = 'alice';
const BOB = 'bob';
const CAROL = 'carol';

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-pairquest',
    firestore: {
      rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8'),
    },
  });
});

after(async () => {
  await testEnv?.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

const db = (uid) => testEnv.authenticatedContext(uid).firestore();
const guestDb = () => testEnv.unauthenticatedContext().firestore();

async function seed(docs) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const admin = context.firestore();
    for (const [path, data] of Object.entries(docs)) {
      await setDoc(doc(admin, path), data);
    }
  });
}

const inMinutes = (minutes) => Timestamp.fromMillis(Date.now() + minutes * 60_000);

const player = (uid) => ({
  oddserId: uid,
  displayName: uid,
  photoUrl: `https://photo/${uid}`,
  rating: 1200,
  score: 0,
});

// OnlineGame.toFirestore: games since playerIds was added.
const game = (...uids) => ({
  players: uids.map(player),
  playerIds: uids,
  status: 'inProgress',
  currentPlayerIndex: 0,
  moves: [],
  createdAt: Timestamp.fromMillis(Date.UTC(2026, 10, 1)),
});

// Games written by app versions before playerIds.
const oldGame = (...uids) => {
  const { playerIds, ...rest } = game(...uids);
  return rest;
};

// MatchmakingEntry.toFirestore
const queueEntry = (uid, expiresAt = inMinutes(1)) => ({
  oddserId: uid,
  displayName: uid,
  photoUrl: null,
  rating: 1200,
  status: 'waiting',
  ratingRadius: 100,
  createdAt: Timestamp.now(),
  expiresAt,
});

// GameInvitation.toFirestore
const invitation = (from, to, status = 'pending') => ({
  fromUserId: from,
  fromDisplayName: from,
  toUserId: to,
  level: 5,
  status,
  createdAt: Timestamp.now(),
  expiresAt: inMinutes(5),
});

// Friendship.toFirestore: user1Id sorts before user2Id.
const friendship = (requestedBy, other, status = 'pending') => {
  const [user1Id, user2Id] = [requestedBy, other].sort();
  return { user1Id, user2Id, requestedBy, status, createdAt: Timestamp.now() };
};

// LeaderboardRepository.submitScore
const score = (uid, value = 100) => ({
  userId: uid,
  playerName: uid,
  level: 3,
  score: value,
  stars: 3,
  moves: 10,
  timeSeconds: 30,
});

describe('users', () => {
  it('owner creates, updates and deletes the profile (getOrCreateProfile, deleteAccount)', async () => {
    const alice = db(ALICE);
    await assertSucceeds(setDoc(doc(alice, 'users/alice'), { displayName: 'Alice', rating: 1200 }));
    await assertSucceeds(updateDoc(doc(alice, 'users/alice'), { email: deleteField(), connectionStatus: 'online' }));
    await assertSucceeds(deleteDoc(doc(alice, 'users/alice')));
  });

  it('nobody writes another player\'s profile', async () => {
    await seed({ 'users/bob': { displayName: 'Bob', rating: 1200 } });
    await assertFails(updateDoc(doc(db(ALICE), 'users/bob'), { rating: 9999 }));
    await assertFails(setDoc(doc(db(ALICE), 'users/bob'), { displayName: 'x' }));
    await assertFails(deleteDoc(doc(db(ALICE), 'users/bob')));
  });

  it('signed-in players read profiles; signed-out cannot', async () => {
    await seed({ 'users/bob': { displayName: 'Bob', rating: 1200, connectionStatus: 'online' } });
    await assertSucceeds(getDoc(doc(db(ALICE), 'users/bob')));
    await assertFails(getDoc(doc(guestDb(), 'users/bob')));
  });

  it('allows the profile queries (friend search, rating leaderboard, friends leaderboard, online list)', async () => {
    await seed({
      'users/alice': { displayName: 'Alice', rating: 1300 },
      'users/bob': { displayName: 'Bob', rating: 1200, status: 'online' },
    });
    const users = collection(db(ALICE), 'users');
    await assertSucceeds(getDocs(query(users, where('displayName', '>=', 'B'), where('displayName', '<=', 'B'), limit(20))));
    await assertSucceeds(getDocs(query(users, orderBy('rating', 'desc'), limit(100))));
    await assertSucceeds(getDocs(query(users, where('rating', '>', 1200))));
    await assertSucceeds(getDocs(query(users, where('rating', '>=', 1000), where('rating', '<=', 1499))));
    await assertSucceeds(getDocs(query(users, where(documentId(), 'in', [ALICE, BOB]))));
    await assertSucceeds(getDocs(query(users, where('status', '==', 'online'))));
  });

  it('wallet and inventory are private to the owner (WalletSyncService)', async () => {
    await seed({ 'users/alice/data/wallet': { coins: 10 } });
    await assertSucceeds(getDoc(doc(db(ALICE), 'users/alice/data/wallet')));
    await assertSucceeds(setDoc(doc(db(ALICE), 'users/alice/data/inventory'), { hint: 2 }));
    await assertSucceeds(deleteDoc(doc(db(ALICE), 'users/alice/data/wallet')));
    await assertFails(getDoc(doc(db(BOB), 'users/alice/data/inventory')));
    await assertFails(setDoc(doc(db(BOB), 'users/alice/data/wallet'), { coins: 0 }));
  });
});

describe('games', () => {
  it('a player creates the game; an outsider cannot (_createMatchedGame, _createFriendGame)', async () => {
    await assertSucceeds(addDoc(collection(db(BOB), 'games'), game(ALICE, BOB)));
    await assertFails(addDoc(collection(db(CAROL), 'games'), game(ALICE, BOB)));
  });

  it('players read the game, old games included; an outsider cannot (watchGame)', async () => {
    await seed({ 'games/g1': game(ALICE, BOB), 'games/old': oldGame(ALICE, BOB) });
    await assertSucceeds(getDoc(doc(db(BOB), 'games/g1')));
    await assertSucceeds(getDoc(doc(db(BOB), 'games/old')));
    await assertFails(getDoc(doc(db(CAROL), 'games/g1')));
    await assertFails(getDoc(doc(db(CAROL), 'games/old')));
  });

  it('a player submits a move in a transaction (submitMove)', async () => {
    await seed({ 'games/g1': game(ALICE, BOB) });
    const alice = db(ALICE);
    await assertSucceeds(runTransaction(alice, async (tx) => {
      const ref = doc(alice, 'games/g1');
      const snapshot = await tx.get(ref);
      const players = snapshot.data().players;
      players[0] = { ...players[0], score: 10 };
      tx.update(ref, {
        players,
        moves: [{ oddserId: ALICE, matched: true }],
        currentPlayerIndex: 0,
        lastActivityAt: serverTimestamp(),
      });
    }));
  });

  it('players of an old game still update it', async () => {
    await seed({ 'games/old': oldGame(ALICE, BOB) });
    await assertSucceeds(updateDoc(doc(db(BOB), 'games/old'), { status: 'completed', winnerId: BOB }));
  });

  it('an outsider cannot update; nobody changes createdAt or deletes', async () => {
    await seed({ 'games/g1': game(ALICE, BOB) });
    await assertFails(updateDoc(doc(db(CAROL), 'games/g1'), { status: 'completed' }));
    await assertFails(updateDoc(doc(db(ALICE), 'games/g1'), { createdAt: Timestamp.now() }));
    await assertFails(deleteDoc(doc(db(ALICE), 'games/g1')));
  });

  it('a player finds their games by playerIds (AccountRepository._anonymizeGames)', async () => {
    await seed({ 'games/g1': game(ALICE, BOB), 'games/g2': game(BOB, CAROL) });
    const alice = db(ALICE);
    const games = await assertSucceeds(getDocs(query(collection(alice, 'games'), where('playerIds', 'array-contains', ALICE))));
    if (games.size !== 1) throw new Error(`expected 1 game, got ${games.size}`);
    await assertFails(getDocs(query(collection(db(CAROL), 'games'), where('playerIds', 'array-contains', ALICE))));
  });
});

describe('matchmaking', () => {
  it('a player joins the queue only as themselves (joinQueue)', async () => {
    await assertSucceeds(addDoc(collection(db(ALICE), 'matchmaking'), queueEntry(ALICE)));
    await assertFails(addDoc(collection(db(ALICE), 'matchmaking'), queueEntry(BOB)));
  });

  it('the matcher marks both entries and then adds the game ID (findMatch)', async () => {
    await seed({ 'matchmaking/qa': queueEntry(ALICE), 'matchmaking/qb': queueEntry(BOB) });
    const alice = db(ALICE);
    const candidates = await assertSucceeds(getDocs(query(collection(alice, 'matchmaking'), where('status', '==', 'waiting'), limit(20))));
    if (candidates.size !== 2) throw new Error(`expected 2 entries, got ${candidates.size}`);

    await assertSucceeds(runTransaction(alice, async (tx) => {
      await tx.get(doc(alice, 'matchmaking/qa'));
      await tx.get(doc(alice, 'matchmaking/qb'));
      tx.update(doc(alice, 'matchmaking/qa'), { status: 'matched', matchedOpponentId: BOB });
      tx.update(doc(alice, 'matchmaking/qb'), { status: 'matched', matchedOpponentId: ALICE });
    }));
    await assertSucceeds(runTransaction(alice, async (tx) => {
      tx.update(doc(alice, 'matchmaking/qa'), { matchedGameId: 'g1' });
      tx.update(doc(alice, 'matchmaking/qb'), { matchedGameId: 'g1' });
    }));
  });

  it('others cannot change any other field of an entry', async () => {
    await seed({ 'matchmaking/qb': queueEntry(BOB) });
    const carol = db(CAROL);
    await assertFails(updateDoc(doc(carol, 'matchmaking/qb'), { rating: 100 }));
    await assertFails(updateDoc(doc(carol, 'matchmaking/qb'), { status: 'matched', matchedOpponentId: ALICE }));
  });

  it('the owner widens the rating radius and leaves the queue (findMatch, leaveQueue)', async () => {
    await seed({ 'matchmaking/qa': queueEntry(ALICE) });
    await assertSucceeds(updateDoc(doc(db(ALICE), 'matchmaking/qa'), { ratingRadius: 200 }));
    await assertSucceeds(deleteDoc(doc(db(ALICE), 'matchmaking/qa')));
  });

  it('anyone removes stale entries, nobody removes live ones (cleanupExpiredEntries)', async () => {
    await seed({ 'matchmaking/old': queueEntry(BOB, inMinutes(-10)), 'matchmaking/live': queueEntry(BOB) });
    const carol = db(CAROL);
    const expired = await assertSucceeds(getDocs(query(collection(carol, 'matchmaking'), where('expiresAt', '<', inMinutes(-5)), limit(100))));
    if (expired.size !== 1) throw new Error(`expected 1 stale entry, got ${expired.size}`);
    for (const d of expired.docs) await assertSucceeds(deleteDoc(d.ref));
    await assertFails(deleteDoc(doc(carol, 'matchmaking/live')));
  });
});

describe('invitations', () => {
  it('a player sends invitations only as themselves (sendInvitation)', async () => {
    await assertSucceeds(addDoc(collection(db(ALICE), 'invitations'), invitation(ALICE, BOB)));
    await assertFails(addDoc(collection(db(ALICE), 'invitations'), invitation(BOB, CAROL)));
  });

  it('the sender cancels earlier pending invitations (cancelPendingInvitationsFromUser, cancelInvitation)', async () => {
    await seed({ 'invitations/i1': invitation(ALICE, BOB) });
    const alice = db(ALICE);
    const pending = await assertSucceeds(getDocs(query(collection(alice, 'invitations'), where('fromUserId', '==', ALICE), where('toUserId', '==', BOB))));
    const batch = writeBatch(alice);
    pending.docs.forEach((d) => batch.update(d.ref, { status: 'cancelled' }));
    await assertSucceeds(batch.commit());
  });

  it('the recipient lists and accepts; the sender watches (watchPendingInvitations, acceptInvitation, watchInvitation)', async () => {
    await seed({
      'invitations/i1': invitation(ALICE, BOB),
      'users/alice': { displayName: 'Alice', rating: 1200 },
      'users/bob': { displayName: 'Bob', rating: 1200 },
    });
    const bob = db(BOB);
    await assertSucceeds(getDocs(query(collection(bob, 'invitations'), where('toUserId', '==', BOB))));
    await assertSucceeds(runTransaction(bob, async (tx) => {
      const ref = doc(bob, 'invitations/i1');
      await tx.get(ref);
      tx.update(ref, { status: 'accepted', gameId: 'CREATING' });
    }));
    await assertSucceeds(getDoc(doc(bob, 'users/alice')));
    const created = await assertSucceeds(addDoc(collection(bob, 'games'), game(ALICE, BOB)));
    await assertSucceeds(updateDoc(doc(bob, 'invitations/i1'), { gameId: created.id }));
    await assertSucceeds(getDoc(doc(db(ALICE), 'invitations/i1')));
  });

  it('the recipient declines (declineInvitation)', async () => {
    await seed({ 'invitations/i1': invitation(ALICE, BOB) });
    await assertSucceeds(updateDoc(doc(db(BOB), 'invitations/i1'), { status: 'declined' }));
  });

  it('a watched invitation that no longer exists reads as missing', async () => {
    await assertSucceeds(getDoc(doc(db(ALICE), 'invitations/gone')));
  });

  it('an outsider cannot read, list, change or delete invitations', async () => {
    await seed({ 'invitations/i1': invitation(ALICE, BOB) });
    const carol = db(CAROL);
    await assertFails(getDoc(doc(carol, 'invitations/i1')));
    await assertFails(getDocs(query(collection(carol, 'invitations'), where('toUserId', '==', BOB))));
    await assertFails(updateDoc(doc(carol, 'invitations/i1'), { status: 'declined' }));
    await assertFails(deleteDoc(doc(carol, 'invitations/i1')));
  });
});

describe('friendships', () => {
  it('either player sends a request after checking for an existing one (sendFriendRequest, areFriendsOrPending)', async () => {
    for (const [from, to] of [[ALICE, BOB], [BOB, ALICE]]) {
      await testEnv.clearFirestore();
      const sender = db(from);
      const [user1Id, user2Id] = [from, to].sort();
      await assertSucceeds(getDocs(query(collection(sender, 'friendships'), where('user1Id', '==', user1Id), where('user2Id', '==', user2Id), limit(1))));
      await assertSucceeds(addDoc(collection(sender, 'friendships'), friendship(from, to)));
    }
  });

  it('nobody creates a request in someone else\'s name', async () => {
    await assertFails(addDoc(collection(db(CAROL), 'friendships'), friendship(ALICE, BOB)));
    await assertFails(addDoc(collection(db(ALICE), 'friendships'), friendship(BOB, ALICE)));
  });

  it('the other player accepts or declines (acceptFriendRequest, declineFriendRequest)', async () => {
    await seed({ 'friendships/f1': friendship(ALICE, BOB), 'friendships/f2': friendship(ALICE, CAROL) });
    await assertSucceeds(updateDoc(doc(db(BOB), 'friendships/f1'), { status: 'accepted', acceptedAt: serverTimestamp() }));
    await assertSucceeds(updateDoc(doc(db(CAROL), 'friendships/f2'), { status: 'declined' }));
  });

  it('both players list their friends and requests (watchFriends, watchPendingFriendRequests, friends leaderboard)', async () => {
    await seed({ 'friendships/f1': friendship(ALICE, BOB, 'accepted') });
    for (const uid of [ALICE, BOB]) {
      const friendships = collection(db(uid), 'friendships');
      for (const status of ['accepted', 'pending']) {
        await assertSucceeds(getDocs(query(friendships, where('user1Id', '==', uid), where('status', '==', status))));
        await assertSucceeds(getDocs(query(friendships, where('user2Id', '==', uid), where('status', '==', status))));
      }
    }
  });

  it('an outsider cannot read, list, change or delete a friendship', async () => {
    await seed({ 'friendships/f1': friendship(ALICE, BOB, 'accepted') });
    const carol = db(CAROL);
    await assertFails(getDoc(doc(carol, 'friendships/f1')));
    await assertFails(getDocs(query(collection(carol, 'friendships'), where('user1Id', '==', ALICE))));
    await assertFails(updateDoc(doc(carol, 'friendships/f1'), { status: 'blocked' }));
    await assertFails(deleteDoc(doc(carol, 'friendships/f1')));
  });

  it('either player removes the friend (removeFriend)', async () => {
    await seed({ 'friendships/f1': friendship(ALICE, BOB, 'accepted') });
    await assertSucceeds(deleteDoc(doc(db(BOB), 'friendships/f1')));
  });
});

describe('leaderboards', () => {
  const entries = (firestore) => collection(firestore, 'leaderboards/global/entries');

  it('a player submits and resubmits only their own scores (submitScore)', async () => {
    const alice = db(ALICE);
    await assertSucceeds(setDoc(doc(entries(alice), 's1'), { ...score(ALICE), playedAt: serverTimestamp() }));
    await assertSucceeds(setDoc(doc(entries(alice), 's1'), { ...score(ALICE, 200), playedAt: serverTimestamp() }));
    await assertFails(setDoc(doc(entries(alice), 's2'), score(BOB)));
    await assertFails(setDoc(doc(entries(db(BOB)), 's1'), score(BOB)));
  });

  it('allows the leaderboard queries (getTopScores, getUserBestScore, getUserRank)', async () => {
    await seed({ 'leaderboards/global/entries/s1': score(ALICE), 'leaderboards/global/entries/s2': score(BOB, 50) });
    const bob = db(BOB);
    await assertSucceeds(getDocs(query(entries(bob), orderBy('score', 'desc'), limit(50))));
    await assertSucceeds(getDocs(query(entries(bob), where('level', '==', 3), orderBy('score', 'desc'))));
    await assertSucceeds(getDocs(query(entries(bob), where('userId', '==', BOB), orderBy('score', 'desc'), limit(1))));
    await assertSucceeds(getDocs(query(entries(bob), where('score', '>', 50))));
    await assertFails(getDocs(query(entries(guestDb()), orderBy('score', 'desc'))));
  });

  it('a player keeps one best score per level under {uid}_{level} (submitScore)', async () => {
    const alice = db(ALICE);
    const ref = doc(entries(alice), 'alice_3');
    await assertSucceeds(runTransaction(alice, async (tx) => {
      await tx.get(ref);
      tx.set(ref, { ...score(ALICE, 100), playedAt: serverTimestamp() });
    }));
    await assertSucceeds(runTransaction(alice, async (tx) => {
      await tx.get(ref);
      tx.update(ref, { playerName: 'Alice' });
    }));
  });

  it('nobody takes another player\'s {uid}_{level} ID or files a score under the wrong level', async () => {
    await assertFails(setDoc(doc(entries(db(CAROL)), 'alice_3'), score(CAROL)));
    await assertFails(setDoc(doc(entries(db(ALICE)), 'alice_4'), score(ALICE)));
    await seed({ 'leaderboards/global/entries/alice_3': score(ALICE) });
    await assertFails(updateDoc(doc(entries(db(BOB)), 'alice_3'), { score: 1 }));
  });

  it('a player merges and renames their scores (migrateLegacyScores, renamePlayer)', async () => {
    await seed({
      'leaderboards/global/entries/old1': score(ALICE, 80),
      'leaderboards/global/entries/old2': score(ALICE, 120),
    });
    const alice = db(ALICE);
    const mine = await assertSucceeds(getDocs(query(entries(alice), where('userId', '==', ALICE))));
    const batch = writeBatch(alice);
    batch.set(doc(entries(alice), 'alice_3'), { ...score(ALICE, 120), playerName: 'Alice' });
    mine.docs.forEach((d) => batch.delete(d.ref));
    await assertSucceeds(batch.commit());
    await assertSucceeds(updateDoc(doc(entries(alice), 'alice_3'), { playerName: 'Alice 2' }));
  });

  it('only the owner deletes a score', async () => {
    await seed({ 'leaderboards/global/entries/s1': score(ALICE) });
    await assertFails(deleteDoc(doc(entries(db(BOB)), 's1')));
    await assertSucceeds(deleteDoc(doc(entries(db(ALICE)), 's1')));
  });
});

describe('rankings', () => {
  it('players read rankings; nobody writes them', async () => {
    await seed({ 'rankings/weekly/entries/alice': { rating: 1300 } });
    await assertSucceeds(getDoc(doc(db(BOB), 'rankings/weekly/entries/alice')));
    await assertFails(setDoc(doc(db(ALICE), 'rankings/weekly/entries/alice'), { rating: 9999 }));
  });
});

describe('moderation', () => {
  const report = (reporter, reported) => ({
    reporterId: reporter,
    reportedUserId: reported,
    reportedName: reported,
    reason: 'offensiveName',
    source: 'leaderboard',
    createdAt: serverTimestamp(),
  });

  it('a player reports another player, guests included (reportPlayer)', async () => {
    await assertSucceeds(addDoc(collection(db(ALICE), 'reports'), report(ALICE, BOB)));
  });

  it('nobody reports in someone else\'s name, reports themselves or adds fields', async () => {
    const alice = db(ALICE);
    await assertFails(addDoc(collection(alice, 'reports'), report(BOB, CAROL)));
    await assertFails(addDoc(collection(alice, 'reports'), report(ALICE, ALICE)));
    await assertFails(addDoc(collection(alice, 'reports'), { ...report(ALICE, BOB), status: 'resolved' }));
  });

  it('only the reporter reads or deletes a report; nobody edits it', async () => {
    await seed({ 'reports/r1': { reporterId: ALICE, reportedUserId: BOB, reason: 'other' } });
    await assertFails(getDoc(doc(db(BOB), 'reports/r1')));
    await assertFails(getDocs(query(collection(db(BOB), 'reports'), where('reportedUserId', '==', BOB))));
    await assertFails(updateDoc(doc(db(ALICE), 'reports/r1'), { reason: 'cheating' }));
    await assertSucceeds(getDoc(doc(db(ALICE), 'reports/r1')));
    await assertSucceeds(deleteDoc(doc(db(ALICE), 'reports/r1')));
  });

  it('blocking ends the friendship and declines invitations; the list is private (blockPlayer)', async () => {
    await seed({
      'friendships/f1': friendship(ALICE, BOB, 'accepted'),
      'invitations/i1': invitation(BOB, ALICE),
    });
    const alice = db(ALICE);
    await assertSucceeds(setDoc(doc(alice, 'users/alice/blocked/bob'), { displayName: 'bob', createdAt: serverTimestamp() }));
    const [user1Id, user2Id] = [ALICE, BOB].sort();
    const friendships = await assertSucceeds(getDocs(query(collection(alice, 'friendships'), where('user1Id', '==', user1Id), where('user2Id', '==', user2Id))));
    const invitations = await assertSucceeds(getDocs(query(collection(alice, 'invitations'), where('fromUserId', '==', BOB), where('toUserId', '==', ALICE))));
    const batch = writeBatch(alice);
    friendships.docs.forEach((d) => batch.delete(d.ref));
    invitations.docs.forEach((d) => batch.update(d.ref, { status: 'declined' }));
    await assertSucceeds(batch.commit());

    await assertFails(getDoc(doc(db(BOB), 'users/alice/blocked/bob')));
    await assertFails(setDoc(doc(db(BOB), 'users/alice/blocked/carol'), { displayName: 'carol' }));
    await assertSucceeds(getDocs(collection(alice, 'users/alice/blocked')));
    await assertSucceeds(deleteDoc(doc(alice, 'users/alice/blocked/bob')));
  });
});

describe('account deletion', () => {
  // The same reads and writes as AccountRepository.deleteUserData.
  it('removes every document of the user and keeps the other players\' documents', async () => {
    await seed({
      'users/alice': { displayName: 'Alice' },
      'users/alice/data/wallet': { coins: 10 },
      'users/alice/data/inventory': { hint: 2 },
      'users/bob': { displayName: 'Bob' },
      'friendships/f1': friendship(ALICE, BOB, 'accepted'),
      'friendships/f2': friendship(CAROL, ALICE),
      'friendships/f3': friendship(BOB, CAROL),
      'invitations/i1': invitation(ALICE, BOB),
      'invitations/i2': invitation(BOB, ALICE),
      'invitations/i3': invitation(BOB, CAROL),
      'matchmaking/qa': queueEntry(ALICE),
      'matchmaking/qb': queueEntry(BOB),
      'leaderboards/global/entries/s1': score(ALICE),
      'leaderboards/global/entries/s2': score(BOB),
      'games/g1': game(ALICE, BOB),
      'users/alice/blocked/carol': { displayName: 'carol' },
      'reports/r1': { reporterId: ALICE, reportedUserId: CAROL, reason: 'other' },
      'reports/r2': { reporterId: BOB, reportedUserId: ALICE, reason: 'other' },
    });
    const alice = db(ALICE);

    const games = await getDocs(query(collection(alice, 'games'), where('playerIds', 'array-contains', ALICE)));
    const anonymize = writeBatch(alice);
    for (const g of games.docs) {
      anonymize.update(g.ref, {
        players: g.data().players.map((p) => (p.oddserId === ALICE ? { ...p, displayName: 'Deleted player', photoUrl: null } : p)),
      });
    }
    await assertSucceeds(anonymize.commit());

    const refs = [doc(alice, 'users/alice/data/wallet'), doc(alice, 'users/alice/data/inventory')];
    for (const q of [
      collection(alice, 'users/alice/blocked'),
      query(collection(alice, 'friendships'), where('user1Id', '==', ALICE)),
      query(collection(alice, 'friendships'), where('user2Id', '==', ALICE)),
      query(collection(alice, 'invitations'), where('fromUserId', '==', ALICE)),
      query(collection(alice, 'invitations'), where('toUserId', '==', ALICE)),
      query(collection(alice, 'matchmaking'), where('oddserId', '==', ALICE)),
      query(collection(alice, 'reports'), where('reporterId', '==', ALICE)),
      query(collection(alice, 'leaderboards/global/entries'), where('userId', '==', ALICE)),
    ]) {
      const snapshot = await assertSucceeds(getDocs(q));
      refs.push(...snapshot.docs.map((d) => d.ref));
    }
    refs.push(doc(alice, 'users/alice'));
    const batch = writeBatch(alice);
    refs.forEach((ref) => batch.delete(ref));
    await assertSucceeds(batch.commit());

    await testEnv.withSecurityRulesDisabled(async (context) => {
      const admin = context.firestore();
      const exists = async (path) => (await getDoc(doc(admin, path))).exists();
      const gone = ['users/alice', 'users/alice/data/wallet', 'users/alice/data/inventory', 'friendships/f1',
        'friendships/f2', 'invitations/i1', 'invitations/i2', 'matchmaking/qa', 'leaderboards/global/entries/s1',
        'users/alice/blocked/carol', 'reports/r1'];
      const kept = ['users/bob', 'friendships/f3', 'invitations/i3', 'matchmaking/qb', 'leaderboards/global/entries/s2',
        'games/g1', 'reports/r2'];
      for (const path of gone) if (await exists(path)) throw new Error(`${path} was not deleted`);
      for (const path of kept) if (!(await exists(path))) throw new Error(`${path} was deleted`);
      const [me, opponent] = (await getDoc(doc(admin, 'games/g1'))).data().players;
      if (me.displayName !== 'Deleted player' || me.photoUrl !== null) throw new Error('game was not anonymized');
      if (opponent.displayName !== BOB) throw new Error('opponent changed');
    });
  });
});
