import 'package:equatable/equatable.dart';

/// Player statistics model for tracking game progress
class PlayerStats extends Equatable {
  final int totalGamesPlayed;
  final int totalGamesWon;
  final int totalGamesLost;
  final int totalMatchesMade;
  final int totalMovesMade;
  final int totalPlayTimeSeconds;
  final int highestCombo;
  final int perfectGames;
  final int currentStreak;
  final int longestStreak;
  final Map<int, LevelStats> levelStats;
  final DateTime? lastPlayedAt;
  final DateTime firstPlayedAt;
  final int totalStarsEarned;

  const PlayerStats({
    this.totalGamesPlayed = 0,
    this.totalGamesWon = 0,
    this.totalGamesLost = 0,
    this.totalMatchesMade = 0,
    this.totalMovesMade = 0,
    this.totalPlayTimeSeconds = 0,
    this.highestCombo = 0,
    this.perfectGames = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.levelStats = const {},
    this.lastPlayedAt,
    required this.firstPlayedAt,
    this.totalStarsEarned = 0,
  });

  /// Win rate as percentage
  double get winRate =>
      totalGamesPlayed > 0 ? (totalGamesWon / totalGamesPlayed) * 100 : 0;

  /// Average moves per game
  double get avgMovesPerGame =>
      totalGamesWon > 0 ? totalMovesMade / totalGamesWon : 0;

  /// Total play time formatted as hours and minutes
  String get formattedPlayTime {
    final hours = totalPlayTimeSeconds ~/ 3600;
    final minutes = (totalPlayTimeSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Highest level completed
  int get highestLevelCompleted {
    int highest = 0;
    for (final entry in levelStats.entries) {
      if (entry.value.completed && entry.key > highest) {
        highest = entry.key;
      }
    }
    return highest;
  }

  /// Total levels with 3 stars
  int get levelsWithThreeStars {
    return levelStats.values.where((stats) => stats.bestStars == 3).length;
  }

  PlayerStats copyWith({
    int? totalGamesPlayed,
    int? totalGamesWon,
    int? totalGamesLost,
    int? totalMatchesMade,
    int? totalMovesMade,
    int? totalPlayTimeSeconds,
    int? highestCombo,
    int? perfectGames,
    int? currentStreak,
    int? longestStreak,
    Map<int, LevelStats>? levelStats,
    DateTime? lastPlayedAt,
    DateTime? firstPlayedAt,
    int? totalStarsEarned,
  }) {
    return PlayerStats(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalGamesWon: totalGamesWon ?? this.totalGamesWon,
      totalGamesLost: totalGamesLost ?? this.totalGamesLost,
      totalMatchesMade: totalMatchesMade ?? this.totalMatchesMade,
      totalMovesMade: totalMovesMade ?? this.totalMovesMade,
      totalPlayTimeSeconds: totalPlayTimeSeconds ?? this.totalPlayTimeSeconds,
      highestCombo: highestCombo ?? this.highestCombo,
      perfectGames: perfectGames ?? this.perfectGames,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      levelStats: levelStats ?? this.levelStats,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      firstPlayedAt: firstPlayedAt ?? this.firstPlayedAt,
      totalStarsEarned: totalStarsEarned ?? this.totalStarsEarned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalGamesWon': totalGamesWon,
      'totalGamesLost': totalGamesLost,
      'totalMatchesMade': totalMatchesMade,
      'totalMovesMade': totalMovesMade,
      'totalPlayTimeSeconds': totalPlayTimeSeconds,
      'highestCombo': highestCombo,
      'perfectGames': perfectGames,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'levelStats': levelStats.map(
        (key, value) => MapEntry(key.toString(), value.toJson()),
      ),
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
      'firstPlayedAt': firstPlayedAt.toIso8601String(),
      'totalStarsEarned': totalStarsEarned,
    };
  }

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    final levelStatsMap = <int, LevelStats>{};
    if (json['levelStats'] != null) {
      (json['levelStats'] as Map<String, dynamic>).forEach((key, value) {
        levelStatsMap[int.parse(key)] = LevelStats.fromJson(value);
      });
    }

    return PlayerStats(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalGamesWon: json['totalGamesWon'] ?? 0,
      totalGamesLost: json['totalGamesLost'] ?? 0,
      totalMatchesMade: json['totalMatchesMade'] ?? 0,
      totalMovesMade: json['totalMovesMade'] ?? 0,
      totalPlayTimeSeconds: json['totalPlayTimeSeconds'] ?? 0,
      highestCombo: json['highestCombo'] ?? 0,
      perfectGames: json['perfectGames'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      levelStats: levelStatsMap,
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.parse(json['lastPlayedAt'])
          : null,
      firstPlayedAt: json['firstPlayedAt'] != null
          ? DateTime.parse(json['firstPlayedAt'])
          : DateTime.now(),
      totalStarsEarned: json['totalStarsEarned'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        totalGamesPlayed,
        totalGamesWon,
        totalGamesLost,
        totalMatchesMade,
        totalMovesMade,
        totalPlayTimeSeconds,
        highestCombo,
        perfectGames,
        currentStreak,
        longestStreak,
        levelStats,
        lastPlayedAt,
        firstPlayedAt,
        totalStarsEarned,
      ];
}

/// Statistics for a specific level
class LevelStats extends Equatable {
  final int level;
  final bool completed;
  final int timesPlayed;
  final int timesWon;
  final int bestScore;
  final int bestMoves;
  final int bestTimeSeconds;
  final int bestStars;
  final int bestCombo;

  const LevelStats({
    required this.level,
    this.completed = false,
    this.timesPlayed = 0,
    this.timesWon = 0,
    this.bestScore = 0,
    this.bestMoves = 0,
    this.bestTimeSeconds = 0,
    this.bestStars = 0,
    this.bestCombo = 0,
  });

  LevelStats copyWith({
    int? level,
    bool? completed,
    int? timesPlayed,
    int? timesWon,
    int? bestScore,
    int? bestMoves,
    int? bestTimeSeconds,
    int? bestStars,
    int? bestCombo,
  }) {
    return LevelStats(
      level: level ?? this.level,
      completed: completed ?? this.completed,
      timesPlayed: timesPlayed ?? this.timesPlayed,
      timesWon: timesWon ?? this.timesWon,
      bestScore: bestScore ?? this.bestScore,
      bestMoves: bestMoves ?? this.bestMoves,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
      bestStars: bestStars ?? this.bestStars,
      bestCombo: bestCombo ?? this.bestCombo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'completed': completed,
      'timesPlayed': timesPlayed,
      'timesWon': timesWon,
      'bestScore': bestScore,
      'bestMoves': bestMoves,
      'bestTimeSeconds': bestTimeSeconds,
      'bestStars': bestStars,
      'bestCombo': bestCombo,
    };
  }

  factory LevelStats.fromJson(Map<String, dynamic> json) {
    return LevelStats(
      level: json['level'] ?? 1,
      completed: json['completed'] ?? false,
      timesPlayed: json['timesPlayed'] ?? 0,
      timesWon: json['timesWon'] ?? 0,
      bestScore: json['bestScore'] ?? 0,
      bestMoves: json['bestMoves'] ?? 0,
      bestTimeSeconds: json['bestTimeSeconds'] ?? 0,
      bestStars: json['bestStars'] ?? 0,
      bestCombo: json['bestCombo'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        level,
        completed,
        timesPlayed,
        timesWon,
        bestScore,
        bestMoves,
        bestTimeSeconds,
        bestStars,
        bestCombo,
      ];
}
