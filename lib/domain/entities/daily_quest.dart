import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Types of daily quests
enum QuestType {
  playGames,
  winGames,
  makeMatches,
  getCombo,
  perfectGame,
  earnStars,
}

/// Daily quest model
class DailyQuest extends Equatable {
  final String id;
  final QuestType type;
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final int targetValue;
  final int rewardPoints;

  const DailyQuest({
    required this.id,
    required this.type,
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.targetValue,
    this.rewardPoints = 50,
  });

  @override
  List<Object?> get props => [id, type, targetValue];
}

/// Player's progress on a daily quest
class QuestProgress extends Equatable {
  final String questId;
  final int currentValue;
  final bool isCompleted;
  final bool isRewardClaimed;

  const QuestProgress({
    required this.questId,
    this.currentValue = 0,
    this.isCompleted = false,
    this.isRewardClaimed = false,
  });

  QuestProgress copyWith({
    String? questId,
    int? currentValue,
    bool? isCompleted,
    bool? isRewardClaimed,
  }) {
    return QuestProgress(
      questId: questId ?? this.questId,
      currentValue: currentValue ?? this.currentValue,
      isCompleted: isCompleted ?? this.isCompleted,
      isRewardClaimed: isRewardClaimed ?? this.isRewardClaimed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questId': questId,
      'currentValue': currentValue,
      'isCompleted': isCompleted,
      'isRewardClaimed': isRewardClaimed,
    };
  }

  factory QuestProgress.fromJson(Map<String, dynamic> json) {
    return QuestProgress(
      questId: json['questId'] ?? '',
      currentValue: json['currentValue'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      isRewardClaimed: json['isRewardClaimed'] ?? false,
    );
  }

  @override
  List<Object?> get props => [questId, currentValue, isCompleted, isRewardClaimed];
}

/// Daily quests data for a specific day
class DailyQuestsData extends Equatable {
  final DateTime date;
  final List<DailyQuest> quests;
  final Map<String, QuestProgress> progress;

  const DailyQuestsData({
    required this.date,
    required this.quests,
    this.progress = const {},
  });

  /// Check if quests need to be refreshed (new day)
  bool get needsRefresh {
    final now = DateTime.now();
    return date.year != now.year ||
        date.month != now.month ||
        date.day != now.day;
  }

  /// Get completed quest count
  int get completedCount =>
      progress.values.where((p) => p.isCompleted).length;

  /// Get all completed count
  int get totalCount => quests.length;

  /// Get time until refresh
  Duration get timeUntilRefresh {
    final tomorrow = DateTime(date.year, date.month, date.day + 1);
    return tomorrow.difference(DateTime.now());
  }

  DailyQuestsData copyWith({
    DateTime? date,
    List<DailyQuest>? quests,
    Map<String, QuestProgress>? progress,
  }) {
    return DailyQuestsData(
      date: date ?? this.date,
      quests: quests ?? this.quests,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'quests': quests.map((q) => {
        'id': q.id,
        'type': q.type.index,
        'targetValue': q.targetValue,
        'rewardPoints': q.rewardPoints,
      }).toList(),
      'progress': progress.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  @override
  List<Object?> get props => [date, quests, progress];
}

/// Quest templates for daily generation
class QuestTemplates {
  static const List<DailyQuest> easy = [
    DailyQuest(
      id: 'play_1',
      type: QuestType.playGames,
      titleKey: 'quest_play_1',
      descriptionKey: 'quest_play_1_desc',
      icon: Icons.play_arrow_rounded,
      targetValue: 1,
      rewardPoints: 25,
    ),
    DailyQuest(
      id: 'matches_10',
      type: QuestType.makeMatches,
      titleKey: 'quest_matches_10',
      descriptionKey: 'quest_matches_10_desc',
      icon: Icons.join_full_rounded,
      targetValue: 10,
      rewardPoints: 30,
    ),
    DailyQuest(
      id: 'stars_3',
      type: QuestType.earnStars,
      titleKey: 'quest_stars_3',
      descriptionKey: 'quest_stars_3_desc',
      icon: Icons.star_rounded,
      targetValue: 3,
      rewardPoints: 35,
    ),
  ];

  static const List<DailyQuest> medium = [
    DailyQuest(
      id: 'play_3',
      type: QuestType.playGames,
      titleKey: 'quest_play_3',
      descriptionKey: 'quest_play_3_desc',
      icon: Icons.videogame_asset_rounded,
      targetValue: 3,
      rewardPoints: 50,
    ),
    DailyQuest(
      id: 'win_2',
      type: QuestType.winGames,
      titleKey: 'quest_win_2',
      descriptionKey: 'quest_win_2_desc',
      icon: Icons.emoji_events_rounded,
      targetValue: 2,
      rewardPoints: 60,
    ),
    DailyQuest(
      id: 'matches_30',
      type: QuestType.makeMatches,
      titleKey: 'quest_matches_30',
      descriptionKey: 'quest_matches_30_desc',
      icon: Icons.hub_rounded,
      targetValue: 30,
      rewardPoints: 55,
    ),
    DailyQuest(
      id: 'combo_3',
      type: QuestType.getCombo,
      titleKey: 'quest_combo_3',
      descriptionKey: 'quest_combo_3_desc',
      icon: Icons.flash_on_rounded,
      targetValue: 3,
      rewardPoints: 50,
    ),
  ];

  static const List<DailyQuest> hard = [
    DailyQuest(
      id: 'win_5',
      type: QuestType.winGames,
      titleKey: 'quest_win_5',
      descriptionKey: 'quest_win_5_desc',
      icon: Icons.military_tech_rounded,
      targetValue: 5,
      rewardPoints: 100,
    ),
    DailyQuest(
      id: 'perfect_1',
      type: QuestType.perfectGame,
      titleKey: 'quest_perfect_1',
      descriptionKey: 'quest_perfect_1_desc',
      icon: Icons.workspace_premium_rounded,
      targetValue: 1,
      rewardPoints: 100,
    ),
    DailyQuest(
      id: 'combo_5',
      type: QuestType.getCombo,
      titleKey: 'quest_combo_5',
      descriptionKey: 'quest_combo_5_desc',
      icon: Icons.local_fire_department_rounded,
      targetValue: 5,
      rewardPoints: 100,
    ),
    DailyQuest(
      id: 'stars_6',
      type: QuestType.earnStars,
      titleKey: 'quest_stars_6',
      descriptionKey: 'quest_stars_6_desc',
      icon: Icons.stars_rounded,
      targetValue: 6,
      rewardPoints: 100,
    ),
  ];
}
