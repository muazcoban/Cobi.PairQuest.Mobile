import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'online_player.freezed.dart';
part 'online_player.g.dart';

/// Player connection status
enum ConnectionStatus {
  /// Player is online and active
  online,

  /// Player is offline
  offline,

  /// Player is idle (no recent activity)
  idle,

  /// Player has disconnected during game
  disconnected,
}

/// Timestamp converter for Firestore
class _TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const _TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

/// Represents a player in online multiplayer
@freezed
abstract class OnlinePlayer with _$OnlinePlayer {
  const OnlinePlayer._();

  const factory OnlinePlayer({
    /// Firebase user ID
    required String oddserId,

    /// Display name
    required String displayName,

    /// Profile photo URL (nullable)
    String? photoUrl,

    /// Player's ELO rating
    @Default(1200) int rating,

    /// Player color index (0-3)
    @Default(0) int colorIndex,

    /// Current score in this game
    @Default(0) int score,

    /// Number of pairs matched
    @Default(0) int matches,

    /// Current combo streak
    @Default(0) int combo,

    /// Maximum combo achieved
    @Default(0) int maxCombo,

    /// Number of errors (mismatches)
    @Default(0) int errors,

    /// Connection status
    @Default(ConnectionStatus.online) ConnectionStatus connectionStatus,

    /// Last activity timestamp
    @_TimestampConverter() required DateTime lastActivityAt,

    /// Whether player is ready to start
    @Default(false) bool isReady,
  }) = _OnlinePlayer;

  factory OnlinePlayer.fromJson(Map<String, dynamic> json) =>
      _$OnlinePlayerFromJson(json);

  /// Predefined player colors
  static const List<Color> colors = [
    Color(0xFF2196F3), // Blue
    Color(0xFFF44336), // Red
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
  ];

  /// Get player's color
  Color get color => colors[colorIndex % colors.length];

  /// Color names for display
  static const List<String> colorNames = ['Blue', 'Red', 'Green', 'Orange'];

  /// Get player's color name
  String get colorName => colorNames[colorIndex % colorNames.length];

  /// Check if player is connected
  bool get isConnected =>
      connectionStatus == ConnectionStatus.online ||
      connectionStatus == ConnectionStatus.idle;

  /// Get rating tier name
  String get tierName {
    if (rating < 1000) return 'Bronze';
    if (rating < 1500) return 'Silver';
    if (rating < 2000) return 'Gold';
    if (rating < 2500) return 'Platinum';
    if (rating < 3000) return 'Diamond';
    return 'Master';
  }

  /// Get tier color
  Color get tierColor {
    if (rating < 1000) return const Color(0xFFCD7F32); // Bronze
    if (rating < 1500) return const Color(0xFFC0C0C0); // Silver
    if (rating < 2000) return const Color(0xFFFFD700); // Gold
    if (rating < 2500) return const Color(0xFFE5E4E2); // Platinum
    if (rating < 3000) return const Color(0xFFB9F2FF); // Diamond
    return const Color(0xFF9966CC); // Master
  }

  /// Create a copy with updated score and stats
  OnlinePlayer addScore(int points, {bool matched = true}) {
    if (matched) {
      return copyWith(
        score: score + points,
        matches: matches + 1,
        combo: combo + 1,
        maxCombo: combo + 1 > maxCombo ? combo + 1 : maxCombo,
      );
    } else {
      return copyWith(
        errors: errors + 1,
        combo: 0,
      );
    }
  }
}

/// User profile for online features
@freezed
abstract class OnlineUserProfile with _$OnlineUserProfile {
  const OnlineUserProfile._();

  const factory OnlineUserProfile({
    /// Firebase user ID
    required String oddserId,

    /// Display name
    required String displayName,

    /// Profile photo URL
    String? photoUrl,

    /// Email (optional)
    String? email,

    /// ELO rating (only changes in ranked games)
    @Default(1200) int rating,

    // ========== RANKED STATS ==========
    /// Ranked wins
    @Default(0) int rankedWins,

    /// Ranked losses
    @Default(0) int rankedLosses,

    /// Ranked games played
    @Default(0) int rankedGames,

    // ========== CASUAL STATS ==========
    /// Casual wins
    @Default(0) int casualWins,

    /// Casual losses
    @Default(0) int casualLosses,

    /// Casual games played
    @Default(0) int casualGames,

    // ========== LEGACY FIELDS (backward compatibility) ==========
    /// Total wins (ranked + casual) - kept for backward compatibility
    @Default(0) int wins,

    /// Total losses (ranked + casual) - kept for backward compatibility
    @Default(0) int losses,

    /// Total draws
    @Default(0) int draws,

    /// Total online games played - kept for backward compatibility
    @Default(0) int totalGames,

    /// Current online status
    @Default(ConnectionStatus.offline) ConnectionStatus status,

    /// Account creation date
    @_TimestampConverter() required DateTime createdAt,

    /// Last seen timestamp
    @_TimestampConverter() required DateTime lastSeenAt,

    /// Current game ID (if in a game)
    String? currentGameId,
  }) = _OnlineUserProfile;

  factory OnlineUserProfile.fromJson(Map<String, dynamic> json) =>
      _$OnlineUserProfileFromJson(json);

  /// Create from Firestore document
  factory OnlineUserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OnlineUserProfile.fromJson({...data, 'oddserId': doc.id});
  }

  // ========== COMPUTED GETTERS ==========

  /// Overall win rate percentage (all games)
  double get winRate {
    final total = totalGames > 0 ? totalGames : (rankedGames + casualGames);
    if (total == 0) return 0;
    final totalWins = wins > 0 ? wins : (rankedWins + casualWins);
    return (totalWins / total) * 100;
  }

  /// Ranked win rate percentage
  double get rankedWinRate {
    if (rankedGames == 0) return 0;
    return (rankedWins / rankedGames) * 100;
  }

  /// Casual win rate percentage
  double get casualWinRate {
    if (casualGames == 0) return 0;
    return (casualWins / casualGames) * 100;
  }

  /// Total wins (computed from ranked + casual if legacy field is 0)
  int get totalWins => wins > 0 ? wins : (rankedWins + casualWins);

  /// Total losses (computed from ranked + casual if legacy field is 0)
  int get totalLosses => losses > 0 ? losses : (rankedLosses + casualLosses);

  /// Total games played (computed)
  int get totalGamesPlayed => totalGames > 0 ? totalGames : (rankedGames + casualGames);

  /// Get tier name based on rating
  String get tierName {
    if (rating < 1000) return 'Bronze';
    if (rating < 1500) return 'Silver';
    if (rating < 2000) return 'Gold';
    if (rating < 2500) return 'Platinum';
    if (rating < 3000) return 'Diamond';
    return 'Master';
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('oddserId'); // ID is the document ID
    return json;
  }
}
