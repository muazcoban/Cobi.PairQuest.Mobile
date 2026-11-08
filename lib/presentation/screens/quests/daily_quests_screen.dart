import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/daily_quest.dart';
import '../../../domain/entities/power_up.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/quest_l10n.dart';
import '../../providers/daily_quest_provider.dart';
import '../../providers/power_up_provider.dart';
import '../../providers/wallet_provider.dart';

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
        titleTextStyle: AppTheme.onPrimaryTitleStyle,
        iconTheme: AppTheme.onPrimaryIconTheme,
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
                final progress =
                    questData.progress[quest.id] ??
                    QuestProgress(questId: quest.id);

                return _QuestCard(
                  quest: quest,
                  progress: progress,
                  onClaimReward: () {
                    final reward = ref
                        .read(dailyQuestProvider.notifier)
                        .claimReward(quest.id);
                    if (reward.coins > 0) {
                      // Add coins to wallet
                      ref.read(walletProvider.notifier).addCoins(reward.coins);

                      // Add power-up if rewarded
                      if (reward.powerUp != null &&
                          reward.powerUpQuantity > 0) {
                        ref
                            .read(powerUpInventoryProvider.notifier)
                            .addPowerUp(
                              reward.powerUp!,
                              reward.powerUpQuantity,
                            );
                      }

                      // Build snackbar message
                      String message = '+${reward.coins} coins!';
                      if (reward.powerUp != null &&
                          reward.powerUpQuantity > 0) {
                        final powerUp = PowerUps.all.firstWhere(
                          (p) => p.type == reward.powerUp,
                        );
                        message +=
                            ' +${reward.powerUpQuantity} ${powerUp.icon}';
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: AppColors.successStrong,
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

  Color get _difficultyColor {
    if (QuestTemplates.easy.any((q) => q.id == quest.id)) {
      return AppColors.success;
    } else if (QuestTemplates.medium.any((q) => q.id == quest.id)) {
      return AppColors.warning;
    }
    return AppColors.error;
  }

  String _difficultyLabel(AppLocalizations l10n) {
    if (QuestTemplates.easy.any((q) => q.id == quest.id)) {
      return l10n.easy;
    } else if (QuestTemplates.medium.any((q) => q.id == quest.id)) {
      return l10n.medium;
    }
    return l10n.hard;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final isCompleted = progress.isCompleted;
    final isClaimed = progress.isRewardClaimed;
    final progressPercent = quest.targetValue > 0
        ? (progress.currentValue / quest.targetValue).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        // A fixed white card hid the title, which is white in dark mode.
        color: AppColors.cardBackground(context),
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
                  child: Icon(quest.icon, color: _difficultyColor, size: 24),
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
                              QuestTexts.title(quest.id, languageCode),
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
                              _difficultyLabel(l10n),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _difficultyColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        QuestTexts.description(quest.id, languageCode),
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
                    color: isCompleted
                        ? AppColors.success
                        : AppColors.textSecondary(context),
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
                    // Show power-up reward if exists
                    if (quest.rewardPowerUp != null &&
                        quest.rewardPowerUpQuantity > 0) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              PowerUps.all
                                  .firstWhere(
                                    (p) => p.type == quest.rewardPowerUp,
                                  )
                                  .icon,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${quest.rewardPowerUpQuantity}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (isCompleted && !isClaimed)
                  ElevatedButton(
                    onPressed: onClaimReward,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successStrong,
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
