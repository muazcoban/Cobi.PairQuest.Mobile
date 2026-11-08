import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/data/repositories/online_game_repository.dart';
import 'package:pair_quest/domain/entities/online_player.dart';

void main() {
  final now = DateTime(2026, 11, 8, 12);

  OnlineUserProfile profile(ConnectionStatus status, Duration sinceSeen) =>
      OnlineUserProfile(
        oddserId: 'u1',
        displayName: 'Ayşe',
        status: status,
        createdAt: DateTime(2026, 1, 1),
        lastSeenAt: now.subtract(sinceSeen),
      );

  group('isOnlineAt', () {
    test('is true for an online status refreshed recently', () {
      expect(
        profile(
          ConnectionStatus.online,
          const Duration(minutes: 2),
        ).isOnlineAt(now),
        isTrue,
      );
    });

    test('is false for an online status the app stopped refreshing', () {
      // The app was killed and never wrote "offline".
      expect(
        profile(
          ConnectionStatus.online,
          const Duration(minutes: 3),
        ).isOnlineAt(now),
        isFalse,
      );
      expect(
        profile(
          ConnectionStatus.online,
          const Duration(days: 30),
        ).isOnlineAt(now),
        isFalse,
      );
    });

    test('is false for an offline status', () {
      expect(
        profile(ConnectionStatus.offline, Duration.zero).isOnlineAt(now),
        isFalse,
      );
    });
  });

  group('presence in Firestore', () {
    late FakeFirebaseFirestore firestore;
    late OnlineGameRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = OnlineGameRepository(firestore: firestore);
    });

    test('reads a profile whose server timestamps are still pending', () async {
      await firestore.doc('users/u1').set({
        'displayName': 'Ayşe',
        'status': 'online',
        'createdAt': null,
        'lastSeenAt': null,
      });

      final doc = await firestore.doc('users/u1').get();
      final read = OnlineUserProfile.fromFirestore(doc);

      expect(read.displayName, 'Ayşe');
      expect(read.isOnlineAt(DateTime.now()), isTrue);
    });

    test('a heartbeat keeps the current game', () async {
      await firestore.doc('users/u1').set({
        'displayName': 'Ayşe',
        'status': 'online',
        'currentGameId': 'g1',
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
        'lastSeenAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });

      await repository.updatePresence('u1', ConnectionStatus.offline);

      final data = (await firestore.doc('users/u1').get()).data()!;
      expect(data['status'], 'offline');
      expect(data['currentGameId'], 'g1');
      expect(
        (data['lastSeenAt'] as Timestamp).toDate(),
        isNot(DateTime(2026, 1, 1)),
      );
    });
  });
}
