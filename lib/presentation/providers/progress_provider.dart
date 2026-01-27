import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Progress data for a single level
class LevelProgress {
  final int level;
  final int stars;
  final int bestScore;
  final int bestMoves;
  final int bestTime;
  final int timesPlayed;
  final int timesCompleted;

  const LevelProgress({
    required this.level,
    this.stars = 0,
    this.bestScore = 0,
    this.bestMoves = 0,
    this.bestTime = 0,
    this.timesPlayed = 0,
    this.timesCompleted = 0,
  });

  LevelProgress copyWith({
    int? stars,
    int? bestScore,
    int? bestMoves,
    int? bestTime,
    int? timesPlayed,
    int? timesCompleted,
  }) {
    return LevelProgress(
      level: level,
      stars: stars ?? this.stars,
      bestScore: bestScore ?? this.bestScore,
      bestMoves: bestMoves ?? this.bestMoves,
      bestTime: bestTime ?? this.bestTime,
      timesPlayed: timesPlayed ?? this.timesPlayed,
      timesCompleted: timesCompleted ?? this.timesCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'level': level,
        'stars': stars,
        'bestScore': bestScore,
        'bestMoves': bestMoves,
        'bestTime': bestTime,
        'timesPlayed': timesPlayed,
        'timesCompleted': timesCompleted,
      };

  factory LevelProgress.fromJson(Map<String, dynamic> json) => LevelProgress(
        level: json['level'] as int,
        stars: json['stars'] as int? ?? 0,
        bestScore: json['bestScore'] as int? ?? 0,
        bestMoves: json['bestMoves'] as int? ?? 0,
        bestTime: json['bestTime'] as int? ?? 0,
        timesPlayed: json['timesPlayed'] as int? ?? 0,
        timesCompleted: json['timesCompleted'] as int? ?? 0,
      );
}

/// Overall game progress state
class GameProgress {
  final Map<int, LevelProgress> levels;
  final int totalStars;
  final int highestUnlockedLevel;

  const GameProgress({
    this.levels = const {},
    this.totalStars = 0,
    this.highestUnlockedLevel = 1,
  });

  GameProgress copyWith({
    Map<int, LevelProgress>? levels,
    int? totalStars,
    int? highestUnlockedLevel,
  }) {
    return GameProgress(
      levels: levels ?? this.levels,
      totalStars: totalStars ?? this.totalStars,
      highestUnlockedLevel: highestUnlockedLevel ?? this.highestUnlockedLevel,
    );
  }

  LevelProgress? getLevelProgress(int level) => levels[level];

  bool isLevelUnlocked(int level) {
    if (level == 1) return true;
    // A level is unlocked if the previous level has at least 1 star
    final previousLevel = levels[level - 1];
    return previousLevel != null && previousLevel.stars >= 1;
  }
}

/// Progress notifier for managing game progress
class ProgressNotifier extends StateNotifier<GameProgress> {
  static const _progressKey = 'game_progress';

  ProgressNotifier() : super(const GameProgress()) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_progressKey);

    if (progressJson != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(progressJson);
        final levelsMap = <int, LevelProgress>{};

        if (data['levels'] != null) {
          final levelsData = data['levels'] as Map<String, dynamic>;
          for (final entry in levelsData.entries) {
            final level = int.parse(entry.key);
            levelsMap[level] = LevelProgress.fromJson(entry.value);
          }
        }

        state = GameProgress(
          levels: levelsMap,
          totalStars: data['totalStars'] as int? ?? 0,
          highestUnlockedLevel: data['highestUnlockedLevel'] as int? ?? 1,
        );
      } catch (e) {
        // If parsing fails, start fresh
        state = const GameProgress();
      }
    }
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final levelsJson = <String, dynamic>{};
    for (final entry in state.levels.entries) {
      levelsJson[entry.key.toString()] = entry.value.toJson();
    }

    final data = {
      'levels': levelsJson,
      'totalStars': state.totalStars,
      'highestUnlockedLevel': state.highestUnlockedLevel,
    };

    await prefs.setString(_progressKey, jsonEncode(data));
  }

  /// Calculate stars based on score, moves, and perfect game status
  int calculateStars({
    required int level,
    required int score,
    required int moves,
    required int pairs,
    required bool isPerfectGame,
  }) {
    // Perfect game = 3 stars
    if (isPerfectGame) return 3;

    // Calculate efficiency (fewer moves = better)
    final minMoves = pairs; // Minimum possible moves = number of pairs
    final maxMoves = pairs * 3; // Maximum reasonable moves
    final moveEfficiency = (maxMoves - moves) / (maxMoves - minMoves);

    if (moveEfficiency >= 0.8) return 3; // 80%+ efficiency = 3 stars
    if (moveEfficiency >= 0.5) return 2; // 50%+ efficiency = 2 stars
    return 1; // Completed = at least 1 star
  }

  /// Update progress after completing a level
  Future<void> completeLevelProgress({
    required int level,
    required int score,
    required int moves,
    required int pairs,
    required int timeSpent,
    required bool isPerfectGame,
  }) async {
    final currentProgress = state.levels[level] ?? LevelProgress(level: level);
    final newStars = calculateStars(
      level: level,
      score: score,
      moves: moves,
      pairs: pairs,
      isPerfectGame: isPerfectGame,
    );

    // Update level progress (keep best values)
    final updatedProgress = currentProgress.copyWith(
      stars: newStars > currentProgress.stars ? newStars : currentProgress.stars,
      bestScore: score > currentProgress.bestScore ? score : currentProgress.bestScore,
      bestMoves: currentProgress.bestMoves == 0 || moves < currentProgress.bestMoves
          ? moves
          : currentProgress.bestMoves,
      bestTime: currentProgress.bestTime == 0 || timeSpent < currentProgress.bestTime
          ? timeSpent
          : currentProgress.bestTime,
      timesPlayed: currentProgress.timesPlayed + 1,
      timesCompleted: currentProgress.timesCompleted + 1,
    );

    final newLevels = Map<int, LevelProgress>.from(state.levels);
    newLevels[level] = updatedProgress;

    // Calculate total stars
    int totalStars = 0;
    for (final progress in newLevels.values) {
      totalStars += progress.stars;
    }

    // Update highest unlocked level
    int highestUnlocked = state.highestUnlockedLevel;
    if (newStars >= 1 && level >= highestUnlocked && level < 20) {
      highestUnlocked = level + 1;
    }

    state = state.copyWith(
      levels: newLevels,
      totalStars: totalStars,
      highestUnlockedLevel: highestUnlocked,
    );

    await _saveProgress();
  }

  /// Record that a level was played (even if not completed)
  Future<void> recordLevelPlayed(int level) async {
    final currentProgress = state.levels[level] ?? LevelProgress(level: level);
    final updatedProgress = currentProgress.copyWith(
      timesPlayed: currentProgress.timesPlayed + 1,
    );

    final newLevels = Map<int, LevelProgress>.from(state.levels);
    newLevels[level] = updatedProgress;

    state = state.copyWith(levels: newLevels);
    await _saveProgress();
  }

  /// Reset all progress
  Future<void> resetProgress() async {
    state = const GameProgress();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
  }
}

/// Progress provider
final progressProvider =
    StateNotifierProvider<ProgressNotifier, GameProgress>((ref) {
  return ProgressNotifier();
});
