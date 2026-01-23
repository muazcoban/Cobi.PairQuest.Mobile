// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUser {

/// Firebase user ID
 String get uid;/// Display name
 String? get displayName;/// Email address
 String? get email;/// Profile photo URL
 String? get photoUrl;/// Total games played
 int get totalGames;/// Total score accumulated
 int get totalScore;/// Highest level completed
 int get highestLevel;/// Best score ever achieved
 int get bestScore;/// Total matches found
 int get totalMatches;/// Account creation timestamp
@TimestampConverter() DateTime? get createdAt;/// Last played timestamp
@TimestampConverter() DateTime? get lastPlayedAt;/// Is anonymous user
 bool get isAnonymous;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.totalGames, totalGames) || other.totalGames == totalGames)&&(identical(other.totalScore, totalScore) || other.totalScore == totalScore)&&(identical(other.highestLevel, highestLevel) || other.highestLevel == highestLevel)&&(identical(other.bestScore, bestScore) || other.bestScore == bestScore)&&(identical(other.totalMatches, totalMatches) || other.totalMatches == totalMatches)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastPlayedAt, lastPlayedAt) || other.lastPlayedAt == lastPlayedAt)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,displayName,email,photoUrl,totalGames,totalScore,highestLevel,bestScore,totalMatches,createdAt,lastPlayedAt,isAnonymous);

@override
String toString() {
  return 'AppUser(uid: $uid, displayName: $displayName, email: $email, photoUrl: $photoUrl, totalGames: $totalGames, totalScore: $totalScore, highestLevel: $highestLevel, bestScore: $bestScore, totalMatches: $totalMatches, createdAt: $createdAt, lastPlayedAt: $lastPlayedAt, isAnonymous: $isAnonymous)';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String uid, String? displayName, String? email, String? photoUrl, int totalGames, int totalScore, int highestLevel, int bestScore, int totalMatches,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? lastPlayedAt, bool isAnonymous
});




}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? displayName = freezed,Object? email = freezed,Object? photoUrl = freezed,Object? totalGames = null,Object? totalScore = null,Object? highestLevel = null,Object? bestScore = null,Object? totalMatches = null,Object? createdAt = freezed,Object? lastPlayedAt = freezed,Object? isAnonymous = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,totalGames: null == totalGames ? _self.totalGames : totalGames // ignore: cast_nullable_to_non_nullable
as int,totalScore: null == totalScore ? _self.totalScore : totalScore // ignore: cast_nullable_to_non_nullable
as int,highestLevel: null == highestLevel ? _self.highestLevel : highestLevel // ignore: cast_nullable_to_non_nullable
as int,bestScore: null == bestScore ? _self.bestScore : bestScore // ignore: cast_nullable_to_non_nullable
as int,totalMatches: null == totalMatches ? _self.totalMatches : totalMatches // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPlayedAt: freezed == lastPlayedAt ? _self.lastPlayedAt : lastPlayedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String? displayName,  String? email,  String? photoUrl,  int totalGames,  int totalScore,  int highestLevel,  int bestScore,  int totalMatches, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? lastPlayedAt,  bool isAnonymous)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.uid,_that.displayName,_that.email,_that.photoUrl,_that.totalGames,_that.totalScore,_that.highestLevel,_that.bestScore,_that.totalMatches,_that.createdAt,_that.lastPlayedAt,_that.isAnonymous);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String? displayName,  String? email,  String? photoUrl,  int totalGames,  int totalScore,  int highestLevel,  int bestScore,  int totalMatches, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? lastPlayedAt,  bool isAnonymous)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.uid,_that.displayName,_that.email,_that.photoUrl,_that.totalGames,_that.totalScore,_that.highestLevel,_that.bestScore,_that.totalMatches,_that.createdAt,_that.lastPlayedAt,_that.isAnonymous);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String? displayName,  String? email,  String? photoUrl,  int totalGames,  int totalScore,  int highestLevel,  int bestScore,  int totalMatches, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? lastPlayedAt,  bool isAnonymous)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.uid,_that.displayName,_that.email,_that.photoUrl,_that.totalGames,_that.totalScore,_that.highestLevel,_that.bestScore,_that.totalMatches,_that.createdAt,_that.lastPlayedAt,_that.isAnonymous);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUser extends AppUser {
  const _AppUser({required this.uid, this.displayName, this.email, this.photoUrl, this.totalGames = 0, this.totalScore = 0, this.highestLevel = 0, this.bestScore = 0, this.totalMatches = 0, @TimestampConverter() this.createdAt, @TimestampConverter() this.lastPlayedAt, this.isAnonymous = true}): super._();
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

/// Firebase user ID
@override final  String uid;
/// Display name
@override final  String? displayName;
/// Email address
@override final  String? email;
/// Profile photo URL
@override final  String? photoUrl;
/// Total games played
@override@JsonKey() final  int totalGames;
/// Total score accumulated
@override@JsonKey() final  int totalScore;
/// Highest level completed
@override@JsonKey() final  int highestLevel;
/// Best score ever achieved
@override@JsonKey() final  int bestScore;
/// Total matches found
@override@JsonKey() final  int totalMatches;
/// Account creation timestamp
@override@TimestampConverter() final  DateTime? createdAt;
/// Last played timestamp
@override@TimestampConverter() final  DateTime? lastPlayedAt;
/// Is anonymous user
@override@JsonKey() final  bool isAnonymous;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.totalGames, totalGames) || other.totalGames == totalGames)&&(identical(other.totalScore, totalScore) || other.totalScore == totalScore)&&(identical(other.highestLevel, highestLevel) || other.highestLevel == highestLevel)&&(identical(other.bestScore, bestScore) || other.bestScore == bestScore)&&(identical(other.totalMatches, totalMatches) || other.totalMatches == totalMatches)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastPlayedAt, lastPlayedAt) || other.lastPlayedAt == lastPlayedAt)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,displayName,email,photoUrl,totalGames,totalScore,highestLevel,bestScore,totalMatches,createdAt,lastPlayedAt,isAnonymous);

@override
String toString() {
  return 'AppUser(uid: $uid, displayName: $displayName, email: $email, photoUrl: $photoUrl, totalGames: $totalGames, totalScore: $totalScore, highestLevel: $highestLevel, bestScore: $bestScore, totalMatches: $totalMatches, createdAt: $createdAt, lastPlayedAt: $lastPlayedAt, isAnonymous: $isAnonymous)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String uid, String? displayName, String? email, String? photoUrl, int totalGames, int totalScore, int highestLevel, int bestScore, int totalMatches,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? lastPlayedAt, bool isAnonymous
});




}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? displayName = freezed,Object? email = freezed,Object? photoUrl = freezed,Object? totalGames = null,Object? totalScore = null,Object? highestLevel = null,Object? bestScore = null,Object? totalMatches = null,Object? createdAt = freezed,Object? lastPlayedAt = freezed,Object? isAnonymous = null,}) {
  return _then(_AppUser(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,totalGames: null == totalGames ? _self.totalGames : totalGames // ignore: cast_nullable_to_non_nullable
as int,totalScore: null == totalScore ? _self.totalScore : totalScore // ignore: cast_nullable_to_non_nullable
as int,highestLevel: null == highestLevel ? _self.highestLevel : highestLevel // ignore: cast_nullable_to_non_nullable
as int,bestScore: null == bestScore ? _self.bestScore : bestScore // ignore: cast_nullable_to_non_nullable
as int,totalMatches: null == totalMatches ? _self.totalMatches : totalMatches // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPlayedAt: freezed == lastPlayedAt ? _self.lastPlayedAt : lastPlayedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
