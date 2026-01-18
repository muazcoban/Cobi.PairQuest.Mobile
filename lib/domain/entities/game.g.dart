// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GridSize _$GridSizeFromJson(Map<String, dynamic> json) => _GridSize(
  rows: (json['rows'] as num).toInt(),
  cols: (json['cols'] as num).toInt(),
);

Map<String, dynamic> _$GridSizeToJson(_GridSize instance) => <String, dynamic>{
  'rows': instance.rows,
  'cols': instance.cols,
};

_Game _$GameFromJson(Map<String, dynamic> json) => _Game(
  id: json['id'] as String,
  mode: $enumDecode(_$GameModeEnumMap, json['mode']),
  level: (json['level'] as num).toInt(),
  gridSize: GridSize.fromJson(json['gridSize'] as Map<String, dynamic>),
  cards: (json['cards'] as List<dynamic>)
      .map((e) => GameCard.fromJson(e as Map<String, dynamic>))
      .toList(),
  state:
      $enumDecodeNullable(_$GameStateEnumMap, json['state']) ??
      GameState.notStarted,
  score: (json['score'] as num?)?.toInt() ?? 0,
  moves: (json['moves'] as num?)?.toInt() ?? 0,
  matches: (json['matches'] as num?)?.toInt() ?? 0,
  combo: (json['combo'] as num?)?.toInt() ?? 0,
  maxCombo: (json['maxCombo'] as num?)?.toInt() ?? 0,
  errors: (json['errors'] as num?)?.toInt() ?? 0,
  startTime: json['startTime'] == null
      ? null
      : DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  timeLimit: (json['timeLimit'] as num?)?.toInt(),
  timeRemaining: (json['timeRemaining'] as num?)?.toInt(),
  theme: json['theme'] as String? ?? 'animals',
);

Map<String, dynamic> _$GameToJson(_Game instance) => <String, dynamic>{
  'id': instance.id,
  'mode': _$GameModeEnumMap[instance.mode]!,
  'level': instance.level,
  'gridSize': instance.gridSize,
  'cards': instance.cards,
  'state': _$GameStateEnumMap[instance.state]!,
  'score': instance.score,
  'moves': instance.moves,
  'matches': instance.matches,
  'combo': instance.combo,
  'maxCombo': instance.maxCombo,
  'errors': instance.errors,
  'startTime': instance.startTime?.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'timeLimit': instance.timeLimit,
  'timeRemaining': instance.timeRemaining,
  'theme': instance.theme,
};

const _$GameModeEnumMap = {
  GameMode.classic: 'classic',
  GameMode.timed: 'timed',
};

const _$GameStateEnumMap = {
  GameState.notStarted: 'notStarted',
  GameState.inProgress: 'inProgress',
  GameState.paused: 'paused',
  GameState.completed: 'completed',
  GameState.failed: 'failed',
};
