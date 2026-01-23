// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  uid: json['uid'] as String,
  displayName: json['displayName'] as String?,
  email: json['email'] as String?,
  photoUrl: json['photoUrl'] as String?,
  totalGames: (json['totalGames'] as num?)?.toInt() ?? 0,
  totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
  highestLevel: (json['highestLevel'] as num?)?.toInt() ?? 0,
  bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
  totalMatches: (json['totalMatches'] as num?)?.toInt() ?? 0,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  lastPlayedAt: const TimestampConverter().fromJson(json['lastPlayedAt']),
  isAnonymous: json['isAnonymous'] as bool? ?? true,
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'uid': instance.uid,
  'displayName': instance.displayName,
  'email': instance.email,
  'photoUrl': instance.photoUrl,
  'totalGames': instance.totalGames,
  'totalScore': instance.totalScore,
  'highestLevel': instance.highestLevel,
  'bestScore': instance.bestScore,
  'totalMatches': instance.totalMatches,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'lastPlayedAt': const TimestampConverter().toJson(instance.lastPlayedAt),
  'isAnonymous': instance.isAnonymous,
};
