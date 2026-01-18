import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/daily_quest.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/daily_quest_provider.dart';

/// Daily quests screen
class DailyQuestsScreen extends ConsumerWidget {
  const DailyQuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final questData = ref.watch(dailyQuestProvider);
    ref.watch(dailyQuestProvider.notifier).checkAndRefresh();

    final completedCount = questData.completedCount;
    final totalCount = questData.totalCount;
    final timeUntilRefresh = questData.timeUntilRefresh;
    final hours = timeUntilRefresh.inHours;
    final minutes = timeUntilRefresh.inMinutes % 60;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(l10n.dailyQuests),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.today_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.questsCompleted(completedCount, totalCount),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.questRefresh(hours, minutes),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Quest list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: questData.quests.length,
              itemBuilder: (context, index) {
                final quest = questData.quests[index];
                final progress = questData.progress[quest.id] ??
                    QuestProgress(questId: quest.id);

                return _QuestCard(
                  quest: quest,
                  progress: progress,
                  onClaimReward: () {
                    final points = ref
                        .read(dailyQuestProvider.notifier)
                        .claimReward(quest.id);
                    if (points > 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('+$points points!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  final DailyQuest quest;
  final QuestProgress progress;
  final VoidCallback onClaimReward;

  const _QuestCard({
    required this.quest,
    required this.progress,
    required this.onClaimReward,
  });

  String _getTitle() {
    final titles = {
      'play_1': 'Play a Game',
      'play_3': 'Play 3 Games',
      'win_2': 'Win 2 Games',
      'win_5': 'Win 5 Games',
      'matches_10': 'Make 10 Matches',
      'matches_30': 'Make 30 Matches',
      'combo_3': 'Get 3x Combo',
      'combo_5': 'Get 5x Combo',
      'perfect_1': 'Perfect Game',
      'stars_3': 'Earn 3 Stars',
      'stars_6': 'Earn 6 Stars',
    };
    return titles[quest.id] ?? quest.id;
  }

  String _getDescription() {
    final descriptions = {
      'play_1': 'Play any game to complete',
      'play_3': 'Play 3 games today',
      'win_2': 'Win 2 games today',
      'win_5': 'Win 5 games today',
      'matches_10': 'Match 10 pairs',
      'matches_30': 'Match 30 pairs today',
      'combo_3': 'Get a 3x combo streak',
      'combo_5': 'Get a 5x combo streak',
      'perfect_1': 'Complete without mistakes',
      'stars_3': 'Earn 3 stars total',
      'stars_6': 'Earn 6 stars today',
    };
    return descriptions[quest.id] ?? '';
  }

  Color get _difficultyColor {
    if (QuestTemplates.easy.any((q) => q.id == quest.id)) {
      return AppColors.success;
    } else if (QuestTemplates.medium.any((q) => q.id == quest.id)) {
      return AppColors.warning;
    }
    return AppColors.error;
  }

  String get _difficultyLabel {
    if (QuestTemplates.easy.any((q) => q.id == quest.id)) {
      return 'Easy';
    } else if (QuestTemplates.medium.any((q) => q.id == quest.id)) {
      return 'Medium';
    }
    return 'Hard';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCompleted = progress.isCompleted;
    final isClaimed = progress.isRewardClaimed;
    final progressPercent = quest.targetValue > 0
        ? (progress.currentValue / quest.targetValue).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCompleted && !isClaimed
            ? Border.all(color: AppColors.success, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isCompleted && !isClaimed
                ? AppColors.success.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _difficultyColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    quest.icon,
                    color: _difficultyColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Title and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getTitle(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _difficultyColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _difficultyLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _difficultyColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDescription(),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      minHeight: 10,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? AppColors.success : _difficultyColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${progress.currentValue}/${quest.targetValue}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? AppColors.success : Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Reward and claim button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+${quest.rewardPoints}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                if (isCompleted && !isClaimed)
                  ElevatedButton(
                    onPressed: onClaimReward,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                    child: Text(l10n.claimReward),
                  )
                else if (isClaimed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.claimed,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
