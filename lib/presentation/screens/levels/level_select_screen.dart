import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/game_config.dart';
import '../../../domain/entities/game.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/game_provider.dart';
import '../../providers/progress_provider.dart';
import '../game/game_screen.dart';

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final progress = ref.watch(progressProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryLight,
              AppColors.backgroundLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.selectLevel,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    // Total Stars
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${progress.totalStars}/${GameConfig.totalLevels * 3}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Levels Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: GameConfig.levels.length,
                  itemBuilder: (context, index) {
                    final config = GameConfig.levels[index];
                    final levelProgress = progress.getLevelProgress(config.level);
                    final isUnlocked = progress.isLevelUnlocked(config.level);

                    return _LevelCard(
                      config: config,
                      stars: levelProgress?.stars ?? 0,
                      bestScore: levelProgress?.bestScore ?? 0,
                      isUnlocked: isUnlocked,
                      onTap: isUnlocked
                          ? () => _startLevel(context, ref, config.level)
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startLevel(BuildContext context, WidgetRef ref, int level) {
    ref.read(gameProvider.notifier).startGame(
          level: level,
          mode: GameMode.classic,
        );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(
          level: level,
          mode: 'classic',
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final GridConfig config;
  final int stars;
  final int bestScore;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.config,
    required this.stars,
    required this.bestScore,
    required this.isUnlocked,
    this.onTap,
  });

  String _getDifficultyLabel(BuildContext context, String difficulty) {
    final l10n = AppLocalizations.of(context)!;
    switch (difficulty) {
      case 'tutorial':
        return l10n.tutorial;
      case 'very_easy':
        return l10n.veryEasy;
      case 'easy':
        return l10n.easy;
      case 'medium':
        return l10n.medium;
      case 'hard':
        return l10n.hard;
      case 'very_hard':
        return l10n.veryHard;
      case 'expert':
        return l10n.expert;
      case 'legendary':
        return l10n.legendary;
      case 'master':
        return l10n.master;
      default:
        return difficulty;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'tutorial':
        return Colors.grey;
      case 'very_easy':
        return Colors.green;
      case 'easy':
        return Colors.lightGreen;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.deepOrange;
      case 'very_hard':
        return Colors.red;
      case 'expert':
        return Colors.purple;
      case 'legendary':
        return Colors.amber.shade700;
      case 'master':
        return Colors.teal.shade700;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isUnlocked ? Colors.white : Colors.grey[200],
      borderRadius: BorderRadius.circular(16),
      elevation: isUnlocked ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              // Lock icon for locked levels
              if (!isUnlocked)
                Positioned.fill(
                  child: Center(
                    child: Icon(
                      Icons.lock,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                  ),
                ),

              // Level content
              Opacity(
                opacity: isUnlocked ? 1.0 : 0.3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Level number and grid size
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${config.level}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(config.difficulty)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${config.rows}x${config.cols}',
                            style: TextStyle(
                              color: _getDifficultyColor(config.difficulty),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Difficulty label
                    Text(
                      _getDifficultyLabel(context, config.difficulty),
                      style: TextStyle(
                        color: _getDifficultyColor(config.difficulty),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Pairs count
                    Text(
                      '${config.pairs} pairs',
                      style: TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Stars
                    Row(
                      children: List.generate(3, (index) {
                        return Icon(
                          index < stars ? Icons.star : Icons.star_border,
                          color: index < stars
                              ? AppColors.accent
                              : Colors.grey[400],
                          size: 20,
                        );
                      }),
                    ),

                    // Best score
                    if (bestScore > 0)
                      Text(
                        'Best: $bestScore',
                        style: TextStyle(
                          color: AppColors.textSecondaryLight,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
