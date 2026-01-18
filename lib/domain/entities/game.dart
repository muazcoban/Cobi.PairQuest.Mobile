import 'package:freezed_annotation/freezed_annotation.dart';
import 'card.dart';
import 'player.dart';

part 'game.freezed.dart';
part 'game.g.dart';

/// Game mode enum
enum GameMode {
  /// Classic mode - no time limit
  classic,

  /// Timed mode - complete before time runs out
  timed,

  /// Multiplayer mode - turn-based local multiplayer
  multiplayer,
}

/// Game state enum
enum GameState {
  /// Game hasn't started yet
  notStarted,

  /// Cards are being previewed (shown face up briefly)
  preview,

  /// Game is in progress
  inProgress,

  /// Game is paused
  paused,

  /// Game completed successfully
  completed,

  /// Game failed (time ran out)
  failed,
}

/// Grid size configuration
@freezed
abstract class GridSize with _$GridSize {
  const GridSize._();

  const factory GridSize({
    required int rows,
    required int cols,
  }) = _GridSize;

  factory GridSize.fromJson(Map<String, dynamic> json) =>
      _$GridSizeFromJson(json);

  /// Total number of cards in the grid
  int get totalCards => rows * cols;

  /// Number of pairs to match
  int get pairs => totalCards ~/ 2;
}

/// Represents a game session
@freezed
abstract class Game with _$Game {
  const Game._();

  const factory Game({
    /// Unique game identifier
    required String id,

    /// Current game mode
    required GameMode mode,

    /// Difficulty level (1-10)
    required int level,

    /// Grid configuration
    required GridSize gridSize,

    /// All cards in the game
    required List<GameCard> cards,

    /// Current game state
    @Default(GameState.notStarted) GameState state,

    /// Current score
    @Default(0) int score,

    /// Number of moves made
    @Default(0) int moves,

    /// Number of pairs matched
    @Default(0) int matches,

    /// Current combo count
    @Default(0) int combo,

    /// Maximum combo achieved
    @Default(0) int maxCombo,

    /// Number of errors made
    @Default(0) int errors,

    /// Game start time
    DateTime? startTime,

    /// Game end time
    DateTime? endTime,

    /// Time limit in seconds (for timed mode)
    int? timeLimit,

    /// Remaining time in seconds
    int? timeRemaining,

    /// Theme used for this game
    @Default('animals') String theme,

    // ===== Multiplayer fields =====

    /// List of players (for multiplayer mode)
    List<Player>? players,

    /// Index of current player (0 to players.length-1)
    @Default(0) int currentPlayerIndex,

    /// Whether the current player earned an extra turn (matched successfully)
    @Default(false) bool extraTurnAwarded,
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  /// Check if this is a multiplayer game
  bool get isMultiplayer => mode == GameMode.multiplayer && players != null;

  /// Get number of players
  int get playerCount => players?.length ?? 1;

  /// Get current player (for multiplayer)
  Player? get currentPlayer =>
      isMultiplayer ? players![currentPlayerIndex] : null;

  /// Check if all pairs are matched
  bool get isCompleted => matches == gridSize.pairs;

  /// Get remaining pairs to match
  int get remainingPairs => gridSize.pairs - matches;

  /// Calculate game duration in seconds
  int get duration {
    if (startTime == null) return 0;
    final end = endTime ?? DateTime.now();
    return end.difference(startTime!).inSeconds;
  }

  /// Check if game is currently playable
  bool get isPlayable => state == GameState.inProgress;

  /// Check if game is in preview mode
  bool get isPreview => state == GameState.preview;

  /// Check if this was a perfect game (no errors)
  bool get isPerfectGame => errors == 0 && isCompleted;

  /// Get winner player (for multiplayer) - player with highest score
  Player? get winner {
    if (!isMultiplayer || players == null || players!.isEmpty) return null;
    return players!.reduce((a, b) => a.score >= b.score ? a : b);
  }

  /// Get players sorted by score (descending)
  List<Player> get rankedPlayers {
    if (!isMultiplayer || players == null) return [];
    final sorted = List<Player>.from(players!);
    sorted.sort((a, b) => b.score.compareTo(a.score));
    return sorted;
  }

  /// Total matches found by all players in multiplayer
  int get totalMultiplayerMatches {
    if (!isMultiplayer || players == null) return matches;
    return players!.fold(0, (sum, p) => sum + p.matches);
  }
}
