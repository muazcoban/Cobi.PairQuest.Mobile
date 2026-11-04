import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/moderation_repository.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  return ModerationRepository();
});

/// Players the user blocked.
final blockedPlayersProvider =
    StreamProvider.family<List<BlockedPlayer>, String>((ref, uid) {
  return ref.watch(moderationRepositoryProvider).watchBlockedPlayers(uid);
});

/// IDs of blocked players, to hide their requests and invitations and to
/// skip them in matchmaking.
final blockedUserIdsProvider = Provider.family<Set<String>, String>((ref, uid) {
  final blocked = ref.watch(blockedPlayersProvider(uid)).valueOrNull ?? const [];
  return {for (final player in blocked) player.userId};
});
