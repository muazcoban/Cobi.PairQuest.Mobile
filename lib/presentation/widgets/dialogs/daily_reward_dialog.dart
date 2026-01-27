import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/daily_reward.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/daily_reward_provider.dart';

/// Dialog for claiming daily rewards
class DailyRewardDialog extends ConsumerWidget {
  const DailyRewardDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rewardNotifier = ref.watch(dailyRewardProvider.notifier);
    final progress = ref.watch(dailyRewardProvider);
    final weeklyRewards = rewardNotifier.getWeeklyRewards();
    final canClaim = rewardNotifier.canClaim;
    final todaysReward = rewardNotifier.todaysReward;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.card_giftcard_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dailyReward,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.streakBonus(progress.currentStreak),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Weekly rewards grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 0.7,
              ),
              itemCount: weeklyRewards.length,
              itemBuilder: (context, index) {
                final status = weeklyRewards[index];
                return _RewardDay(
                  status: status,
                );
              },
            ),

            const SizedBox(height: 24),

            // Today's reward highlight
            if (canClaim)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      todaysReward.icon,
                      color: AppColors.accent,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day ${rewardNotifier.currentDay}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                        _buildRewardText(todaysReward),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Claim button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canClaim
                    ? () async {
                        final reward = await ref
                            .read(dailyRewardProvider.notifier)
                            .claimReward();
                        if (context.mounted) {
                          Navigator.of(context).pop(reward);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  canClaim ? l10n.claimDailyReward : l10n.dailyRewardClaimed,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardText(DailyReward reward) {
    final List<Widget> items = [];

    if (reward.coins > 0) {
      items.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 20),
          const SizedBox(width: 4),
          Text(
            '+${reward.coins}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
        ],
      ));
    }

    if (reward.gems > 0) {
      items.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.diamond_rounded, color: Colors.purple, size: 20),
          const SizedBox(width: 4),
          Text(
            '+${reward.gems}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ],
      ));
    }

    if (reward.powerUpId != null) {
      items.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lightbulb_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 4),
          const Text(
            '+1',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }
}

class _RewardDay extends StatelessWidget {
  final DailyRewardStatus status;

  const _RewardDay({required this.status});

  Color get _backgroundColor {
    if (status.isClaimed) return AppColors.success.withOpacity(0.1);
    if (status.isAvailable) return AppColors.accent.withOpacity(0.1);
    return Colors.grey.withOpacity(0.1);
  }

  Color get _borderColor {
    if (status.isClaimed) return AppColors.success;
    if (status.isAvailable) return AppColors.accent;
    return Colors.grey.shade300;
  }

  Color get _iconColor {
    if (status.isClaimed) return AppColors.success;
    if (status.isAvailable) return AppColors.accent;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _borderColor,
          width: status.isAvailable ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'D${status.reward.day}',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: _iconColor,
              ),
            ),
            if (status.isClaimed)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 14,
              )
            else
              Icon(
                status.reward.icon,
                color: _iconColor,
                size: 14,
              ),
            Flexible(child: _buildRewardLabel()),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardLabel() {
    final reward = status.reward;

    if (reward.gems > 0) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on_rounded, color: _iconColor, size: 8),
                Text(
                  '+${reward.coins}',
                  style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: _iconColor),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.diamond_rounded, color: _iconColor, size: 8),
                Text(
                  '+${reward.gems}',
                  style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: _iconColor),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (reward.powerUpId != null) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+${reward.coins}',
              style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: _iconColor),
            ),
            const Text(
              '💡',
              style: TextStyle(fontSize: 8),
            ),
          ],
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        '+${reward.coins}',
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: _iconColor,
        ),
      ),
    );
  }
}
