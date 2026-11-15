import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/core/services/age_gate.dart';
import 'package:pair_quest/core/services/age_signals_service.dart';
import 'package:pair_quest/presentation/providers/age_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> container({String? answer, StoreAgeSignal? signal}) async {
    SharedPreferences.setMockInitialValues({if (answer != null) 'age_group': answer});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await c.read(ageGroupProvider.notifier).ready;
    c.read(storeAgeSignalProvider.notifier).state = signal;
    return c;
  }

  test('a store range replaces a missing answer, so no age screen is needed', () async {
    final c = await container(signal: const StoreAgeSignal(ageLower: 18));
    expect(c.read(effectiveAgeGroupProvider), AgeGroup.teenOrAdult);
    expect(c.read(onlineAllowedProvider), isTrue);
  });

  test('a store range under 13 turns an adult answer into child mode', () async {
    final c = await container(answer: 'teenOrAdult', signal: const StoreAgeSignal(ageLower: 0, ageUpper: 12));
    expect(c.read(onlineAllowedProvider), isFalse);
  });

  test('an unverified user in a state with a law gets child mode for the session', () async {
    final c = await container(answer: 'teenOrAdult', signal: const StoreAgeSignal(verificationRequired: true));
    expect(c.read(onlineAllowedProvider), isFalse);

    // Nothing from the store is written to disk: the answer is unchanged.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('age_group'), 'teenOrAdult');
  });

  test('a parent who has not approved the update keeps ads and purchases off', () async {
    for (final change in [SignificantChange.pending, SignificantChange.declined]) {
      final c = await container(
        answer: 'teenOrAdult',
        signal: StoreAgeSignal(ageLower: 13, ageUpper: 15, significantChange: change),
      );
      expect(c.read(parentApprovalPendingProvider), isTrue, reason: '$change');
    }
    final approved = await container(
      signal: const StoreAgeSignal(ageLower: 13, ageUpper: 15, significantChange: SignificantChange.approved),
    );
    expect(approved.read(parentApprovalPendingProvider), isFalse);
  });

  test('without a store signal only the answer counts', () async {
    final c = await container(answer: 'child');
    expect(c.read(effectiveAgeGroupProvider), AgeGroup.child);
    expect(c.read(parentApprovalPendingProvider), isFalse);
  });
}
