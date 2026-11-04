import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/achievement.dart';
import '../../../l10n/achievement_l10n.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/achievement_provider.dart';

/// Achievements screen displaying all game achievements
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final achievementNotifier = ref.watch(achievementProvider.notifier);
    final progress = ref.watch(achievementProvider);

    final unlockedCount = achievementNotifier.unlockedCount;
    final totalCount = achievementNotifier.totalCount;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(l10n.achievements),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleTextStyle: AppTheme.onPrimaryTitleStyle,
        iconTheme: AppTheme.onPrimaryIconTheme,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress header
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
                Text(
                  '$unlockedCount / $totalCount',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.achievementsEarned(unlockedCount, totalCount),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: totalCount > 0 ? unlockedCount / totalCount : 0,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Achievement list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: Achievements.all.length,
              itemBuilder: (context, index) {
                final achievement = Achievements.all[index];
                final achievementProgress = progress[achievement.id] ??
                    AchievementProgress(achievementId: achievement.id);

                return _AchievementCard(
                  achievement: achievement,
                  progress: achievementProgress,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final AchievementProgress progress;

  const _AchievementCard({
    required this.achievement,
    required this.progress,
  });

  Color get _rarityColor {
    switch (achievement.rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  String _getRarityName(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isTurkish = locale == 'tr';

    switch (achievement.rarity) {
      case AchievementRarity.common:
        return isTurkish ? 'Yaygın' : 'Common';
      case AchievementRarity.rare:
        return isTurkish ? 'Nadir' : 'Rare';
      case AchievementRarity.epic:
        return isTurkish ? 'Destansı' : 'Epic';
      case AchievementRarity.legendary:
        return isTurkish ? 'Efsanevi' : 'Legendary';
    }
  }

  String _getTitle(BuildContext context) => AchievementTexts.title(
      achievement.id, Localizations.localeOf(context).languageCode);

  String _getDescription(BuildContext context) => AchievementTexts.description(
      achievement.id, Localizations.localeOf(context).languageCode);

  @override
  Widget build(BuildContext context) {
    final isUnlocked = progress.isUnlocked;
    final progressPercent = achievement.targetValue > 0
        ? (progress.currentValue / achievement.targetValue).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: isUnlocked
            ? Border.all(color: _rarityColor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isUnlocked
                ? _rarityColor.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: isUnlocked ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? _rarityColor.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
                border: isUnlocked
                    ? Border.all(color: _rarityColor, width: 2)
                    : null,
              ),
              child: Icon(
                achievement.icon,
                color: isUnlocked ? _rarityColor : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getTitle(context),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked
                                ? AppColors.textPrimary(context)
                                : Colors.grey,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _rarityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getRarityName(context),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _rarityColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDescription(context),
                    style: TextStyle(
                      fontSize: 13,
                      color: isUnlocked
                          ? AppColors.textSecondary(context)
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progressPercent,
                            minHeight: 6,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isUnlocked ? _rarityColor : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${progress.currentValue}/${achievement.targetValue}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked ? _rarityColor : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Unlock indicator
            if (isUnlocked)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
