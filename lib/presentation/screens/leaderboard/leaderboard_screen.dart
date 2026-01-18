import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/leaderboard_entry.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/settings_provider.dart';

/// Local leaderboard screen
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  int? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allEntries = ref.watch(leaderboardProvider);
    final playerName = ref.watch(settingsProvider).playerName;

    // Filter by level if selected
    final entries = _selectedLevel == null
        ? allEntries.take(20).toList()
        : allEntries.where((e) => e.level == _selectedLevel).take(20).toList();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(l10n.leaderboard),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Level filter
          _buildLevelFilter(context, l10n),

          // Leaderboard content
          Expanded(
            child: entries.isEmpty
                ? _buildEmptyState(context, l10n)
                : _buildLeaderboard(context, l10n, entries, playerName),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelFilter(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterChip(
            label: l10n.allLevels,
            isSelected: _selectedLevel == null,
            onTap: () => setState(() => _selectedLevel = null),
          ),
          const SizedBox(width: 8),
          ...List.generate(10, (index) {
            final level = index + 1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: '${l10n.level} $level',
                isSelected: _selectedLevel == level,
                onTap: () => setState(() => _selectedLevel = level),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noScoresYet,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.playGamesToSeeScores,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(
    BuildContext context,
    AppLocalizations l10n,
    List<LeaderboardEntry> entries,
    String currentPlayerName,
  ) {
    return Column(
      children: [
        // Top 3 podium
        if (entries.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 2nd place
                if (entries.length >= 2)
                  _PodiumItem(
                    rank: 2,
                    entry: entries[1],
                    height: 80,
                    isCurrentPlayer: entries[1].playerName.toLowerCase() ==
                        currentPlayerName.toLowerCase(),
                  )
                else
                  const SizedBox(width: 100),

                const SizedBox(width: 8),

                // 1st place
                _PodiumItem(
                  rank: 1,
                  entry: entries[0],
                  height: 100,
                  isCurrentPlayer: entries[0].playerName.toLowerCase() ==
                      currentPlayerName.toLowerCase(),
                ),

                const SizedBox(width: 8),

                // 3rd place
                if (entries.length >= 3)
                  _PodiumItem(
                    rank: 3,
                    entry: entries[2],
                    height: 60,
                    isCurrentPlayer: entries[2].playerName.toLowerCase() ==
                        currentPlayerName.toLowerCase(),
                  )
                else
                  const SizedBox(width: 100),
              ],
            ),
          ),

        // Rest of the list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length > 3 ? entries.length - 3 : 0,
            itemBuilder: (context, index) {
              final entry = entries[index + 3];
              return _LeaderboardRow(
                rank: index + 4,
                entry: entry,
                isCurrentPlayer: entry.playerName.toLowerCase() ==
                    currentPlayerName.toLowerCase(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  final double height;
  final bool isCurrentPlayer;

  const _PodiumItem({
    required this.rank,
    required this.entry,
    required this.height,
    this.isCurrentPlayer = false,
  });

  Color get _medalColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey;
    }
  }

  IconData get _medalIcon {
    switch (rank) {
      case 1:
        return Icons.emoji_events_rounded;
      case 2:
        return Icons.workspace_premium_rounded;
      case 3:
        return Icons.military_tech_rounded;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Medal
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _medalColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _medalColor.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            _medalIcon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),

        // Name with "You" indicator
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              entry.playerName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isCurrentPlayer ? AppColors.accent : Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isCurrentPlayer) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.you,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),

        // Score
        Text(
          '${entry.score}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),

        // Podium block
        Container(
          width: 100,
          height: height,
          decoration: BoxDecoration(
            color: isCurrentPlayer
                ? AppColors.accent.withOpacity(0.3)
                : Colors.white.withOpacity(0.2),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            border: isCurrentPlayer
                ? Border.all(color: AppColors.accent, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  final bool isCurrentPlayer;

  const _LeaderboardRow({
    required this.rank,
    required this.entry,
    this.isCurrentPlayer = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? AppColors.accent.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentPlayer
            ? Border.all(color: AppColors.accent, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCurrentPlayer
                  ? AppColors.accent
                  : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isCurrentPlayer ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name and level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.playerName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isCurrentPlayer
                            ? AppColors.accent
                            : AppColors.textPrimary(context),
                      ),
                    ),
                    if (isCurrentPlayer) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.you,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${l10n.level} ${entry.level}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),

          // Stars
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return Icon(
                index < entry.stars
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: index < entry.stars ? AppColors.accent : Colors.grey.shade300,
                size: 18,
              );
            }),
          ),
          const SizedBox(width: 12),

          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.score}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCurrentPlayer ? AppColors.accent : AppColors.primary,
                ),
              ),
              Text(
                entry.formattedTime,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
