import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/achievement.dart';
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

  String _getTitle(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isTurkish = locale == 'tr';

    final titles = isTurkish ? {
      'first_game': 'İlk Adım',
      'games_10': 'Başlangıç',
      'games_50': 'Sadık Oyuncu',
      'games_100': 'Hafıza Ustası',
      'matches_100': 'Eşleştirici',
      'matches_500': 'Desen Uzmanı',
      'matches_1000': 'Hafıza Dehası',
      'combo_3': 'Combo Başlangıcı',
      'combo_5': 'Combo Kralı',
      'combo_8': 'Ateşte',
      'combo_10': 'Durdurulamaz',
      'perfect_1': 'Mükemmeliyetçi',
      'perfect_5': 'Kusursuz',
      'perfect_10': 'Efsanevi Zeka',
      'streak_3': 'Sıcak Seri',
      'streak_7': 'Haftalık Savaşçı',
      'streak_10': 'Şampiyon',
      'level_5': 'Yarı Yolda',
      'level_10': 'Büyük Usta',
      'stars_30': 'Yıldız Toplayıcı',
    } : {
      'first_game': 'First Steps',
      'games_10': 'Getting Started',
      'games_50': 'Dedicated Player',
      'games_100': 'Memory Master',
      'matches_100': 'Match Maker',
      'matches_500': 'Pattern Expert',
      'matches_1000': 'Memory Genius',
      'combo_3': 'Combo Starter',
      'combo_5': 'Combo King',
      'combo_8': 'On Fire',
      'combo_10': 'Unstoppable',
      'perfect_1': 'Perfectionist',
      'perfect_5': 'Flawless',
      'perfect_10': 'Legendary Mind',
      'streak_3': 'Hot Streak',
      'streak_7': 'Week Warrior',
      'streak_10': 'Champion',
      'level_5': 'Halfway There',
      'level_10': 'Grand Master',
      'stars_30': 'Star Collector',
    };
    return titles[achievement.id] ?? achievement.id;
  }

  String _getDescription(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isTurkish = locale == 'tr';

    final descriptions = isTurkish ? {
      'first_game': 'İlk oyununu kazan',
      'games_10': '10 oyun kazan',
      'games_50': '50 oyun kazan',
      'games_100': '100 oyun kazan',
      'matches_100': '100 eşleşme yap',
      'matches_500': '500 eşleşme yap',
      'matches_1000': '1000 eşleşme yap',
      'combo_3': '3x combo yap',
      'combo_5': '5x combo yap',
      'combo_8': '8x combo yap',
      'combo_10': '10x combo yap',
      'perfect_1': 'Mükemmel bir oyun tamamla',
      'perfect_5': '5 mükemmel oyun tamamla',
      'perfect_10': '10 mükemmel oyun tamamla',
      'streak_3': 'Ard arda 3 oyun kazan',
      'streak_7': 'Ard arda 7 oyun kazan',
      'streak_10': 'Ard arda 10 oyun kazan',
      'level_5': 'Seviye 5\'i tamamla',
      'level_10': 'Tüm 10 seviyeyi tamamla',
      'stars_30': '30 yıldız topla',
    } : {
      'first_game': 'Win your first game',
      'games_10': 'Win 10 games',
      'games_50': 'Win 50 games',
      'games_100': 'Win 100 games',
      'matches_100': 'Make 100 matches',
      'matches_500': 'Make 500 matches',
      'matches_1000': 'Make 1000 matches',
      'combo_3': 'Get a 3x combo',
      'combo_5': 'Get a 5x combo',
      'combo_8': 'Get an 8x combo',
      'combo_10': 'Get a 10x combo',
      'perfect_1': 'Complete a perfect game',
      'perfect_5': 'Complete 5 perfect games',
      'perfect_10': 'Complete 10 perfect games',
      'streak_3': 'Win 3 games in a row',
      'streak_7': 'Win 7 games in a row',
      'streak_10': 'Win 10 games in a row',
      'level_5': 'Complete level 5',
      'level_10': 'Complete all 10 levels',
      'stars_30': 'Earn all 30 stars',
    };
    return descriptions[achievement.id] ?? '';
  }

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
                            fontSize: 10,
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
