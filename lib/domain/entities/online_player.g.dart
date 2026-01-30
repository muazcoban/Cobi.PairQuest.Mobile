// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'online_player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnlinePlayer _$OnlinePlayerFromJson(Map<String, dynamic> json) =>
    _OnlinePlayer(
      oddserId: json['oddserId'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      rating: (json['rating'] as num?)?.toInt() ?? 1200,
      colorIndex: (json['colorIndex'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toInt() ?? 0,
      matches: (json['matches'] as num?)?.toInt() ?? 0,
      combo: (json['combo'] as num?)?.toInt() ?? 0,
      maxCombo: (json['maxCombo'] as num?)?.toInt() ?? 0,
      errors: (json['errors'] as num?)?.toInt() ?? 0,
      connectionStatus:
          $enumDecodeNullable(
            _$ConnectionStatusEnumMap,
            json['connectionStatus'],
          ) ??
          ConnectionStatus.online,
      lastActivityAt: const _TimestampConverter().fromJson(
        json['lastActivityAt'] as Timestamp,
      ),
      isReady: json['isReady'] as bool? ?? false,
    );

Map<String, dynamic> _$OnlinePlayerToJson(
  _OnlinePlayer instance,
) => <String, dynamic>{
  'oddserId': instance.oddserId,
  'displayName': instance.displayName,
  'photoUrl': instance.photoUrl,
  'rating': instance.rating,
  'colorIndex': instance.colorIndex,
  'score': instance.score,
  'matches': instance.matches,
  'combo': instance.combo,
  'maxCombo': instance.maxCombo,
  'errors': instance.errors,
  'connectionStatus': _$ConnectionStatusEnumMap[instance.connectionStatus]!,
  'lastActivityAt': const _TimestampConverter().toJson(instance.lastActivityAt),
  'isReady': instance.isReady,
};

const _$ConnectionStatusEnumMap = {
  ConnectionStatus.online: 'online',
  ConnectionStatus.offline: 'offline',
  ConnectionStatus.idle: 'idle',
  ConnectionStatus.disconnected: 'disconnected',
};

_OnlineUserProfile _$OnlineUserProfileFromJson(Map<String, dynamic> json) =>
    _OnlineUserProfile(
      oddserId: json['oddserId'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      email: json['email'] as String?,
      rating: (json['rating'] as num?)?.toInt() ?? 1200,
      rankedWins: (json['rankedWins'] as num?)?.toInt() ?? 0,
      rankedLosses: (json['rankedLosses'] as num?)?.toInt() ?? 0,
      rankedGames: (json['rankedGames'] as num?)?.toInt() ?? 0,
      casualWins: (json['casualWins'] as num?)?.toInt() ?? 0,
      casualLosses: (json['casualLosses'] as num?)?.toInt() ?? 0,
      casualGames: (json['casualGames'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      draws: (json['draws'] as num?)?.toInt() ?? 0,
      totalGames: (json['totalGames'] as num?)?.toInt() ?? 0,
      status:
          $enumDecodeNullable(_$ConnectionStatusEnumMap, json['status']) ??
          ConnectionStatus.offline,
      createdAt: const _TimestampConverter().fromJson(
        json['createdAt'] as Timestamp,
      ),
      lastSeenAt: const _TimestampConverter().fromJson(
        json['lastSeenAt'] as Timestamp,
      ),
      currentGameId: json['currentGameId'] as String?,
    );

Map<String, dynamic> _$OnlineUserProfileToJson(_OnlineUserProfile instance) =>
    <String, dynamic>{
      'oddserId': instance.oddserId,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'email': instance.email,
      'rating': instance.rating,
      'rankedWins': instance.rankedWins,
      'rankedLosses': instance.rankedLosses,
      'rankedGames': instance.rankedGames,
      'casualWins': instance.casualWins,
      'casualLosses': instance.casualLosses,
      'casualGames': instance.casualGames,
      'wins': instance.wins,
      'losses': instance.losses,
      'draws': instance.draws,
      'totalGames': instance.totalGames,
      'status': _$ConnectionStatusEnumMap[instance.status]!,
      'createdAt': const _TimestampConverter().toJson(instance.createdAt),
      'lastSeenAt': const _TimestampConverter().toJson(instance.lastSeenAt),
      'currentGameId': instance.currentGameId,
    };
