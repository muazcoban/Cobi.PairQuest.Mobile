// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'online_player.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnlinePlayer {

/// Firebase user ID
 String get oddserId;/// Display name
 String get displayName;/// Profile photo URL (nullable)
 String? get photoUrl;/// Player's ELO rating
 int get rating;/// Player color index (0-3)
 int get colorIndex;/// Current score in this game
 int get score;/// Number of pairs matched
 int get matches;/// Current combo streak
 int get combo;/// Maximum combo achieved
 int get maxCombo;/// Number of errors (mismatches)
 int get errors;/// Connection status
 ConnectionStatus get connectionStatus;/// Last activity timestamp
@_TimestampConverter() DateTime get lastActivityAt;/// Whether player is ready to start
 bool get isReady;
/// Create a copy of OnlinePlayer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnlinePlayerCopyWith<OnlinePlayer> get copyWith => _$OnlinePlayerCopyWithImpl<OnlinePlayer>(this as OnlinePlayer, _$identity);

  /// Serializes this OnlinePlayer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnlinePlayer&&(identical(other.oddserId, oddserId) || other.oddserId == oddserId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.colorIndex, colorIndex) || other.colorIndex == colorIndex)&&(identical(other.score, score) || other.score == score)&&(identical(other.matches, matches) || other.matches == matches)&&(identical(other.combo, combo) || other.combo == combo)&&(identical(other.maxCombo, maxCombo) || other.maxCombo == maxCombo)&&(identical(other.errors, errors) || other.errors == errors)&&(identical(other.connectionStatus, connectionStatus) || other.connectionStatus == connectionStatus)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.isReady, isReady) || other.isReady == isReady));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,oddserId,displayName,photoUrl,rating,colorIndex,score,matches,combo,maxCombo,errors,connectionStatus,lastActivityAt,isReady);

@override
String toString() {
  return 'OnlinePlayer(oddserId: $oddserId, displayName: $displayName, photoUrl: $photoUrl, rating: $rating, colorIndex: $colorIndex, score: $score, matches: $matches, combo: $combo, maxCombo: $maxCombo, errors: $errors, connectionStatus: $connectionStatus, lastActivityAt: $lastActivityAt, isReady: $isReady)';
}


}

