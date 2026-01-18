// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GridSize {

 int get rows; int get cols;
/// Create a copy of GridSize
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GridSizeCopyWith<GridSize> get copyWith => _$GridSizeCopyWithImpl<GridSize>(this as GridSize, _$identity);

  /// Serializes this GridSize to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GridSize&&(identical(other.rows, rows) || other.rows == rows)&&(identical(other.cols, cols) || other.cols == cols));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rows,cols);

@override
String toString() {
  return 'GridSize(rows: $rows, cols: $cols)';
}


}

/// @nodoc
abstract mixin class $GridSizeCopyWith<$Res>  {
  factory $GridSizeCopyWith(GridSize value, $Res Function(GridSize) _then) = _$GridSizeCopyWithImpl;
@useResult
$Res call({
 int rows, int cols
});




}
/// @nodoc
class _$GridSizeCopyWithImpl<$Res>
    implements $GridSizeCopyWith<$Res> {
  _$GridSizeCopyWithImpl(this._self, this._then);

  final GridSize _self;
  final $Res Function(GridSize) _then;

/// Create a copy of GridSize
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rows = null,Object? cols = null,}) {
  return _then(_self.copyWith(
rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as int,cols: null == cols ? _self.cols : cols // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GridSize].
extension GridSizePatterns on GridSize {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GridSize value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GridSize() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GridSize value)  $default,){
final _that = this;
switch (_that) {
case _GridSize():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GridSize value)?  $default,){
final _that = this;
switch (_that) {
case _GridSize() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rows,  int cols)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GridSize() when $default != null:
return $default(_that.rows,_that.cols);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rows,  int cols)  $default,) {final _that = this;
switch (_that) {
case _GridSize():
return $default(_that.rows,_that.cols);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rows,  int cols)?  $default,) {final _that = this;
switch (_that) {
case _GridSize() when $default != null:
return $default(_that.rows,_that.cols);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GridSize extends GridSize {
  const _GridSize({required this.rows, required this.cols}): super._();
  factory _GridSize.fromJson(Map<String, dynamic> json) => _$GridSizeFromJson(json);

@override final  int rows;
@override final  int cols;

/// Create a copy of GridSize
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GridSizeCopyWith<_GridSize> get copyWith => __$GridSizeCopyWithImpl<_GridSize>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GridSizeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GridSize&&(identical(other.rows, rows) || other.rows == rows)&&(identical(other.cols, cols) || other.cols == cols));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rows,cols);

@override
String toString() {
  return 'GridSize(rows: $rows, cols: $cols)';
}


}

/// @nodoc
abstract mixin class _$GridSizeCopyWith<$Res> implements $GridSizeCopyWith<$Res> {
  factory _$GridSizeCopyWith(_GridSize value, $Res Function(_GridSize) _then) = __$GridSizeCopyWithImpl;
@override @useResult
$Res call({
 int rows, int cols
});




}
/// @nodoc
class __$GridSizeCopyWithImpl<$Res>
    implements _$GridSizeCopyWith<$Res> {
  __$GridSizeCopyWithImpl(this._self, this._then);

  final _GridSize _self;
  final $Res Function(_GridSize) _then;

/// Create a copy of GridSize
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rows = null,Object? cols = null,}) {
  return _then(_GridSize(
rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as int,cols: null == cols ? _self.cols : cols // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Game {

/// Unique game identifier
 String get id;/// Current game mode
 GameMode get mode;/// Difficulty level (1-10)
 int get level;/// Grid configuration
 GridSize get gridSize;/// All cards in the game
 List<GameCard> get cards;/// Current game state
 GameState get state;/// Current score
 int get score;/// Number of moves made
 int get moves;/// Number of pairs matched
 int get matches;/// Current combo count
 int get combo;/// Maximum combo achieved
 int get maxCombo;/// Number of errors made
 int get errors;/// Game start time
 DateTime? get startTime;/// Game end time
 DateTime? get endTime;/// Time limit in seconds (for timed mode)
 int? get timeLimit;/// Remaining time in seconds
 int? get timeRemaining;/// Theme used for this game
 String get theme;// ===== Multiplayer fields =====
/// List of players (for multiplayer mode)
 List<Player>? get players;/// Index of current player (0 to players.length-1)
 int get currentPlayerIndex;/// Whether the current player earned an extra turn (matched successfully)
 bool get extraTurnAwarded;
/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameCopyWith<Game> get copyWith => _$GameCopyWithImpl<Game>(this as Game, _$identity);

  /// Serializes this Game to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Game&&(identical(other.id, id) || other.id == id)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.level, level) || other.level == level)&&(identical(other.gridSize, gridSize) || other.gridSize == gridSize)&&const DeepCollectionEquality().equals(other.cards, cards)&&(identical(other.state, state) || other.state == state)&&(identical(other.score, score) || other.score == score)&&(identical(other.moves, moves) || other.moves == moves)&&(identical(other.matches, matches) || other.matches == matches)&&(identical(other.combo, combo) || other.combo == combo)&&(identical(other.maxCombo, maxCombo) || other.maxCombo == maxCombo)&&(identical(other.errors, errors) || other.errors == errors)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.timeLimit, timeLimit) || other.timeLimit == timeLimit)&&(identical(other.timeRemaining, timeRemaining) || other.timeRemaining == timeRemaining)&&(identical(other.theme, theme) || other.theme == theme)&&const DeepCollectionEquality().equals(other.players, players)&&(identical(other.currentPlayerIndex, currentPlayerIndex) || other.currentPlayerIndex == currentPlayerIndex)&&(identical(other.extraTurnAwarded, extraTurnAwarded) || other.extraTurnAwarded == extraTurnAwarded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,mode,level,gridSize,const DeepCollectionEquality().hash(cards),state,score,moves,matches,combo,maxCombo,errors,startTime,endTime,timeLimit,timeRemaining,theme,const DeepCollectionEquality().hash(players),currentPlayerIndex,extraTurnAwarded]);

@override
String toString() {
  return 'Game(id: $id, mode: $mode, level: $level, gridSize: $gridSize, cards: $cards, state: $state, score: $score, moves: $moves, matches: $matches, combo: $combo, maxCombo: $maxCombo, errors: $errors, startTime: $startTime, endTime: $endTime, timeLimit: $timeLimit, timeRemaining: $timeRemaining, theme: $theme, players: $players, currentPlayerIndex: $currentPlayerIndex, extraTurnAwarded: $extraTurnAwarded)';
}


}

/// @nodoc
abstract mixin class $GameCopyWith<$Res>  {
  factory $GameCopyWith(Game value, $Res Function(Game) _then) = _$GameCopyWithImpl;
@useResult
$Res call({
 String id, GameMode mode, int level, GridSize gridSize, List<GameCard> cards, GameState state, int score, int moves, int matches, int combo, int maxCombo, int errors, DateTime? startTime, DateTime? endTime, int? timeLimit, int? timeRemaining, String theme, List<Player>? players, int currentPlayerIndex, bool extraTurnAwarded
});


$GridSizeCopyWith<$Res> get gridSize;

}
/// @nodoc
class _$GameCopyWithImpl<$Res>
    implements $GameCopyWith<$Res> {
  _$GameCopyWithImpl(this._self, this._then);

  final Game _self;
  final $Res Function(Game) _then;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? mode = null,Object? level = null,Object? gridSize = null,Object? cards = null,Object? state = null,Object? score = null,Object? moves = null,Object? matches = null,Object? combo = null,Object? maxCombo = null,Object? errors = null,Object? startTime = freezed,Object? endTime = freezed,Object? timeLimit = freezed,Object? timeRemaining = freezed,Object? theme = null,Object? players = freezed,Object? currentPlayerIndex = null,Object? extraTurnAwarded = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,gridSize: null == gridSize ? _self.gridSize : gridSize // ignore: cast_nullable_to_non_nullable
as GridSize,cards: null == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as List<GameCard>,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as GameState,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as int,matches: null == matches ? _self.matches : matches // ignore: cast_nullable_to_non_nullable
as int,combo: null == combo ? _self.combo : combo // ignore: cast_nullable_to_non_nullable
as int,maxCombo: null == maxCombo ? _self.maxCombo : maxCombo // ignore: cast_nullable_to_non_nullable
as int,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as int,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,timeLimit: freezed == timeLimit ? _self.timeLimit : timeLimit // ignore: cast_nullable_to_non_nullable
as int?,timeRemaining: freezed == timeRemaining ? _self.timeRemaining : timeRemaining // ignore: cast_nullable_to_non_nullable
as int?,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,players: freezed == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<Player>?,currentPlayerIndex: null == currentPlayerIndex ? _self.currentPlayerIndex : currentPlayerIndex // ignore: cast_nullable_to_non_nullable
as int,extraTurnAwarded: null == extraTurnAwarded ? _self.extraTurnAwarded : extraTurnAwarded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GridSizeCopyWith<$Res> get gridSize {
  
  return $GridSizeCopyWith<$Res>(_self.gridSize, (value) {
    return _then(_self.copyWith(gridSize: value));
  });
}
}


/// Adds pattern-matching-related methods to [Game].
extension GamePatterns on Game {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Game value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Game() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Game value)  $default,){
final _that = this;
switch (_that) {
case _Game():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Game value)?  $default,){
final _that = this;
switch (_that) {
case _Game() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  GameMode mode,  int level,  GridSize gridSize,  List<GameCard> cards,  GameState state,  int score,  int moves,  int matches,  int combo,  int maxCombo,  int errors,  DateTime? startTime,  DateTime? endTime,  int? timeLimit,  int? timeRemaining,  String theme,  List<Player>? players,  int currentPlayerIndex,  bool extraTurnAwarded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that.id,_that.mode,_that.level,_that.gridSize,_that.cards,_that.state,_that.score,_that.moves,_that.matches,_that.combo,_that.maxCombo,_that.errors,_that.startTime,_that.endTime,_that.timeLimit,_that.timeRemaining,_that.theme,_that.players,_that.currentPlayerIndex,_that.extraTurnAwarded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  GameMode mode,  int level,  GridSize gridSize,  List<GameCard> cards,  GameState state,  int score,  int moves,  int matches,  int combo,  int maxCombo,  int errors,  DateTime? startTime,  DateTime? endTime,  int? timeLimit,  int? timeRemaining,  String theme,  List<Player>? players,  int currentPlayerIndex,  bool extraTurnAwarded)  $default,) {final _that = this;
switch (_that) {
case _Game():
return $default(_that.id,_that.mode,_that.level,_that.gridSize,_that.cards,_that.state,_that.score,_that.moves,_that.matches,_that.combo,_that.maxCombo,_that.errors,_that.startTime,_that.endTime,_that.timeLimit,_that.timeRemaining,_that.theme,_that.players,_that.currentPlayerIndex,_that.extraTurnAwarded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  GameMode mode,  int level,  GridSize gridSize,  List<GameCard> cards,  GameState state,  int score,  int moves,  int matches,  int combo,  int maxCombo,  int errors,  DateTime? startTime,  DateTime? endTime,  int? timeLimit,  int? timeRemaining,  String theme,  List<Player>? players,  int currentPlayerIndex,  bool extraTurnAwarded)?  $default,) {final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that.id,_that.mode,_that.level,_that.gridSize,_that.cards,_that.state,_that.score,_that.moves,_that.matches,_that.combo,_that.maxCombo,_that.errors,_that.startTime,_that.endTime,_that.timeLimit,_that.timeRemaining,_that.theme,_that.players,_that.currentPlayerIndex,_that.extraTurnAwarded);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Game extends Game {
  const _Game({required this.id, required this.mode, required this.level, required this.gridSize, required final  List<GameCard> cards, this.state = GameState.notStarted, this.score = 0, this.moves = 0, this.matches = 0, this.combo = 0, this.maxCombo = 0, this.errors = 0, this.startTime, this.endTime, this.timeLimit, this.timeRemaining, this.theme = 'animals', final  List<Player>? players, this.currentPlayerIndex = 0, this.extraTurnAwarded = false}): _cards = cards,_players = players,super._();
  factory _Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

/// Unique game identifier
@override final  String id;
/// Current game mode
@override final  GameMode mode;
/// Difficulty level (1-10)
@override final  int level;
/// Grid configuration
@override final  GridSize gridSize;
/// All cards in the game
 final  List<GameCard> _cards;
/// All cards in the game
@override List<GameCard> get cards {
  if (_cards is EqualUnmodifiableListView) return _cards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cards);
}

/// Current game state
@override@JsonKey() final  GameState state;
/// Current score
@override@JsonKey() final  int score;
/// Number of moves made
@override@JsonKey() final  int moves;
/// Number of pairs matched
@override@JsonKey() final  int matches;
/// Current combo count
@override@JsonKey() final  int combo;
/// Maximum combo achieved
@override@JsonKey() final  int maxCombo;
/// Number of errors made
@override@JsonKey() final  int errors;
/// Game start time
@override final  DateTime? startTime;
/// Game end time
@override final  DateTime? endTime;
/// Time limit in seconds (for timed mode)
@override final  int? timeLimit;
/// Remaining time in seconds
@override final  int? timeRemaining;
/// Theme used for this game
@override@JsonKey() final  String theme;
// ===== Multiplayer fields =====
/// List of players (for multiplayer mode)
 final  List<Player>? _players;
// ===== Multiplayer fields =====
/// List of players (for multiplayer mode)
@override List<Player>? get players {
  final value = _players;
  if (value == null) return null;
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Index of current player (0 to players.length-1)
@override@JsonKey() final  int currentPlayerIndex;
/// Whether the current player earned an extra turn (matched successfully)
@override@JsonKey() final  bool extraTurnAwarded;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameCopyWith<_Game> get copyWith => __$GameCopyWithImpl<_Game>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Game&&(identical(other.id, id) || other.id == id)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.level, level) || other.level == level)&&(identical(other.gridSize, gridSize) || other.gridSize == gridSize)&&const DeepCollectionEquality().equals(other._cards, _cards)&&(identical(other.state, state) || other.state == state)&&(identical(other.score, score) || other.score == score)&&(identical(other.moves, moves) || other.moves == moves)&&(identical(other.matches, matches) || other.matches == matches)&&(identical(other.combo, combo) || other.combo == combo)&&(identical(other.maxCombo, maxCombo) || other.maxCombo == maxCombo)&&(identical(other.errors, errors) || other.errors == errors)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.timeLimit, timeLimit) || other.timeLimit == timeLimit)&&(identical(other.timeRemaining, timeRemaining) || other.timeRemaining == timeRemaining)&&(identical(other.theme, theme) || other.theme == theme)&&const DeepCollectionEquality().equals(other._players, _players)&&(identical(other.currentPlayerIndex, currentPlayerIndex) || other.currentPlayerIndex == currentPlayerIndex)&&(identical(other.extraTurnAwarded, extraTurnAwarded) || other.extraTurnAwarded == extraTurnAwarded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,mode,level,gridSize,const DeepCollectionEquality().hash(_cards),state,score,moves,matches,combo,maxCombo,errors,startTime,endTime,timeLimit,timeRemaining,theme,const DeepCollectionEquality().hash(_players),currentPlayerIndex,extraTurnAwarded]);

