import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/online_player.dart';

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

/// Global leaderboard provider (top 100)
final globalLeaderboardProvider =
    StreamProvider<List<LeaderboardEntry>>((ref) async* {
  final firestore = FirebaseFirestore.instance;

  yield* firestore
      .collection('users')
      .orderBy('rating', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.asMap().entries.map((entry) {
      final index = entry.key;
      final doc = entry.value;
      final data = doc.data();

      return LeaderboardEntry(
        rank: index + 1,
        profile: OnlineUserProfile(
          oddserId: doc.id,
          displayName: data['displayName'] ?? 'Unknown',
          photoUrl: data['photoUrl'],
          email: data['email'],
          rating: data['rating'] ?? 1200,
          wins: data['wins'] ?? 0,
          losses: data['losses'] ?? 0,
          draws: data['draws'] ?? 0,
          totalGames: (data['wins'] ?? 0) + (data['losses'] ?? 0) + (data['draws'] ?? 0),
          status: ConnectionStatus.values.firstWhere(
            (s) => s.name == data['status'],
            orElse: () => ConnectionStatus.offline,
          ),
          lastSeenAt: (data['lastSeenAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        ),
      );
    }).toList();
  });
});

/// Friends leaderboard provider
final friendsLeaderboardProvider =
    StreamProvider.family<List<LeaderboardEntry>, String>((ref, userId) async* {
  final firestore = FirebaseFirestore.instance;

  // First get friend IDs
  final friendshipsSnapshot = await firestore
      .collection('friendships')
      .where('status', isEqualTo: 'accepted')
      .where('userIds', arrayContains: userId)
      .get();

  final friendIds = <String>{userId}; // Include self
  for (final doc in friendshipsSnapshot.docs) {
    final userIds = List<String>.from(doc.data()['userIds'] ?? []);
    friendIds.addAll(userIds);
  }

  if (friendIds.isEmpty) {
    yield [];
    return;
  }

  // Get friend profiles
  yield* firestore
      .collection('users')
      .where(FieldPath.documentId, whereIn: friendIds.toList())
      .snapshots()
      .map((snapshot) {
    final profiles = snapshot.docs.map((doc) {
      final data = doc.data();
      return OnlineUserProfile(
        oddserId: doc.id,
        displayName: data['displayName'] ?? 'Unknown',
        photoUrl: data['photoUrl'],
        email: data['email'],
        rating: data['rating'] ?? 1200,
        wins: data['wins'] ?? 0,
        losses: data['losses'] ?? 0,
        draws: data['draws'] ?? 0,
        totalGames: (data['wins'] ?? 0) + (data['losses'] ?? 0) + (data['draws'] ?? 0),
        status: ConnectionStatus.values.firstWhere(
          (s) => s.name == data['status'],
          orElse: () => ConnectionStatus.offline,
        ),
        lastSeenAt: (data['lastSeenAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();

    // Sort by rating
    profiles.sort((a, b) => b.rating.compareTo(a.rating));

    // Add ranks
    return profiles.asMap().entries.map((entry) {
      return LeaderboardEntry(
        rank: entry.key + 1,
        profile: entry.value,
        isCurrentUser: entry.value.oddserId == userId,
      );
    }).toList();
  });
});

/// Current user's rank provider
final currentUserRankProvider =
    FutureProvider.family<int?, String>((ref, userId) async {
  final firestore = FirebaseFirestore.instance;

  // Get user's rating
  final userDoc = await firestore.collection('users').doc(userId).get();
  if (!userDoc.exists) return null;

  final userRating = userDoc.data()?['rating'] ?? 1200;

  // Count users with higher rating
  final higherRatedCount = await firestore
      .collection('users')
      .where('rating', isGreaterThan: userRating)
      .count()
      .get();

  return (higherRatedCount.count ?? 0) + 1;
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

/// Total online players count
final totalOnlinePlayersProvider = StreamProvider<int>((ref) {
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('users')
      .where('connectionStatus', isEqualTo: 'online')
      .snapshots()
      .map((snapshot) => snapshot.size);
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
