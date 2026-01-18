import '../core/constants/game_config.dart';
import '../domain/entities/game.dart';

/// Result of a match check
class MatchResult {
  final bool isMatch;
  final int points;
  final int newCombo;
  final List<ScoreBonus> bonuses;

  const MatchResult({
    required this.isMatch,
    required this.points,
    required this.newCombo,
    this.bonuses = const [],
  });
}

/// Represents a score bonus
class ScoreBonus {
  final String type;
  final int value;
  final String label;

  const ScoreBonus({
    required this.type,
    required this.value,
    required this.label,
  });
}

/// Final score calculation result
class FinalScore {
  final int baseScore;
  final int timeBonus;
  final int perfectBonus;
  final int comboBonus;
  final double difficultyMultiplier;
  final int totalScore;
  final int stars;

  const FinalScore({
    required this.baseScore,
    required this.timeBonus,
    required this.perfectBonus,
    required this.comboBonus,
    required this.difficultyMultiplier,
    required this.totalScore,
    required this.stars,
  });
}

/// Service for score calculations
class ScoreService {
  /// Calculate points for a match attempt
  MatchResult calculateMatchPoints({
    required bool isMatch,
    required int currentCombo,
    required bool isFirstTry,
    required String difficulty,
  }) {
    if (!isMatch) {
      return MatchResult(
        isMatch: false,
        points: -GameConfig.errorPenalty,
        newCombo: 0,
        bonuses: const [],
      );
    }

    final bonuses = <ScoreBonus>[];
    int points = GameConfig.matchPoints;
    final newCombo = currentCombo + 1;

    // Combo bonus
    if (newCombo > 1) {
      final comboPoints = (newCombo - 1) * GameConfig.comboBonus;
      points += comboPoints;
      bonuses.add(ScoreBonus(
        type: 'combo',
        value: comboPoints,
        label: '${newCombo}x Combo!',
      ));
    }

    // First try bonus
    if (isFirstTry) {
      points += GameConfig.firstTryBonus;
      bonuses.add(const ScoreBonus(
        type: 'first_try',
        value: GameConfig.firstTryBonus,
        label: 'İlk Deneme!',
      ));
    }

    // Apply difficulty multiplier
    final multiplier = GameConfig.difficultyMultipliers[difficulty] ?? 1.0;
    points = (points * multiplier).round();

    return MatchResult(
      isMatch: true,
      points: points,
      newCombo: newCombo,
      bonuses: bonuses,
    );
  }

  /// Calculate final score when game is completed
  FinalScore calculateFinalScore(Game game) {
    final baseScore = game.score;
    final gridConfig = GameConfig.levels.firstWhere(
      (l) => l.level == game.level,
      orElse: () => GameConfig.levels.first,
    );

    // Time bonus (only for timed mode)
    int timeBonus = 0;
    if (game.mode == GameMode.timed && game.timeRemaining != null) {
      timeBonus = (game.timeRemaining! * 10);
    }

    // Perfect game bonus (no errors)
    int perfectBonus = 0;
    if (game.isPerfectGame) {
      perfectBonus = GameConfig.perfectGameBonus;
    }

    // Combo master bonus
    int comboBonus = 0;
    if (game.maxCombo >= 5) {
      comboBonus = GameConfig.comboMasterBonus;
    } else if (game.maxCombo >= 3) {
      comboBonus = 100;
    }

    // Difficulty multiplier
    final difficultyMultiplier = gridConfig.multiplier;

    // Calculate total
    final subtotal = baseScore + timeBonus + perfectBonus + comboBonus;
    final totalScore = (subtotal * difficultyMultiplier).round();

    // Calculate stars
    final stars = _calculateStars(game, totalScore);

    return FinalScore(
      baseScore: baseScore,
      timeBonus: timeBonus,
      perfectBonus: perfectBonus,
      comboBonus: comboBonus,
      difficultyMultiplier: difficultyMultiplier,
      totalScore: totalScore,
      stars: stars,
    );
  }

  /// Calculate star rating based on performance
  int _calculateStars(Game game, int totalScore) {
    // Calculate max possible score for this level
    final pairs = game.gridSize.pairs;
    final maxBaseScore = pairs * GameConfig.matchPoints;
    final maxComboScore = _calculateMaxComboScore(pairs);
    final maxScore = maxBaseScore + maxComboScore + GameConfig.perfectGameBonus;

    final percentage = totalScore / maxScore;

    if (percentage >= GameConfig.threeStarThreshold) return 3;
    if (percentage >= GameConfig.twoStarThreshold) return 2;
    if (percentage >= GameConfig.oneStarThreshold) return 1;
    return 0;
  }

  /// Calculate maximum possible combo score
  int _calculateMaxComboScore(int pairs) {
    // If all matches are consecutive, combo builds from 1 to pairs
    // Combo bonus starts from combo 2
    int total = 0;
    for (int i = 2; i <= pairs; i++) {
      total += (i - 1) * GameConfig.comboBonus;
    }
    return total;
  }
}