@override
String toString() {
  return 'Game(id: $id, mode: $mode, level: $level, gridSize: $gridSize, cards: $cards, state: $state, score: $score, moves: $moves, matches: $matches, combo: $combo, maxCombo: $maxCombo, errors: $errors, startTime: $startTime, endTime: $endTime, timeLimit: $timeLimit, timeRemaining: $timeRemaining, theme: $theme, players: $players, currentPlayerIndex: $currentPlayerIndex, extraTurnAwarded: $extraTurnAwarded)';
}


}

/// @nodoc
abstract mixin class _$GameCopyWith<$Res> implements $GameCopyWith<$Res> {
  factory _$GameCopyWith(_Game value, $Res Function(_Game) _then) = __$GameCopyWithImpl;
@override @useResult
$Res call({
 String id, GameMode mode, int level, GridSize gridSize, List<GameCard> cards, GameState state, int score, int moves, int matches, int combo, int maxCombo, int errors, DateTime? startTime, DateTime? endTime, int? timeLimit, int? timeRemaining, String theme, List<Player>? players, int currentPlayerIndex, bool extraTurnAwarded
});


@override $GridSizeCopyWith<$Res> get gridSize;

}
/// @nodoc
class __$GameCopyWithImpl<$Res>
    implements _$GameCopyWith<$Res> {
  __$GameCopyWithImpl(this._self, this._then);

  final _Game _self;
  final $Res Function(_Game) _then;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? mode = null,Object? level = null,Object? gridSize = null,Object? cards = null,Object? state = null,Object? score = null,Object? moves = null,Object? matches = null,Object? combo = null,Object? maxCombo = null,Object? errors = null,Object? startTime = freezed,Object? endTime = freezed,Object? timeLimit = freezed,Object? timeRemaining = freezed,Object? theme = null,Object? players = freezed,Object? currentPlayerIndex = null,Object? extraTurnAwarded = null,}) {
  return _then(_Game(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,gridSize: null == gridSize ? _self.gridSize : gridSize // ignore: cast_nullable_to_non_nullable
as GridSize,cards: null == cards ? _self._cards : cards // ignore: cast_nullable_to_non_nullable
as List<GameCard>,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as GameState,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as int,matches: null == matches ? _self.matches : matches // ignore: cast_nullable_to_non_nullable
as int,combo: null == combo ? _self.combo : combo // ignore: cast_nullable_to_non_nullable
as int,maxCombo: null == maxCombo ? _self.maxCombo : maxCombo // ignore: cast_nullable_to_non_nullable
as int,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as int,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,timeLimit: freezed == timeLimit ? _self.timeLimit : timeLimit // ignore: cast_nullable_to_non_nullable
as int?,timeRemaining: freezed == timeRemaining ? _self.timeRemaining : timeRemaining // ignore: cast_nullable_to_non_nullable
as int?,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,players: freezed == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<Player>?,currentPlayerIndex: null == currentPlayerIndex ? _self.currentPlayerIndex : currentPlayerIndex // ignore: cast_nullable_to_non_nullable
as int,extraTurnAwarded: null == extraTurnAwarded ? _self.extraTurnAwarded : extraTurnAwarded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GridSizeCopyWith<$Res> get gridSize {
  
  return $GridSizeCopyWith<$Res>(_self.gridSize, (value) {
    return _then(_self.copyWith(gridSize: value));
  });
}
}

// dart format on
