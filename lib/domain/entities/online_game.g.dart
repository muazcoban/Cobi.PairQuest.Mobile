// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'online_game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnlineGame _$OnlineGameFromJson(Map<String, dynamic> json) => _OnlineGame(
  id: json['id'] as String,
  status:
      $enumDecodeNullable(_$OnlineGameStatusEnumMap, json['status']) ??
      OnlineGameStatus.waiting,
  mode:
      $enumDecodeNullable(_$OnlineGameModeEnumMap, json['mode']) ??
      OnlineGameMode.casual,
  level: (json['level'] as num).toInt(),
  rows: (json['rows'] as num).toInt(),
  cols: (json['cols'] as num).toInt(),
  theme: json['theme'] as String? ?? 'animals',
  players:
      (json['players'] as List<dynamic>?)
          ?.map((e) => OnlinePlayer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  currentPlayerIndex: (json['currentPlayerIndex'] as num?)?.toInt() ?? 0,
  cardPairIds:
      (json['cardPairIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  matchedPairIds:
      (json['matchedPairIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  moves:
      (json['moves'] as List<dynamic>?)
          ?.map((e) => GameMove.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  winnerId: json['winnerId'] as String?,
  extraTurnAwarded: json['extraTurnAwarded'] as bool? ?? false,
  createdAt: const TimestampConverterNonNull().fromJson(
    json['createdAt'] as Timestamp,
  ),
  startedAt: const TimestampConverter().fromJson(
    json['startedAt'] as Timestamp?,
  ),
  completedAt: const TimestampConverter().fromJson(
    json['completedAt'] as Timestamp?,
  ),
  lastActivityAt: const TimestampConverter().fromJson(
    json['lastActivityAt'] as Timestamp?,
  ),
);

Map<String, dynamic> _$OnlineGameToJson(
  _OnlineGame instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': _$OnlineGameStatusEnumMap[instance.status]!,
  'mode': _$OnlineGameModeEnumMap[instance.mode]!,
  'level': instance.level,
  'rows': instance.rows,
  'cols': instance.cols,
  'theme': instance.theme,
  'players': instance.players,
  'currentPlayerIndex': instance.currentPlayerIndex,
  'cardPairIds': instance.cardPairIds,
  'matchedPairIds': instance.matchedPairIds,
  'moves': instance.moves,
  'winnerId': instance.winnerId,
  'extraTurnAwarded': instance.extraTurnAwarded,
  'createdAt': const TimestampConverterNonNull().toJson(instance.createdAt),
  'startedAt': const TimestampConverter().toJson(instance.startedAt),
  'completedAt': const TimestampConverter().toJson(instance.completedAt),
  'lastActivityAt': const TimestampConverter().toJson(instance.lastActivityAt),
};

const _$OnlineGameStatusEnumMap = {
  OnlineGameStatus.waiting: 'waiting',
  OnlineGameStatus.inProgress: 'inProgress',
  OnlineGameStatus.completed: 'completed',
  OnlineGameStatus.abandoned: 'abandoned',
  OnlineGameStatus.cancelled: 'cancelled',
};

const _$OnlineGameModeEnumMap = {
  OnlineGameMode.casual: 'casual',
  OnlineGameMode.ranked: 'ranked',
  OnlineGameMode.friend: 'friend',
};

_GameMove _$GameMoveFromJson(Map<String, dynamic> json) => _GameMove(
  oddserId: json['oddserId'] as String,
  card1Position: (json['card1Position'] as num).toInt(),
  card2Position: (json['card2Position'] as num).toInt(),
  pairId: json['pairId'] as String,
  matched: json['matched'] as bool,
  scoreAwarded: (json['scoreAwarded'] as num?)?.toInt() ?? 0,
  timestamp: const TimestampConverterNonNull().fromJson(
    json['timestamp'] as Timestamp,
  ),
);

Map<String, dynamic> _$GameMoveToJson(_GameMove instance) => <String, dynamic>{
  'oddserId': instance.oddserId,
  'card1Position': instance.card1Position,
  'card2Position': instance.card2Position,
  'pairId': instance.pairId,
  'matched': instance.matched,
  'scoreAwarded': instance.scoreAwarded,
  'timestamp': const TimestampConverterNonNull().toJson(instance.timestamp),
};
