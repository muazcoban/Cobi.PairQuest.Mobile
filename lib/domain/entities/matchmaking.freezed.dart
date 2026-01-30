// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'matchmaking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MatchmakingEntry {

/// Queue entry ID (Firestore document ID)
 String get id;/// User ID
 String get oddserId;/// User's display name
 String get displayName;/// User's photo URL
 String? get photoUrl;/// User's current rating
 int get rating;/// Preferred level (1-20, or 0 for any)
 int get preferredLevel;/// Game mode preference
 MatchmakingMode get mode;/// Current status
 MatchmakingStatus get status;/// Matched game ID (when status is matched)
 String? get matchedGameId;/// Matched opponent ID
 String? get matchedOpponentId;/// Queue join time
@_TimestampConverter() DateTime get createdAt;/// Queue expiration time (60 seconds from creation)
@_TimestampConverter() DateTime get expiresAt;/// Search radius for rating (starts at 100, expands over time)
 int get ratingRadius;
/// Create a copy of MatchmakingEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchmakingEntryCopyWith<MatchmakingEntry> get copyWith => _$MatchmakingEntryCopyWithImpl<MatchmakingEntry>(this as MatchmakingEntry, _$identity);

  /// Serializes this MatchmakingEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchmakingEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.oddserId, oddserId) || other.oddserId == oddserId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.preferredLevel, preferredLevel) || other.preferredLevel == preferredLevel)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.status, status) || other.status == status)&&(identical(other.matchedGameId, matchedGameId) || other.matchedGameId == matchedGameId)&&(identical(other.matchedOpponentId, matchedOpponentId) || other.matchedOpponentId == matchedOpponentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.ratingRadius, ratingRadius) || other.ratingRadius == ratingRadius));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,oddserId,displayName,photoUrl,rating,preferredLevel,mode,status,matchedGameId,matchedOpponentId,createdAt,expiresAt,ratingRadius);

@override
String toString() {
  return 'MatchmakingEntry(id: $id, oddserId: $oddserId, displayName: $displayName, photoUrl: $photoUrl, rating: $rating, preferredLevel: $preferredLevel, mode: $mode, status: $status, matchedGameId: $matchedGameId, matchedOpponentId: $matchedOpponentId, createdAt: $createdAt, expiresAt: $expiresAt, ratingRadius: $ratingRadius)';
}


}

