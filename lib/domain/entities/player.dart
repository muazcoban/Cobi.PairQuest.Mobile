import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

/// Represents a player in multiplayer mode
@freezed
abstract class Player with _$Player {
  const Player._();

  const factory Player({
    /// Unique player identifier
    required String id,

    /// Player display name
    required String name,

    /// Player color index (0-3 for predefined colors)
    @Default(0) int colorIndex,

    /// Player's current score
    @Default(0) int score,

    /// Number of pairs matched by this player
    @Default(0) int matches,

    /// Number of moves made
    @Default(0) int moves,

    /// Current combo streak
    @Default(0) int combo,

    /// Maximum combo achieved
    @Default(0) int maxCombo,

    /// Number of errors (mismatches)
    @Default(0) int errors,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  /// Predefined player colors
  static const List<Color> colors = [
    Color(0xFF2196F3), // Blue
    Color(0xFFF44336), // Red
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
  ];

  /// Get player's color
  Color get color => colors[colorIndex % colors.length];

  /// Predefined player color names for display
  static const List<String> colorNames = [
    'Blue',
    'Red',
    'Green',
    'Orange',
  ];

  /// Get player's color name
  String get colorName => colorNames[colorIndex % colorNames.length];
}
