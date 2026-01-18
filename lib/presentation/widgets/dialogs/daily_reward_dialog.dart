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
                childAspectRatio: 0.85,
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
                        Text(
                          '+${todaysReward.amount}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
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
                    ? () {
                        final points = ref
                            .read(dailyRewardProvider.notifier)
                            .claimReward();
                        Navigator.of(context).pop(points);
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
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'D${status.reward.day}',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: _iconColor,
              ),
            ),
            if (status.isClaimed)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 12,
              )
            else
              Icon(
                status.reward.icon,
                color: _iconColor,
                size: 12,
              ),
            Text(
              '+${status.reward.amount}',
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: _iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
