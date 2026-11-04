import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/core/services/wallet_sync_service.dart';
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
}
