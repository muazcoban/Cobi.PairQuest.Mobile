import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

/// Player statistics
@freezed
abstract class PlayerStats with _$PlayerStats {
  const factory PlayerStats({
    @Default(0) int totalGamesPlayed,
    @Default(0) int totalGamesWon,
    @Default(0) int totalScore,
    @Default(0) int highestScore,
    @Default(0) int totalMatches,
    @Default(0) int perfectGames,
    @Default(0) int maxCombo,
    @Default(0) int totalPlayTimeSeconds,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
  }) = _PlayerStats;

  factory PlayerStats.fromJson(Map<String, dynamic> json) =>
      _$PlayerStatsFromJson(json);
}

/// Level progress tracking
@freezed
abstract class LevelProgress with _$LevelProgress {
  const factory LevelProgress({
    required int level,
    @Default(0) int bestScore,
    @Default(0) int bestMoves,
    @Default(0) int bestTimeSeconds,
    @Default(0) int stars,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
  }) = _LevelProgress;

  factory LevelProgress.fromJson(Map<String, dynamic> json) =>
      _$LevelProgressFromJson(json);
}

/// Player data model
@freezed
abstract class Player with _$Player {
  const Player._();

  const factory Player({
    required String id,
    @Default('Player') String username,
    required DateTime createdAt,
    required DateTime lastActiveAt,
    @Default(PlayerStats()) PlayerStats stats,
    @Default({}) Map<int, LevelProgress> levelProgress,
    @Default(['animals']) List<String> unlockedThemes,
    @Default(1) int currentLevel,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  /// Get progress for a specific level
  LevelProgress? getProgressForLevel(int level) => levelProgress[level];

  /// Check if a level is unlocked
  bool isLevelUnlocked(int level) {
    if (level == 1) return true;
    final previousProgress = levelProgress[level - 1];
    return previousProgress?.isCompleted ?? false;
  }

  /// Get the highest unlocked level
  int get highestUnlockedLevel {
    int highest = 1;
    for (final entry in levelProgress.entries) {
      if (entry.value.isCompleted && entry.key >= highest) {
        highest = entry.key + 1;
      }
    }
    return highest.clamp(1, 10);
  }
}
