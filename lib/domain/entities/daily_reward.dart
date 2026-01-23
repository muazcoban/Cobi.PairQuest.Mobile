import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Daily reward types
enum RewardType {
  coins,
  gems,
  powerUp,
}

/// Daily reward model
class DailyReward extends Equatable {
  final int day;
  final RewardType type;
  final int coins;
  final int gems;
  final String? powerUpId; // For power-up rewards
  final IconData icon;

  const DailyReward({
    required this.day,
    required this.type,
    this.coins = 0,
    this.gems = 0,
    this.powerUpId,
    required this.icon,
  });

  /// Legacy getter for backward compatibility
  int get amount => coins;

  @override
  List<Object?> get props => [day, type, coins, gems, powerUpId];
}

/// Daily reward progress
class DailyRewardProgress extends Equatable {
  final int currentStreak;
  final DateTime? lastClaimedAt;
  final int totalClaimed;

  const DailyRewardProgress({
    this.currentStreak = 0,
    this.lastClaimedAt,
    this.totalClaimed = 0,
  });

  /// Check if reward can be claimed today
  bool get canClaimToday {
    if (lastClaimedAt == null) return true;

    final now = DateTime.now();
    final lastClaimed = lastClaimedAt!;

    // Check if it's a new day
    return now.year != lastClaimed.year ||
        now.month != lastClaimed.month ||
        now.day != lastClaimed.day;
  }

  /// Check if streak is still valid (not more than 1 day gap)
  bool get isStreakValid {
    if (lastClaimedAt == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(
      lastClaimedAt!.year,
      lastClaimedAt!.month,
      lastClaimedAt!.day,
    );

    final difference = today.difference(lastDay).inDays;
    return difference <= 1;
  }

  /// Get current day in the reward cycle (1-7)
  int get currentDay {
    if (!isStreakValid) return 1;
    return ((currentStreak - 1) % 7) + 1;
  }

  /// Get next reward day
  int get nextRewardDay {
    if (!canClaimToday) {
      return ((currentStreak) % 7) + 1;
    }
    if (!isStreakValid) return 1;
    return (currentStreak % 7) + 1;
  }

  DailyRewardProgress copyWith({
    int? currentStreak,
    DateTime? lastClaimedAt,
    int? totalClaimed,
  }) {
    return DailyRewardProgress(
      currentStreak: currentStreak ?? this.currentStreak,
      lastClaimedAt: lastClaimedAt ?? this.lastClaimedAt,
      totalClaimed: totalClaimed ?? this.totalClaimed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'lastClaimedAt': lastClaimedAt?.toIso8601String(),
      'totalClaimed': totalClaimed,
    };
  }

  factory DailyRewardProgress.fromJson(Map<String, dynamic> json) {
    return DailyRewardProgress(
      currentStreak: json['currentStreak'] ?? 0,
      lastClaimedAt: json['lastClaimedAt'] != null
          ? DateTime.parse(json['lastClaimedAt'])
          : null,
      totalClaimed: json['totalClaimed'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [currentStreak, lastClaimedAt, totalClaimed];
}

/// Predefined daily rewards for a 7-day cycle
class DailyRewards {
  static const List<DailyReward> week = [
    DailyReward(
      day: 1,
      type: RewardType.coins,
      coins: 50,
      icon: Icons.monetization_on_rounded,
    ),
    DailyReward(
      day: 2,
      type: RewardType.coins,
      coins: 75,
      icon: Icons.monetization_on_rounded,
    ),
    DailyReward(
      day: 3,
      type: RewardType.coins,
      coins: 100,
      icon: Icons.monetization_on_rounded,
    ),
    DailyReward(
      day: 4,
      type: RewardType.powerUp,
      coins: 50,
      powerUpId: 'hint', // 1x Hint power-up
      icon: Icons.lightbulb_rounded,
    ),
    DailyReward(
      day: 5,
      type: RewardType.coins,
      coins: 125,
      icon: Icons.monetization_on_rounded,
    ),
    DailyReward(
      day: 6,
      type: RewardType.coins,
      coins: 150,
      icon: Icons.monetization_on_rounded,
    ),
    DailyReward(
      day: 7,
      type: RewardType.gems,
      coins: 200,
      gems: 5,
      icon: Icons.diamond_rounded,
    ),
  ];

  static DailyReward getRewardForDay(int day) {
    final index = ((day - 1) % 7);
    return week[index];
  }
}
