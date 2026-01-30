// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'online_game.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnlineGame {

/// Unique game identifier (Firestore document ID)
 String get id;/// Current game status
 OnlineGameStatus get status;/// Game mode (casual, ranked, friend)
 OnlineGameMode get mode;/// Difficulty level (1-20)
 int get level;/// Grid rows
 int get rows;/// Grid columns
 int get cols;/// Card theme
 String get theme;/// List of players (2 players for 1v1)
 List<OnlinePlayer> get players;/// Index of current player's turn
 int get currentPlayerIndex;/// Card pair IDs in order (encrypted positions)
/// Format: ["pairId1", "pairId1", "pairId2", "pairId2", ...]
 List<String> get cardPairIds;/// Set of matched pair IDs
 List<String> get matchedPairIds;/// List of moves made in the game
 List<GameMove> get moves;/// Winner's user ID (null if not completed or draw)
 String? get winnerId;/// Whether current player earned extra turn
 bool get extraTurnAwarded;/// Game creation time
@TimestampConverterNonNull() DateTime get createdAt;/// Game start time (when both players ready)
@TimestampConverter() DateTime? get startedAt;/// Game completion time
@TimestampConverter() DateTime? get completedAt;/// Last activity timestamp (for timeout detection)
@TimestampConverter() DateTime? get lastActivityAt;
/// Create a copy of OnlineGame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnlineGameCopyWith<OnlineGame> get copyWith => _$OnlineGameCopyWithImpl<OnlineGame>(this as OnlineGame, _$identity);

  /// Serializes this OnlineGame to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnlineGame&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.level, level) || other.level == level)&&(identical(other.rows, rows) || other.rows == rows)&&(identical(other.cols, cols) || other.cols == cols)&&(identical(other.theme, theme) || other.theme == theme)&&const DeepCollectionEquality().equals(other.players, players)&&(identical(other.currentPlayerIndex, currentPlayerIndex) || other.currentPlayerIndex == currentPlayerIndex)&&const DeepCollectionEquality().equals(other.cardPairIds, cardPairIds)&&const DeepCollectionEquality().equals(other.matchedPairIds, matchedPairIds)&&const DeepCollectionEquality().equals(other.moves, moves)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.extraTurnAwarded, extraTurnAwarded) || other.extraTurnAwarded == extraTurnAwarded)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,mode,level,rows,cols,theme,const DeepCollectionEquality().hash(players),currentPlayerIndex,const DeepCollectionEquality().hash(cardPairIds),const DeepCollectionEquality().hash(matchedPairIds),const DeepCollectionEquality().hash(moves),winnerId,extraTurnAwarded,createdAt,startedAt,completedAt,lastActivityAt);

@override
String toString() {
  return 'OnlineGame(id: $id, status: $status, mode: $mode, level: $level, rows: $rows, cols: $cols, theme: $theme, players: $players, currentPlayerIndex: $currentPlayerIndex, cardPairIds: $cardPairIds, matchedPairIds: $matchedPairIds, moves: $moves, winnerId: $winnerId, extraTurnAwarded: $extraTurnAwarded, createdAt: $createdAt, startedAt: $startedAt, completedAt: $completedAt, lastActivityAt: $lastActivityAt)';
}


}

