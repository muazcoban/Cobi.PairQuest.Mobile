import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/player_stats.dart';

/// Provider for player statistics
final statsProvider = StateNotifierProvider<StatsNotifier, PlayerStats>((ref) {
  return StatsNotifier();
});

/// Notifier for managing player statistics
class StatsNotifier extends StateNotifier<PlayerStats> {
  static const String _storageKey = 'player_stats';

  StatsNotifier() : super(PlayerStats(firstPlayedAt: DateTime.now())) {
    _loadStats();
  }

  /// Load stats from local storage
  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_storageKey);
      if (statsJson != null) {
        final data = jsonDecode(statsJson) as Map<String, dynamic>;
        state = PlayerStats.fromJson(data);
      }
    } catch (e) {
      // Keep default stats on error
    }
  }

  /// Save stats to local storage
  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toJson()));
    } catch (e) {
      // Ignore save errors
    }
  }

  /// Record a game completion (win)
  void recordGameWin({
    required int level,
    required int score,
    required int moves,
    required int matches,
    required int timeSeconds,
    required int maxCombo,
    required int stars,
    required bool isPerfectGame,
  }) {
    // Update level stats
    final levelStats = Map<int, LevelStats>.from(state.levelStats);
    final existingStats = levelStats[level] ?? LevelStats(level: level);

    levelStats[level] = existingStats.copyWith(
      completed: true,
      timesPlayed: existingStats.timesPlayed + 1,
      timesWon: existingStats.timesWon + 1,
      bestScore: score > existingStats.bestScore ? score : null,
      bestMoves: existingStats.bestMoves == 0 || moves < existingStats.bestMoves
          ? moves
          : null,
      bestTimeSeconds:
          existingStats.bestTimeSeconds == 0 || timeSeconds < existingStats.bestTimeSeconds
              ? timeSeconds
              : null,
      bestStars: stars > existingStats.bestStars ? stars : null,
      bestCombo: maxCombo > existingStats.bestCombo ? maxCombo : null,
    );

    // Update streak
    final newStreak = state.currentStreak + 1;
    final newLongestStreak =
        newStreak > state.longestStreak ? newStreak : state.longestStreak;

    state = state.copyWith(
      totalGamesPlayed: state.totalGamesPlayed + 1,
      totalGamesWon: state.totalGamesWon + 1,
      totalMatchesMade: state.totalMatchesMade + matches,
      totalMovesMade: state.totalMovesMade + moves,
      totalPlayTimeSeconds: state.totalPlayTimeSeconds + timeSeconds,
      highestCombo: maxCombo > state.highestCombo ? maxCombo : null,
      perfectGames: isPerfectGame ? state.perfectGames + 1 : null,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      levelStats: levelStats,
      lastPlayedAt: DateTime.now(),
      totalStarsEarned: state.totalStarsEarned + stars,
    );

    _saveStats();
  }

  /// Record a game loss
  void recordGameLoss({
    required int level,
    required int matches,
    required int moves,
    required int timeSeconds,
  }) {
    // Update level stats
    final levelStats = Map<int, LevelStats>.from(state.levelStats);
    final existingStats = levelStats[level] ?? LevelStats(level: level);

    levelStats[level] = existingStats.copyWith(
      timesPlayed: existingStats.timesPlayed + 1,
    );

    state = state.copyWith(
      totalGamesPlayed: state.totalGamesPlayed + 1,
      totalGamesLost: state.totalGamesLost + 1,
      totalMatchesMade: state.totalMatchesMade + matches,
      totalMovesMade: state.totalMovesMade + moves,
      totalPlayTimeSeconds: state.totalPlayTimeSeconds + timeSeconds,
      currentStreak: 0, // Reset streak on loss
      levelStats: levelStats,
      lastPlayedAt: DateTime.now(),
    );

    _saveStats();
  }

  /// Get stats for a specific level
  LevelStats? getLevelStats(int level) {
    return state.levelStats[level];
  }

  /// Reset all statistics
  Future<void> resetStats() async {
    state = PlayerStats(firstPlayedAt: DateTime.now());
    await _saveStats();
  }
}
