import 'package:equatable/equatable.dart';

/// A single entry in the local leaderboard
class LeaderboardEntry extends Equatable {
  final String id;
  final String playerName;
  final int level;
  final int score;
  final int stars;
  final int moves;
  final int timeSeconds;
  final DateTime playedAt;

  const LeaderboardEntry({
    required this.id,
    required this.playerName,
    required this.level,
    required this.score,
    required this.stars,
    required this.moves,
    required this.timeSeconds,
    required this.playedAt,
  });

  LeaderboardEntry copyWith({
    String? id,
    String? playerName,
    int? level,
    int? score,
    int? stars,
    int? moves,
    int? timeSeconds,
    DateTime? playedAt,
  }) {
    return LeaderboardEntry(
      id: id ?? this.id,
      playerName: playerName ?? this.playerName,
      level: level ?? this.level,
      score: score ?? this.score,
      stars: stars ?? this.stars,
      moves: moves ?? this.moves,
      timeSeconds: timeSeconds ?? this.timeSeconds,
      playedAt: playedAt ?? this.playedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerName': playerName,
      'level': level,
      'score': score,
      'stars': stars,
      'moves': moves,
      'timeSeconds': timeSeconds,
      'playedAt': playedAt.toIso8601String(),
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] ?? '',
      playerName: json['playerName'] ?? 'Player',
      level: json['level'] ?? 1,
      score: json['score'] ?? 0,
      stars: json['stars'] ?? 0,
      moves: json['moves'] ?? 0,
      timeSeconds: json['timeSeconds'] ?? 0,
      playedAt: json['playedAt'] != null
          ? DateTime.parse(json['playedAt'])
          : DateTime.now(),
    );
  }

  /// Format time as MM:SS
  String get formattedTime {
    final minutes = timeSeconds ~/ 60;
    final seconds = timeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        id,
        playerName,
        level,
        score,
        stars,
        moves,
        timeSeconds,
        playedAt,
      ];
}
