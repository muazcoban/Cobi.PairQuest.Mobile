import 'package:freezed_annotation/freezed_annotation.dart';
import 'card.dart';

part 'game.freezed.dart';
part 'game.g.dart';

/// Game mode enum
enum GameMode {
  /// Classic mode - no time limit
  classic,

  /// Timed mode - complete before time runs out
  timed,
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
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

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
}
