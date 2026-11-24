import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/online_player.dart';
import '../../domain/services/online_ranking.dart';
import 'auth_provider.dart';

/// Leaderboard filter type
enum LeaderboardFilter {
  global,
  friends,
  weekly,
  monthly,
}

/// Player tier based on rating
enum PlayerTier {
  bronze(0, 999, 'Bronze', '🥉'),
  silver(1000, 1499, 'Silver', '🥈'),
  gold(1500, 1999, 'Gold', '🥇'),
  platinum(2000, 2499, 'Platinum', '💎'),
  diamond(2500, 2999, 'Diamond', '💠'),
  master(3000, 9999, 'Master', '👑');

  final int minRating;
  final int maxRating;
  final String name;
  final String emoji;

  const PlayerTier(this.minRating, this.maxRating, this.name, this.emoji);

  static PlayerTier fromRating(int rating) {
    for (final tier in PlayerTier.values) {
      if (rating >= tier.minRating && rating <= tier.maxRating) {
        return tier;
      }
    }
    return PlayerTier.bronze;
  }

  /// Progress to next tier (0.0 - 1.0)
  double progressToNext(int rating) {
    if (this == PlayerTier.master) return 1.0;
    final range = maxRating - minRating + 1;
    final progress = rating - minRating;
    return (progress / range).clamp(0.0, 1.0);
  }

  /// Rating needed for next tier
  int? get nextTierRating {
    if (this == PlayerTier.master) return null;
    return maxRating + 1;
  }
}

/// Leaderboard entry with rank
class LeaderboardEntry {
  final int rank;
  final OnlineUserProfile profile;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.profile,
    this.isCurrentUser = false,
  });
}

