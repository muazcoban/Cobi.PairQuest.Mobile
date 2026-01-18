// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayerStats {

 int get totalGamesPlayed; int get totalGamesWon; int get totalScore; int get highestScore; int get totalMatches; int get perfectGames; int get maxCombo; int get totalPlayTimeSeconds; int get currentStreak; int get longestStreak;
/// Create a copy of PlayerStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerStatsCopyWith<PlayerStats> get copyWith => _$PlayerStatsCopyWithImpl<PlayerStats>(this as PlayerStats, _$identity);

  /// Serializes this PlayerStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerStats&&(identical(other.totalGamesPlayed, totalGamesPlayed) || other.totalGamesPlayed == totalGamesPlayed)&&(identical(other.totalGamesWon, totalGamesWon) || other.totalGamesWon == totalGamesWon)&&(identical(other.totalScore, totalScore) || other.totalScore == totalScore)&&(identical(other.highestScore, highestScore) || other.highestScore == highestScore)&&(identical(other.totalMatches, totalMatches) || other.totalMatches == totalMatches)&&(identical(other.perfectGames, perfectGames) || other.perfectGames == perfectGames)&&(identical(other.maxCombo, maxCombo) || other.maxCombo == maxCombo)&&(identical(other.totalPlayTimeSeconds, totalPlayTimeSeconds) || other.totalPlayTimeSeconds == totalPlayTimeSeconds)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalGamesPlayed,totalGamesWon,totalScore,highestScore,totalMatches,perfectGames,maxCombo,totalPlayTimeSeconds,currentStreak,longestStreak);

@override
String toString() {
  return 'PlayerStats(totalGamesPlayed: $totalGamesPlayed, totalGamesWon: $totalGamesWon, totalScore: $totalScore, highestScore: $highestScore, totalMatches: $totalMatches, perfectGames: $perfectGames, maxCombo: $maxCombo, totalPlayTimeSeconds: $totalPlayTimeSeconds, currentStreak: $currentStreak, longestStreak: $longestStreak)';
}


}