/// @nodoc
abstract mixin class $MatchmakingEntryCopyWith<$Res>  {
  factory $MatchmakingEntryCopyWith(MatchmakingEntry value, $Res Function(MatchmakingEntry) _then) = _$MatchmakingEntryCopyWithImpl;
@useResult
$Res call({
 String id, String oddserId, String displayName, String? photoUrl, int rating, int preferredLevel, MatchmakingMode mode, MatchmakingStatus status, String? matchedGameId, String? matchedOpponentId,@_TimestampConverter() DateTime createdAt,@_TimestampConverter() DateTime expiresAt, int ratingRadius
});




}
/// @nodoc
class _$MatchmakingEntryCopyWithImpl<$Res>
    implements $MatchmakingEntryCopyWith<$Res> {
  _$MatchmakingEntryCopyWithImpl(this._self, this._then);

  final MatchmakingEntry _self;
  final $Res Function(MatchmakingEntry) _then;

/// Create a copy of MatchmakingEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? oddserId = null,Object? displayName = null,Object? photoUrl = freezed,Object? rating = null,Object? preferredLevel = null,Object? mode = null,Object? status = null,Object? matchedGameId = freezed,Object? matchedOpponentId = freezed,Object? createdAt = null,Object? expiresAt = null,Object? ratingRadius = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,oddserId: null == oddserId ? _self.oddserId : oddserId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,preferredLevel: null == preferredLevel ? _self.preferredLevel : preferredLevel // ignore: cast_nullable_to_non_nullable
as int,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as MatchmakingMode,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MatchmakingStatus,matchedGameId: freezed == matchedGameId ? _self.matchedGameId : matchedGameId // ignore: cast_nullable_to_non_nullable
as String?,matchedOpponentId: freezed == matchedOpponentId ? _self.matchedOpponentId : matchedOpponentId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,ratingRadius: null == ratingRadius ? _self.ratingRadius : ratingRadius // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchmakingEntry].
extension MatchmakingEntryPatterns on MatchmakingEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchmakingEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchmakingEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchmakingEntry value)  $default,){
final _that = this;
switch (_that) {
case _MatchmakingEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchmakingEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MatchmakingEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String oddserId,  String displayName,  String? photoUrl,  int rating,  int preferredLevel,  MatchmakingMode mode,  MatchmakingStatus status,  String? matchedGameId,  String? matchedOpponentId, @_TimestampConverter()  DateTime createdAt, @_TimestampConverter()  DateTime expiresAt,  int ratingRadius)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchmakingEntry() when $default != null:
return $default(_that.id,_that.oddserId,_that.displayName,_that.photoUrl,_that.rating,_that.preferredLevel,_that.mode,_that.status,_that.matchedGameId,_that.matchedOpponentId,_that.createdAt,_that.expiresAt,_that.ratingRadius);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String oddserId,  String displayName,  String? photoUrl,  int rating,  int preferredLevel,  MatchmakingMode mode,  MatchmakingStatus status,  String? matchedGameId,  String? matchedOpponentId, @_TimestampConverter()  DateTime createdAt, @_TimestampConverter()  DateTime expiresAt,  int ratingRadius)  $default,) {final _that = this;
switch (_that) {
case _MatchmakingEntry():
return $default(_that.id,_that.oddserId,_that.displayName,_that.photoUrl,_that.rating,_that.preferredLevel,_that.mode,_that.status,_that.matchedGameId,_that.matchedOpponentId,_that.createdAt,_that.expiresAt,_that.ratingRadius);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String oddserId,  String displayName,  String? photoUrl,  int rating,  int preferredLevel,  MatchmakingMode mode,  MatchmakingStatus status,  String? matchedGameId,  String? matchedOpponentId, @_TimestampConverter()  DateTime createdAt, @_TimestampConverter()  DateTime expiresAt,  int ratingRadius)?  $default,) {final _that = this;
switch (_that) {
case _MatchmakingEntry() when $default != null:
return $default(_that.id,_that.oddserId,_that.displayName,_that.photoUrl,_that.rating,_that.preferredLevel,_that.mode,_that.status,_that.matchedGameId,_that.matchedOpponentId,_that.createdAt,_that.expiresAt,_that.ratingRadius);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchmakingEntry extends MatchmakingEntry {
  const _MatchmakingEntry({required this.id, required this.oddserId, required this.displayName, this.photoUrl, required this.rating, this.preferredLevel = 0, this.mode = MatchmakingMode.any, this.status = MatchmakingStatus.waiting, this.matchedGameId, this.matchedOpponentId, @_TimestampConverter() required this.createdAt, @_TimestampConverter() required this.expiresAt, this.ratingRadius = 100}): super._();
  factory _MatchmakingEntry.fromJson(Map<String, dynamic> json) => _$MatchmakingEntryFromJson(json);

/// Queue entry ID (Firestore document ID)
@override final  String id;
/// User ID
@override final  String oddserId;
/// User's display name
@override final  String displayName;
/// User's photo URL
@override final  String? photoUrl;
/// User's current rating
@override final  int rating;
/// Preferred level (1-20, or 0 for any)
@override@JsonKey() final  int preferredLevel;
/// Game mode preference
@override@JsonKey() final  MatchmakingMode mode;
/// Current status
@override@JsonKey() final  MatchmakingStatus status;
/// Matched game ID (when status is matched)
@override final  String? matchedGameId;
/// Matched opponent ID
@override final  String? matchedOpponentId;
/// Queue join time
@override@_TimestampConverter() final  DateTime createdAt;
/// Queue expiration time (60 seconds from creation)
@override@_TimestampConverter() final  DateTime expiresAt;
/// Search radius for rating (starts at 100, expands over time)
@override@JsonKey() final  int ratingRadius;

/// Create a copy of MatchmakingEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchmakingEntryCopyWith<_MatchmakingEntry> get copyWith => __$MatchmakingEntryCopyWithImpl<_MatchmakingEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchmakingEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchmakingEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.oddserId, oddserId) || other.oddserId == oddserId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.preferredLevel, preferredLevel) || other.preferredLevel == preferredLevel)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.status, status) || other.status == status)&&(identical(other.matchedGameId, matchedGameId) || other.matchedGameId == matchedGameId)&&(identical(other.matchedOpponentId, matchedOpponentId) || other.matchedOpponentId == matchedOpponentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.ratingRadius, ratingRadius) || other.ratingRadius == ratingRadius));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,oddserId,displayName,photoUrl,rating,preferredLevel,mode,status,matchedGameId,matchedOpponentId,createdAt,expiresAt,ratingRadius);

@override
String toString() {
  return 'MatchmakingEntry(id: $id, oddserId: $oddserId, displayName: $displayName, photoUrl: $photoUrl, rating: $rating, preferredLevel: $preferredLevel, mode: $mode, status: $status, matchedGameId: $matchedGameId, matchedOpponentId: $matchedOpponentId, createdAt: $createdAt, expiresAt: $expiresAt, ratingRadius: $ratingRadius)';
}


}

/// @nodoc
abstract mixin class _$MatchmakingEntryCopyWith<$Res> implements $MatchmakingEntryCopyWith<$Res> {
  factory _$MatchmakingEntryCopyWith(_MatchmakingEntry value, $Res Function(_MatchmakingEntry) _then) = __$MatchmakingEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String oddserId, String displayName, String? photoUrl, int rating, int preferredLevel, MatchmakingMode mode, MatchmakingStatus status, String? matchedGameId, String? matchedOpponentId,@_TimestampConverter() DateTime createdAt,@_TimestampConverter() DateTime expiresAt, int ratingRadius
});




}
/// @nodoc
class __$MatchmakingEntryCopyWithImpl<$Res>
    implements _$MatchmakingEntryCopyWith<$Res> {
  __$MatchmakingEntryCopyWithImpl(this._self, this._then);

  final _MatchmakingEntry _self;
  final $Res Function(_MatchmakingEntry) _then;

/// Create a copy of MatchmakingEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? oddserId = null,Object? displayName = null,Object? photoUrl = freezed,Object? rating = null,Object? preferredLevel = null,Object? mode = null,Object? status = null,Object? matchedGameId = freezed,Object? matchedOpponentId = freezed,Object? createdAt = null,Object? expiresAt = null,Object? ratingRadius = null,}) {
  return _then(_MatchmakingEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,oddserId: null == oddserId ? _self.oddserId : oddserId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,preferredLevel: null == preferredLevel ? _self.preferredLevel : preferredLevel // ignore: cast_nullable_to_non_nullable
as int,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as MatchmakingMode,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MatchmakingStatus,matchedGameId: freezed == matchedGameId ? _self.matchedGameId : matchedGameId // ignore: cast_nullable_to_non_nullable
as String?,matchedOpponentId: freezed == matchedOpponentId ? _self.matchedOpponentId : matchedOpponentId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,ratingRadius: null == ratingRadius ? _self.ratingRadius : ratingRadius // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$GameInvitation {

/// Invitation ID
 String get id;/// Sender user ID
 String get fromUserId;/// Sender display name
 String get fromDisplayName;/// Sender photo URL
 String? get fromPhotoUrl;/// Recipient user ID
 String get toUserId;/// Proposed level
 int get level;/// Invitation status
 InvitationStatus get status;/// Created game ID (when accepted)
 String? get gameId;/// Invitation creation time
@_TimestampConverter() DateTime get createdAt;/// Expiration time (5 minutes)
@_TimestampConverter() DateTime get expiresAt;
/// Create a copy of GameInvitation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameInvitationCopyWith<GameInvitation> get copyWith => _$GameInvitationCopyWithImpl<GameInvitation>(this as GameInvitation, _$identity);

  /// Serializes this GameInvitation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameInvitation&&(identical(other.id, id) || other.id == id)&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.fromDisplayName, fromDisplayName) || other.fromDisplayName == fromDisplayName)&&(identical(other.fromPhotoUrl, fromPhotoUrl) || other.fromPhotoUrl == fromPhotoUrl)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.level, level) || other.level == level)&&(identical(other.status, status) || other.status == status)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromUserId,fromDisplayName,fromPhotoUrl,toUserId,level,status,gameId,createdAt,expiresAt);

@override
String toString() {
  return 'GameInvitation(id: $id, fromUserId: $fromUserId, fromDisplayName: $fromDisplayName, fromPhotoUrl: $fromPhotoUrl, toUserId: $toUserId, level: $level, status: $status, gameId: $gameId, createdAt: $createdAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $GameInvitationCopyWith<$Res>  {
  factory $GameInvitationCopyWith(GameInvitation value, $Res Function(GameInvitation) _then) = _$GameInvitationCopyWithImpl;
@useResult
$Res call({
 String id, String fromUserId, String fromDisplayName, String? fromPhotoUrl, String toUserId, int level, InvitationStatus status, String? gameId,@_TimestampConverter() DateTime createdAt,@_TimestampConverter() DateTime expiresAt
});




}
/// @nodoc
class _$GameInvitationCopyWithImpl<$Res>
    implements $GameInvitationCopyWith<$Res> {
  _$GameInvitationCopyWithImpl(this._self, this._then);

  final GameInvitation _self;
  final $Res Function(GameInvitation) _then;

/// Create a copy of GameInvitation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fromUserId = null,Object? fromDisplayName = null,Object? fromPhotoUrl = freezed,Object? toUserId = null,Object? level = null,Object? status = null,Object? gameId = freezed,Object? createdAt = null,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,fromDisplayName: null == fromDisplayName ? _self.fromDisplayName : fromDisplayName // ignore: cast_nullable_to_non_nullable
as String,fromPhotoUrl: freezed == fromPhotoUrl ? _self.fromPhotoUrl : fromPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,toUserId: null == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvitationStatus,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GameInvitation].
extension GameInvitationPatterns on GameInvitation {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameInvitation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameInvitation() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameInvitation value)  $default,){
final _that = this;
switch (_that) {
case _GameInvitation():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameInvitation value)?  $default,){
final _that = this;
switch (_that) {
case _GameInvitation() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fromUserId,  String fromDisplayName,  String? fromPhotoUrl,  String toUserId,  int level,  InvitationStatus status,  String? gameId, @_TimestampConverter()  DateTime createdAt, @_TimestampConverter()  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameInvitation() when $default != null:
return $default(_that.id,_that.fromUserId,_that.fromDisplayName,_that.fromPhotoUrl,_that.toUserId,_that.level,_that.status,_that.gameId,_that.createdAt,_that.expiresAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fromUserId,  String fromDisplayName,  String? fromPhotoUrl,  String toUserId,  int level,  InvitationStatus status,  String? gameId, @_TimestampConverter()  DateTime createdAt, @_TimestampConverter()  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _GameInvitation():
return $default(_that.id,_that.fromUserId,_that.fromDisplayName,_that.fromPhotoUrl,_that.toUserId,_that.level,_that.status,_that.gameId,_that.createdAt,_that.expiresAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fromUserId,  String fromDisplayName,  String? fromPhotoUrl,  String toUserId,  int level,  InvitationStatus status,  String? gameId, @_TimestampConverter()  DateTime createdAt, @_TimestampConverter()  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _GameInvitation() when $default != null:
return $default(_that.id,_that.fromUserId,_that.fromDisplayName,_that.fromPhotoUrl,_that.toUserId,_that.level,_that.status,_that.gameId,_that.createdAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameInvitation extends GameInvitation {
  const _GameInvitation({required this.id, required this.fromUserId, required this.fromDisplayName, this.fromPhotoUrl, required this.toUserId, this.level = 5, this.status = InvitationStatus.pending, this.gameId, @_TimestampConverter() required this.createdAt, @_TimestampConverter() required this.expiresAt}): super._();
  factory _GameInvitation.fromJson(Map<String, dynamic> json) => _$GameInvitationFromJson(json);

/// Invitation ID
@override final  String id;
/// Sender user ID
@override final  String fromUserId;
/// Sender display name
@override final  String fromDisplayName;
/// Sender photo URL
@override final  String? fromPhotoUrl;
/// Recipient user ID
@override final  String toUserId;
/// Proposed level
@override@JsonKey() final  int level;
/// Invitation status
@override@JsonKey() final  InvitationStatus status;
/// Created game ID (when accepted)
@override final  String? gameId;
/// Invitation creation time
@override@_TimestampConverter() final  DateTime createdAt;
/// Expiration time (5 minutes)
@override@_TimestampConverter() final  DateTime expiresAt;

/// Create a copy of GameInvitation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameInvitationCopyWith<_GameInvitation> get copyWith => __$GameInvitationCopyWithImpl<_GameInvitation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameInvitationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameInvitation&&(identical(other.id, id) || other.id == id)&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.fromDisplayName, fromDisplayName) || other.fromDisplayName == fromDisplayName)&&(identical(other.fromPhotoUrl, fromPhotoUrl) || other.fromPhotoUrl == fromPhotoUrl)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.level, level) || other.level == level)&&(identical(other.status, status) || other.status == status)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromUserId,fromDisplayName,fromPhotoUrl,toUserId,level,status,gameId,createdAt,expiresAt);

@override
String toString() {
  return 'GameInvitation(id: $id, fromUserId: $fromUserId, fromDisplayName: $fromDisplayName, fromPhotoUrl: $fromPhotoUrl, toUserId: $toUserId, level: $level, status: $status, gameId: $gameId, createdAt: $createdAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$GameInvitationCopyWith<$Res> implements $GameInvitationCopyWith<$Res> {
  factory _$GameInvitationCopyWith(_GameInvitation value, $Res Function(_GameInvitation) _then) = __$GameInvitationCopyWithImpl;
@override @useResult
$Res call({
 String id, String fromUserId, String fromDisplayName, String? fromPhotoUrl, String toUserId, int level, InvitationStatus status, String? gameId,@_TimestampConverter() DateTime createdAt,@_TimestampConverter() DateTime expiresAt
});




}
/// @nodoc
class __$GameInvitationCopyWithImpl<$Res>
    implements _$GameInvitationCopyWith<$Res> {
  __$GameInvitationCopyWithImpl(this._self, this._then);

  final _GameInvitation _self;
  final $Res Function(_GameInvitation) _then;

/// Create a copy of GameInvitation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fromUserId = null,Object? fromDisplayName = null,Object? fromPhotoUrl = freezed,Object? toUserId = null,Object? level = null,Object? status = null,Object? gameId = freezed,Object? createdAt = null,Object? expiresAt = null,}) {
  return _then(_GameInvitation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,fromDisplayName: null == fromDisplayName ? _self.fromDisplayName : fromDisplayName // ignore: cast_nullable_to_non_nullable
as String,fromPhotoUrl: freezed == fromPhotoUrl ? _self.fromPhotoUrl : fromPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,toUserId: null == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvitationStatus,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$Friendship {

/// Friendship ID
 String get id;/// First user ID (alphabetically smaller)
 String get user1Id;/// Second user ID
 String get user2Id;/// First user's display name
 String? get user1DisplayName;/// Second user's display name
 String? get user2DisplayName;/// Friendship status
 FriendshipStatus get status;/// Who sent the friend request
 String get requestedBy;/// Creation time
@_TimestampConverter() DateTime get createdAt;/// Accepted time
@_TimestampConverter() DateTime? get acceptedAt;
/// Create a copy of Friendship
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FriendshipCopyWith<Friendship> get copyWith => _$FriendshipCopyWithImpl<Friendship>(this as Friendship, _$identity);

  /// Serializes this Friendship to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Friendship&&(identical(other.id, id) || other.id == id)&&(identical(other.user1Id, user1Id) || other.user1Id == user1Id)&&(identical(other.user2Id, user2Id) || other.user2Id == user2Id)&&(identical(other.user1DisplayName, user1DisplayName) || other.user1DisplayName == user1DisplayName)&&(identical(other.user2DisplayName, user2DisplayName) || other.user2DisplayName == user2DisplayName)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,user1Id,user2Id,user1DisplayName,user2DisplayName,status,requestedBy,createdAt,acceptedAt);

@override
String toString() {
  return 'Friendship(id: $id, user1Id: $user1Id, user2Id: $user2Id, user1DisplayName: $user1DisplayName, user2DisplayName: $user2DisplayName, status: $status, requestedBy: $requestedBy, createdAt: $createdAt, acceptedAt: $acceptedAt)';
}


}

/// @nodoc
abstract mixin class $FriendshipCopyWith<$Res>  {
  factory $FriendshipCopyWith(Friendship value, $Res Function(Friendship) _then) = _$FriendshipCopyWithImpl;
@useResult
$Res call({
 String id, String user1Id, String user2Id, String? user1DisplayName, String? user2DisplayName, FriendshipStatus status, String requestedBy,@_TimestampConverter() DateTime createdAt,@_TimestampConverter() DateTime? acceptedAt
});




}
/// @nodoc
class _$FriendshipCopyWithImpl<$Res>
    implements $FriendshipCopyWith<$Res> {
  _$FriendshipCopyWithImpl(this._self, this._then);

  final Friendship _self;
  final $Res Function(Friendship) _then;

/// Create a copy of Friendship
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? user1Id = null,Object? user2Id = null,Object? user1DisplayName = freezed,Object? user2DisplayName = freezed,Object? status = null,Object? requestedBy = null,Object? createdAt = null,Object? acceptedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,user1Id: null == user1Id ? _self.user1Id : user1Id // ignore: cast_nullable_to_non_nullable
as String,user2Id: null == user2Id ? _self.user2Id : user2Id // ignore: cast_nullable_to_non_nullable
as String,user1DisplayName: freezed == user1DisplayName ? _self.user1DisplayName : user1DisplayName // ignore: cast_nullable_to_non_nullable
as String?,user2DisplayName: freezed == user2DisplayName ? _self.user2DisplayName : user2DisplayName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FriendshipStatus,requestedBy: null == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Friendship].
extension FriendshipPatterns on Friendship {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Friendship value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Friendship() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Friendship value)  $default,){
final _that = this;
switch (_that) {
case _Friendship():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Friendship value)?  $default,){
final _that = this;
switch (_that) {
case _Friendship() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String user1Id,  String user2Id,  String? user1DisplayName,  String? user2DisplayName,  FriendshipStatus status,  String requestedBy, @_TimestampConverter()  DateTime createdAt, @_TimestampConverter()  DateTime? acceptedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Friendship() when $default != null:
return $default(_that.id,_that.user1Id,_that.user2Id,_that.user1DisplayName,_that.user2DisplayName,_that.status,_that.requestedBy,_that.createdAt,_that.acceptedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String user1Id,  String user2Id,  String? user1DisplayName,  String? user2DisplayName,  FriendshipStatus status,  String requestedBy, @_TimestampConverter()  DateTime createdAt, @_TimestampConverter()  DateTime? acceptedAt)  $default,) {final _that = this;
switch (_that) {
case _Friendship():
return $default(_that.id,_that.user1Id,_that.user2Id,_that.user1DisplayName,_that.user2DisplayName,_that.status,_that.requestedBy,_that.createdAt,_that.acceptedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String user1Id,  String user2Id,  String? user1DisplayName,  String? user2DisplayName,  FriendshipStatus status,  String requestedBy, @_TimestampConverter()  DateTime createdAt, @_TimestampConverter()  DateTime? acceptedAt)?  $default,) {final _that = this;
switch (_that) {
case _Friendship() when $default != null:
return $default(_that.id,_that.user1Id,_that.user2Id,_that.user1DisplayName,_that.user2DisplayName,_that.status,_that.requestedBy,_that.createdAt,_that.acceptedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Friendship extends Friendship {
  const _Friendship({required this.id, required this.user1Id, required this.user2Id, this.user1DisplayName, this.user2DisplayName, this.status = FriendshipStatus.pending, required this.requestedBy, @_TimestampConverter() required this.createdAt, @_TimestampConverter() this.acceptedAt}): super._();
  factory _Friendship.fromJson(Map<String, dynamic> json) => _$FriendshipFromJson(json);

/// Friendship ID
@override final  String id;
/// First user ID (alphabetically smaller)
@override final  String user1Id;
/// Second user ID
@override final  String user2Id;
/// First user's display name
@override final  String? user1DisplayName;
/// Second user's display name
@override final  String? user2DisplayName;
/// Friendship status
@override@JsonKey() final  FriendshipStatus status;
/// Who sent the friend request
@override final  String requestedBy;
/// Creation time
@override@_TimestampConverter() final  DateTime createdAt;
/// Accepted time
@override@_TimestampConverter() final  DateTime? acceptedAt;

/// Create a copy of Friendship
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FriendshipCopyWith<_Friendship> get copyWith => __$FriendshipCopyWithImpl<_Friendship>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FriendshipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Friendship&&(identical(other.id, id) || other.id == id)&&(identical(other.user1Id, user1Id) || other.user1Id == user1Id)&&(identical(other.user2Id, user2Id) || other.user2Id == user2Id)&&(identical(other.user1DisplayName, user1DisplayName) || other.user1DisplayName == user1DisplayName)&&(identical(other.user2DisplayName, user2DisplayName) || other.user2DisplayName == user2DisplayName)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,user1Id,user2Id,user1DisplayName,user2DisplayName,status,requestedBy,createdAt,acceptedAt);

@override
String toString() {
  return 'Friendship(id: $id, user1Id: $user1Id, user2Id: $user2Id, user1DisplayName: $user1DisplayName, user2DisplayName: $user2DisplayName, status: $status, requestedBy: $requestedBy, createdAt: $createdAt, acceptedAt: $acceptedAt)';
}


}

/// @nodoc
abstract mixin class _$FriendshipCopyWith<$Res> implements $FriendshipCopyWith<$Res> {
  factory _$FriendshipCopyWith(_Friendship value, $Res Function(_Friendship) _then) = __$FriendshipCopyWithImpl;
@override @useResult
$Res call({
 String id, String user1Id, String user2Id, String? user1DisplayName, String? user2DisplayName, FriendshipStatus status, String requestedBy,@_TimestampConverter() DateTime createdAt,@_TimestampConverter() DateTime? acceptedAt
});




}
/// @nodoc
class __$FriendshipCopyWithImpl<$Res>
    implements _$FriendshipCopyWith<$Res> {
  __$FriendshipCopyWithImpl(this._self, this._then);

  final _Friendship _self;
  final $Res Function(_Friendship) _then;

/// Create a copy of Friendship
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? user1Id = null,Object? user2Id = null,Object? user1DisplayName = freezed,Object? user2DisplayName = freezed,Object? status = null,Object? requestedBy = null,Object? createdAt = null,Object? acceptedAt = freezed,}) {
  return _then(_Friendship(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,user1Id: null == user1Id ? _self.user1Id : user1Id // ignore: cast_nullable_to_non_nullable
as String,user2Id: null == user2Id ? _self.user2Id : user2Id // ignore: cast_nullable_to_non_nullable
as String,user1DisplayName: freezed == user1DisplayName ? _self.user1DisplayName : user1DisplayName // ignore: cast_nullable_to_non_nullable
as String?,user2DisplayName: freezed == user2DisplayName ? _self.user2DisplayName : user2DisplayName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FriendshipStatus,requestedBy: null == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
