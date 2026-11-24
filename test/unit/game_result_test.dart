import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/data/repositories/online_game_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late OnlineGameRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = OnlineGameRepository(firestore: firestore);
  });

  Future<void> seedUser(String uid, {int rating = 1200, Map<String, dynamic>? extra}) =>
      firestore.doc('users/$uid').set({
        'displayName': uid,
        'rating': rating,
        'wins': 0,
        'losses': 0,
        'draws': 0,
        'totalGames': 0,
        'rankedGames': 0,
        'rankedWins': 0,
        'rankedLosses': 0,
        'casualGames': 0,
        'casualWins': 0,
        'casualLosses': 0,
        ...?extra,
      });

  Future<void> seedGame(
    String id, {
    String mode = 'ranked',
    String status = 'completed',
    String? winnerId = 'alice',
    int aliceRating = 1200,
    int bobRating = 1200,
    bool pending = true,
  }) =>
      firestore.doc('games/$id').set({
        'mode': mode,
        'status': status,
        if (winnerId != null) 'winnerId': winnerId,
        'playerIds': ['alice', 'bob'],
        'players': [
          {'oddserId': 'alice', 'displayName': 'alice', 'rating': aliceRating},
          {'oddserId': 'bob', 'displayName': 'bob', 'rating': bobRating},
        ],
        if (pending) 'statsPending': {'alice': true, 'bob': true},
      });

  Future<Map<String, dynamic>> user(String uid) async =>
      (await firestore.doc('users/$uid').get()).data()!;

  Future<Map<String, dynamic>> game(String id) async =>
      (await firestore.doc('games/$id').get()).data()!;

  group('applyGameResult', () {
    test('records a ranked win and loss with the same Elo change on both sides', () async {
      await seedUser('alice');
      await seedUser('bob');
      await seedGame('g1');

      expect(await repository.applyGameResult('g1', 'alice'), isTrue);
      expect(await repository.applyGameResult('g1', 'bob'), isTrue);

      final a = await user('alice');
      final b = await user('bob');
      expect(a['rating'], 1216);
      expect(b['rating'], 1184);
      expect([a['rankedWins'], a['rankedLosses'], a['rankedGames']], [1, 0, 1]);
      expect([b['rankedWins'], b['rankedLosses'], b['rankedGames']], [0, 1, 1]);
      expect(a['isRanked'], isTrue);
      expect(b['isRanked'], isTrue);
      expect([a['wins'], a['losses'], a['totalGames']], [1, 0, 1]);

      final g = await game('g1');
      expect(g['statsAppliedFor'], containsAll(['alice', 'bob']));
      expect((g['statsPending'] as Map?) ?? const {}, isEmpty);
    });

    test('applies a game once per player however often it is called', () async {
      await seedUser('alice');
      await seedGame('g1');

      expect(await repository.applyGameResult('g1', 'alice'), isTrue);
      expect(await repository.applyGameResult('g1', 'alice'), isFalse);
      expect(await repository.applyGameResult('g1', 'alice'), isFalse);

      final a = await user('alice');
      expect(a['rating'], 1216);
      expect(a['rankedGames'], 1);
      expect(a['totalGames'], 1);
    });

    test('adds the change to the current rating, not to the copy in the game', () async {
      // The game stored 1200 vs 1200, but alice already won another game.
      await seedUser('alice', rating: 1216);
      await seedGame('g2');

      await repository.applyGameResult('g2', 'alice');

      expect((await user('alice'))['rating'], 1232);
    });

    test('counts a draw and gives equal players no rating change', () async {
      await seedUser('alice', rating: 1300);
      await seedGame('g3', winnerId: null, aliceRating: 1300, bobRating: 1300);

      expect(await repository.applyGameResult('g3', 'alice'), isTrue);

      final a = await user('alice');
      expect(a['rating'], 1300);
      expect(a['draws'], 1);
      expect(a['totalGames'], 1);
      expect(a['rankedGames'], 1);
      expect([a['wins'], a['losses'], a['rankedWins'], a['rankedLosses']], [0, 0, 0, 0]);
    });

    test('casual games count wins and losses and leave the rating alone', () async {
      await seedUser('bob');
      await seedGame('g4', mode: 'casual');

      await repository.applyGameResult('g4', 'bob');

      final b = await user('bob');
      expect(b['rating'], 1200);
      expect([b['casualGames'], b['casualLosses'], b['losses']], [1, 1, 1]);
      expect(b['rankedGames'], 0);
      expect(b.containsKey('isRanked'), isFalse);
    });

    test('a forfeit counts like any finished game', () async {
      await seedUser('bob');
      await seedGame('g5', status: 'abandoned', winnerId: 'alice');

      expect(await repository.applyGameResult('g5', 'bob'), isTrue);
      expect((await user('bob'))['rating'], 1184);
    });

    test('an abandoned game that nobody won records nothing', () async {
      await seedUser('alice');
      await seedGame('g6', status: 'abandoned', winnerId: null);

      expect(await repository.applyGameResult('g6', 'alice'), isFalse);

      final a = await user('alice');
      expect(a['totalGames'], 0);
      expect((await game('g6'))['statsAppliedFor'], ['alice']);
    });

    test('a game that is still running records nothing', () async {
      await seedUser('alice');
      await seedGame('g7', status: 'inProgress', winnerId: null);

      expect(await repository.applyGameResult('g7', 'alice'), isFalse);
      expect((await user('alice'))['totalGames'], 0);
    });
  });

  group('applyPendingResults', () {
    test('records the games that ended while the app was away', () async {
      await seedUser('bob');
      await seedGame('g1');
      await seedGame('g2', mode: 'casual');
      await seedGame('old', pending: false); // ended before this version

      expect(await repository.applyPendingResults('bob'), 2);
      expect(await repository.applyPendingResults('bob'), 0);

      final b = await user('bob');
      expect(b['totalGames'], 2);
      expect(b['rankedLosses'], 1);
      expect(b['casualLosses'], 1);
    });
  });

  group('getOrCreateProfile', () {
    test('fills the ranked counters an old version left out', () async {
      await firestore.doc('users/carol').set({
        'displayName': 'carol',
        'rating': 1184,
        'totalGames': 14,
        'wins': 3,
        'losses': 11,
        'casualGames': 13,
        'casualWins': 3,
        'casualLosses': 10,
      });

      final profile =
          await repository.getOrCreateProfile('carol', displayName: 'carol');

      final c = await user('carol');
      expect([c['rankedGames'], c['rankedWins'], c['rankedLosses']], [1, 0, 1]);
      expect(c['isRanked'], isTrue);
      expect(profile.rankedLosses, 1);
    });
  });
}