/// @nodoc
abstract mixin class $OnlinePlayerCopyWith<$Res>  {
  factory $OnlinePlayerCopyWith(OnlinePlayer value, $Res Function(OnlinePlayer) _then) = _$OnlinePlayerCopyWithImpl;
@useResult
$Res call({
 String oddserId, String displayName, String? photoUrl, int rating, int colorIndex, int score, int matches, int combo, int maxCombo, int errors, ConnectionStatus connectionStatus,@_TimestampConverter() DateTime lastActivityAt, bool isReady
});




}
/// @nodoc
class _$OnlinePlayerCopyWithImpl<$Res>
    implements $OnlinePlayerCopyWith<$Res> {
  _$OnlinePlayerCopyWithImpl(this._self, this._then);

  final OnlinePlayer _self;
  final $Res Function(OnlinePlayer) _then;

/// Create a copy of OnlinePlayer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? oddserId = null,Object? displayName = null,Object? photoUrl = freezed,Object? rating = null,Object? colorIndex = null,Object? score = null,Object? matches = null,Object? combo = null,Object? maxCombo = null,Object? errors = null,Object? connectionStatus = null,Object? lastActivityAt = null,Object? isReady = null,}) {
  return _then(_self.copyWith(
oddserId: null == oddserId ? _self.oddserId : oddserId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,colorIndex: null == colorIndex ? _self.colorIndex : colorIndex // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,matches: null == matches ? _self.matches : matches // ignore: cast_nullable_to_non_nullable
as int,combo: null == combo ? _self.combo : combo // ignore: cast_nullable_to_non_nullable
as int,maxCombo: null == maxCombo ? _self.maxCombo : maxCombo // ignore: cast_nullable_to_non_nullable
as int,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as int,connectionStatus: null == connectionStatus ? _self.connectionStatus : connectionStatus // ignore: cast_nullable_to_non_nullable
as ConnectionStatus,lastActivityAt: null == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime,isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [OnlinePlayer].
extension OnlinePlayerPatterns on OnlinePlayer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnlinePlayer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnlinePlayer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnlinePlayer value)  $default,){
final _that = this;
switch (_that) {
case _OnlinePlayer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnlinePlayer value)?  $default,){
final _that = this;
switch (_that) {
case _OnlinePlayer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String oddserId,  String displayName,  String? photoUrl,  int rating,  int colorIndex,  int score,  int matches,  int combo,  int maxCombo,  int errors,  ConnectionStatus connectionStatus, @_TimestampConverter()  DateTime lastActivityAt,  bool isReady)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnlinePlayer() when $default != null:
return $default(_that.oddserId,_that.displayName,_that.photoUrl,_that.rating,_that.colorIndex,_that.score,_that.matches,_that.combo,_that.maxCombo,_that.errors,_that.connectionStatus,_that.lastActivityAt,_that.isReady);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String oddserId,  String displayName,  String? photoUrl,  int rating,  int colorIndex,  int score,  int matches,  int combo,  int maxCombo,  int errors,  ConnectionStatus connectionStatus, @_TimestampConverter()  DateTime lastActivityAt,  bool isReady)  $default,) {final _that = this;
switch (_that) {
case _OnlinePlayer():
return $default(_that.oddserId,_that.displayName,_that.photoUrl,_that.rating,_that.colorIndex,_that.score,_that.matches,_that.combo,_that.maxCombo,_that.errors,_that.connectionStatus,_that.lastActivityAt,_that.isReady);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String oddserId,  String displayName,  String? photoUrl,  int rating,  int colorIndex,  int score,  int matches,  int combo,  int maxCombo,  int errors,  ConnectionStatus connectionStatus, @_TimestampConverter()  DateTime lastActivityAt,  bool isReady)?  $default,) {final _that = this;
switch (_that) {
case _OnlinePlayer() when $default != null:
return $default(_that.oddserId,_that.displayName,_that.photoUrl,_that.rating,_that.colorIndex,_that.score,_that.matches,_that.combo,_that.maxCombo,_that.errors,_that.connectionStatus,_that.lastActivityAt,_that.isReady);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnlinePlayer extends OnlinePlayer {
  const _OnlinePlayer({required this.oddserId, required this.displayName, this.photoUrl, this.rating = 1200, this.colorIndex = 0, this.score = 0, this.matches = 0, this.combo = 0, this.maxCombo = 0, this.errors = 0, this.connectionStatus = ConnectionStatus.online, @_TimestampConverter() required this.lastActivityAt, this.isReady = false}): super._();
  factory _OnlinePlayer.fromJson(Map<String, dynamic> json) => _$OnlinePlayerFromJson(json);

/// Firebase user ID
@override final  String oddserId;
/// Display name
@override final  String displayName;
/// Profile photo URL (nullable)
@override final  String? photoUrl;
/// Player's ELO rating
@override@JsonKey() final  int rating;
/// Player color index (0-3)
@override@JsonKey() final  int colorIndex;
/// Current score in this game
@override@JsonKey() final  int score;
/// Number of pairs matched
@override@JsonKey() final  int matches;
/// Current combo streak
@override@JsonKey() final  int combo;
/// Maximum combo achieved
@override@JsonKey() final  int maxCombo;
/// Number of errors (mismatches)
@override@JsonKey() final  int errors;
/// Connection status
@override@JsonKey() final  ConnectionStatus connectionStatus;
/// Last activity timestamp
@override@_TimestampConverter() final  DateTime lastActivityAt;
/// Whether player is ready to start
@override@JsonKey() final  bool isReady;

/// Create a copy of OnlinePlayer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnlinePlayerCopyWith<_OnlinePlayer> get copyWith => __$OnlinePlayerCopyWithImpl<_OnlinePlayer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnlinePlayerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnlinePlayer&&(identical(other.oddserId, oddserId) || other.oddserId == oddserId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.colorIndex, colorIndex) || other.colorIndex == colorIndex)&&(identical(other.score, score) || other.score == score)&&(identical(other.matches, matches) || other.matches == matches)&&(identical(other.combo, combo) || other.combo == combo)&&(identical(other.maxCombo, maxCombo) || other.maxCombo == maxCombo)&&(identical(other.errors, errors) || other.errors == errors)&&(identical(other.connectionStatus, connectionStatus) || other.connectionStatus == connectionStatus)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.isReady, isReady) || other.isReady == isReady));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,oddserId,displayName,photoUrl,rating,colorIndex,score,matches,combo,maxCombo,errors,connectionStatus,lastActivityAt,isReady);

@override
String toString() {
  return 'OnlinePlayer(oddserId: $oddserId, displayName: $displayName, photoUrl: $photoUrl, rating: $rating, colorIndex: $colorIndex, score: $score, matches: $matches, combo: $combo, maxCombo: $maxCombo, errors: $errors, connectionStatus: $connectionStatus, lastActivityAt: $lastActivityAt, isReady: $isReady)';
}


}

/// @nodoc
abstract mixin class _$OnlinePlayerCopyWith<$Res> implements $OnlinePlayerCopyWith<$Res> {
  factory _$OnlinePlayerCopyWith(_OnlinePlayer value, $Res Function(_OnlinePlayer) _then) = __$OnlinePlayerCopyWithImpl;
@override @useResult
$Res call({
 String oddserId, String displayName, String? photoUrl, int rating, int colorIndex, int score, int matches, int combo, int maxCombo, int errors, ConnectionStatus connectionStatus,@_TimestampConverter() DateTime lastActivityAt, bool isReady
});




}
/// @nodoc
class __$OnlinePlayerCopyWithImpl<$Res>
    implements _$OnlinePlayerCopyWith<$Res> {
  __$OnlinePlayerCopyWithImpl(this._self, this._then);

  final _OnlinePlayer _self;
  final $Res Function(_OnlinePlayer) _then;

/// Create a copy of OnlinePlayer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? oddserId = null,Object? displayName = null,Object? photoUrl = freezed,Object? rating = null,Object? colorIndex = null,Object? score = null,Object? matches = null,Object? combo = null,Object? maxCombo = null,Object? errors = null,Object? connectionStatus = null,Object? lastActivityAt = null,Object? isReady = null,}) {
  return _then(_OnlinePlayer(
oddserId: null == oddserId ? _self.oddserId : oddserId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,colorIndex: null == colorIndex ? _self.colorIndex : colorIndex // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,matches: null == matches ? _self.matches : matches // ignore: cast_nullable_to_non_nullable
as int,combo: null == combo ? _self.combo : combo // ignore: cast_nullable_to_non_nullable
as int,maxCombo: null == maxCombo ? _self.maxCombo : maxCombo // ignore: cast_nullable_to_non_nullable
as int,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as int,connectionStatus: null == connectionStatus ? _self.connectionStatus : connectionStatus // ignore: cast_nullable_to_non_nullable
as ConnectionStatus,lastActivityAt: null == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime,isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$OnlineUserProfile {

/// Firebase user ID
 String get oddserId;/// Display name
 String get displayName;/// Profile photo URL
 String? get photoUrl;/// Email (optional)
 String? get email;/// ELO rating (only changes in ranked games)
 int get rating;// ========== RANKED STATS ==========
/// Ranked wins
 int get rankedWins;/// Ranked losses
 int get rankedLosses;/// Ranked games played
 int get rankedGames;// ========== CASUAL STATS ==========
/// Casual wins
 int get casualWins;/// Casual losses
 int get casualLosses;/// Casual games played
 int get casualGames;// ========== LEGACY FIELDS (backward compatibility) ==========
/// Total wins (ranked + casual) - kept for backward compatibility
 int get wins;/// Total losses (ranked + casual) - kept for backward compatibility
 int get losses;/// Total draws
 int get draws;/// Total online games played - kept for backward compatibility
 int get totalGames;/// Current online status
 ConnectionStatus get status;/// Account creation date
@_TimestampConverter() DateTime get createdAt;/// Last seen timestamp
@_TimestampConverter() DateTime get lastSeenAt;/// Current game ID (if in a game)
 String? get currentGameId;
/// Create a copy of OnlineUserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnlineUserProfileCopyWith<OnlineUserProfile> get copyWith => _$OnlineUserProfileCopyWithImpl<OnlineUserProfile>(this as OnlineUserProfile, _$identity);

  /// Serializes this OnlineUserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnlineUserProfile&&(identical(other.oddserId, oddserId) || other.oddserId == oddserId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.email, email) || other.email == email)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.rankedWins, rankedWins) || other.rankedWins == rankedWins)&&(identical(other.rankedLosses, rankedLosses) || other.rankedLosses == rankedLosses)&&(identical(other.rankedGames, rankedGames) || other.rankedGames == rankedGames)&&(identical(other.casualWins, casualWins) || other.casualWins == casualWins)&&(identical(other.casualLosses, casualLosses) || other.casualLosses == casualLosses)&&(identical(other.casualGames, casualGames) || other.casualGames == casualGames)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.losses, losses) || other.losses == losses)&&(identical(other.draws, draws) || other.draws == draws)&&(identical(other.totalGames, totalGames) || other.totalGames == totalGames)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.currentGameId, currentGameId) || other.currentGameId == currentGameId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,oddserId,displayName,photoUrl,email,rating,rankedWins,rankedLosses,rankedGames,casualWins,casualLosses,casualGames,wins,losses,draws,totalGames,status,createdAt,lastSeenAt,currentGameId]);

@override
String toString() {
  return 'OnlineUserProfile(oddserId: $oddserId, displayName: $displayName, photoUrl: $photoUrl, email: $email, rating: $rating, rankedWins: $rankedWins, rankedLosses: $rankedLosses, rankedGames: $rankedGames, casualWins: $casualWins, casualLosses: $casualLosses, casualGames: $casualGames, wins: $wins, losses: $losses, draws: $draws, totalGames: $totalGames, status: $status, createdAt: $createdAt, lastSeenAt: $lastSeenAt, currentGameId: $currentGameId)';
}


}

/// @nodoc
abstract mixin class $OnlineUserProfileCopyWith<$Res>  {
  factory $OnlineUserProfileCopyWith(OnlineUserProfile value, $Res Function(OnlineUserProfile) _then) = _$OnlineUserProfileCopyWithImpl;
@useResult
$Res call({
 String oddserId, String displayName, String? photoUrl, String? email, int rating, int rankedWins, int rankedLosses, int rankedGames, int casualWins, int casualLosses, int casualGames, int wins, int losses, int draws, int totalGames, ConnectionStatus status,@_TimestampConverter() DateTime createdAt,@_TimestampConverter() DateTime lastSeenAt, String? currentGameId
});




}
/// @nodoc
class _$OnlineUserProfileCopyWithImpl<$Res>
    implements $OnlineUserProfileCopyWith<$Res> {
  _$OnlineUserProfileCopyWithImpl(this._self, this._then);

  final OnlineUserProfile _self;
  final $Res Function(OnlineUserProfile) _then;

/// Create a copy of OnlineUserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? oddserId = null,Object? displayName = null,Object? photoUrl = freezed,Object? email = freezed,Object? rating = null,Object? rankedWins = null,Object? rankedLosses = null,Object? rankedGames = null,Object? casualWins = null,Object? casualLosses = null,Object? casualGames = null,Object? wins = null,Object? losses = null,Object? draws = null,Object? totalGames = null,Object? status = null,Object? createdAt = null,Object? lastSeenAt = null,Object? currentGameId = freezed,}) {
  return _then(_self.copyWith(
oddserId: null == oddserId ? _self.oddserId : oddserId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,rankedWins: null == rankedWins ? _self.rankedWins : rankedWins // ignore: cast_nullable_to_non_nullable
as int,rankedLosses: null == rankedLosses ? _self.rankedLosses : rankedLosses // ignore: cast_nullable_to_non_nullable
as int,rankedGames: null == rankedGames ? _self.rankedGames : rankedGames // ignore: cast_nullable_to_non_nullable
as int,casualWins: null == casualWins ? _self.casualWins : casualWins // ignore: cast_nullable_to_non_nullable
as int,casualLosses: null == casualLosses ? _self.casualLosses : casualLosses // ignore: cast_nullable_to_non_nullable
as int,casualGames: null == casualGames ? _self.casualGames : casualGames // ignore: cast_nullable_to_non_nullable
as int,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,losses: null == losses ? _self.losses : losses // ignore: cast_nullable_to_non_nullable
as int,draws: null == draws ? _self.draws : draws // ignore: cast_nullable_to_non_nullable
as int,totalGames: null == totalGames ? _self.totalGames : totalGames // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConnectionStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastSeenAt: null == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime,currentGameId: freezed == currentGameId ? _self.currentGameId : currentGameId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OnlineUserProfile].
extension OnlineUserProfilePatterns on OnlineUserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnlineUserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnlineUserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnlineUserProfile value)  $default,){
final _that = this;
switch (_that) {
case _OnlineUserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnlineUserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _OnlineUserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String oddserId,  String displayName,  String? photoUrl,  String? email,  int rating,  int rankedWins,  int rankedLosses,  int rankedGames,  int casualWins,  int casualLosses,  int casualGames,  int wins,  int losses,  int draws,  int totalGames,  ConnectionStatus status, @_TimestampConverter()  DateTime createdAt, @_TimestampConverter()  DateTime lastSeenAt,  String? currentGameId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnlineUserProfile() when $default != null:
return $default(_that.oddserId,_that.displayName,_that.photoUrl,_that.email,_that.rating,_that.rankedWins,_that.rankedLosses,_that.rankedGames,_that.casualWins,_that.casualLosses,_that.casualGames,_that.wins,_that.losses,_that.draws,_that.totalGames,_that.status,_that.createdAt,_that.lastSeenAt,_that.currentGameId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String oddserId,  String displayName,  String? photoUrl,  String? email,  int rating,  int rankedWins,  int rankedLosses,  int rankedGames,  int casualWins,  int casualLosses,  int casualGames,  int wins,  int losses,  int draws,  int totalGames,  ConnectionStatus status, @_TimestampConverter()  DateTime createdAt, @_TimestampConverter()  DateTime lastSeenAt,  String? currentGameId)  $default,) {final _that = this;
switch (_that) {
case _OnlineUserProfile():
return $default(_that.oddserId,_that.displayName,_that.photoUrl,_that.email,_that.rating,_that.rankedWins,_that.rankedLosses,_that.rankedGames,_that.casualWins,_that.casualLosses,_that.casualGames,_that.wins,_that.losses,_that.draws,_that.totalGames,_that.status,_that.createdAt,_that.lastSeenAt,_that.currentGameId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String oddserId,  String displayName,  String? photoUrl,  String? email,  int rating,  int rankedWins,  int rankedLosses,  int rankedGames,  int casualWins,  int casualLosses,  int casualGames,  int wins,  int losses,  int draws,  int totalGames,  ConnectionStatus status, @_TimestampConverter()  DateTime createdAt, @_TimestampConverter()  DateTime lastSeenAt,  String? currentGameId)?  $default,) {final _that = this;
switch (_that) {
case _OnlineUserProfile() when $default != null:
return $default(_that.oddserId,_that.displayName,_that.photoUrl,_that.email,_that.rating,_that.rankedWins,_that.rankedLosses,_that.rankedGames,_that.casualWins,_that.casualLosses,_that.casualGames,_that.wins,_that.losses,_that.draws,_that.totalGames,_that.status,_that.createdAt,_that.lastSeenAt,_that.currentGameId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnlineUserProfile extends OnlineUserProfile {
  const _OnlineUserProfile({required this.oddserId, required this.displayName, this.photoUrl, this.email, this.rating = 1200, this.rankedWins = 0, this.rankedLosses = 0, this.rankedGames = 0, this.casualWins = 0, this.casualLosses = 0, this.casualGames = 0, this.wins = 0, this.losses = 0, this.draws = 0, this.totalGames = 0, this.status = ConnectionStatus.offline, @_TimestampConverter() required this.createdAt, @_TimestampConverter() required this.lastSeenAt, this.currentGameId}): super._();
  factory _OnlineUserProfile.fromJson(Map<String, dynamic> json) => _$OnlineUserProfileFromJson(json);

/// Firebase user ID
@override final  String oddserId;
/// Display name
@override final  String displayName;
/// Profile photo URL
@override final  String? photoUrl;
/// Email (optional)
@override final  String? email;
/// ELO rating (only changes in ranked games)
@override@JsonKey() final  int rating;
// ========== RANKED STATS ==========
/// Ranked wins
@override@JsonKey() final  int rankedWins;
/// Ranked losses
@override@JsonKey() final  int rankedLosses;
/// Ranked games played
@override@JsonKey() final  int rankedGames;
// ========== CASUAL STATS ==========
/// Casual wins
@override@JsonKey() final  int casualWins;
/// Casual losses
@override@JsonKey() final  int casualLosses;
/// Casual games played
@override@JsonKey() final  int casualGames;
// ========== LEGACY FIELDS (backward compatibility) ==========
/// Total wins (ranked + casual) - kept for backward compatibility
@override@JsonKey() final  int wins;
/// Total losses (ranked + casual) - kept for backward compatibility
@override@JsonKey() final  int losses;
/// Total draws
@override@JsonKey() final  int draws;
/// Total online games played - kept for backward compatibility
@override@JsonKey() final  int totalGames;
/// Current online status
@override@JsonKey() final  ConnectionStatus status;
/// Account creation date
@override@_TimestampConverter() final  DateTime createdAt;
/// Last seen timestamp
@override@_TimestampConverter() final  DateTime lastSeenAt;
/// Current game ID (if in a game)
@override final  String? currentGameId;

/// Create a copy of OnlineUserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnlineUserProfileCopyWith<_OnlineUserProfile> get copyWith => __$OnlineUserProfileCopyWithImpl<_OnlineUserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnlineUserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnlineUserProfile&&(identical(other.oddserId, oddserId) || other.oddserId == oddserId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.email, email) || other.email == email)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.rankedWins, rankedWins) || other.rankedWins == rankedWins)&&(identical(other.rankedLosses, rankedLosses) || other.rankedLosses == rankedLosses)&&(identical(other.rankedGames, rankedGames) || other.rankedGames == rankedGames)&&(identical(other.casualWins, casualWins) || other.casualWins == casualWins)&&(identical(other.casualLosses, casualLosses) || other.casualLosses == casualLosses)&&(identical(other.casualGames, casualGames) || other.casualGames == casualGames)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.losses, losses) || other.losses == losses)&&(identical(other.draws, draws) || other.draws == draws)&&(identical(other.totalGames, totalGames) || other.totalGames == totalGames)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.currentGameId, currentGameId) || other.currentGameId == currentGameId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,oddserId,displayName,photoUrl,email,rating,rankedWins,rankedLosses,rankedGames,casualWins,casualLosses,casualGames,wins,losses,draws,totalGames,status,createdAt,lastSeenAt,currentGameId]);

@override
String toString() {
  return 'OnlineUserProfile(oddserId: $oddserId, displayName: $displayName, photoUrl: $photoUrl, email: $email, rating: $rating, rankedWins: $rankedWins, rankedLosses: $rankedLosses, rankedGames: $rankedGames, casualWins: $casualWins, casualLosses: $casualLosses, casualGames: $casualGames, wins: $wins, losses: $losses, draws: $draws, totalGames: $totalGames, status: $status, createdAt: $createdAt, lastSeenAt: $lastSeenAt, currentGameId: $currentGameId)';
}


}

/// @nodoc
abstract mixin class _$OnlineUserProfileCopyWith<$Res> implements $OnlineUserProfileCopyWith<$Res> {
  factory _$OnlineUserProfileCopyWith(_OnlineUserProfile value, $Res Function(_OnlineUserProfile) _then) = __$OnlineUserProfileCopyWithImpl;
@override @useResult
$Res call({
 String oddserId, String displayName, String? photoUrl, String? email, int rating, int rankedWins, int rankedLosses, int rankedGames, int casualWins, int casualLosses, int casualGames, int wins, int losses, int draws, int totalGames, ConnectionStatus status,@_TimestampConverter() DateTime createdAt,@_TimestampConverter() DateTime lastSeenAt, String? currentGameId
});




}
/// @nodoc
class __$OnlineUserProfileCopyWithImpl<$Res>
    implements _$OnlineUserProfileCopyWith<$Res> {
  __$OnlineUserProfileCopyWithImpl(this._self, this._then);

  final _OnlineUserProfile _self;
  final $Res Function(_OnlineUserProfile) _then;

/// Create a copy of OnlineUserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? oddserId = null,Object? displayName = null,Object? photoUrl = freezed,Object? email = freezed,Object? rating = null,Object? rankedWins = null,Object? rankedLosses = null,Object? rankedGames = null,Object? casualWins = null,Object? casualLosses = null,Object? casualGames = null,Object? wins = null,Object? losses = null,Object? draws = null,Object? totalGames = null,Object? status = null,Object? createdAt = null,Object? lastSeenAt = null,Object? currentGameId = freezed,}) {
  return _then(_OnlineUserProfile(
oddserId: null == oddserId ? _self.oddserId : oddserId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,rankedWins: null == rankedWins ? _self.rankedWins : rankedWins // ignore: cast_nullable_to_non_nullable
as int,rankedLosses: null == rankedLosses ? _self.rankedLosses : rankedLosses // ignore: cast_nullable_to_non_nullable
as int,rankedGames: null == rankedGames ? _self.rankedGames : rankedGames // ignore: cast_nullable_to_non_nullable
as int,casualWins: null == casualWins ? _self.casualWins : casualWins // ignore: cast_nullable_to_non_nullable
as int,casualLosses: null == casualLosses ? _self.casualLosses : casualLosses // ignore: cast_nullable_to_non_nullable
as int,casualGames: null == casualGames ? _self.casualGames : casualGames // ignore: cast_nullable_to_non_nullable
as int,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,losses: null == losses ? _self.losses : losses // ignore: cast_nullable_to_non_nullable
as int,draws: null == draws ? _self.draws : draws // ignore: cast_nullable_to_non_nullable
as int,totalGames: null == totalGames ? _self.totalGames : totalGames // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConnectionStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastSeenAt: null == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime,currentGameId: freezed == currentGameId ? _self.currentGameId : currentGameId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
