// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Player _$PlayerFromJson(Map<String, dynamic> json) => _Player(
  id: json['id'] as String,
  name: json['name'] as String,
  colorIndex: (json['colorIndex'] as num?)?.toInt() ?? 0,
  score: (json['score'] as num?)?.toInt() ?? 0,
  matches: (json['matches'] as num?)?.toInt() ?? 0,
  moves: (json['moves'] as num?)?.toInt() ?? 0,
  combo: (json['combo'] as num?)?.toInt() ?? 0,
  maxCombo: (json['maxCombo'] as num?)?.toInt() ?? 0,
  errors: (json['errors'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PlayerToJson(_Player instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'colorIndex': instance.colorIndex,
  'score': instance.score,
  'matches': instance.matches,
  'moves': instance.moves,
  'combo': instance.combo,
  'maxCombo': instance.maxCombo,
  'errors': instance.errors,
};
