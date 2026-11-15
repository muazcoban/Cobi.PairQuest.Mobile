import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/age_gate.dart';

/// The player's age group from the one-time age screen; null until it has
/// been answered. Screens treat null like a child, so nothing that needs an
/// account shows before the answer.
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

/// True when account and online features are open: 13 or older.
final onlineAllowedProvider = Provider<bool>(
  (ref) => ref.watch(ageGroupProvider) == AgeGroup.teenOrAdult,
);
