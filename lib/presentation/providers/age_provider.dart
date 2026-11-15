import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/age_gate.dart';
import '../../core/services/age_signals_service.dart';

/// The player's answer on the one-time age screen; null until answered.
/// This is the only age data the app stores, and only as a group.
class AgeGroupNotifier extends StateNotifier<AgeGroup?> {
  AgeGroupNotifier() : super(null) {
    _ready = _load();
  }

  static const _key = 'age_group';

  late final Future<void> _ready;

  /// Completes once the stored answer, if any, is loaded.
  Future<void> get ready => _ready;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    final group = AgeGroup.values.where((g) => g.name == stored).firstOrNull;
    if (mounted && group != null) state = group;
  }

  /// Stores the answer. It is asked once: there is no way to change it in
  /// the app, so a child cannot go back and pick another year.
  Future<void> answer(AgeGroup group) async {
    await _ready;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, group.name);
    if (mounted) state = group;
  }
}

final ageGroupProvider = StateNotifierProvider<AgeGroupNotifier, AgeGroup?>(
  (ref) => AgeGroupNotifier(),
);

/// The app store's age signal for this session (Google Play Age Signals),
/// read at start. Kept in memory only: Texas SB 2420 and Google Play allow
/// it for age restrictions alone and ask for its deletion after use.
final storeAgeSignalProvider = StateProvider<StoreAgeSignal?>((ref) => null);

/// The app store's age signal source; tests override it.
final ageSignalsSourceProvider = Provider<AgeSignalsSource>(
  (ref) => const PlatformAgeSignals(),
);

/// The age group the app acts on: the player's answer and the store's
/// signal combined, the stricter one winning. Null means unknown, which
/// every screen treats like a child.
final effectiveAgeGroupProvider = Provider<AgeGroup?>((ref) {
  final signal = ref.watch(storeAgeSignalProvider);
  final store = signal == null
      ? null
      : AgeGate.groupForStoreRange(
          ageLower: signal.ageLower,
          ageUpper: signal.ageUpper,
          verificationRequired: signal.verificationRequired,
        );
  return AgeGate.combine(stored: ref.watch(ageGroupProvider), store: store);
});

/// True when account and online features are open: 13 or older.
final onlineAllowedProvider = Provider<bool>(
  (ref) => ref.watch(effectiveAgeGroupProvider) == AgeGroup.teenOrAdult,
);

/// A parent has not approved the app's latest significant change (Texas
/// SB 2420): the features it added, ads and purchases, stay off.
final parentApprovalPendingProvider = Provider<bool>(
  (ref) => ref.watch(storeAgeSignalProvider)?.awaitsParentApproval ?? false,
);
