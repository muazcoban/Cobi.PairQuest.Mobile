import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/leaderboard_entry.dart';

/// Provider for local leaderboard
final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, List<LeaderboardEntry>>((ref) {
  return LeaderboardNotifier();
});

/// Notifier for managing the local leaderboard
class LeaderboardNotifier extends StateNotifier<List<LeaderboardEntry>> {
  static const String _storageKey = 'leaderboard';
  static const int _maxEntries = 100;
  final Uuid _uuid = const Uuid();

  LeaderboardNotifier() : super([]) {
    _loadLeaderboard();
  }

  /// Load leaderboard from local storage
  Future<void> _loadLeaderboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final leaderboardJson = prefs.getString(_storageKey);
      if (leaderboardJson != null) {
        final data = jsonDecode(leaderboardJson) as List<dynamic>;
        state = data
            .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Keep empty leaderboard on error
    }
  }

  /// Save leaderboard to local storage
  Future<void> _saveLeaderboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = state.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(data));
    } catch (e) {
      // Ignore save errors
    }
  }

  /// Add a new entry to the leaderboard
  void addEntry({
    required String playerName,
    required int level,
    required int score,
    required int stars,
    required int moves,
    required int timeSeconds,
  }) {
    final entry = LeaderboardEntry(
      id: _uuid.v4(),
      playerName: playerName.isEmpty ? 'Player' : playerName,
      level: level,
      score: score,
      stars: stars,
      moves: moves,
      timeSeconds: timeSeconds,
      playedAt: DateTime.now(),
    );

    final newList = [...state, entry];

    // Sort by score descending
    newList.sort((a, b) => b.score.compareTo(a.score));

    // Keep only top entries
    if (newList.length > _maxEntries) {
      newList.removeRange(_maxEntries, newList.length);
    }

    state = newList;
    _saveLeaderboard();
  }

  /// Get top entries
  List<LeaderboardEntry> getTopEntries([int count = 10]) {
    return state.take(count).toList();
  }

  /// Get entries for a specific level
  List<LeaderboardEntry> getEntriesForLevel(int level, [int count = 10]) {
    return state
        .where((e) => e.level == level)
        .take(count)
        .toList();
  }

  /// Get player's best entry
  LeaderboardEntry? getPlayerBest(String playerName) {
    final playerEntries = state
        .where((e) => e.playerName.toLowerCase() == playerName.toLowerCase())
        .toList();

    if (playerEntries.isEmpty) return null;

    playerEntries.sort((a, b) => b.score.compareTo(a.score));
    return playerEntries.first;
  }

  /// Get player's rank
  int? getPlayerRank(String playerName) {
    for (int i = 0; i < state.length; i++) {
      if (state[i].playerName.toLowerCase() == playerName.toLowerCase()) {
        return i + 1;
      }
    }
    return null;
  }

  /// Clear leaderboard
  Future<void> clearLeaderboard() async {
    state = [];
    await _saveLeaderboard();
  }
}