/// @nodoc
abstract mixin class $PlayerStatsCopyWith<$Res>  {
  factory $PlayerStatsCopyWith(PlayerStats value, $Res Function(PlayerStats) _then) = _$PlayerStatsCopyWithImpl;
@useResult
$Res call({
 int totalGamesPlayed, int totalGamesWon, int totalScore, int highestScore, int totalMatches, int perfectGames, int maxCombo, int totalPlayTimeSeconds, int currentStreak, int longestStreak
});




}
/// @nodoc
class _$PlayerStatsCopyWithImpl<$Res>
    implements $PlayerStatsCopyWith<$Res> {
  _$PlayerStatsCopyWithImpl(this._self, this._then);

  final PlayerStats _self;
  final $Res Function(PlayerStats) _then;

/// Create a copy of PlayerStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalGamesPlayed = null,Object? totalGamesWon = null,Object? totalScore = null,Object? highestScore = null,Object? totalMatches = null,Object? perfectGames = null,Object? maxCombo = null,Object? totalPlayTimeSeconds = null,Object? currentStreak = null,Object? longestStreak = null,}) {
  return _then(_self.copyWith(
totalGamesPlayed: null == totalGamesPlayed ? _self.totalGamesPlayed : totalGamesPlayed // ignore: cast_nullable_to_non_nullable
as int,totalGamesWon: null == totalGamesWon ? _self.totalGamesWon : totalGamesWon // ignore: cast_nullable_to_non_nullable
as int,totalScore: null == totalScore ? _self.totalScore : totalScore // ignore: cast_nullable_to_non_nullable
as int,highestScore: null == highestScore ? _self.highestScore : highestScore // ignore: cast_nullable_to_non_nullable
as int,totalMatches: null == totalMatches ? _self.totalMatches : totalMatches // ignore: cast_nullable_to_non_nullable
as int,perfectGames: null == perfectGames ? _self.perfectGames : perfectGames // ignore: cast_nullable_to_non_nullable
as int,maxCombo: null == maxCombo ? _self.maxCombo : maxCombo // ignore: cast_nullable_to_non_nullable
as int,totalPlayTimeSeconds: null == totalPlayTimeSeconds ? _self.totalPlayTimeSeconds : totalPlayTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerStats].
extension PlayerStatsPatterns on PlayerStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerStats value)  $default,){
final _that = this;
switch (_that) {
case _PlayerStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerStats value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalGamesPlayed,  int totalGamesWon,  int totalScore,  int highestScore,  int totalMatches,  int perfectGames,  int maxCombo,  int totalPlayTimeSeconds,  int currentStreak,  int longestStreak)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerStats() when $default != null:
return $default(_that.totalGamesPlayed,_that.totalGamesWon,_that.totalScore,_that.highestScore,_that.totalMatches,_that.perfectGames,_that.maxCombo,_that.totalPlayTimeSeconds,_that.currentStreak,_that.longestStreak);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalGamesPlayed,  int totalGamesWon,  int totalScore,  int highestScore,  int totalMatches,  int perfectGames,  int maxCombo,  int totalPlayTimeSeconds,  int currentStreak,  int longestStreak)  $default,) {final _that = this;
switch (_that) {
case _PlayerStats():
return $default(_that.totalGamesPlayed,_that.totalGamesWon,_that.totalScore,_that.highestScore,_that.totalMatches,_that.perfectGames,_that.maxCombo,_that.totalPlayTimeSeconds,_that.currentStreak,_that.longestStreak);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalGamesPlayed,  int totalGamesWon,  int totalScore,  int highestScore,  int totalMatches,  int perfectGames,  int maxCombo,  int totalPlayTimeSeconds,  int currentStreak,  int longestStreak)?  $default,) {final _that = this;
switch (_that) {
case _PlayerStats() when $default != null:
return $default(_that.totalGamesPlayed,_that.totalGamesWon,_that.totalScore,_that.highestScore,_that.totalMatches,_that.perfectGames,_that.maxCombo,_that.totalPlayTimeSeconds,_that.currentStreak,_that.longestStreak);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayerStats implements PlayerStats {
  const _PlayerStats({this.totalGamesPlayed = 0, this.totalGamesWon = 0, this.totalScore = 0, this.highestScore = 0, this.totalMatches = 0, this.perfectGames = 0, this.maxCombo = 0, this.totalPlayTimeSeconds = 0, this.currentStreak = 0, this.longestStreak = 0});
  factory _PlayerStats.fromJson(Map<String, dynamic> json) => _$PlayerStatsFromJson(json);

@override@JsonKey() final  int totalGamesPlayed;
@override@JsonKey() final  int totalGamesWon;
@override@JsonKey() final  int totalScore;
@override@JsonKey() final  int highestScore;
@override@JsonKey() final  int totalMatches;
@override@JsonKey() final  int perfectGames;
@override@JsonKey() final  int maxCombo;
@override@JsonKey() final  int totalPlayTimeSeconds;
@override@JsonKey() final  int currentStreak;
@override@JsonKey() final  int longestStreak;

/// Create a copy of PlayerStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerStatsCopyWith<_PlayerStats> get copyWith => __$PlayerStatsCopyWithImpl<_PlayerStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerStats&&(identical(other.totalGamesPlayed, totalGamesPlayed) || other.totalGamesPlayed == totalGamesPlayed)&&(identical(other.totalGamesWon, totalGamesWon) || other.totalGamesWon == totalGamesWon)&&(identical(other.totalScore, totalScore) || other.totalScore == totalScore)&&(identical(other.highestScore, highestScore) || other.highestScore == highestScore)&&(identical(other.totalMatches, totalMatches) || other.totalMatches == totalMatches)&&(identical(other.perfectGames, perfectGames) || other.perfectGames == perfectGames)&&(identical(other.maxCombo, maxCombo) || other.maxCombo == maxCombo)&&(identical(other.totalPlayTimeSeconds, totalPlayTimeSeconds) || other.totalPlayTimeSeconds == totalPlayTimeSeconds)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalGamesPlayed,totalGamesWon,totalScore,highestScore,totalMatches,perfectGames,maxCombo,totalPlayTimeSeconds,currentStreak,longestStreak);

@override
String toString() {
  return 'PlayerStats(totalGamesPlayed: $totalGamesPlayed, totalGamesWon: $totalGamesWon, totalScore: $totalScore, highestScore: $highestScore, totalMatches: $totalMatches, perfectGames: $perfectGames, maxCombo: $maxCombo, totalPlayTimeSeconds: $totalPlayTimeSeconds, currentStreak: $currentStreak, longestStreak: $longestStreak)';
}


}

/// @nodoc
abstract mixin class _$PlayerStatsCopyWith<$Res> implements $PlayerStatsCopyWith<$Res> {
  factory _$PlayerStatsCopyWith(_PlayerStats value, $Res Function(_PlayerStats) _then) = __$PlayerStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalGamesPlayed, int totalGamesWon, int totalScore, int highestScore, int totalMatches, int perfectGames, int maxCombo, int totalPlayTimeSeconds, int currentStreak, int longestStreak
});




}
/// @nodoc
class __$PlayerStatsCopyWithImpl<$Res>
    implements _$PlayerStatsCopyWith<$Res> {
  __$PlayerStatsCopyWithImpl(this._self, this._then);

  final _PlayerStats _self;
  final $Res Function(_PlayerStats) _then;

/// Create a copy of PlayerStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalGamesPlayed = null,Object? totalGamesWon = null,Object? totalScore = null,Object? highestScore = null,Object? totalMatches = null,Object? perfectGames = null,Object? maxCombo = null,Object? totalPlayTimeSeconds = null,Object? currentStreak = null,Object? longestStreak = null,}) {
  return _then(_PlayerStats(
totalGamesPlayed: null == totalGamesPlayed ? _self.totalGamesPlayed : totalGamesPlayed // ignore: cast_nullable_to_non_nullable
as int,totalGamesWon: null == totalGamesWon ? _self.totalGamesWon : totalGamesWon // ignore: cast_nullable_to_non_nullable
as int,totalScore: null == totalScore ? _self.totalScore : totalScore // ignore: cast_nullable_to_non_nullable
as int,highestScore: null == highestScore ? _self.highestScore : highestScore // ignore: cast_nullable_to_non_nullable
as int,totalMatches: null == totalMatches ? _self.totalMatches : totalMatches // ignore: cast_nullable_to_non_nullable
as int,perfectGames: null == perfectGames ? _self.perfectGames : perfectGames // ignore: cast_nullable_to_non_nullable
as int,maxCombo: null == maxCombo ? _self.maxCombo : maxCombo // ignore: cast_nullable_to_non_nullable
as int,totalPlayTimeSeconds: null == totalPlayTimeSeconds ? _self.totalPlayTimeSeconds : totalPlayTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$LevelProgress {

 int get level; int get bestScore; int get bestMoves; int get bestTimeSeconds; int get stars; bool get isCompleted; DateTime? get completedAt;
/// Create a copy of LevelProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LevelProgressCopyWith<LevelProgress> get copyWith => _$LevelProgressCopyWithImpl<LevelProgress>(this as LevelProgress, _$identity);

  /// Serializes this LevelProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LevelProgress&&(identical(other.level, level) || other.level == level)&&(identical(other.bestScore, bestScore) || other.bestScore == bestScore)&&(identical(other.bestMoves, bestMoves) || other.bestMoves == bestMoves)&&(identical(other.bestTimeSeconds, bestTimeSeconds) || other.bestTimeSeconds == bestTimeSeconds)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,level,bestScore,bestMoves,bestTimeSeconds,stars,isCompleted,completedAt);

@override
String toString() {
  return 'LevelProgress(level: $level, bestScore: $bestScore, bestMoves: $bestMoves, bestTimeSeconds: $bestTimeSeconds, stars: $stars, isCompleted: $isCompleted, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $LevelProgressCopyWith<$Res>  {
  factory $LevelProgressCopyWith(LevelProgress value, $Res Function(LevelProgress) _then) = _$LevelProgressCopyWithImpl;
@useResult
$Res call({
 int level, int bestScore, int bestMoves, int bestTimeSeconds, int stars, bool isCompleted, DateTime? completedAt
});




}
/// @nodoc
class _$LevelProgressCopyWithImpl<$Res>
    implements $LevelProgressCopyWith<$Res> {
  _$LevelProgressCopyWithImpl(this._self, this._then);

  final LevelProgress _self;
  final $Res Function(LevelProgress) _then;

/// Create a copy of LevelProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level = null,Object? bestScore = null,Object? bestMoves = null,Object? bestTimeSeconds = null,Object? stars = null,Object? isCompleted = null,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,bestScore: null == bestScore ? _self.bestScore : bestScore // ignore: cast_nullable_to_non_nullable
as int,bestMoves: null == bestMoves ? _self.bestMoves : bestMoves // ignore: cast_nullable_to_non_nullable
as int,bestTimeSeconds: null == bestTimeSeconds ? _self.bestTimeSeconds : bestTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LevelProgress].
extension LevelProgressPatterns on LevelProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LevelProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LevelProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LevelProgress value)  $default,){
final _that = this;
switch (_that) {
case _LevelProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LevelProgress value)?  $default,){
final _that = this;
switch (_that) {
case _LevelProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int level,  int bestScore,  int bestMoves,  int bestTimeSeconds,  int stars,  bool isCompleted,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LevelProgress() when $default != null:
return $default(_that.level,_that.bestScore,_that.bestMoves,_that.bestTimeSeconds,_that.stars,_that.isCompleted,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int level,  int bestScore,  int bestMoves,  int bestTimeSeconds,  int stars,  bool isCompleted,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _LevelProgress():
return $default(_that.level,_that.bestScore,_that.bestMoves,_that.bestTimeSeconds,_that.stars,_that.isCompleted,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int level,  int bestScore,  int bestMoves,  int bestTimeSeconds,  int stars,  bool isCompleted,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _LevelProgress() when $default != null:
return $default(_that.level,_that.bestScore,_that.bestMoves,_that.bestTimeSeconds,_that.stars,_that.isCompleted,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LevelProgress implements LevelProgress {
  const _LevelProgress({required this.level, this.bestScore = 0, this.bestMoves = 0, this.bestTimeSeconds = 0, this.stars = 0, this.isCompleted = false, this.completedAt});
  factory _LevelProgress.fromJson(Map<String, dynamic> json) => _$LevelProgressFromJson(json);

@override final  int level;
@override@JsonKey() final  int bestScore;
@override@JsonKey() final  int bestMoves;
@override@JsonKey() final  int bestTimeSeconds;
@override@JsonKey() final  int stars;
@override@JsonKey() final  bool isCompleted;
@override final  DateTime? completedAt;

/// Create a copy of LevelProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LevelProgressCopyWith<_LevelProgress> get copyWith => __$LevelProgressCopyWithImpl<_LevelProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LevelProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LevelProgress&&(identical(other.level, level) || other.level == level)&&(identical(other.bestScore, bestScore) || other.bestScore == bestScore)&&(identical(other.bestMoves, bestMoves) || other.bestMoves == bestMoves)&&(identical(other.bestTimeSeconds, bestTimeSeconds) || other.bestTimeSeconds == bestTimeSeconds)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,level,bestScore,bestMoves,bestTimeSeconds,stars,isCompleted,completedAt);

@override
String toString() {
  return 'LevelProgress(level: $level, bestScore: $bestScore, bestMoves: $bestMoves, bestTimeSeconds: $bestTimeSeconds, stars: $stars, isCompleted: $isCompleted, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$LevelProgressCopyWith<$Res> implements $LevelProgressCopyWith<$Res> {
  factory _$LevelProgressCopyWith(_LevelProgress value, $Res Function(_LevelProgress) _then) = __$LevelProgressCopyWithImpl;
@override @useResult
$Res call({
 int level, int bestScore, int bestMoves, int bestTimeSeconds, int stars, bool isCompleted, DateTime? completedAt
});




}
/// @nodoc
class __$LevelProgressCopyWithImpl<$Res>
    implements _$LevelProgressCopyWith<$Res> {
  __$LevelProgressCopyWithImpl(this._self, this._then);

  final _LevelProgress _self;
  final $Res Function(_LevelProgress) _then;

/// Create a copy of LevelProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level = null,Object? bestScore = null,Object? bestMoves = null,Object? bestTimeSeconds = null,Object? stars = null,Object? isCompleted = null,Object? completedAt = freezed,}) {
  return _then(_LevelProgress(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,bestScore: null == bestScore ? _self.bestScore : bestScore // ignore: cast_nullable_to_non_nullable
as int,bestMoves: null == bestMoves ? _self.bestMoves : bestMoves // ignore: cast_nullable_to_non_nullable
as int,bestTimeSeconds: null == bestTimeSeconds ? _self.bestTimeSeconds : bestTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Player {

 String get id; String get username; DateTime get createdAt; DateTime get lastActiveAt; PlayerStats get stats; Map<int, LevelProgress> get levelProgress; List<String> get unlockedThemes; int get currentLevel;
/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerCopyWith<Player> get copyWith => _$PlayerCopyWithImpl<Player>(this as Player, _$identity);

  /// Serializes this Player to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Player&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other.levelProgress, levelProgress)&&const DeepCollectionEquality().equals(other.unlockedThemes, unlockedThemes)&&(identical(other.currentLevel, currentLevel) || other.currentLevel == currentLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,createdAt,lastActiveAt,stats,const DeepCollectionEquality().hash(levelProgress),const DeepCollectionEquality().hash(unlockedThemes),currentLevel);

@override
String toString() {
  return 'Player(id: $id, username: $username, createdAt: $createdAt, lastActiveAt: $lastActiveAt, stats: $stats, levelProgress: $levelProgress, unlockedThemes: $unlockedThemes, currentLevel: $currentLevel)';
}


}

/// @nodoc
abstract mixin class $PlayerCopyWith<$Res>  {
  factory $PlayerCopyWith(Player value, $Res Function(Player) _then) = _$PlayerCopyWithImpl;
@useResult
$Res call({
 String id, String username, DateTime createdAt, DateTime lastActiveAt, PlayerStats stats, Map<int, LevelProgress> levelProgress, List<String> unlockedThemes, int currentLevel
});


$PlayerStatsCopyWith<$Res> get stats;

}
/// @nodoc
class _$PlayerCopyWithImpl<$Res>
    implements $PlayerCopyWith<$Res> {
  _$PlayerCopyWithImpl(this._self, this._then);

  final Player _self;
  final $Res Function(Player) _then;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? createdAt = null,Object? lastActiveAt = null,Object? stats = null,Object? levelProgress = null,Object? unlockedThemes = null,Object? currentLevel = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastActiveAt: null == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as PlayerStats,levelProgress: null == levelProgress ? _self.levelProgress : levelProgress // ignore: cast_nullable_to_non_nullable
as Map<int, LevelProgress>,unlockedThemes: null == unlockedThemes ? _self.unlockedThemes : unlockedThemes // ignore: cast_nullable_to_non_nullable
as List<String>,currentLevel: null == currentLevel ? _self.currentLevel : currentLevel // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerStatsCopyWith<$Res> get stats {
  
  return $PlayerStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [Player].
extension PlayerPatterns on Player {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Player value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Player() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Player value)  $default,){
final _that = this;
switch (_that) {
case _Player():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Player value)?  $default,){
final _that = this;
switch (_that) {
case _Player() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  DateTime createdAt,  DateTime lastActiveAt,  PlayerStats stats,  Map<int, LevelProgress> levelProgress,  List<String> unlockedThemes,  int currentLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Player() when $default != null:
return $default(_that.id,_that.username,_that.createdAt,_that.lastActiveAt,_that.stats,_that.levelProgress,_that.unlockedThemes,_that.currentLevel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  DateTime createdAt,  DateTime lastActiveAt,  PlayerStats stats,  Map<int, LevelProgress> levelProgress,  List<String> unlockedThemes,  int currentLevel)  $default,) {final _that = this;
switch (_that) {
case _Player():
return $default(_that.id,_that.username,_that.createdAt,_that.lastActiveAt,_that.stats,_that.levelProgress,_that.unlockedThemes,_that.currentLevel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  DateTime createdAt,  DateTime lastActiveAt,  PlayerStats stats,  Map<int, LevelProgress> levelProgress,  List<String> unlockedThemes,  int currentLevel)?  $default,) {final _that = this;
switch (_that) {
case _Player() when $default != null:
return $default(_that.id,_that.username,_that.createdAt,_that.lastActiveAt,_that.stats,_that.levelProgress,_that.unlockedThemes,_that.currentLevel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Player extends Player {
  const _Player({required this.id, this.username = 'Player', required this.createdAt, required this.lastActiveAt, this.stats = const PlayerStats(), final  Map<int, LevelProgress> levelProgress = const {}, final  List<String> unlockedThemes = const ['animals'], this.currentLevel = 1}): _levelProgress = levelProgress,_unlockedThemes = unlockedThemes,super._();
  factory _Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

@override final  String id;
@override@JsonKey() final  String username;
@override final  DateTime createdAt;
@override final  DateTime lastActiveAt;
@override@JsonKey() final  PlayerStats stats;
 final  Map<int, LevelProgress> _levelProgress;
@override@JsonKey() Map<int, LevelProgress> get levelProgress {
  if (_levelProgress is EqualUnmodifiableMapView) return _levelProgress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_levelProgress);
}

 final  List<String> _unlockedThemes;
@override@JsonKey() List<String> get unlockedThemes {
  if (_unlockedThemes is EqualUnmodifiableListView) return _unlockedThemes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unlockedThemes);
}

@override@JsonKey() final  int currentLevel;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerCopyWith<_Player> get copyWith => __$PlayerCopyWithImpl<_Player>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Player&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other._levelProgress, _levelProgress)&&const DeepCollectionEquality().equals(other._unlockedThemes, _unlockedThemes)&&(identical(other.currentLevel, currentLevel) || other.currentLevel == currentLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,createdAt,lastActiveAt,stats,const DeepCollectionEquality().hash(_levelProgress),const DeepCollectionEquality().hash(_unlockedThemes),currentLevel);

@override
String toString() {
  return 'Player(id: $id, username: $username, createdAt: $createdAt, lastActiveAt: $lastActiveAt, stats: $stats, levelProgress: $levelProgress, unlockedThemes: $unlockedThemes, currentLevel: $currentLevel)';
}


}

/// @nodoc
abstract mixin class _$PlayerCopyWith<$Res> implements $PlayerCopyWith<$Res> {
  factory _$PlayerCopyWith(_Player value, $Res Function(_Player) _then) = __$PlayerCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, DateTime createdAt, DateTime lastActiveAt, PlayerStats stats, Map<int, LevelProgress> levelProgress, List<String> unlockedThemes, int currentLevel
});


@override $PlayerStatsCopyWith<$Res> get stats;

}
/// @nodoc
class __$PlayerCopyWithImpl<$Res>
    implements _$PlayerCopyWith<$Res> {
  __$PlayerCopyWithImpl(this._self, this._then);

  final _Player _self;
  final $Res Function(_Player) _then;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? createdAt = null,Object? lastActiveAt = null,Object? stats = null,Object? levelProgress = null,Object? unlockedThemes = null,Object? currentLevel = null,}) {
  return _then(_Player(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastActiveAt: null == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as PlayerStats,levelProgress: null == levelProgress ? _self._levelProgress : levelProgress // ignore: cast_nullable_to_non_nullable
as Map<int, LevelProgress>,unlockedThemes: null == unlockedThemes ? _self._unlockedThemes : unlockedThemes // ignore: cast_nullable_to_non_nullable
as List<String>,currentLevel: null == currentLevel ? _self.currentLevel : currentLevel // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerStatsCopyWith<$Res> get stats {
  
  return $PlayerStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}

// dart format on
