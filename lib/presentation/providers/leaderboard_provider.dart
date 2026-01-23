import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/leaderboard_repository.dart';
import '../../domain/entities/leaderboard_entry.dart';
import 'auth_provider.dart';

/// Provider for leaderboard repository
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository();
});

/// Provider for global leaderboard scores
final globalLeaderboardProvider = FutureProvider.family<List<LeaderboardEntry>, int?>((ref, level) async {
  final repository = ref.watch(leaderboardRepositoryProvider);
  return repository.getTopScores(limit: 50, level: level);
});

/// Provider for local leaderboard
final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, List<LeaderboardEntry>>((ref) {
  return LeaderboardNotifier(ref);
});

/// Notifier for managing the local leaderboard
class LeaderboardNotifier extends StateNotifier<List<LeaderboardEntry>> {
  static const String _storageKey = 'leaderboard';
  static const int _maxEntries = 100;
  final Uuid _uuid = const Uuid();
  final Ref _ref;
  bool _isSyncing = false;
  bool _isLoaded = false;

  LeaderboardNotifier(this._ref) : super([]) {
    _loadLeaderboard();
  }

  /// Check if leaderboard has been loaded
  bool get isLoaded => _isLoaded;

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;

  /// Get count of pending (unsynced) entries
  int get pendingCount => state.where((e) => !e.isSynced).length;

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
    _isLoaded = true;

    // Try to sync pending entries after loading
    _syncPendingEntries();
  }

  /// Wait for leaderboard to be loaded
  Future<void> waitForLoad() async {
    if (_isLoaded) return;
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (_isLoaded) return;
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

  /// Add a new entry to the leaderboard (local and optionally global)
  Future<void> addEntry({
    required String playerName,
    required int level,
    required int score,
    required int stars,
    required int moves,
    required int timeSeconds,
    bool submitToGlobal = true,
  }) async {
    final entry = LeaderboardEntry(
      id: _uuid.v4(),
      playerName: playerName.isEmpty ? 'Player' : playerName,
      level: level,
      score: score,
      stars: stars,
      moves: moves,
      timeSeconds: timeSeconds,
      playedAt: DateTime.now(),
      isSynced: false, // Start as not synced
    );

    final newList = [...state, entry];

    // Sort by score descending
    newList.sort((a, b) => b.score.compareTo(a.score));

    // Keep only top entries
    if (newList.length > _maxEntries) {
      newList.removeRange(_maxEntries, newList.length);
    }

    state = newList;
    await _saveLeaderboard();

    // Try to submit to global leaderboard if user is authenticated
    if (submitToGlobal) {
      await _trySubmitEntry(entry, level);
    }
  }

  /// Try to submit a single entry to global leaderboard
  Future<bool> _trySubmitEntry(LeaderboardEntry entry, int level) async {
    final authState = _ref.read(authProvider);
    if (!authState.isAuthenticated) return false;

    try {
      final repository = _ref.read(leaderboardRepositoryProvider);
      final success = await repository.submitScore(
        entry: entry,
        userId: authState.uid,
      );

      if (success) {
        // Mark entry as synced
        _markAsSynced(entry.id);
        // Refresh global leaderboard
        _ref.invalidate(globalLeaderboardProvider(null));
        _ref.invalidate(globalLeaderboardProvider(level));
        return true;
      }
    } catch (e) {
      // Failed to sync - will retry later
    }
    return false;
  }

  /// Mark an entry as synced
  void _markAsSynced(String entryId) {
    final index = state.indexWhere((e) => e.id == entryId);
    if (index != -1) {
      final updatedList = List<LeaderboardEntry>.from(state);
      updatedList[index] = updatedList[index].copyWith(
        isSynced: true,
        syncedAt: DateTime.now(),
      );
      state = updatedList;
      _saveLeaderboard();
    }
  }

  /// Sync all pending (unsynced) entries to global leaderboard
  Future<int> _syncPendingEntries() async {
    if (_isSyncing) return 0;

    final authState = _ref.read(authProvider);
    if (!authState.isAuthenticated) return 0;

    final pendingEntries = state.where((e) => !e.isSynced).toList();
    if (pendingEntries.isEmpty) return 0;

    _isSyncing = true;
    int syncedCount = 0;

    try {
      final repository = _ref.read(leaderboardRepositoryProvider);

      for (final entry in pendingEntries) {
        try {
          final success = await repository.submitScore(
            entry: entry,
            userId: authState.uid,
          );

          if (success) {
            _markAsSynced(entry.id);
            syncedCount++;
          }

          // Small delay between requests to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          // Continue with next entry
        }
      }

      if (syncedCount > 0) {
        // Refresh global leaderboard
        _ref.invalidate(globalLeaderboardProvider(null));
      }
    } finally {
      _isSyncing = false;
    }

    return syncedCount;
  }

  /// Manually trigger sync of pending entries
  Future<int> syncPending() async {
    return _syncPendingEntries();
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
