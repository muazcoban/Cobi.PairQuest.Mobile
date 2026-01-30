// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matchmaking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MatchmakingEntry _$MatchmakingEntryFromJson(Map<String, dynamic> json) =>
    _MatchmakingEntry(
      id: json['id'] as String,
      oddserId: json['oddserId'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      rating: (json['rating'] as num).toInt(),
      preferredLevel: (json['preferredLevel'] as num?)?.toInt() ?? 0,
      mode:
          $enumDecodeNullable(_$MatchmakingModeEnumMap, json['mode']) ??
          MatchmakingMode.any,
      status:
          $enumDecodeNullable(_$MatchmakingStatusEnumMap, json['status']) ??
          MatchmakingStatus.waiting,
      matchedGameId: json['matchedGameId'] as String?,
      matchedOpponentId: json['matchedOpponentId'] as String?,
      createdAt: const _TimestampConverter().fromJson(
        json['createdAt'] as Timestamp,
      ),
      expiresAt: const _TimestampConverter().fromJson(
        json['expiresAt'] as Timestamp,
      ),
      ratingRadius: (json['ratingRadius'] as num?)?.toInt() ?? 100,
    );

Map<String, dynamic> _$MatchmakingEntryToJson(_MatchmakingEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'oddserId': instance.oddserId,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'rating': instance.rating,
      'preferredLevel': instance.preferredLevel,
      'mode': _$MatchmakingModeEnumMap[instance.mode]!,
      'status': _$MatchmakingStatusEnumMap[instance.status]!,
      'matchedGameId': instance.matchedGameId,
      'matchedOpponentId': instance.matchedOpponentId,
      'createdAt': const _TimestampConverter().toJson(instance.createdAt),
      'expiresAt': const _TimestampConverter().toJson(instance.expiresAt),
      'ratingRadius': instance.ratingRadius,
    };

const _$MatchmakingModeEnumMap = {
  MatchmakingMode.any: 'any',
  MatchmakingMode.casual: 'casual',
  MatchmakingMode.ranked: 'ranked',
};

const _$MatchmakingStatusEnumMap = {
  MatchmakingStatus.waiting: 'waiting',
  MatchmakingStatus.matching: 'matching',
  MatchmakingStatus.matched: 'matched',
  MatchmakingStatus.expired: 'expired',
  MatchmakingStatus.cancelled: 'cancelled',
};

_GameInvitation _$GameInvitationFromJson(Map<String, dynamic> json) =>
    _GameInvitation(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      fromDisplayName: json['fromDisplayName'] as String,
      fromPhotoUrl: json['fromPhotoUrl'] as String?,
      toUserId: json['toUserId'] as String,
      level: (json['level'] as num?)?.toInt() ?? 5,
      status:
          $enumDecodeNullable(_$InvitationStatusEnumMap, json['status']) ??
          InvitationStatus.pending,
      gameId: json['gameId'] as String?,
      createdAt: const _TimestampConverter().fromJson(
        json['createdAt'] as Timestamp,
      ),
      expiresAt: const _TimestampConverter().fromJson(
        json['expiresAt'] as Timestamp,
      ),
    );

Map<String, dynamic> _$GameInvitationToJson(_GameInvitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fromUserId': instance.fromUserId,
      'fromDisplayName': instance.fromDisplayName,
      'fromPhotoUrl': instance.fromPhotoUrl,
      'toUserId': instance.toUserId,
      'level': instance.level,
      'status': _$InvitationStatusEnumMap[instance.status]!,
      'gameId': instance.gameId,
      'createdAt': const _TimestampConverter().toJson(instance.createdAt),
      'expiresAt': const _TimestampConverter().toJson(instance.expiresAt),
    };

const _$InvitationStatusEnumMap = {
  InvitationStatus.pending: 'pending',
  InvitationStatus.accepted: 'accepted',
  InvitationStatus.declined: 'declined',
  InvitationStatus.expired: 'expired',
};

_Friendship _$FriendshipFromJson(Map<String, dynamic> json) => _Friendship(
  id: json['id'] as String,
  user1Id: json['user1Id'] as String,
  user2Id: json['user2Id'] as String,
  user1DisplayName: json['user1DisplayName'] as String?,
  user2DisplayName: json['user2DisplayName'] as String?,
  status:
      $enumDecodeNullable(_$FriendshipStatusEnumMap, json['status']) ??
      FriendshipStatus.pending,
  requestedBy: json['requestedBy'] as String,
  createdAt: const _TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  acceptedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['acceptedAt'],
    const _TimestampConverter().fromJson,
  ),
);

Map<String, dynamic> _$FriendshipToJson(_Friendship instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user1Id': instance.user1Id,
      'user2Id': instance.user2Id,
      'user1DisplayName': instance.user1DisplayName,
      'user2DisplayName': instance.user2DisplayName,
      'status': _$FriendshipStatusEnumMap[instance.status]!,
      'requestedBy': instance.requestedBy,
      'createdAt': const _TimestampConverter().toJson(instance.createdAt),
      'acceptedAt': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.acceptedAt,
        const _TimestampConverter().toJson,
      ),
    };

const _$FriendshipStatusEnumMap = {
  FriendshipStatus.pending: 'pending',
  FriendshipStatus.accepted: 'accepted',
  FriendshipStatus.declined: 'declined',
  FriendshipStatus.blocked: 'blocked',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
