import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/core/services/wallet_sync_service.dart';
import 'package:pair_quest/domain/entities/currency.dart';
import 'package:pair_quest/domain/entities/power_up.dart';

void main() {
  test('a used-up power-up is saved to the cloud as zero', () {
    final inventory = const PowerUpInventory()
        .add(PowerUpType.peek, 1)
        .add(PowerUpType.hint, 2)
        .use(PowerUpType.peek)!;

    final saved = WalletSyncService.cloudQuantities(inventory);

    // Saved with merge: a missing key would keep the old cloud count of 1
    expect(saved['peek'], 0);
    expect(saved['hint'], 2);
    expect(saved.keys.toSet(), PowerUpType.values.map((t) => t.name).toSet());
  });

  group('sync', () {
    const uid = 'me';
    late FakeFirebaseFirestore firestore;
    late WalletSyncService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = WalletSyncService(firestore: firestore, signedInUserId: () => uid);
    });

    test('a new account receives the guest wallet', () async {
      final synced = await service.syncWallet(const PlayerWallet(coins: 40, gems: 2));

      expect(synced.coins, 40);
      final cloud = (await firestore.doc('users/$uid/data/wallet').get()).data()!;
      expect(cloud['coins'], 40);
      expect(cloud['gems'], 2);
    });

    test('the cloud wallet wins, so spending on another device stays spent', () async {
      await firestore.doc('users/$uid/data/wallet').set({'coins': 30, 'gems': 1});

      final synced = await service.syncWallet(const PlayerWallet(coins: 100, gems: 5));

      expect(synced.coins, 30);
      expect(synced.gems, 1);
      final cloud = (await firestore.doc('users/$uid/data/wallet').get()).data()!;
      expect(cloud['coins'], 30);
    });

    test('a guest keeps the local wallet and writes nothing', () async {
      final guest = WalletSyncService(firestore: firestore, signedInUserId: () => null);

      final synced = await guest.syncWallet(const PlayerWallet(coins: 7));

      expect(synced.coins, 7);
      expect((await firestore.collection('users').get()).docs, isEmpty);
    });

    test('the cloud inventory wins, used-up power-ups included', () async {
      await firestore.doc('users/$uid/data/inventory').set({
        'quantities': {'peek': 0, 'hint': 1},
      });

      final synced = await service.syncInventory(
        const PowerUpInventory().add(PowerUpType.peek, 3).add(PowerUpType.hint, 3),
      );

      expect(synced.getQuantity(PowerUpType.peek), 0);
      expect(synced.getQuantity(PowerUpType.hint), 1);
    });

    test('a new account receives the guest inventory', () async {
      final synced = await service.syncInventory(
        const PowerUpInventory().add(PowerUpType.freeze, 2),
      );

      expect(synced.getQuantity(PowerUpType.freeze), 2);
      final cloud = (await firestore.doc('users/$uid/data/inventory').get()).data()!;
      expect((cloud['quantities'] as Map)['freeze'], 2);
    });
  });
}
