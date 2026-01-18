import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/stats_provider.dart';

/// Statistics screen showing player achievements and progress
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stats = ref.watch(statsProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(l10n.statistics),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview section
            _buildSectionTitle(context, l10n.overview),
            const SizedBox(height: 12),
            _buildOverviewCards(context, l10n, stats),
            const SizedBox(height: 24),

            // Performance section
            _buildSectionTitle(context, l10n.performance),
            const SizedBox(height: 12),
            _buildPerformanceCards(context, l10n, stats),
            const SizedBox(height: 24),

            // Records section
            _buildSectionTitle(context, l10n.records),
            const SizedBox(height: 12),
            _buildRecordsCards(context, l10n, stats),
            const SizedBox(height: 24),

            // Progress section
            _buildSectionTitle(context, l10n.progress),
            const SizedBox(height: 12),
            _buildProgressCard(context, l10n, stats),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary(context),
      ),
    );
  }

  Widget _buildOverviewCards(
      BuildContext context, AppLocalizations l10n, stats) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.videogame_asset_rounded,
            iconColor: AppColors.primary,
            label: l10n.totalGames,
            value: '${stats.totalGamesPlayed}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.emoji_events_rounded,
            iconColor: AppColors.accent,
            label: l10n.gamesWon,
            value: '${stats.totalGamesWon}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_rounded,
            iconColor: AppColors.info,
            label: l10n.playTime,
            value: stats.formattedPlayTime,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCards(
      BuildContext context, AppLocalizations l10n, stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.percent_rounded,
                iconColor: AppColors.success,
                label: l10n.winRate,
                value: '${stats.winRate.toStringAsFixed(1)}%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.touch_app_rounded,
                iconColor: AppColors.warning,
                label: l10n.avgMoves,
                value: stats.avgMovesPerGame.toStringAsFixed(1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.join_full_rounded,
                iconColor: AppColors.primary,
                label: l10n.totalMatches,
                value: '${stats.totalMatchesMade}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.star_rounded,
                iconColor: AppColors.accent,
                label: l10n.starsEarned,
                value: '${stats.totalStarsEarned}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecordsCards(
      BuildContext context, AppLocalizations l10n, stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department_rounded,
                iconColor: AppColors.error,
                label: l10n.highestCombo,
                value: '${stats.highestCombo}x',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.whatshot_rounded,
                iconColor: AppColors.warning,
                label: l10n.longestStreak,
                value: '${stats.longestStreak}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.workspace_premium_rounded,
                iconColor: AppColors.success,
                label: l10n.perfectGames,
                value: '${stats.perfectGames}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.grade_rounded,
                iconColor: AppColors.accent,
                label: l10n.threeStarLevels,
                value: '${stats.levelsWithThreeStars}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressCard(
      BuildContext context, AppLocalizations l10n, stats) {
    final highestLevel = stats.highestLevelCompleted;
    final progress = highestLevel / 10;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.levelProgress,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$highestLevel / 10',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(10, (index) {
              final level = index + 1;
              final levelStats = stats.levelStats[level];
              final isCompleted = levelStats?.completed ?? false;
              final stars = levelStats?.bestStars ?? 0;

              return Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$level',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (starIndex) {
                      return Icon(
                        starIndex < stars
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 8,
                        color: starIndex < stars
                            ? AppColors.accent
                            : Colors.grey.shade300,
                      );
                    }),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Individual stat card widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
