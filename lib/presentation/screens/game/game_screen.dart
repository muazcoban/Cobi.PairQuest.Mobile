import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/game.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/daily_quest_provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/stats_provider.dart';
import '../../widgets/dialogs/game_complete_dialog.dart';
import '../../widgets/dialogs/game_over_dialog.dart';
import '../../widgets/game/combo_popup.dart';
import '../../widgets/game/game_board.dart';
import '../../widgets/game/game_header.dart';

/// Main game screen
class GameScreen extends ConsumerStatefulWidget {
  final int level;
  final String mode;

  const GameScreen({
    super.key,
    required this.level,
    this.mode = 'classic',
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late ConfettiController _confettiController;
  int? _currentCombo;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGame();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _startGame() {
    // End any existing game first
    ref.read(gameProvider.notifier).endGame();

    final gameMode = widget.mode == 'timed' ? GameMode.timed : GameMode.classic;
    final cardTheme = ref.read(settingsProvider).cardTheme;

    ref.read(gameProvider.notifier).startGame(
          level: widget.level,
          mode: gameMode,
          theme: cardTheme,
        );
  }

  void _saveProgress(Game game, int stars) {
    final timeSpent = game.endTime != null && game.startTime != null
        ? game.endTime!.difference(game.startTime!).inSeconds
        : 0;

    // Save level progress
    ref.read(progressProvider.notifier).completeLevelProgress(
          level: game.level,
          score: game.score,
          moves: game.moves,
          pairs: game.gridSize.pairs,
          timeSpent: timeSpent,
          isPerfectGame: game.isPerfectGame,
        );

    // Update player stats
    ref.read(statsProvider.notifier).recordGameWin(
          level: game.level,
          score: game.score,
          moves: game.moves,
          matches: game.matches,
          timeSeconds: timeSpent,
          maxCombo: game.maxCombo,
          stars: stars,
          isPerfectGame: game.isPerfectGame,
        );

    // Update daily quests
    ref.read(dailyQuestProvider.notifier).recordGameResult(
          won: true,
          matches: game.matches,
          maxCombo: game.maxCombo,
          isPerfect: game.isPerfectGame,
          starsEarned: stars,
        );

    // Add to leaderboard
    ref.read(leaderboardProvider.notifier).addEntry(
          playerName: 'Player',
          level: game.level,
          score: game.score,
          stars: stars,
          moves: game.moves,
          timeSeconds: timeSpent,
        );

    // Check achievements
    final newAchievements = ref.read(achievementProvider.notifier).checkAchievements();
    if (newAchievements.isNotEmpty && mounted) {
      // Show achievement unlocked notification
      for (final achievement in newAchievements) {
        final achievementTitle = _getAchievementTitle(achievement.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(achievement.icon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.achievementUnlocked,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(achievementTitle),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _getAchievementTitle(String id) {
    const titles = {
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
    return titles[id] ?? id;
  }

  void _saveGameLoss(Game game) {
    final timeSpent = game.endTime != null && game.startTime != null
        ? game.endTime!.difference(game.startTime!).inSeconds
        : 0;

    // Update player stats
    ref.read(statsProvider.notifier).recordGameLoss(
          level: game.level,
          matches: game.matches,
          moves: game.moves,
          timeSeconds: timeSpent,
        );

    // Update daily quests
    ref.read(dailyQuestProvider.notifier).recordGameResult(
          won: false,
          matches: game.matches,
          maxCombo: game.maxCombo,
          isPerfect: false,
          starsEarned: 0,
        );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final game = gameState.currentGame;

    ref.listen<GameStateData>(gameProvider, (previous, next) {
      // Check for combo changes
      final prevCombo = previous?.currentGame?.combo ?? 0;
      final nextCombo = next.currentGame?.combo ?? 0;
      if (nextCombo > prevCombo && nextCombo >= 2) {
        setState(() => _currentCombo = nextCombo);
      }

      if (next.currentGame?.state == GameState.completed &&
          previous?.currentGame?.state != GameState.completed) {
        _confettiController.play();
        _showGameCompleteDialog();
      } else if (next.currentGame?.state == GameState.failed &&
          previous?.currentGame?.state != GameState.failed) {
        _saveGameLoss(next.currentGame!);
        _showGameOverDialog();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Stack(
        children: [
          Column(
            children: [
              const GameHeader(),
              _buildControls(game),
              Expanded(
                child: gameState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : const GameBoard(),
              ),
            ],
          ),

          // Combo popup
          if (_currentCombo != null && _currentCombo! >= 2)
            ComboPopup(
              combo: _currentCombo!,
              onComplete: () => setState(() => _currentCombo = null),
            ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.accent,
                AppColors.success,
                AppColors.primaryLight,
                AppColors.accentLight,
              ],
              numberOfParticles: 30,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(Game? game) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ref.read(gameProvider.notifier).endGame();
              Navigator.of(context).pop();
            },
          ),
          if (game != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${AppLocalizations.of(context)!.level} ${game.level} • ${game.gridSize.rows}x${game.gridSize.cols}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Row(
            children: [
              if (game?.state == GameState.inProgress)
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: () {
                    ref.read(gameProvider.notifier).pauseGame();
                    _showPauseDialog();
                  },
                ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.read(gameProvider.notifier).resetGame();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPauseDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.gamePaused),
        content: Text(l10n.continueQuestion),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(gameProvider.notifier).endGame();
              Navigator.of(context).pop();
            },
            child: Text(l10n.quit),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(gameProvider.notifier).resumeGame();
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(l10n.resume),
          ),
        ],
      ),
    );
  }

  void _showGameCompleteDialog() {
    final game = ref.read(gameProvider).currentGame;
    if (game == null) return;

    final stars = ref.read(progressProvider.notifier).calculateStars(
          level: game.level,
          score: game.score,
          moves: game.moves,
          pairs: game.gridSize.pairs,
          isPerfectGame: game.isPerfectGame,
        );

    // Save progress with stars
    _saveProgress(game, stars);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GameCompleteDialog(
        level: game.level,
        stars: stars,
        score: game.score,
        moves: game.moves,
        maxCombo: game.maxCombo,
        isPerfectGame: game.isPerfectGame,
        hasNextLevel: game.level < 10,
        onMainMenu: () {
          Navigator.of(dialogContext).pop();
          ref.read(gameProvider.notifier).endGame();
          Navigator.of(context).pop();
        },
        onPlayAgain: () {
          Navigator.of(dialogContext).pop();
          ref.read(gameProvider.notifier).resetGame();
        },
        onNextLevel: game.level < 10
            ? () {
                Navigator.of(dialogContext).pop();
                final cardTheme = ref.read(settingsProvider).cardTheme;
                ref.read(gameProvider.notifier).startGame(
                      level: game.level + 1,
                      mode: game.mode,
                      theme: cardTheme,
                    );
              }
            : null,
      ),
    );
  }

  void _showGameOverDialog() {
    final game = ref.read(gameProvider).currentGame;
    if (game == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GameOverDialog(
        score: game.score,
        matchedPairs: game.matches,
        totalPairs: game.gridSize.pairs,
        onMainMenu: () {
          Navigator.of(dialogContext).pop();
          ref.read(gameProvider.notifier).endGame();
          Navigator.of(context).pop();
        },
        onTryAgain: () {
          Navigator.of(dialogContext).pop();
          ref.read(gameProvider.notifier).resetGame();
        },
      ),
    );
  }
}
