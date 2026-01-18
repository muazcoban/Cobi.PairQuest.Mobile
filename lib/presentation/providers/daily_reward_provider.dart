import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/daily_reward.dart';

/// Provider for daily rewards
final dailyRewardProvider =
    StateNotifierProvider<DailyRewardNotifier, DailyRewardProgress>((ref) {
  return DailyRewardNotifier();
});

/// Notifier for managing daily rewards
class DailyRewardNotifier extends StateNotifier<DailyRewardProgress> {
  static const String _storageKey = 'daily_reward_progress';

  DailyRewardNotifier() : super(const DailyRewardProgress()) {
    _loadProgress();
  }

  /// Load progress from local storage
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_storageKey);
      if (progressJson != null) {
        final data = jsonDecode(progressJson) as Map<String, dynamic>;
        state = DailyRewardProgress.fromJson(data);

        // Check if streak should be reset (more than 1 day gap)
        if (!state.isStreakValid) {
          state = state.copyWith(currentStreak: 0);
          _saveProgress();
        }
      }
    } catch (e) {
      // Keep default progress on error
    }
  }

  /// Save progress to local storage
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toJson()));
    } catch (e) {
      // Ignore save errors
    }
  }

  /// Check if daily reward can be claimed
  bool get canClaim => state.canClaimToday;

  /// Get current streak day (1-7)
  int get currentDay => state.nextRewardDay;

  /// Get today's reward
  DailyReward get todaysReward => DailyRewards.getRewardForDay(currentDay);

  /// Claim daily reward
  int claimReward() {
    if (!state.canClaimToday) {
      return 0;
    }

    final reward = todaysReward;
    final newStreak = state.isStreakValid ? state.currentStreak + 1 : 1;

    state = state.copyWith(
      currentStreak: newStreak,
      lastClaimedAt: DateTime.now(),
      totalClaimed: state.totalClaimed + reward.amount,
    );

    _saveProgress();
    return reward.amount;
  }

  /// Get all weekly rewards with claimed status
  List<DailyRewardStatus> getWeeklyRewards() {
    final currentDay = state.nextRewardDay;
    final canClaimToday = state.canClaimToday;

    return DailyRewards.week.map((reward) {
      bool isClaimed = false;
      bool isAvailable = false;

      if (reward.day < currentDay) {
        isClaimed = true;
      } else if (reward.day == currentDay && !canClaimToday) {
        isClaimed = true;
      } else if (reward.day == currentDay && canClaimToday) {
        isAvailable = true;
      }

      return DailyRewardStatus(
        reward: reward,
        isClaimed: isClaimed,
        isAvailable: isAvailable,
      );
    }).toList();
  }

  /// Reset progress (for testing)
  Future<void> resetProgress() async {
    state = const DailyRewardProgress();
    await _saveProgress();
  }
}

/// Status wrapper for a daily reward
class DailyRewardStatus {
  final DailyReward reward;
  final bool isClaimed;
  final bool isAvailable;

  const DailyRewardStatus({
    required this.reward,
    required this.isClaimed,
    required this.isAvailable,
  });
}
