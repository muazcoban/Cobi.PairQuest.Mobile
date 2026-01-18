import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Achievement types
enum AchievementType {
  games,
  matches,
  combos,
  perfect,
  streak,
  speed,
  levels,
  stars,
  time,
  special,
}

/// Achievement rarity for visual styling
enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

/// Achievement model
class Achievement extends Equatable {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final AchievementType type;
  final AchievementRarity rarity;
  final int targetValue;
  final int rewardPoints;

  const Achievement({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.type,
    this.rarity = AchievementRarity.common,
    required this.targetValue,
    this.rewardPoints = 100,
  });

  @override
  List<Object?> get props => [id, titleKey, type, targetValue];
}

/// Player's progress on an achievement
class AchievementProgress extends Equatable {
  final String achievementId;
  final int currentValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementProgress({
    required this.achievementId,
    this.currentValue = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  AchievementProgress copyWith({
    String? achievementId,
    int? currentValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementProgress(
      achievementId: achievementId ?? this.achievementId,
      currentValue: currentValue ?? this.currentValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'currentValue': currentValue,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      achievementId: json['achievementId'] ?? '',
      currentValue: json['currentValue'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
    );
  }

  @override
  List<Object?> get props => [achievementId, currentValue, isUnlocked, unlockedAt];
}

/// All achievements in the game
class Achievements {
  static const List<Achievement> all = [
    // Games played achievements
    Achievement(
      id: 'first_game',
      titleKey: 'achievement_first_game',
      descriptionKey: 'achievement_first_game_desc',
      icon: Icons.play_arrow_rounded,
      type: AchievementType.games,
      rarity: AchievementRarity.common,
      targetValue: 1,
      rewardPoints: 50,
    ),
    Achievement(
      id: 'games_10',
      titleKey: 'achievement_games_10',
      descriptionKey: 'achievement_games_10_desc',
      icon: Icons.videogame_asset_rounded,
      type: AchievementType.games,
      rarity: AchievementRarity.common,
      targetValue: 10,
      rewardPoints: 100,
    ),
    Achievement(
      id: 'games_50',
      titleKey: 'achievement_games_50',
      descriptionKey: 'achievement_games_50_desc',
      icon: Icons.sports_esports_rounded,
      type: AchievementType.games,
      rarity: AchievementRarity.rare,
      targetValue: 50,
      rewardPoints: 250,
    ),
    Achievement(
      id: 'games_100',
      titleKey: 'achievement_games_100',
      descriptionKey: 'achievement_games_100_desc',
      icon: Icons.gamepad_rounded,
      type: AchievementType.games,
      rarity: AchievementRarity.epic,
      targetValue: 100,
      rewardPoints: 500,
    ),

    // Match achievements
    Achievement(
      id: 'matches_100',
      titleKey: 'achievement_matches_100',
      descriptionKey: 'achievement_matches_100_desc',
      icon: Icons.join_full_rounded,
      type: AchievementType.matches,
      rarity: AchievementRarity.common,
      targetValue: 100,
      rewardPoints: 100,
    ),
    Achievement(
      id: 'matches_500',
      titleKey: 'achievement_matches_500',
      descriptionKey: 'achievement_matches_500_desc',
      icon: Icons.hub_rounded,
      type: AchievementType.matches,
      rarity: AchievementRarity.rare,
      targetValue: 500,
      rewardPoints: 250,
    ),
    Achievement(
      id: 'matches_1000',
      titleKey: 'achievement_matches_1000',
      descriptionKey: 'achievement_matches_1000_desc',
      icon: Icons.psychology_rounded,
      type: AchievementType.matches,
      rarity: AchievementRarity.epic,
      targetValue: 1000,
      rewardPoints: 500,
    ),

    // Combo achievements
    Achievement(
      id: 'combo_3',
      titleKey: 'achievement_combo_3',
      descriptionKey: 'achievement_combo_3_desc',
      icon: Icons.flash_on_rounded,
      type: AchievementType.combos,
      rarity: AchievementRarity.common,
      targetValue: 3,
      rewardPoints: 100,
    ),
    Achievement(
      id: 'combo_5',
      titleKey: 'achievement_combo_5',
      descriptionKey: 'achievement_combo_5_desc',
      icon: Icons.bolt_rounded,
      type: AchievementType.combos,
      rarity: AchievementRarity.rare,
      targetValue: 5,
      rewardPoints: 250,
    ),
    Achievement(
      id: 'combo_8',
      titleKey: 'achievement_combo_8',
      descriptionKey: 'achievement_combo_8_desc',
      icon: Icons.local_fire_department_rounded,
      type: AchievementType.combos,
      rarity: AchievementRarity.epic,
      targetValue: 8,
      rewardPoints: 500,
    ),
    Achievement(
      id: 'combo_10',
      titleKey: 'achievement_combo_10',
      descriptionKey: 'achievement_combo_10_desc',
      icon: Icons.whatshot_rounded,
      type: AchievementType.combos,
      rarity: AchievementRarity.legendary,
      targetValue: 10,
      rewardPoints: 1000,
    ),

    // Perfect game achievements
    Achievement(
      id: 'perfect_1',
      titleKey: 'achievement_perfect_1',
      descriptionKey: 'achievement_perfect_1_desc',
      icon: Icons.star_rounded,
      type: AchievementType.perfect,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      rewardPoints: 200,
    ),
    Achievement(
      id: 'perfect_5',
      titleKey: 'achievement_perfect_5',
      descriptionKey: 'achievement_perfect_5_desc',
      icon: Icons.stars_rounded,
      type: AchievementType.perfect,
      rarity: AchievementRarity.epic,
      targetValue: 5,
      rewardPoints: 500,
    ),
    Achievement(
      id: 'perfect_10',
      titleKey: 'achievement_perfect_10',
      descriptionKey: 'achievement_perfect_10_desc',
      icon: Icons.workspace_premium_rounded,
      type: AchievementType.perfect,
      rarity: AchievementRarity.legendary,
      targetValue: 10,
      rewardPoints: 1000,
    ),

    // Win streak achievements
    Achievement(
      id: 'streak_3',
      titleKey: 'achievement_streak_3',
      descriptionKey: 'achievement_streak_3_desc',
      icon: Icons.trending_up_rounded,
      type: AchievementType.streak,
      rarity: AchievementRarity.common,
      targetValue: 3,
      rewardPoints: 100,
    ),
    Achievement(
      id: 'streak_7',
      titleKey: 'achievement_streak_7',
      descriptionKey: 'achievement_streak_7_desc',
      icon: Icons.rocket_launch_rounded,
      type: AchievementType.streak,
      rarity: AchievementRarity.rare,
      targetValue: 7,
      rewardPoints: 300,
    ),
    Achievement(
      id: 'streak_10',
      titleKey: 'achievement_streak_10',
      descriptionKey: 'achievement_streak_10_desc',
      icon: Icons.military_tech_rounded,
      type: AchievementType.streak,
      rarity: AchievementRarity.epic,
      targetValue: 10,
      rewardPoints: 500,
    ),

    // Level achievements
    Achievement(
      id: 'level_5',
      titleKey: 'achievement_level_5',
      descriptionKey: 'achievement_level_5_desc',
      icon: Icons.looks_5_rounded,
      type: AchievementType.levels,
      rarity: AchievementRarity.common,
      targetValue: 5,
      rewardPoints: 150,
    ),
    Achievement(
      id: 'level_10',
      titleKey: 'achievement_level_10',
      descriptionKey: 'achievement_level_10_desc',
      icon: Icons.emoji_events_rounded,
      type: AchievementType.levels,
      rarity: AchievementRarity.epic,
      targetValue: 10,
      rewardPoints: 500,
    ),

    // Star achievements
    Achievement(
      id: 'stars_30',
      titleKey: 'achievement_stars_30',
      descriptionKey: 'achievement_stars_30_desc',
      icon: Icons.grade_rounded,
      type: AchievementType.stars,
      rarity: AchievementRarity.epic,
      targetValue: 30,
      rewardPoints: 500,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
