import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/matchmaking_repository.dart';
import '../../domain/entities/matchmaking.dart';
import 'matchmaking_provider.dart';

/// Watch user's accepted friends
final friendsListProvider =
    StreamProvider.family<List<Friendship>, String>((ref, oddserId) {
  final repository = ref.watch(matchmakingRepositoryProvider);
  return repository.watchFriends(oddserId);
});

/// Watch pending friend requests (incoming)
final pendingFriendRequestsProvider =
    StreamProvider.family<List<Friendship>, String>((ref, oddserId) {
  final repository = ref.watch(matchmakingRepositoryProvider);
  return repository.watchPendingFriendRequests(oddserId);
});

/// Friends actions notifier
class FriendsNotifier extends StateNotifier<AsyncValue<void>> {
  final MatchmakingRepository _repository;

  FriendsNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Send friend request
  Future<String?> sendFriendRequest({
    required String fromUserId,
    required String toUserId,
    String? fromDisplayName,
    String? toDisplayName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final friendshipId = await _repository.sendFriendRequest(
        fromUserId: fromUserId,
        toUserId: toUserId,
        fromDisplayName: fromDisplayName,
        toDisplayName: toDisplayName,
      );
      state = const AsyncValue.data(null);
      return friendshipId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Accept friend request
  Future<void> acceptFriendRequest(String friendshipId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.acceptFriendRequest(friendshipId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Decline friend request
  Future<void> declineFriendRequest(String friendshipId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.declineFriendRequest(friendshipId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Remove friend
  Future<void> removeFriend(String friendshipId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.removeFriend(friendshipId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final friendsNotifierProvider =
    StateNotifierProvider<FriendsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(matchmakingRepositoryProvider);
  return FriendsNotifier(repository);
});

/// Get friend's user ID from friendship
extension FriendshipExtension on Friendship {
  /// Get the other user's ID (not the current user)
  String getFriendId(String currentUserId) {
    return user1Id == currentUserId ? user2Id : user1Id;
  }
}

/// Friends count provider
final friendsCountProvider = Provider.family<int, String>((ref, oddserId) {
  final friendsAsync = ref.watch(friendsListProvider(oddserId));
  return friendsAsync.valueOrNull?.length ?? 0;
});

/// Pending requests count provider
final pendingRequestsCountProvider = Provider.family<int, String>((ref, oddserId) {
  final requestsAsync = ref.watch(pendingFriendRequestsProvider(oddserId));
  return requestsAsync.valueOrNull?.length ?? 0;
});

/// Check if two users are friends
final areFriendsProvider =
    Provider.family<bool, (String, String)>((ref, userIds) {
  final (currentUserId, otherUserId) = userIds;
  final friendsAsync = ref.watch(friendsListProvider(currentUserId));

  final friends = friendsAsync.valueOrNull ?? [];
  return friends.any((f) =>
      (f.user1Id == currentUserId && f.user2Id == otherUserId) ||
      (f.user1Id == otherUserId && f.user2Id == currentUserId));
});

/// Check if friend request is pending
final friendRequestPendingProvider =
    Provider.family<bool, (String, String)>((ref, userIds) {
  final (currentUserId, otherUserId) = userIds;
  final requestsAsync = ref.watch(pendingFriendRequestsProvider(currentUserId));

  final requests = requestsAsync.valueOrNull ?? [];
  return requests.any((f) =>
      (f.user1Id == currentUserId && f.user2Id == otherUserId) ||
      (f.user1Id == otherUserId && f.user2Id == currentUserId));
});

/// Online friends (friends who are currently online)
/// Note: This requires fetching user profiles for each friend
/// In production, you might want to use a more efficient approach
final onlineFriendsProvider =
    FutureProvider.family<List<String>, String>((ref, oddserId) async {
  final friendsAsync = ref.watch(friendsListProvider(oddserId));
  final friends = friendsAsync.valueOrNull ?? [];

  // For now, return all friend IDs
  // In production, filter by online status from user profiles
  return friends.map((f) => f.getFriendId(oddserId)).toList();
});