/// @nodoc
abstract mixin class $OnlineGameCopyWith<$Res>  {
  factory $OnlineGameCopyWith(OnlineGame value, $Res Function(OnlineGame) _then) = _$OnlineGameCopyWithImpl;
@useResult
$Res call({
 String id, OnlineGameStatus status, OnlineGameMode mode, int level, int rows, int cols, String theme, List<OnlinePlayer> players, int currentPlayerIndex, List<String> cardPairIds, List<String> matchedPairIds, List<GameMove> moves, String? winnerId, bool extraTurnAwarded,@TimestampConverterNonNull() DateTime createdAt,@TimestampConverter() DateTime? startedAt,@TimestampConverter() DateTime? completedAt,@TimestampConverter() DateTime? lastActivityAt
});




}
/// @nodoc
class _$OnlineGameCopyWithImpl<$Res>
    implements $OnlineGameCopyWith<$Res> {
  _$OnlineGameCopyWithImpl(this._self, this._then);

  final OnlineGame _self;
  final $Res Function(OnlineGame) _then;

/// Create a copy of OnlineGame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? mode = null,Object? level = null,Object? rows = null,Object? cols = null,Object? theme = null,Object? players = null,Object? currentPlayerIndex = null,Object? cardPairIds = null,Object? matchedPairIds = null,Object? moves = null,Object? winnerId = freezed,Object? extraTurnAwarded = null,Object? createdAt = null,Object? startedAt = freezed,Object? completedAt = freezed,Object? lastActivityAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OnlineGameStatus,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as OnlineGameMode,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as int,cols: null == cols ? _self.cols : cols // ignore: cast_nullable_to_non_nullable
as int,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<OnlinePlayer>,currentPlayerIndex: null == currentPlayerIndex ? _self.currentPlayerIndex : currentPlayerIndex // ignore: cast_nullable_to_non_nullable
as int,cardPairIds: null == cardPairIds ? _self.cardPairIds : cardPairIds // ignore: cast_nullable_to_non_nullable
as List<String>,matchedPairIds: null == matchedPairIds ? _self.matchedPairIds : matchedPairIds // ignore: cast_nullable_to_non_nullable
as List<String>,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as List<GameMove>,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,extraTurnAwarded: null == extraTurnAwarded ? _self.extraTurnAwarded : extraTurnAwarded // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [OnlineGame].
extension OnlineGamePatterns on OnlineGame {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnlineGame value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnlineGame() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnlineGame value)  $default,){
final _that = this;
switch (_that) {
case _OnlineGame():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnlineGame value)?  $default,){
final _that = this;
switch (_that) {
case _OnlineGame() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  OnlineGameStatus status,  OnlineGameMode mode,  int level,  int rows,  int cols,  String theme,  List<OnlinePlayer> players,  int currentPlayerIndex,  List<String> cardPairIds,  List<String> matchedPairIds,  List<GameMove> moves,  String? winnerId,  bool extraTurnAwarded, @TimestampConverterNonNull()  DateTime createdAt, @TimestampConverter()  DateTime? startedAt, @TimestampConverter()  DateTime? completedAt, @TimestampConverter()  DateTime? lastActivityAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnlineGame() when $default != null:
return $default(_that.id,_that.status,_that.mode,_that.level,_that.rows,_that.cols,_that.theme,_that.players,_that.currentPlayerIndex,_that.cardPairIds,_that.matchedPairIds,_that.moves,_that.winnerId,_that.extraTurnAwarded,_that.createdAt,_that.startedAt,_that.completedAt,_that.lastActivityAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  OnlineGameStatus status,  OnlineGameMode mode,  int level,  int rows,  int cols,  String theme,  List<OnlinePlayer> players,  int currentPlayerIndex,  List<String> cardPairIds,  List<String> matchedPairIds,  List<GameMove> moves,  String? winnerId,  bool extraTurnAwarded, @TimestampConverterNonNull()  DateTime createdAt, @TimestampConverter()  DateTime? startedAt, @TimestampConverter()  DateTime? completedAt, @TimestampConverter()  DateTime? lastActivityAt)  $default,) {final _that = this;
switch (_that) {
case _OnlineGame():
return $default(_that.id,_that.status,_that.mode,_that.level,_that.rows,_that.cols,_that.theme,_that.players,_that.currentPlayerIndex,_that.cardPairIds,_that.matchedPairIds,_that.moves,_that.winnerId,_that.extraTurnAwarded,_that.createdAt,_that.startedAt,_that.completedAt,_that.lastActivityAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  OnlineGameStatus status,  OnlineGameMode mode,  int level,  int rows,  int cols,  String theme,  List<OnlinePlayer> players,  int currentPlayerIndex,  List<String> cardPairIds,  List<String> matchedPairIds,  List<GameMove> moves,  String? winnerId,  bool extraTurnAwarded, @TimestampConverterNonNull()  DateTime createdAt, @TimestampConverter()  DateTime? startedAt, @TimestampConverter()  DateTime? completedAt, @TimestampConverter()  DateTime? lastActivityAt)?  $default,) {final _that = this;
switch (_that) {
case _OnlineGame() when $default != null:
return $default(_that.id,_that.status,_that.mode,_that.level,_that.rows,_that.cols,_that.theme,_that.players,_that.currentPlayerIndex,_that.cardPairIds,_that.matchedPairIds,_that.moves,_that.winnerId,_that.extraTurnAwarded,_that.createdAt,_that.startedAt,_that.completedAt,_that.lastActivityAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnlineGame extends OnlineGame {
  const _OnlineGame({required this.id, this.status = OnlineGameStatus.waiting, this.mode = OnlineGameMode.casual, required this.level, required this.rows, required this.cols, this.theme = 'animals', final  List<OnlinePlayer> players = const [], this.currentPlayerIndex = 0, final  List<String> cardPairIds = const [], final  List<String> matchedPairIds = const [], final  List<GameMove> moves = const [], this.winnerId, this.extraTurnAwarded = false, @TimestampConverterNonNull() required this.createdAt, @TimestampConverter() this.startedAt, @TimestampConverter() this.completedAt, @TimestampConverter() this.lastActivityAt}): _players = players,_cardPairIds = cardPairIds,_matchedPairIds = matchedPairIds,_moves = moves,super._();
  factory _OnlineGame.fromJson(Map<String, dynamic> json) => _$OnlineGameFromJson(json);

/// Unique game identifier (Firestore document ID)
@override final  String id;
/// Current game status
@override@JsonKey() final  OnlineGameStatus status;
/// Game mode (casual, ranked, friend)
@override@JsonKey() final  OnlineGameMode mode;
/// Difficulty level (1-20)
@override final  int level;
/// Grid rows
@override final  int rows;
/// Grid columns
@override final  int cols;
/// Card theme
@override@JsonKey() final  String theme;
/// List of players (2 players for 1v1)
 final  List<OnlinePlayer> _players;
/// List of players (2 players for 1v1)
@override@JsonKey() List<OnlinePlayer> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}

/// Index of current player's turn
@override@JsonKey() final  int currentPlayerIndex;
/// Card pair IDs in order (encrypted positions)
/// Format: ["pairId1", "pairId1", "pairId2", "pairId2", ...]
 final  List<String> _cardPairIds;
/// Card pair IDs in order (encrypted positions)
/// Format: ["pairId1", "pairId1", "pairId2", "pairId2", ...]
@override@JsonKey() List<String> get cardPairIds {
  if (_cardPairIds is EqualUnmodifiableListView) return _cardPairIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cardPairIds);
}

/// Set of matched pair IDs
 final  List<String> _matchedPairIds;
/// Set of matched pair IDs
@override@JsonKey() List<String> get matchedPairIds {
  if (_matchedPairIds is EqualUnmodifiableListView) return _matchedPairIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_matchedPairIds);
}

/// List of moves made in the game
 final  List<GameMove> _moves;
/// List of moves made in the game
@override@JsonKey() List<GameMove> get moves {
  if (_moves is EqualUnmodifiableListView) return _moves;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_moves);
}

/// Winner's user ID (null if not completed or draw)
@override final  String? winnerId;
/// Whether current player earned extra turn
@override@JsonKey() final  bool extraTurnAwarded;
/// Game creation time
@override@TimestampConverterNonNull() final  DateTime createdAt;
/// Game start time (when both players ready)
@override@TimestampConverter() final  DateTime? startedAt;
/// Game completion time
@override@TimestampConverter() final  DateTime? completedAt;
/// Last activity timestamp (for timeout detection)
@override@TimestampConverter() final  DateTime? lastActivityAt;

/// Create a copy of OnlineGame
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnlineGameCopyWith<_OnlineGame> get copyWith => __$OnlineGameCopyWithImpl<_OnlineGame>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnlineGameToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnlineGame&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.level, level) || other.level == level)&&(identical(other.rows, rows) || other.rows == rows)&&(identical(other.cols, cols) || other.cols == cols)&&(identical(other.theme, theme) || other.theme == theme)&&const DeepCollectionEquality().equals(other._players, _players)&&(identical(other.currentPlayerIndex, currentPlayerIndex) || other.currentPlayerIndex == currentPlayerIndex)&&const DeepCollectionEquality().equals(other._cardPairIds, _cardPairIds)&&const DeepCollectionEquality().equals(other._matchedPairIds, _matchedPairIds)&&const DeepCollectionEquality().equals(other._moves, _moves)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.extraTurnAwarded, extraTurnAwarded) || other.extraTurnAwarded == extraTurnAwarded)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,mode,level,rows,cols,theme,const DeepCollectionEquality().hash(_players),currentPlayerIndex,const DeepCollectionEquality().hash(_cardPairIds),const DeepCollectionEquality().hash(_matchedPairIds),const DeepCollectionEquality().hash(_moves),winnerId,extraTurnAwarded,createdAt,startedAt,completedAt,lastActivityAt);

