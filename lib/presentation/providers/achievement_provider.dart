import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/player_stats.dart';
import 'stats_provider.dart';

/// Provider for achievement progress
final achievementProvider =
    StateNotifierProvider<AchievementNotifier, Map<String, AchievementProgress>>(
        (ref) {
  final stats = ref.watch(statsProvider);
  return AchievementNotifier(stats);
});

/// Provider to get newly unlocked achievements
final newlyUnlockedAchievementProvider = StateProvider<Achievement?>((ref) => null);

/// Notifier for managing achievements
class AchievementNotifier
    extends StateNotifier<Map<String, AchievementProgress>> {
  static const String _storageKey = 'achievement_progress';
  final PlayerStats _stats;

  AchievementNotifier(this._stats) : super({}) {
    _loadProgress();
  }

  /// Load progress from local storage
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_storageKey);
      if (progressJson != null && mounted) {
        final data = jsonDecode(progressJson) as Map<String, dynamic>;
        final progress = <String, AchievementProgress>{};
        data.forEach((key, value) {
          progress[key] = AchievementProgress.fromJson(value);
        });
        if (mounted) state = progress;
      }
    } catch (e) {
      // Keep empty progress on error
    }

    // Check for any new unlocks based on current stats
    if (mounted) _checkAllAchievements();
  }

  /// Save progress to local storage
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = <String, dynamic>{};
      state.forEach((key, value) {
        data[key] = value.toJson();
      });
      await prefs.setString(_storageKey, jsonEncode(data));
    } catch (e) {
      // Ignore save errors
    }
  }

  /// Check all achievements and update progress
  void _checkAllAchievements() {
    if (!mounted) return;

    final newState = Map<String, AchievementProgress>.from(state);

    for (final achievement in Achievements.all) {
      final currentProgress = _getProgressForAchievement(achievement);
      final existing = newState[achievement.id];

      if (existing == null || !existing.isUnlocked) {
        final wasUnlocked = existing?.isUnlocked ?? false;
        final isNowUnlocked = currentProgress >= achievement.targetValue;

        newState[achievement.id] = AchievementProgress(
          achievementId: achievement.id,
          currentValue: currentProgress,
          isUnlocked: isNowUnlocked,
          unlockedAt: isNowUnlocked && !wasUnlocked ? DateTime.now() : existing?.unlockedAt,
        );
      }
    }

    if (mounted) {
      state = newState;
      _saveProgress();
    }
  }

  /// Get current progress for an achievement based on stats
  int _getProgressForAchievement(Achievement achievement) {
    switch (achievement.type) {
      case AchievementType.games:
        return _stats.totalGamesWon;
      case AchievementType.matches:
        return _stats.totalMatchesMade;
      case AchievementType.combos:
        return _stats.highestCombo;
      case AchievementType.perfect:
        return _stats.perfectGames;
      case AchievementType.streak:
        return _stats.longestStreak;
      case AchievementType.levels:
        return _stats.highestLevelCompleted;
      case AchievementType.stars:
        return _stats.totalStarsEarned;
      case AchievementType.speed:
        return 0; // TODO: Implement speed tracking
      case AchievementType.time:
        return _stats.totalPlayTimeSeconds ~/ 60; // In minutes
      case AchievementType.special:
        return 0;
    }
  }

  /// Get progress for a specific achievement
  AchievementProgress getProgress(String achievementId) {
    return state[achievementId] ??
        AchievementProgress(achievementId: achievementId);
  }

  /// Get list of all unlocked achievements
  List<Achievement> getUnlockedAchievements() {
    return Achievements.all
        .where((a) => state[a.id]?.isUnlocked ?? false)
        .toList();
  }

  /// Get list of locked achievements
  List<Achievement> getLockedAchievements() {
    return Achievements.all
        .where((a) => !(state[a.id]?.isUnlocked ?? false))
        .toList();
  }

  /// Get total unlocked count
  int get unlockedCount =>
      state.values.where((p) => p.isUnlocked).length;

  /// Get total achievement count
  int get totalCount => Achievements.all.length;

  /// Check and update achievements (call after game events)
  List<Achievement> checkAchievements() {
    final previouslyUnlocked = Set<String>.from(
      state.entries
          .where((e) => e.value.isUnlocked)
          .map((e) => e.key),
    );

    _checkAllAchievements();

    final newlyUnlocked = state.entries
        .where((e) => e.value.isUnlocked && !previouslyUnlocked.contains(e.key))
        .map((e) => Achievements.getById(e.key))
        .whereType<Achievement>()
        .toList();

    // Notification is now handled by the caller using NotificationSettingsNotifier
    // to respect user's notification preferences

    return newlyUnlocked;
  }

  /// Reset all achievements
  Future<void> resetAchievements() async {
    state = {};
    await _saveProgress();
  }
}
