// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayerStats _$PlayerStatsFromJson(Map<String, dynamic> json) => _PlayerStats(
  totalGamesPlayed: (json['totalGamesPlayed'] as num?)?.toInt() ?? 0,
  totalGamesWon: (json['totalGamesWon'] as num?)?.toInt() ?? 0,
  totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
  highestScore: (json['highestScore'] as num?)?.toInt() ?? 0,
  totalMatches: (json['totalMatches'] as num?)?.toInt() ?? 0,
  perfectGames: (json['perfectGames'] as num?)?.toInt() ?? 0,
  maxCombo: (json['maxCombo'] as num?)?.toInt() ?? 0,
  totalPlayTimeSeconds: (json['totalPlayTimeSeconds'] as num?)?.toInt() ?? 0,
  currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
  longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PlayerStatsToJson(_PlayerStats instance) =>
    <String, dynamic>{
      'totalGamesPlayed': instance.totalGamesPlayed,
      'totalGamesWon': instance.totalGamesWon,
      'totalScore': instance.totalScore,
      'highestScore': instance.highestScore,
      'totalMatches': instance.totalMatches,
      'perfectGames': instance.perfectGames,
      'maxCombo': instance.maxCombo,
      'totalPlayTimeSeconds': instance.totalPlayTimeSeconds,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
    };

_LevelProgress _$LevelProgressFromJson(Map<String, dynamic> json) =>
    _LevelProgress(
      level: (json['level'] as num).toInt(),
      bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
      bestMoves: (json['bestMoves'] as num?)?.toInt() ?? 0,
      bestTimeSeconds: (json['bestTimeSeconds'] as num?)?.toInt() ?? 0,
      stars: (json['stars'] as num?)?.toInt() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$LevelProgressToJson(_LevelProgress instance) =>
    <String, dynamic>{
      'level': instance.level,
      'bestScore': instance.bestScore,
      'bestMoves': instance.bestMoves,
      'bestTimeSeconds': instance.bestTimeSeconds,
      'stars': instance.stars,
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
    };

_Player _$PlayerFromJson(Map<String, dynamic> json) => _Player(
  id: json['id'] as String,
  username: json['username'] as String? ?? 'Player',
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
  stats: json['stats'] == null
      ? const PlayerStats()
      : PlayerStats.fromJson(json['stats'] as Map<String, dynamic>),
  levelProgress:
      (json['levelProgress'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          int.parse(k),
          LevelProgress.fromJson(e as Map<String, dynamic>),
        ),
      ) ??
      const {},
  unlockedThemes:
      (json['unlockedThemes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['animals'],
  currentLevel: (json['currentLevel'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$PlayerToJson(_Player instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'createdAt': instance.createdAt.toIso8601String(),
  'lastActiveAt': instance.lastActiveAt.toIso8601String(),
  'stats': instance.stats,
  'levelProgress': instance.levelProgress.map(
    (k, e) => MapEntry(k.toString(), e),
  ),
  'unlockedThemes': instance.unlockedThemes,
  'currentLevel': instance.currentLevel,
};
