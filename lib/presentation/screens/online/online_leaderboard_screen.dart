import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/online_leaderboard_provider.dart';
import '../../providers/online_profile_provider.dart';

/// Online multiplayer leaderboard screen
class OnlineLeaderboardScreen extends ConsumerWidget {
  const OnlineLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedFilter = ref.watch(selectedLeaderboardFilterProvider);
    final userId = ref.watch(authProvider).user?.uid;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(l10n.onlineLeaderboard),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter tabs
          _buildFilterTabs(context, ref, l10n, selectedFilter),

          // Current user rank card
          if (userId != null) _buildCurrentUserCard(context, ref, l10n, userId),

          // Leaderboard list
          Expanded(
            child: _buildLeaderboardList(context, ref, l10n, selectedFilter, userId),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    LeaderboardFilter selected,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildFilterTab(
            context,
            ref,
            l10n.global,
            LeaderboardFilter.global,
            selected,
          ),
          _buildFilterTab(
            context,
            ref,
            l10n.friends,
            LeaderboardFilter.friends,
            selected,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(
    BuildContext context,
    WidgetRef ref,
    String label,
    LeaderboardFilter filter,
    LeaderboardFilter selected,
  ) {
    final isSelected = filter == selected;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(selectedLeaderboardFilterProvider.notifier).state = filter;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textSecondary(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentUserCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String userId,
  ) {
    final profileAsync = ref.watch(onlineProfileNotifierProvider);
    final rankAsync = ref.watch(currentUserRankProvider(userId));
    final onlineCountAsync = ref.watch(totalOnlinePlayersProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();

        final tier = PlayerTier.fromRating(profile.rating);
        final progress = tier.progressToNext(profile.rating);
        final ratingToNext = ref.watch(ratingToNextTierProvider(profile.rating));

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getTierColor(tier).withValues(alpha: 0.8),
                _getTierColor(tier),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _getTierColor(tier).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    backgroundImage: profile.photoUrl != null
                        ? NetworkImage(profile.photoUrl!)
                        : null,
                    child: profile.photoUrl == null
                        ? Text(
                            profile.displayName.isNotEmpty
                                ? profile.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              tier.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              profile.displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${tier.name} • ${profile.rating} Rating',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rank
                  rankAsync.when(
                    data: (rank) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '#$rank',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            l10n.yourRank,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (e, st) => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress to next tier
              if (ratingToNext != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tier.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '$ratingToNext ${l10n.pointsToNext}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      _getNextTierName(tier),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 6,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(l10n.wins, '${profile.wins}', Colors.green.shade300),
                  _buildStatItem(l10n.losses, '${profile.losses}', Colors.red.shade300),
                  _buildStatItem(
                    l10n.winRate,
                    '${profile.winRate.toStringAsFixed(0)}%',
                    Colors.amber.shade300,
                  ),
                  onlineCountAsync.when(
                    data: (count) => _buildStatItem(
                      l10n.onlineNow,
                      '$count',
                      Colors.cyan.shade300,
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (e, st) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    LeaderboardFilter filter,
    String? userId,
  ) {
    final leaderboardAsync = filter == LeaderboardFilter.friends && userId != null
        ? ref.watch(friendsLeaderboardProvider(userId))
        : ref.watch(globalLeaderboardProvider);

    return leaderboardAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.leaderboard_outlined,
                  size: 64,
                  color: AppColors.textSecondary(context),
                ),
                const SizedBox(height: 16),
                Text(
                  filter == LeaderboardFilter.friends
                      ? l10n.noFriendsOnLeaderboard
                      : l10n.noPlayersYet,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final isCurrentUser = entry.profile.oddserId == userId;

            return _LeaderboardTile(
              entry: entry,
              isCurrentUser: isCurrentUser,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text('${l10n.errorOccurred}: $e'),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(PlayerTier tier) {
    switch (tier) {
      case PlayerTier.bronze:
        return Colors.brown;
      case PlayerTier.silver:
        return Colors.blueGrey;
      case PlayerTier.gold:
        return Colors.amber.shade700;
      case PlayerTier.platinum:
        return Colors.cyan.shade700;
      case PlayerTier.diamond:
        return Colors.blue.shade700;
      case PlayerTier.master:
        return Colors.purple.shade700;
    }
  }

  String _getNextTierName(PlayerTier tier) {
    final index = PlayerTier.values.indexOf(tier);
    if (index < PlayerTier.values.length - 1) {
      return PlayerTier.values[index + 1].name;
    }
    return tier.name;
  }
}

/// Leaderboard entry tile
class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const _LeaderboardTile({
    required this.entry,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final tier = PlayerTier.fromRating(entry.profile.rating);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.cardBorder(context),
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rank
            SizedBox(
              width: 32,
              child: Text(
                _getRankDisplay(entry.rank),
                style: TextStyle(
                  fontSize: entry.rank <= 3 ? 20 : 16,
                  fontWeight: FontWeight.bold,
                  color: _getRankColor(entry.rank),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: _getTierColor(tier).withValues(alpha: 0.2),
              backgroundImage: entry.profile.photoUrl != null
                  ? NetworkImage(entry.profile.photoUrl!)
                  : null,
              child: entry.profile.photoUrl == null
                  ? Text(
                      entry.profile.displayName.isNotEmpty
                          ? entry.profile.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: _getTierColor(tier),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ],
        ),
        title: Row(
          children: [
            Text(
              tier.emoji,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                entry.profile.displayName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser
                      ? AppColors.primary
                      : AppColors.textPrimary(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(
              tier.name,
              style: TextStyle(
                fontSize: 12,
                color: _getTierColor(tier),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${entry.profile.wins}W - ${entry.profile.losses}L',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getTierColor(tier).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${entry.profile.rating}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getTierColor(tier),
            ),
          ),
        ),
      ),
    );
  }

  String _getRankDisplay(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade700;
      case 2:
        return Colors.grey.shade500;
      case 3:
        return Colors.brown.shade400;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getTierColor(PlayerTier tier) {
    switch (tier) {
      case PlayerTier.bronze:
        return Colors.brown;
      case PlayerTier.silver:
        return Colors.blueGrey;
      case PlayerTier.gold:
        return Colors.amber.shade700;
      case PlayerTier.platinum:
        return Colors.cyan.shade700;
      case PlayerTier.diamond:
        return Colors.blue.shade700;
      case PlayerTier.master:
        return Colors.purple.shade700;
    }
  }
}
