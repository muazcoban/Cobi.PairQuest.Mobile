// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameCard _$GameCardFromJson(Map<String, dynamic> json) => _GameCard(
  id: json['id'] as String,
  pairId: json['pairId'] as String,
  imageAsset: json['imageAsset'] as String,
  position: (json['position'] as num).toInt(),
  state:
      $enumDecodeNullable(_$CardStateEnumMap, json['state']) ??
      CardState.hidden,
  theme: json['theme'] as String? ?? 'animals',
);

Map<String, dynamic> _$GameCardToJson(_GameCard instance) => <String, dynamic>{
  'id': instance.id,
  'pairId': instance.pairId,
  'imageAsset': instance.imageAsset,
  'position': instance.position,
  'state': _$CardStateEnumMap[instance.state]!,
  'theme': instance.theme,
};

const _$CardStateEnumMap = {
  CardState.hidden: 'hidden',
  CardState.revealed: 'revealed',
  CardState.matched: 'matched',
};
