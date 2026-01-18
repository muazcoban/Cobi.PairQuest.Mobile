import 'package:freezed_annotation/freezed_annotation.dart';

part 'card.freezed.dart';
part 'card.g.dart';

/// Card state enum
enum CardState {
  /// Card is face down (hidden)
  hidden,

  /// Card is face up (revealed temporarily)
  revealed,

  /// Card has been matched
  matched,
}

/// Represents a single memory card in the game
@freezed
abstract class GameCard with _$GameCard {
  const factory GameCard({
    /// Unique identifier for this card
    required String id,

    /// Shared identifier for matching pairs
    required String pairId,

    /// Image asset path or identifier
    required String imageAsset,

    /// Position index in the grid (0-indexed)
    required int position,

    /// Current state of the card
    @Default(CardState.hidden) CardState state,

    /// Theme this card belongs to
    @Default('animals') String theme,
  }) = _GameCard;

  factory GameCard.fromJson(Map<String, dynamic> json) =>
      _$GameCardFromJson(json);
}
