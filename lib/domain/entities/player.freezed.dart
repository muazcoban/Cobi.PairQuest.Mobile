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
mixin _$Player {

/// Unique player identifier
 String get id;/// Player display name
 String get name;/// Player color index (0-3 for predefined colors)
 int get colorIndex;/// Player's current score
 int get score;/// Number of pairs matched by this player
 int get matches;/// Number of moves made
 int get moves;/// Current combo streak
 int get combo;/// Maximum combo achieved
 int get maxCombo;/// Number of errors (mismatches)
 int get errors;
/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerCopyWith<Player> get copyWith => _$PlayerCopyWithImpl<Player>(this as Player, _$identity);

  /// Serializes this Player to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Player&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.colorIndex, colorIndex) || other.colorIndex == colorIndex)&&(identical(other.score, score) || other.score == score)&&(identical(other.matches, matches) || other.matches == matches)&&(identical(other.moves, moves) || other.moves == moves)&&(identical(other.combo, combo) || other.combo == combo)&&(identical(other.maxCombo, maxCombo) || other.maxCombo == maxCombo)&&(identical(other.errors, errors) || other.errors == errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,colorIndex,score,matches,moves,combo,maxCombo,errors);

@override
String toString() {
  return 'Player(id: $id, name: $name, colorIndex: $colorIndex, score: $score, matches: $matches, moves: $moves, combo: $combo, maxCombo: $maxCombo, errors: $errors)';
}


}

/// @nodoc
abstract mixin class $PlayerCopyWith<$Res>  {
  factory $PlayerCopyWith(Player value, $Res Function(Player) _then) = _$PlayerCopyWithImpl;
@useResult
$Res call({
 String id, String name, int colorIndex, int score, int matches, int moves, int combo, int maxCombo, int errors
});




}
/// @nodoc
class _$PlayerCopyWithImpl<$Res>
    implements $PlayerCopyWith<$Res> {
  _$PlayerCopyWithImpl(this._self, this._then);

  final Player _self;
  final $Res Function(Player) _then;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? colorIndex = null,Object? score = null,Object? matches = null,Object? moves = null,Object? combo = null,Object? maxCombo = null,Object? errors = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,colorIndex: null == colorIndex ? _self.colorIndex : colorIndex // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,matches: null == matches ? _self.matches : matches // ignore: cast_nullable_to_non_nullable
as int,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as int,combo: null == combo ? _self.combo : combo // ignore: cast_nullable_to_non_nullable
as int,maxCombo: null == maxCombo ? _self.maxCombo : maxCombo // ignore: cast_nullable_to_non_nullable
as int,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as int,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int colorIndex,  int score,  int matches,  int moves,  int combo,  int maxCombo,  int errors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Player() when $default != null:
return $default(_that.id,_that.name,_that.colorIndex,_that.score,_that.matches,_that.moves,_that.combo,_that.maxCombo,_that.errors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int colorIndex,  int score,  int matches,  int moves,  int combo,  int maxCombo,  int errors)  $default,) {final _that = this;
switch (_that) {
case _Player():
return $default(_that.id,_that.name,_that.colorIndex,_that.score,_that.matches,_that.moves,_that.combo,_that.maxCombo,_that.errors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int colorIndex,  int score,  int matches,  int moves,  int combo,  int maxCombo,  int errors)?  $default,) {final _that = this;
switch (_that) {
case _Player() when $default != null:
return $default(_that.id,_that.name,_that.colorIndex,_that.score,_that.matches,_that.moves,_that.combo,_that.maxCombo,_that.errors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Player extends Player {
  const _Player({required this.id, required this.name, this.colorIndex = 0, this.score = 0, this.matches = 0, this.moves = 0, this.combo = 0, this.maxCombo = 0, this.errors = 0}): super._();
  factory _Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

/// Unique player identifier
@override final  String id;
/// Player display name
@override final  String name;
/// Player color index (0-3 for predefined colors)
@override@JsonKey() final  int colorIndex;
/// Player's current score
@override@JsonKey() final  int score;
/// Number of pairs matched by this player
@override@JsonKey() final  int matches;
/// Number of moves made
@override@JsonKey() final  int moves;
/// Current combo streak
@override@JsonKey() final  int combo;
/// Maximum combo achieved
@override@JsonKey() final  int maxCombo;
/// Number of errors (mismatches)
@override@JsonKey() final  int errors;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Player&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.colorIndex, colorIndex) || other.colorIndex == colorIndex)&&(identical(other.score, score) || other.score == score)&&(identical(other.matches, matches) || other.matches == matches)&&(identical(other.moves, moves) || other.moves == moves)&&(identical(other.combo, combo) || other.combo == combo)&&(identical(other.maxCombo, maxCombo) || other.maxCombo == maxCombo)&&(identical(other.errors, errors) || other.errors == errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,colorIndex,score,matches,moves,combo,maxCombo,errors);

@override
String toString() {
  return 'Player(id: $id, name: $name, colorIndex: $colorIndex, score: $score, matches: $matches, moves: $moves, combo: $combo, maxCombo: $maxCombo, errors: $errors)';
}


}

/// @nodoc
abstract mixin class _$PlayerCopyWith<$Res> implements $PlayerCopyWith<$Res> {
  factory _$PlayerCopyWith(_Player value, $Res Function(_Player) _then) = __$PlayerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int colorIndex, int score, int matches, int moves, int combo, int maxCombo, int errors
});




}
/// @nodoc
class __$PlayerCopyWithImpl<$Res>
    implements _$PlayerCopyWith<$Res> {
  __$PlayerCopyWithImpl(this._self, this._then);

  final _Player _self;
  final $Res Function(_Player) _then;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? colorIndex = null,Object? score = null,Object? matches = null,Object? moves = null,Object? combo = null,Object? maxCombo = null,Object? errors = null,}) {
  return _then(_Player(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,colorIndex: null == colorIndex ? _self.colorIndex : colorIndex // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,matches: null == matches ? _self.matches : matches // ignore: cast_nullable_to_non_nullable
as int,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as int,combo: null == combo ? _self.combo : combo // ignore: cast_nullable_to_non_nullable
as int,maxCombo: null == maxCombo ? _self.maxCombo : maxCombo // ignore: cast_nullable_to_non_nullable
as int,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
