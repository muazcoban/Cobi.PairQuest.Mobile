import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/card.dart';
import '../../../domain/entities/game.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/daily_quest_provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/power_up_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/dialogs/game_complete_dialog.dart';
import '../../widgets/dialogs/game_over_dialog.dart';
import '../../widgets/dialogs/multiplayer_result_dialog.dart';
import '../../widgets/game/combo_popup.dart';
import '../../widgets/game/game_board.dart';
import '../../widgets/game/game_header.dart';
import '../../widgets/game/multiplayer_header.dart';
import '../../widgets/game/power_up_bar.dart';
import '../../widgets/game/turn_indicator.dart';

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
  bool _showTimeBonusAnimation = false;
  bool _showPeekFlash = false;
  int _previousTimeRemaining = 0;

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
    // Skip if multiplayer - game is started from lobby
    if (widget.mode == 'multiplayer') return;

    // End any existing game first
    ref.read(gameProvider.notifier).endGame();

    // Reset power-up usage for new game
    ref.read(gamePowerUpUsageProvider.notifier).resetForNewGame();

    final gameMode = widget.mode == 'timed' ? GameMode.timed : GameMode.classic;
    final cardTheme = ref.read(settingsProvider).cardTheme;

    ref.read(gameProvider.notifier).startGame(
          level: widget.level,
          mode: gameMode,
          theme: cardTheme,
        );
  }

  int _lastCoinsEarned = 0;

  Future<void> _saveProgress(Game game, int stars) async {
    final timeSpent = game.endTime != null && game.startTime != null
        ? game.endTime!.difference(game.startTime!).inSeconds
        : 0;

    // Award coins for game completion
    _lastCoinsEarned = await ref.read(walletProvider.notifier).awardGameCompletion(
      level: game.level,
      stars: stars,
      isPerfect: game.isPerfectGame,
      maxCombo: game.maxCombo,
    );

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
    final gameState = ref.read(gameProvider);
    ref.read(dailyQuestProvider.notifier).recordGameResult(
          won: true,
          matches: game.matches,
          maxCombo: game.maxCombo,
          isPerfect: game.isPerfectGame,
          starsEarned: stars,
          powerUpsUsed: gameState.powerUpsUsedCount,
          isTimedMode: game.mode == GameMode.timed,
        );

    // Add to leaderboard
    final playerName = ref.read(settingsProvider).playerName;
    ref.read(leaderboardProvider.notifier).addEntry(
          playerName: playerName,
          level: game.level,
          score: game.score,
          stars: stars,
          moves: game.moves,
          timeSeconds: timeSpent,
        );

    // Check achievements
    final newAchievements = ref.read(achievementProvider.notifier).checkAchievements();
    if (newAchievements.isNotEmpty && mounted) {
      // Show achievement unlocked notification (respects user settings)
      for (final achievement in newAchievements) {
        final achievementTitle = _getAchievementTitle(achievement.id);

        // Show in-app SnackBar (always shown when in app)
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

        // Show local notification only if user has enabled achievement notifications
        ref.read(notificationSettingsProvider.notifier).showAchievementUnlocked(
          title: achievementTitle,
          description: achievement.descriptionKey,
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
    final gameState = ref.read(gameProvider);
    ref.read(dailyQuestProvider.notifier).recordGameResult(
          won: false,
          matches: game.matches,
          maxCombo: game.maxCombo,
          isPerfect: false,
          starsEarned: 0,
          powerUpsUsed: gameState.powerUpsUsedCount,
          isTimedMode: game.mode == GameMode.timed,
        );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final game = gameState.currentGame;
    final isPreview = game?.state == GameState.preview;
    final isMultiplayer = game?.isMultiplayer ?? false;

    ref.listen<GameStateData>(gameProvider, (previous, next) {
      // Check for combo changes (single player only)
      if (!isMultiplayer) {
        final prevCombo = previous?.currentGame?.combo ?? 0;
        final nextCombo = next.currentGame?.combo ?? 0;
        if (nextCombo > prevCombo && nextCombo >= 2) {
          setState(() => _currentCombo = nextCombo);
        }
      }

      // Check for Time Bonus power-up (+15 seconds)
      final prevTime = previous?.currentGame?.timeRemaining ?? 0;
      final nextTime = next.currentGame?.timeRemaining ?? 0;
      if (nextTime - prevTime >= 15 && _previousTimeRemaining > 0) {
        setState(() => _showTimeBonusAnimation = true);
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _showTimeBonusAnimation = false);
        });
      }
      _previousTimeRemaining = nextTime;

      // Check for Peek power-up (all cards revealed)
      if (next.isProcessing && !(previous?.isProcessing ?? false)) {
        final allRevealed = next.currentGame?.cards
            .where((c) => c.state != CardState.matched)
            .every((c) => c.state == CardState.revealed) ?? false;
        if (allRevealed && next.currentGame?.cards.isNotEmpty == true) {
          setState(() => _showPeekFlash = true);
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) setState(() => _showPeekFlash = false);
          });
        }
      }

      if (next.currentGame?.state == GameState.completed &&
          previous?.currentGame?.state != GameState.completed) {
        _confettiController.play();
        if (next.currentGame?.isMultiplayer ?? false) {
          _showMultiplayerResultDialog();
        } else {
          _showGameCompleteDialog();
        }
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
              // Use different header for multiplayer
              if (isMultiplayer)
                const MultiplayerHeader()
              else
                const GameHeader(),
              _buildControls(game),

              // Power-up bar (single player only)
              if (!isMultiplayer && game?.state == GameState.inProgress)
                PowerUpBar(
                  isTimedMode: game?.mode == GameMode.timed,
                ),

              Expanded(
                child: gameState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : const GameBoard(),
              ),
            ],
          ),

          // Preview overlay with countdown
          if (isPreview)
            _PreviewOverlay(progress: gameState.previewProgress),

          // Freeze power-up overlay
          if (ref.watch(isTimerFrozenProvider))
            const _FreezeOverlay(),

          // Time Bonus +15 floating text
          if (_showTimeBonusAnimation)
            const _TimeBonusFloatingText(),

          // Peek flash effect
          if (_showPeekFlash)
            const _PeekFlashOverlay(),

          // Magnet active indicator
          if (ref.watch(isMagnetActiveProvider))
            const _MagnetActiveOverlay(),

          // Turn transition indicator (multiplayer only)
          if (isMultiplayer && gameState.showTurnTransition)
            const TurnIndicator(),

          // Combo popup (single player only)
          if (!isMultiplayer && _currentCombo != null && _currentCombo! >= 2)
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

  void _showGameCompleteDialog() async {
    final game = ref.read(gameProvider).currentGame;
    if (game == null) return;

    final stars = ref.read(progressProvider.notifier).calculateStars(
          level: game.level,
          score: game.score,
          moves: game.moves,
          pairs: game.gridSize.pairs,
          isPerfectGame: game.isPerfectGame,
        );

    // Save progress with stars and get coins earned (awaited to ensure coins are calculated)
    await _saveProgress(game, stars);

    if (!mounted) return;

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
        coinsEarned: _lastCoinsEarned,
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

    // Partial completion coins: 5 coins per matched pair
    final partialCoins = game.matches * 5;
    if (partialCoins > 0) {
      ref.read(walletProvider.notifier).addCoins(partialCoins);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GameOverDialog(
        score: game.score,
        matchedPairs: game.matches,
        totalPairs: game.gridSize.pairs,
        coinsEarned: partialCoins,
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

  void _showMultiplayerResultDialog() {
    final game = ref.read(gameProvider).currentGame;
    if (game == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MultiplayerResultDialog(
        game: game,
        onMainMenu: () {
          Navigator.of(dialogContext).pop();
          ref.read(gameProvider.notifier).endGame();
          Navigator.of(context).pop();
        },
        onPlayAgain: () {
          Navigator.of(dialogContext).pop();
          ref.read(gameProvider.notifier).resetGame();
        },
      ),
    );
  }
}

/// Preview overlay widget with animated countdown
class _PreviewOverlay extends StatelessWidget {
  final double progress;

  const _PreviewOverlay({required this.progress});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated "Memorize!" text
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.2),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.9),
                        AppColors.accent.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.memorize,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Circular progress indicator
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress > 0.3 ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                    // Pulsing eye icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.9, end: 1.1),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Icon(
                            Icons.remove_red_eye,
                            color: progress > 0.3 ? AppColors.success : AppColors.error,
                            size: 36,
                          ),
                        );
                      },
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