@override
String toString() {
  return 'OnlineGame(id: $id, status: $status, mode: $mode, level: $level, rows: $rows, cols: $cols, theme: $theme, players: $players, currentPlayerIndex: $currentPlayerIndex, cardPairIds: $cardPairIds, matchedPairIds: $matchedPairIds, moves: $moves, winnerId: $winnerId, extraTurnAwarded: $extraTurnAwarded, createdAt: $createdAt, startedAt: $startedAt, completedAt: $completedAt, lastActivityAt: $lastActivityAt)';
}


}

/// @nodoc
abstract mixin class _$OnlineGameCopyWith<$Res> implements $OnlineGameCopyWith<$Res> {
  factory _$OnlineGameCopyWith(_OnlineGame value, $Res Function(_OnlineGame) _then) = __$OnlineGameCopyWithImpl;
@override @useResult
$Res call({
 String id, OnlineGameStatus status, OnlineGameMode mode, int level, int rows, int cols, String theme, List<OnlinePlayer> players, int currentPlayerIndex, List<String> cardPairIds, List<String> matchedPairIds, List<GameMove> moves, String? winnerId, bool extraTurnAwarded,@TimestampConverterNonNull() DateTime createdAt,@TimestampConverter() DateTime? startedAt,@TimestampConverter() DateTime? completedAt,@TimestampConverter() DateTime? lastActivityAt
});




}
/// @nodoc
class __$OnlineGameCopyWithImpl<$Res>
    implements _$OnlineGameCopyWith<$Res> {
  __$OnlineGameCopyWithImpl(this._self, this._then);

  final _OnlineGame _self;
  final $Res Function(_OnlineGame) _then;

/// Create a copy of OnlineGame
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? mode = null,Object? level = null,Object? rows = null,Object? cols = null,Object? theme = null,Object? players = null,Object? currentPlayerIndex = null,Object? cardPairIds = null,Object? matchedPairIds = null,Object? moves = null,Object? winnerId = freezed,Object? extraTurnAwarded = null,Object? createdAt = null,Object? startedAt = freezed,Object? completedAt = freezed,Object? lastActivityAt = freezed,}) {
  return _then(_OnlineGame(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OnlineGameStatus,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as OnlineGameMode,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as int,cols: null == cols ? _self.cols : cols // ignore: cast_nullable_to_non_nullable
as int,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<OnlinePlayer>,currentPlayerIndex: null == currentPlayerIndex ? _self.currentPlayerIndex : currentPlayerIndex // ignore: cast_nullable_to_non_nullable
as int,cardPairIds: null == cardPairIds ? _self._cardPairIds : cardPairIds // ignore: cast_nullable_to_non_nullable
as List<String>,matchedPairIds: null == matchedPairIds ? _self._matchedPairIds : matchedPairIds // ignore: cast_nullable_to_non_nullable
as List<String>,moves: null == moves ? _self._moves : moves // ignore: cast_nullable_to_non_nullable
as List<GameMove>,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,extraTurnAwarded: null == extraTurnAwarded ? _self.extraTurnAwarded : extraTurnAwarded // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$GameMove {

/// Player who made the move
 String get oddserId;/// First card position
 int get card1Position;/// Second card position
 int get card2Position;/// Pair ID of the cards
 String get pairId;/// Whether the cards matched
 bool get matched;/// Score awarded for this move
 int get scoreAwarded;/// Move timestamp
@TimestampConverterNonNull() DateTime get timestamp;
/// Create a copy of GameMove
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameMoveCopyWith<GameMove> get copyWith => _$GameMoveCopyWithImpl<GameMove>(this as GameMove, _$identity);

  /// Serializes this GameMove to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameMove&&(identical(other.oddserId, oddserId) || other.oddserId == oddserId)&&(identical(other.card1Position, card1Position) || other.card1Position == card1Position)&&(identical(other.card2Position, card2Position) || other.card2Position == card2Position)&&(identical(other.pairId, pairId) || other.pairId == pairId)&&(identical(other.matched, matched) || other.matched == matched)&&(identical(other.scoreAwarded, scoreAwarded) || other.scoreAwarded == scoreAwarded)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,oddserId,card1Position,card2Position,pairId,matched,scoreAwarded,timestamp);

@override
String toString() {
  return 'GameMove(oddserId: $oddserId, card1Position: $card1Position, card2Position: $card2Position, pairId: $pairId, matched: $matched, scoreAwarded: $scoreAwarded, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $GameMoveCopyWith<$Res>  {
  factory $GameMoveCopyWith(GameMove value, $Res Function(GameMove) _then) = _$GameMoveCopyWithImpl;
@useResult
$Res call({
 String oddserId, int card1Position, int card2Position, String pairId, bool matched, int scoreAwarded,@TimestampConverterNonNull() DateTime timestamp
});




}
/// @nodoc
class _$GameMoveCopyWithImpl<$Res>
    implements $GameMoveCopyWith<$Res> {
  _$GameMoveCopyWithImpl(this._self, this._then);

  final GameMove _self;
  final $Res Function(GameMove) _then;

/// Create a copy of GameMove
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? oddserId = null,Object? card1Position = null,Object? card2Position = null,Object? pairId = null,Object? matched = null,Object? scoreAwarded = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
oddserId: null == oddserId ? _self.oddserId : oddserId // ignore: cast_nullable_to_non_nullable
as String,card1Position: null == card1Position ? _self.card1Position : card1Position // ignore: cast_nullable_to_non_nullable
as int,card2Position: null == card2Position ? _self.card2Position : card2Position // ignore: cast_nullable_to_non_nullable
as int,pairId: null == pairId ? _self.pairId : pairId // ignore: cast_nullable_to_non_nullable
as String,matched: null == matched ? _self.matched : matched // ignore: cast_nullable_to_non_nullable
as bool,scoreAwarded: null == scoreAwarded ? _self.scoreAwarded : scoreAwarded // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GameMove].
extension GameMovePatterns on GameMove {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameMove value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameMove() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameMove value)  $default,){
final _that = this;
switch (_that) {
case _GameMove():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameMove value)?  $default,){
final _that = this;
switch (_that) {
case _GameMove() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String oddserId,  int card1Position,  int card2Position,  String pairId,  bool matched,  int scoreAwarded, @TimestampConverterNonNull()  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameMove() when $default != null:
return $default(_that.oddserId,_that.card1Position,_that.card2Position,_that.pairId,_that.matched,_that.scoreAwarded,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String oddserId,  int card1Position,  int card2Position,  String pairId,  bool matched,  int scoreAwarded, @TimestampConverterNonNull()  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _GameMove():
return $default(_that.oddserId,_that.card1Position,_that.card2Position,_that.pairId,_that.matched,_that.scoreAwarded,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String oddserId,  int card1Position,  int card2Position,  String pairId,  bool matched,  int scoreAwarded, @TimestampConverterNonNull()  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _GameMove() when $default != null:
return $default(_that.oddserId,_that.card1Position,_that.card2Position,_that.pairId,_that.matched,_that.scoreAwarded,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameMove extends GameMove {
  const _GameMove({required this.oddserId, required this.card1Position, required this.card2Position, required this.pairId, required this.matched, this.scoreAwarded = 0, @TimestampConverterNonNull() required this.timestamp}): super._();
  factory _GameMove.fromJson(Map<String, dynamic> json) => _$GameMoveFromJson(json);

/// Player who made the move
@override final  String oddserId;
/// First card position
@override final  int card1Position;
/// Second card position
@override final  int card2Position;
/// Pair ID of the cards
@override final  String pairId;
/// Whether the cards matched
@override final  bool matched;
/// Score awarded for this move
@override@JsonKey() final  int scoreAwarded;
/// Move timestamp
@override@TimestampConverterNonNull() final  DateTime timestamp;

/// Create a copy of GameMove
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameMoveCopyWith<_GameMove> get copyWith => __$GameMoveCopyWithImpl<_GameMove>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameMoveToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameMove&&(identical(other.oddserId, oddserId) || other.oddserId == oddserId)&&(identical(other.card1Position, card1Position) || other.card1Position == card1Position)&&(identical(other.card2Position, card2Position) || other.card2Position == card2Position)&&(identical(other.pairId, pairId) || other.pairId == pairId)&&(identical(other.matched, matched) || other.matched == matched)&&(identical(other.scoreAwarded, scoreAwarded) || other.scoreAwarded == scoreAwarded)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,oddserId,card1Position,card2Position,pairId,matched,scoreAwarded,timestamp);

@override
String toString() {
  return 'GameMove(oddserId: $oddserId, card1Position: $card1Position, card2Position: $card2Position, pairId: $pairId, matched: $matched, scoreAwarded: $scoreAwarded, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$GameMoveCopyWith<$Res> implements $GameMoveCopyWith<$Res> {
  factory _$GameMoveCopyWith(_GameMove value, $Res Function(_GameMove) _then) = __$GameMoveCopyWithImpl;
@override @useResult
$Res call({
 String oddserId, int card1Position, int card2Position, String pairId, bool matched, int scoreAwarded,@TimestampConverterNonNull() DateTime timestamp
});




}
/// @nodoc
class __$GameMoveCopyWithImpl<$Res>
    implements _$GameMoveCopyWith<$Res> {
  __$GameMoveCopyWithImpl(this._self, this._then);

  final _GameMove _self;
  final $Res Function(_GameMove) _then;

/// Create a copy of GameMove
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? oddserId = null,Object? card1Position = null,Object? card2Position = null,Object? pairId = null,Object? matched = null,Object? scoreAwarded = null,Object? timestamp = null,}) {
  return _then(_GameMove(
oddserId: null == oddserId ? _self.oddserId : oddserId // ignore: cast_nullable_to_non_nullable
as String,card1Position: null == card1Position ? _self.card1Position : card1Position // ignore: cast_nullable_to_non_nullable
as int,card2Position: null == card2Position ? _self.card2Position : card2Position // ignore: cast_nullable_to_non_nullable
as int,pairId: null == pairId ? _self.pairId : pairId // ignore: cast_nullable_to_non_nullable
as String,matched: null == matched ? _self.matched : matched // ignore: cast_nullable_to_non_nullable
as bool,scoreAwarded: null == scoreAwarded ? _self.scoreAwarded : scoreAwarded // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
