/// Game configuration constants
class GameConfig {
  GameConfig._();

  // Animation durations (milliseconds)
  static const int cardFlipDuration = 400;
  static const int cardMatchDelay = 800;
  static const int cardShakeDuration = 400;
  static const int scorePopupDuration = 1000;
  static const int gameCompletionDelay = 1200; // Delay before showing completion popup

  // Scoring
  static const int matchPoints = 100;
  static const int comboBonus = 50;
  static const int firstTryBonus = 25;
  static const int errorPenalty = 10;
  static const int perfectGameBonus = 500;
  static const int speedBonus = 200;
  static const int comboMasterBonus = 300;

  // Time limits per difficulty (seconds)
  static const Map<int, int> timeLimits = {
    1: 60,   // 2x2
    2: 60,   // 2x3
    3: 90,   // 2x4
    4: 90,   // 3x4
    5: 120,  // 4x4
    6: 150,  // 4x5
    7: 180,  // 5x6
    8: 210,  // 6x6
    9: 240,  // 6x7
    10: 300, // 8x8
  };

  // Star thresholds (percentage of max possible score)
  static const double oneStarThreshold = 0.3;
  static const double twoStarThreshold = 0.6;
  static const double threeStarThreshold = 0.85;

  // Difficulty multipliers
  static const Map<String, double> difficultyMultipliers = {
    'tutorial': 0.5,
    'very_easy': 0.75,
    'easy': 1.0,
    'medium': 1.5,
    'hard': 2.0,
    'very_hard': 2.5,
    'expert': 3.0,
  };

  // Grid configurations
  static const List<GridConfig> levels = [
    GridConfig(level: 1, rows: 2, cols: 2, difficulty: 'tutorial'),
    GridConfig(level: 2, rows: 2, cols: 3, difficulty: 'very_easy'),
    GridConfig(level: 3, rows: 2, cols: 4, difficulty: 'easy'),
    GridConfig(level: 4, rows: 3, cols: 4, difficulty: 'easy'),
    GridConfig(level: 5, rows: 4, cols: 4, difficulty: 'medium'),
    GridConfig(level: 6, rows: 4, cols: 5, difficulty: 'medium'),
    GridConfig(level: 7, rows: 5, cols: 6, difficulty: 'hard'),
    GridConfig(level: 8, rows: 6, cols: 6, difficulty: 'hard'),
    GridConfig(level: 9, rows: 6, cols: 7, difficulty: 'very_hard'),
    GridConfig(level: 10, rows: 8, cols: 8, difficulty: 'expert'),
  ];

  // Card reveal time for power-ups (milliseconds)
  static const int peekDuration = 2000;

  // Timer warning threshold (seconds remaining)
  static const int timerWarningThreshold = 30;
  static const int timerDangerThreshold = 10;
}

/// Grid configuration for each level
class GridConfig {
  final int level;
  final int rows;
  final int cols;
  final String difficulty;

  const GridConfig({
    required this.level,
    required this.rows,
    required this.cols,
    required this.difficulty,
  });

  int get totalCards => rows * cols;
  int get pairs => totalCards ~/ 2;

  double get multiplier => GameConfig.difficultyMultipliers[difficulty] ?? 1.0;
  int get timeLimit => GameConfig.timeLimits[level] ?? 120;
}