/// Freeze power-up overlay with ice effect
class _FreezeOverlay extends StatelessWidget {
  const _FreezeOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.cyan.withOpacity(0.15),
                Colors.blue.withOpacity(0.08),
                Colors.cyan.withOpacity(0.15),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Frost border effect
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.cyan.withOpacity(0.4),
                      width: 3,
                    ),
                  ),
                ),
              ),
              // Snowflake particles
              ...List.generate(6, (index) {
                final positions = [
                  const Offset(30, 100),
                  const Offset(80, 200),
                  const Offset(200, 150),
                  const Offset(280, 100),
                  const Offset(150, 300),
                  const Offset(320, 250),
                ];
                return Positioned(
                  left: positions[index].dx,
                  top: positions[index].dy,
                  child: const Icon(
                    Icons.ac_unit,
                    color: Colors.white54,
                    size: 20,
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .fadeIn(duration: 500.ms)
                      .then()
                      .fadeOut(duration: 500.ms)
                      .slideY(begin: 0, end: 0.5, duration: 2000.ms),
                );
              }),
              // Center freeze indicator
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ac_unit, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'TIME FROZEN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.05, 1.05),
                        duration: 800.ms,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Time Bonus +15 floating text animation
class _TimeBonusFloatingText extends StatelessWidget {
  const _TimeBonusFloatingText();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.purple.shade600],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Text(
                '+15s',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.1, 1.1),
              duration: 300.ms,
              curve: Curves.elasticOut,
            )
            .then()
            .scale(
              begin: const Offset(1.1, 1.1),
              end: const Offset(1.0, 1.0),
              duration: 200.ms,
            )
            .then(delay: 600.ms)
            .fadeOut(duration: 400.ms)
            .slideY(begin: 0, end: -0.5, duration: 400.ms),
      ),
    );
  }
}

/// Peek flash effect overlay
class _PeekFlashOverlay extends StatelessWidget {
  const _PeekFlashOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(0.7),
                Colors.blue.withOpacity(0.2),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: const Icon(
              Icons.visibility,
              color: Colors.blue,
              size: 60,
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.5, 1.5),
                  duration: 300.ms,
                )
                .fadeOut(duration: 300.ms),
          ),
        )
            .animate()
            .fadeIn(duration: 100.ms)
            .then()
            .fadeOut(duration: 300.ms),
      ),
    );
  }
}

/// Magnet power-up active indicator
class _MagnetActiveOverlay extends StatelessWidget {
  const _MagnetActiveOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 150,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🧲', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'TAP ANY CARD',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.05, 1.05),
              duration: 600.ms,
            )
            .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.3)),
      ),
    );
  }
}
