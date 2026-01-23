import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/daily_reward.dart';
import '../../domain/entities/power_up.dart';
import 'wallet_provider.dart';
import 'power_up_provider.dart';

/// Provider for daily rewards
final dailyRewardProvider =
    StateNotifierProvider<DailyRewardNotifier, DailyRewardProgress>((ref) {
  return DailyRewardNotifier(ref);
});

/// Notifier for managing daily rewards
class DailyRewardNotifier extends StateNotifier<DailyRewardProgress> {
  static const String _storageKey = 'daily_reward_progress';
  bool _isLoaded = false;
  final Ref _ref;

  DailyRewardNotifier(this._ref) : super(const DailyRewardProgress()) {
    _loadProgress();
  }

  /// Check if progress has been loaded from storage
  bool get isLoaded => _isLoaded;

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
    _isLoaded = true;
  }

  /// Wait for progress to be loaded
  Future<void> waitForLoad() async {
    if (_isLoaded) return;
    // Wait for async load to complete (max 500ms)
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (_isLoaded) return;
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

  /// Claim daily reward and add to wallet/inventory
  /// Returns the claimed reward, or null if cannot claim
  Future<DailyReward?> claimReward() async {
    if (!state.canClaimToday) {
      return null;
    }

    final reward = todaysReward;
    final newStreak = state.isStreakValid ? state.currentStreak + 1 : 1;

    // Add coins to wallet
    if (reward.coins > 0) {
      await _ref.read(walletProvider.notifier).addCoins(reward.coins);
    }

    // Add gems to wallet
    if (reward.gems > 0) {
      await _ref.read(walletProvider.notifier).addGems(reward.gems);
    }

    // Add power-up to inventory
    if (reward.powerUpId != null) {
      final powerUpType = _getPowerUpTypeFromId(reward.powerUpId!);
      if (powerUpType != null) {
        await _ref.read(powerUpInventoryProvider.notifier).addPowerUp(powerUpType, 1);
      }
    }

    state = state.copyWith(
      currentStreak: newStreak,
      lastClaimedAt: DateTime.now(),
      totalClaimed: state.totalClaimed + reward.coins,
    );

    _saveProgress();
    return reward;
  }

  /// Convert power-up ID to PowerUpType
  PowerUpType? _getPowerUpTypeFromId(String id) {
    switch (id) {
      case 'peek':
        return PowerUpType.peek;
      case 'freeze':
        return PowerUpType.freeze;
      case 'hint':
        return PowerUpType.hint;
      case 'shuffle':
        return PowerUpType.shuffle;
      case 'timeBonus':
        return PowerUpType.timeBonus;
      case 'magnet':
        return PowerUpType.magnet;
      default:
        return null;
    }
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
