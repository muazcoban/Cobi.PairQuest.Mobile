import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'online_player.dart';

part 'online_game.freezed.dart';
part 'online_game.g.dart';

/// Online game status
enum OnlineGameStatus {
  /// Waiting for players to join
  waiting,

  /// Game is in progress
  inProgress,

  /// Game completed successfully
  completed,

  /// Game was abandoned (player left)
  abandoned,

  /// Game was cancelled
  cancelled,
}

/// Online game mode
enum OnlineGameMode {
  /// Casual match - no rating change
  casual,

  /// Ranked match - affects rating
  ranked,

  /// Friend match - private game with friend
  friend,
}

/// Timestamp converter for Firestore
class TimestampConverter implements JsonConverter<DateTime?, Timestamp?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Timestamp? timestamp) => timestamp?.toDate();

  @override
  Timestamp? toJson(DateTime? date) =>
      date != null ? Timestamp.fromDate(date) : null;
}

/// Non-nullable timestamp converter
class TimestampConverterNonNull implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverterNonNull();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

/// Represents an online multiplayer game session
@freezed
abstract class OnlineGame with _$OnlineGame {
  const OnlineGame._();

  const factory OnlineGame({
    /// Unique game identifier (Firestore document ID)
    required String id,

    /// Current game status
    @Default(OnlineGameStatus.waiting) OnlineGameStatus status,

    /// Game mode (casual, ranked, friend)
    @Default(OnlineGameMode.casual) OnlineGameMode mode,

    /// Difficulty level (1-20)
    required int level,

    /// Grid rows
    required int rows,

    /// Grid columns
    required int cols,

    /// Card theme
    @Default('animals') String theme,

    /// List of players (2 players for 1v1)
    @Default([]) List<OnlinePlayer> players,

    /// Index of current player's turn
    @Default(0) int currentPlayerIndex,

    /// Card pair IDs in order (encrypted positions)
    /// Format: ["pairId1", "pairId1", "pairId2", "pairId2", ...]
    @Default([]) List<String> cardPairIds,

    /// Set of matched pair IDs
    @Default([]) List<String> matchedPairIds,

    /// List of moves made in the game
    @Default([]) List<GameMove> moves,

    /// Winner's user ID (null if not completed or draw)
    String? winnerId,

    /// Whether current player earned extra turn
    @Default(false) bool extraTurnAwarded,

    /// Game creation time
    @TimestampConverterNonNull() required DateTime createdAt,

    /// Game start time (when both players ready)
    @TimestampConverter() DateTime? startedAt,

    /// Game completion time
    @TimestampConverter() DateTime? completedAt,

    /// Last activity timestamp (for timeout detection)
    @TimestampConverter() DateTime? lastActivityAt,
  }) = _OnlineGame;

  factory OnlineGame.fromJson(Map<String, dynamic> json) =>
      _$OnlineGameFromJson(json);

  /// Create from Firestore document
  factory OnlineGame.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OnlineGame.fromJson({...data, 'id': doc.id});
  }

  /// Total cards in the grid
  int get totalCards => rows * cols;

  /// Total pairs to match
  int get totalPairs => totalCards ~/ 2;

  /// Check if game is full (2 players)
  bool get isFull => players.length >= 2;

  /// Check if game can start
  bool get canStart =>
      isFull && status == OnlineGameStatus.waiting;

  /// Check if it's a specific player's turn
  bool isPlayerTurn(String oddserId) =>
      status == OnlineGameStatus.inProgress &&
      currentPlayerIndex < players.length &&
      players[currentPlayerIndex].oddserId == oddserId;

  /// Get current player
  OnlinePlayer? get currentPlayer =>
      currentPlayerIndex < players.length ? players[currentPlayerIndex] : null;

  /// Check if all pairs are matched
  bool get isCompleted => matchedPairIds.length >= totalPairs;

  /// Remaining pairs to match
  int get remainingPairs => totalPairs - matchedPairIds.length;

  /// Get winner player
  OnlinePlayer? get winner {
    if (winnerId == null) return null;
    return players.firstWhere(
      (p) => p.oddserId == winnerId,
      orElse: () => players.first,
    );
  }

  /// Get players sorted by score (descending)
  List<OnlinePlayer> get rankedPlayers {
    final sorted = List<OnlinePlayer>.from(players);
    sorted.sort((a, b) => b.score.compareTo(a.score));
    return sorted;
  }

  /// Check if game is timed out (no activity for 2 minutes)
  bool get isTimedOut {
    if (lastActivityAt == null) return false;
    return DateTime.now().difference(lastActivityAt!).inMinutes >= 2;
  }

  /// Convert to Firestore map (without id)
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // ID is the document ID, not a field
    // Players listesini manuel olarak serialize et
    json['players'] = players.map((p) => p.toJson()).toList();
    // Moves listesini manuel olarak serialize et
    json['moves'] = moves.map((m) => m.toJson()).toList();
    return json;
  }
}

/// Represents a single move in the game
@freezed
abstract class GameMove with _$GameMove {
  const GameMove._();

  const factory GameMove({
    /// Player who made the move
    required String oddserId,

    /// First card position
    required int card1Position,

    /// Second card position
    required int card2Position,

    /// Pair ID of the cards
    required String pairId,

    /// Whether the cards matched
    required bool matched,

    /// Score awarded for this move
    @Default(0) int scoreAwarded,

    /// Move timestamp
    @TimestampConverterNonNull() required DateTime timestamp,
  }) = _GameMove;

  factory GameMove.fromJson(Map<String, dynamic> json) =>
      _$GameMoveFromJson(json);
}
