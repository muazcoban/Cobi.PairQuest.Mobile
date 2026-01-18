// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameCard {

/// Unique identifier for this card
 String get id;/// Shared identifier for matching pairs
 String get pairId;/// Image asset path or identifier
 String get imageAsset;/// Position index in the grid (0-indexed)
 int get position;/// Current state of the card
 CardState get state;/// Theme this card belongs to
 String get theme;
/// Create a copy of GameCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameCardCopyWith<GameCard> get copyWith => _$GameCardCopyWithImpl<GameCard>(this as GameCard, _$identity);

  /// Serializes this GameCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameCard&&(identical(other.id, id) || other.id == id)&&(identical(other.pairId, pairId) || other.pairId == pairId)&&(identical(other.imageAsset, imageAsset) || other.imageAsset == imageAsset)&&(identical(other.position, position) || other.position == position)&&(identical(other.state, state) || other.state == state)&&(identical(other.theme, theme) || other.theme == theme));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pairId,imageAsset,position,state,theme);

@override
String toString() {
  return 'GameCard(id: $id, pairId: $pairId, imageAsset: $imageAsset, position: $position, state: $state, theme: $theme)';
}


}

/// @nodoc
abstract mixin class $GameCardCopyWith<$Res>  {
  factory $GameCardCopyWith(GameCard value, $Res Function(GameCard) _then) = _$GameCardCopyWithImpl;
@useResult
$Res call({
 String id, String pairId, String imageAsset, int position, CardState state, String theme
});




}
/// @nodoc
class _$GameCardCopyWithImpl<$Res>
    implements $GameCardCopyWith<$Res> {
  _$GameCardCopyWithImpl(this._self, this._then);

  final GameCard _self;
  final $Res Function(GameCard) _then;

/// Create a copy of GameCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? pairId = null,Object? imageAsset = null,Object? position = null,Object? state = null,Object? theme = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pairId: null == pairId ? _self.pairId : pairId // ignore: cast_nullable_to_non_nullable
as String,imageAsset: null == imageAsset ? _self.imageAsset : imageAsset // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as CardState,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GameCard].
extension GameCardPatterns on GameCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameCard value)  $default,){
final _that = this;
switch (_that) {
case _GameCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameCard value)?  $default,){
final _that = this;
switch (_that) {
case _GameCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String pairId,  String imageAsset,  int position,  CardState state,  String theme)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameCard() when $default != null:
return $default(_that.id,_that.pairId,_that.imageAsset,_that.position,_that.state,_that.theme);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String pairId,  String imageAsset,  int position,  CardState state,  String theme)  $default,) {final _that = this;
switch (_that) {
case _GameCard():
return $default(_that.id,_that.pairId,_that.imageAsset,_that.position,_that.state,_that.theme);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String pairId,  String imageAsset,  int position,  CardState state,  String theme)?  $default,) {final _that = this;
switch (_that) {
case _GameCard() when $default != null:
return $default(_that.id,_that.pairId,_that.imageAsset,_that.position,_that.state,_that.theme);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameCard implements GameCard {
  const _GameCard({required this.id, required this.pairId, required this.imageAsset, required this.position, this.state = CardState.hidden, this.theme = 'animals'});
  factory _GameCard.fromJson(Map<String, dynamic> json) => _$GameCardFromJson(json);

/// Unique identifier for this card
@override final  String id;
/// Shared identifier for matching pairs
@override final  String pairId;
/// Image asset path or identifier
@override final  String imageAsset;
/// Position index in the grid (0-indexed)
@override final  int position;
/// Current state of the card
@override@JsonKey() final  CardState state;
/// Theme this card belongs to
@override@JsonKey() final  String theme;

/// Create a copy of GameCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameCardCopyWith<_GameCard> get copyWith => __$GameCardCopyWithImpl<_GameCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameCard&&(identical(other.id, id) || other.id == id)&&(identical(other.pairId, pairId) || other.pairId == pairId)&&(identical(other.imageAsset, imageAsset) || other.imageAsset == imageAsset)&&(identical(other.position, position) || other.position == position)&&(identical(other.state, state) || other.state == state)&&(identical(other.theme, theme) || other.theme == theme));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pairId,imageAsset,position,state,theme);

@override
String toString() {
  return 'GameCard(id: $id, pairId: $pairId, imageAsset: $imageAsset, position: $position, state: $state, theme: $theme)';
}


}

/// @nodoc
abstract mixin class _$GameCardCopyWith<$Res> implements $GameCardCopyWith<$Res> {
  factory _$GameCardCopyWith(_GameCard value, $Res Function(_GameCard) _then) = __$GameCardCopyWithImpl;
@override @useResult
$Res call({
 String id, String pairId, String imageAsset, int position, CardState state, String theme
});




}
/// @nodoc
class __$GameCardCopyWithImpl<$Res>
    implements _$GameCardCopyWith<$Res> {
  __$GameCardCopyWithImpl(this._self, this._then);

  final _GameCard _self;
  final $Res Function(_GameCard) _then;

/// Create a copy of GameCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? pairId = null,Object? imageAsset = null,Object? position = null,Object? state = null,Object? theme = null,}) {
  return _then(_GameCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pairId: null == pairId ? _self.pairId : pairId // ignore: cast_nullable_to_non_nullable
as String,imageAsset: null == imageAsset ? _self.imageAsset : imageAsset // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as CardState,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
