import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/data/repositories/leaderboard_repository.dart';
import 'package:pair_quest/domain/entities/leaderboard_entry.dart';

void main() {
  const entriesPath = 'leaderboards/global/entries';

  late FakeFirebaseFirestore firestore;
  late LeaderboardRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = LeaderboardRepository(firestore: firestore);
  });

  LeaderboardEntry game(int score, {int level = 3, String name = 'Ayşe'}) => LeaderboardEntry(
        id: 'local-$score',
        playerName: name,
        level: level,
        score: score,
        stars: 3,
        moves: 10,
        timeSeconds: 30,
        playedAt: DateTime(2026, 11, 4),
      );

  Future<Map<String, dynamic>?> stored(String id) async =>
      (await firestore.doc('$entriesPath/$id').get()).data();

  group('submitScore', () {
    test('keeps one document per player and level with the best score', () async {
      await repository.submitScore(entry: game(100), userId: 'me');
      await repository.submitScore(entry: game(250), userId: 'me');
      await repository.submitScore(entry: game(180), userId: 'me');

      final docs = await firestore.collection(entriesPath).get();
      expect(docs.docs.map((d) => d.id), ['me_3']);
      expect((await stored('me_3'))!['score'], 250);
    });

    test('a lower score still updates the name', () async {
      await repository.submitScore(entry: game(250, name: 'Oyuncu 4821'), userId: 'me');
      await repository.submitScore(entry: game(90, name: 'Ayşe'), userId: 'me');

      final doc = (await stored('me_3'))!;
      expect(doc['score'], 250);
      expect(doc['playerName'], 'Ayşe');
    });

    test('each level has its own best', () async {
      await repository.submitScore(entry: game(100, level: 1), userId: 'me');
      await repository.submitScore(entry: game(300, level: 2), userId: 'me');

      expect((await stored('me_1'))!['score'], 100);
      expect((await stored('me_2'))!['score'], 300);
    });
  });

  group('getTopScores', () {
    test('lists each player once, with their best score', () async {
      // As older app versions saved them: one document per game.
      for (final (id, user, score) in [
        ('a1', 'me', 500), ('a2', 'me', 450), ('a3', 'me', 400),
        ('b1', 'friend', 420), ('b2', 'friend', 300),
      ]) {
        await firestore.doc('$entriesPath/$id').set({
          'userId': user, 'playerName': 'Player', 'level': 3, 'score': score,
          'stars': 3, 'moves': 10, 'timeSeconds': 30,
        });
      }

      final top = await repository.getTopScores();

      expect(top.map((e) => (e.userId, e.score)), [('me', 500), ('friend', 420)]);
    });

    test('the level filter also lists each player once', () async {
      await repository.submitScore(entry: game(100, level: 2), userId: 'me');
      await repository.submitScore(entry: game(300, level: 3), userId: 'me');
      await repository.submitScore(entry: game(200, level: 3), userId: 'friend');

      final top = await repository.getTopScores(level: 3);

      expect(top.map((e) => (e.userId, e.score)), [('me', 300), ('friend', 200)]);
    });
  });

  test('migrateLegacyScores merges per-game documents into per-level bests', () async {
    for (final (id, level, score) in [('x1', 3, 120), ('x2', 3, 200), ('x3', 5, 90)]) {
      await firestore.doc('$entriesPath/$id').set({
        'userId': 'me', 'playerName': 'Player', 'level': level, 'score': score,
      });
    }
    await firestore.doc('$entriesPath/y1').set({'userId': 'friend', 'level': 3, 'score': 999});

    expect(await repository.migrateLegacyScores(userId: 'me', playerName: 'Ayşe'), isTrue);

    final docs = await firestore.collection(entriesPath).get();
    expect(docs.docs.map((d) => d.id).toSet(), {'me_3', 'me_5', 'y1'});
    expect((await stored('me_3'))!['score'], 200);
    expect((await stored('me_3'))!['playerName'], 'Ayşe');
    expect((await stored('me_5'))!['score'], 90);
  });

  test('renamePlayer renames every level of the player only', () async {
    await repository.submitScore(entry: game(100, level: 1, name: 'Player'), userId: 'me');
    await repository.submitScore(entry: game(200, level: 2, name: 'Player'), userId: 'me');
    await repository.submitScore(entry: game(300, level: 1, name: 'Player'), userId: 'friend');

    await repository.renamePlayer(userId: 'me', playerName: 'Ayşe');

    expect((await stored('me_1'))!['playerName'], 'Ayşe');
    expect((await stored('me_2'))!['playerName'], 'Ayşe');
    expect((await stored('friend_1'))!['playerName'], 'Player');
  });
}
