import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/data/repositories/account_repository.dart';
import 'package:pair_quest/domain/entities/online_game.dart';
import 'package:pair_quest/domain/entities/online_player.dart';

void main() {
  const me = 'me';
  const friend = 'friend';

  late FakeFirebaseFirestore firestore;
  late AccountRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = AccountRepository(firestore: firestore);
  });

  Future<bool> exists(String path) async =>
      (await firestore.doc(path).get()).exists;

  group('AccountRepository.deleteUserData', () {
    test('deletes every document of the user and keeps the friend\'s', () async {
      await firestore.doc('users/$me').set({'displayName': 'Me'});
      await firestore.doc('users/$me/data/wallet').set({'coins': 10});
      await firestore.doc('users/$me/data/inventory').set({'hint': 2});
      await firestore.doc('users/$me/blocked/troll').set({'displayName': 'Troll'});
      await firestore.doc('reports/r1').set({'reporterId': me, 'reportedUserId': 'troll'});
      await firestore.doc('reports/r2').set({'reporterId': friend, 'reportedUserId': me});
      await firestore.doc('users/$friend').set({'displayName': 'Friend'});
      await firestore.doc('users/$friend/data/wallet').set({'coins': 5});

      await firestore.doc('friendships/f1').set({'user1Id': friend, 'user2Id': me});
      await firestore.doc('friendships/f2').set({'user1Id': me, 'user2Id': 'other'});
      await firestore.doc('friendships/f3').set({'user1Id': friend, 'user2Id': 'other'});
      await firestore.doc('invitations/i1').set({'fromUserId': me, 'toUserId': friend});
      await firestore.doc('invitations/i2').set({'fromUserId': friend, 'toUserId': me});
      await firestore.doc('invitations/i3').set({'fromUserId': friend, 'toUserId': 'other'});
      await firestore.doc('matchmaking/q1').set({'oddserId': me});
      await firestore.doc('matchmaking/q2').set({'oddserId': friend});
      await firestore.doc('leaderboards/global/entries/s1').set({'userId': me});
      await firestore.doc('leaderboards/global/entries/s2').set({'userId': friend});

      await repository.deleteUserData(me);

      for (final path in [
        'users/$me',
        'users/$me/data/wallet',
        'users/$me/data/inventory',
        'users/$me/blocked/troll',
        'reports/r1',
        'friendships/f1',
        'friendships/f2',
        'invitations/i1',
        'invitations/i2',
        'matchmaking/q1',
        'leaderboards/global/entries/s1',
      ]) {
        expect(await exists(path), isFalse, reason: path);
      }
      for (final path in [
        'users/$friend',
        'users/$friend/data/wallet',
        'reports/r2',
        'friendships/f3',
        'invitations/i3',
        'matchmaking/q2',
        'leaderboards/global/entries/s2',
      ]) {
        expect(await exists(path), isTrue, reason: path);
      }
    });

    test('keeps games for the opponent but removes the name and photo', () async {
      await firestore.doc('games/g1').set({
        'playerIds': [me, friend],
        'players': [
          {'oddserId': me, 'displayName': 'Me', 'photoUrl': 'https://photo/me', 'score': 4},
          {'oddserId': friend, 'displayName': 'Friend', 'photoUrl': 'https://photo/f', 'score': 2},
        ],
      });

      await repository.deleteUserData(me);

      final game = (await firestore.doc('games/g1').get()).data()!;
      final players = [
        for (final player in game['players'] as List) Map<String, dynamic>.from(player as Map),
      ];
      expect(players[0]['oddserId'], me);
      expect(players[0]['displayName'], AccountRepository.deletedPlayerName);
      expect(players[0]['photoUrl'], isNull);
      expect(players[0]['score'], 4);
      expect(players[1]['displayName'], 'Friend');
      expect(players[1]['photoUrl'], 'https://photo/f');
    });

    test('deletes more documents than one batch holds', () async {
      for (var i = 0; i < 620; i++) {
        await firestore.doc('leaderboards/global/entries/s$i').set({'userId': me});
      }

      await repository.deleteUserData(me);

      final left = await firestore.collection('leaderboards/global/entries').get();
      expect(left.docs, isEmpty);
    });
  });

  group('what the app writes to Firestore', () {
    test('a profile never carries an e-mail address', () {
      final profile = OnlineUserProfile(
        oddserId: me,
        displayName: 'Me',
        email: 'me@example.com',
        createdAt: DateTime(2026),
        lastSeenAt: DateTime(2026),
      );

      expect(profile.toFirestore().containsKey('email'), isFalse);
    });

    test('a game lists its player IDs for account deletion', () {
      OnlinePlayer player(String id) => OnlinePlayer(
            oddserId: id,
            displayName: id,
            lastActivityAt: DateTime(2026),
          );
      final game = OnlineGame(
        id: 'g1',
        level: 1,
        rows: 2,
        cols: 2,
        players: [player(me), player(friend)],
        createdAt: DateTime(2026),
      );

      expect(game.toFirestore()['playerIds'], [me, friend]);
    });
  });
}