/// Profile fields as the ranking shows them.
OnlineUserProfile _profileFromData(String id, Map<String, dynamic> data) {
  int read(String key) => (data[key] as num?)?.toInt() ?? 0;
  return OnlineUserProfile(
    oddserId: id,
    displayName: data['displayName'] ?? 'Unknown',
    photoUrl: data['photoUrl'],
    rating: (data['rating'] as num?)?.toInt() ?? OnlineRanking.startRating,
    rankedWins: read('rankedWins'),
    rankedLosses: read('rankedLosses'),
    rankedGames: read('rankedGames'),
    casualWins: read('casualWins'),
    casualLosses: read('casualLosses'),
    casualGames: read('casualGames'),
    wins: read('wins'),
    losses: read('losses'),
    draws: read('draws'),
    totalGames: read('totalGames'),
    status: ConnectionStatus.values.firstWhere(
      (s) => s.name == data['status'],
      orElse: () => ConnectionStatus.offline,
    ),
    lastSeenAt: (data['lastSeenAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}

List<LeaderboardEntry> _entries(
  Iterable<OnlineUserProfile> profiles,
  String? currentUserId,
) =>
    [
      for (final ranked in OnlineRanking.rank(profiles))
        LeaderboardEntry(
          rank: ranked.rank,
          profile: ranked.profile,
          isCurrentUser: ranked.profile.oddserId == currentUserId,
        ),
    ];

/// How many players the global ranking lists.
const int globalLeaderboardSize = 100;

/// Global ranking: the players who have played at least one ranked game,
/// by rating. Every profile starts at 1200, so a list of all profiles put
/// players who never played a ranked game among (and above) real ones.
///
/// Read once per visit instead of listened to: every profile changes its
/// lastSeenAt each minute while its app is open, and a listener on the top
/// 100 is billed one read for each of those writes. Pull to refresh
/// invalidates it.
final globalLeaderboardProvider =
    FutureProvider.autoDispose<List<LeaderboardEntry>>((ref) async {
  final users = FirebaseFirestore.instance.collection('users');
  final uid = ref.watch(authProvider.select((s) => s.user?.uid));
  final byId = <String, Map<String, dynamic>>{};

  // Profiles flagged by this version (needs the isRanked + rating index).
  try {
    final flagged = await users
        .where('isRanked', isEqualTo: true)
        .orderBy('rating', descending: true)
        .limit(globalLeaderboardSize)
        .get();
    for (final doc in flagged.docs) {
      byId[doc.id] = doc.data();
    }
  } on FirebaseException catch (e) {
    debugPrint('Ranked index not available yet: ${e.code}');
  }

  // Players whose app has not set the flag yet (older versions): the top of
  // the rating order, keeping only those who played ranked.
  final byRating = await users
      .orderBy('rating', descending: true)
      .limit(globalLeaderboardSize * 3)
      .get();
  for (final doc in byRating.docs) {
    if (OnlineRanking.hasPlayedRanked(doc.data())) {
      byId.putIfAbsent(doc.id, () => doc.data());
    }
  }

  final entries = _entries(
    [for (final e in byId.entries) _profileFromData(e.key, e.value)],
    uid,
  );
  return entries.take(globalLeaderboardSize).toList();
});

/// Friends ranking: the player and up to 29 friends, by rating. Friends who
/// never played ranked are listed too (it is a short, personal list), below
/// the ranked ones only by rating.
final friendsLeaderboardProvider = FutureProvider.autoDispose
    .family<List<LeaderboardEntry>, String>((ref, userId) async {
  final firestore = FirebaseFirestore.instance;

  // A friendship stores its two users as user1Id and user2Id, so both sides
  // are queried (the rules allow only these queries).
  final friendships = firestore
      .collection('friendships')
      .where('status', isEqualTo: 'accepted');
  final friendshipSnapshots = await Future.wait([
    friendships.where('user1Id', isEqualTo: userId).get(),
    friendships.where('user2Id', isEqualTo: userId).get(),
  ]);

  final friendIds = <String>{userId}; // Include self
  for (final doc in friendshipSnapshots.expand((snapshot) => snapshot.docs)) {
    final data = doc.data();
    friendIds.addAll([data['user1Id'] as String, data['user2Id'] as String]);
  }

  final snapshot = await firestore
      .collection('users')
      // whereIn takes at most 30 values; self comes first in the set.
      .where(FieldPath.documentId, whereIn: friendIds.take(30).toList())
      .get();
  return _entries(
    [for (final doc in snapshot.docs) _profileFromData(doc.id, doc.data())],
    userId,
  );
});

/// The player's place on the global ranking, or null while they have not
/// played a ranked game ("unranked"). Ties share a rank, as in the list.
/// Auto-disposed, and invalidated after a recorded game, so it follows the
/// rating instead of keeping the number from the first visit.
final currentUserRankProvider =
    FutureProvider.autoDispose.family<int?, String>((ref, userId) async {
  final users = FirebaseFirestore.instance.collection('users');
  final userDoc = await users.doc(userId).get();
  final data = userDoc.data();
  if (data == null || !OnlineRanking.hasPlayedRanked(data)) return null;

  final board = await ref.watch(globalLeaderboardProvider.future);
  for (final entry in board) {
    if (entry.profile.oddserId == userId) return entry.rank;
  }

  // Below the listed players: count the ranked players above.
  final rating = (data['rating'] as num?)?.toInt() ?? OnlineRanking.startRating;
  try {
    final above = await users
        .where('isRanked', isEqualTo: true)
        .where('rating', isGreaterThan: rating)
        .count()
        .get();
    return (above.count ?? 0) + 1;
  } on FirebaseException catch (e) {
    debugPrint('Rank count not available: ${e.code}');
    return null;
  }
});

/// Tier distribution provider (for stats)
final tierDistributionProvider = FutureProvider<Map<PlayerTier, int>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  final distribution = <PlayerTier, int>{};

  for (final tier in PlayerTier.values) {
    final count = await firestore
        .collection('users')
        .where('rating', isGreaterThanOrEqualTo: tier.minRating)
        .where('rating', isLessThanOrEqualTo: tier.maxRating)
        .count()
        .get();

    distribution[tier] = count.count ?? 0;
  }

  return distribution;
});

/// Players online now, counted again every heartbeat.
///
/// An app refreshes lastSeenAt every minute while it is open, and an app
/// that was killed never writes "offline", so a recent lastSeenAt is what
/// counts. A count aggregation reads index entries instead of every recent
/// profile (one read per 1,000 entries).
final totalOnlinePlayersProvider = StreamProvider.autoDispose<int>((ref) async* {
  final users = FirebaseFirestore.instance.collection('users');
  while (true) {
    final cutoff = DateTime.now().subtract(OnlineUserProfile.onlineTimeout);
    final recent =
        users.where('lastSeenAt', isGreaterThan: Timestamp.fromDate(cutoff));
    try {
      // "online" and recent (status + lastSeenAt index).
      final count = await recent
          .where('status', isEqualTo: ConnectionStatus.online.name)
          .count()
          .get();
      yield count.count ?? 0;
    } on FirebaseException {
      try {
        // Without that index: recent only, which also counts players who
        // closed the app in the last few minutes.
        final count = await recent.count().get();
        yield count.count ?? 0;
      } on FirebaseException catch (e) {
        debugPrint('Online count failed: ${e.code}');
      }
    }
    await Future<void>.delayed(OnlineUserProfile.presenceHeartbeat);
  }
});

/// Selected leaderboard filter
final selectedLeaderboardFilterProvider =
    StateProvider<LeaderboardFilter>((ref) => LeaderboardFilter.global);

/// Player tier from rating provider
final playerTierProvider = Provider.family<PlayerTier, int>((ref, rating) {
  return PlayerTier.fromRating(rating);
});

/// Tier progress provider
final tierProgressProvider =
    Provider.family<double, int>((ref, rating) {
  final tier = PlayerTier.fromRating(rating);
  return tier.progressToNext(rating);
});

/// Rating to next tier provider
final ratingToNextTierProvider =
    Provider.family<int?, int>((ref, rating) {
  final tier = PlayerTier.fromRating(rating);
  final nextRating = tier.nextTierRating;
  if (nextRating == null) return null;
  return nextRating - rating;
});
