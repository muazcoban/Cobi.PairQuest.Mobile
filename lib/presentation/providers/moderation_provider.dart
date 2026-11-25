import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/moderation_repository.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  return ModerationRepository();
});

/// Players the user blocked.
final blockedPlayersProvider = StreamProvider.autoDispose
    .family<List<BlockedPlayer>, String>((ref, uid) {
  return ref.watch(moderationRepositoryProvider).watchBlockedPlayers(uid);
});

/// IDs of blocked players, to hide their requests and invitations and to
/// skip them in matchmaking.
final blockedUserIdsProvider =
    Provider.autoDispose.family<Set<String>, String>((ref, uid) {
  final blocked = ref.watch(blockedPlayersProvider(uid)).valueOrNull ?? const [];
  return BlockedIds([for (final player in blocked) player.userId]);
});

/// A read-only set of blocked IDs that equals another with the same IDs.
/// Riverpod tells dependents only about a value that is not equal to the
/// last one, so the invitation and friend-request listeners are not
/// re-subscribed each time the block list emits the same players.
class BlockedIds extends SetBase<String> {
  BlockedIds(Iterable<String> ids) : _ids = Set.unmodifiable(ids);

  final Set<String> _ids;

  @override
  bool add(String value) => throw UnsupportedError('BlockedIds is read-only');

  @override
  bool remove(Object? value) =>
      throw UnsupportedError('BlockedIds is read-only');

  @override
  bool contains(Object? element) => _ids.contains(element);

  @override
  String? lookup(Object? element) => _ids.lookup(element);

  @override
  Iterator<String> get iterator => _ids.iterator;

  @override
  int get length => _ids.length;

  @override
  Set<String> toSet() => _ids.toSet();

  @override
  bool operator ==(Object other) =>
      other is BlockedIds &&
      other.length == length &&
      _ids.containsAll(other._ids);

  @override
  int get hashCode => Object.hashAllUnordered(_ids);
}
