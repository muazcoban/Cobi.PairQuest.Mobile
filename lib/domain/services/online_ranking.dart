import 'dart:math' as math;

import '../entities/online_player.dart';

/// Rules for the online rating (Elo) and the global ranking.
///
/// Every profile starts at [startRating], and the rating moves only in
/// ranked games. A profile that never played a ranked game therefore says
/// nothing about skill and stays off the ranking.
abstract final class OnlineRanking {
  static const int startRating = 1200;
  static const int minRating = 100;
  static const int maxRating = 9999;

  /// Elo K-factor: the most a single game can move a rating.
  static const int kFactor = 32;

  /// Whether a stored profile belongs on the ranking. Old app versions
  /// counted ranked games only in the totals, so a rating that moved away
  /// from [startRating] also counts as ranked play.
  static bool hasPlayedRanked(Map<String, dynamic> data) {
    if (data['isRanked'] == true) return true;
    final rankedGames = data['rankedGames'];
    if (rankedGames is num && rankedGames > 0) return true;
    final rating = data['rating'];
    return rating is num && rating.round() != startRating;
  }

  /// Expected score of a player rated [rating] against [opponentRating].
  static double expectedScore(int rating, int opponentRating) =>
      1 / (1 + math.pow(10, (opponentRating - rating) / 400));

  /// Rating change for one game. [score] is 1 for a win, 0.5 for a draw and
  /// 0 for a loss.
  static int ratingDelta({
    required int rating,
    required int opponentRating,
    required double score,
  }) =>
      (kFactor * (score - expectedScore(rating, opponentRating))).round();

  /// [rating] plus [delta], kept inside the allowed range.
  static int applyDelta(int rating, int delta) =>
      (rating + delta).clamp(minRating, maxRating);

  /// Sorts profiles for the ranking and numbers them. Equal ratings share a
  /// rank (1, 2, 2, 4), which matches "players above me + 1"; more ranked
  /// wins, then the name, decide the order inside a tie.
  static List<RankedProfile> rank(Iterable<OnlineUserProfile> profiles) {
    final sorted = profiles.toList()
      ..sort((a, b) {
        final byRating = b.rating.compareTo(a.rating);
        if (byRating != 0) return byRating;
        final byWins = b.rankedWins.compareTo(a.rankedWins);
        if (byWins != 0) return byWins;
        return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
      });
    final ranked = <RankedProfile>[];
    for (var i = 0; i < sorted.length; i++) {
      final sameAsPrevious = i > 0 && sorted[i].rating == sorted[i - 1].rating;
      ranked.add(RankedProfile(
        rank: sameAsPrevious ? ranked[i - 1].rank : i + 1,
        profile: sorted[i],
      ));
    }
    return ranked;
  }

  /// Fills the ranked counters of a profile that an old app version wrote:
  /// it counted ranked games only in the totals. Returns the fields to
  /// write, or an empty map when nothing is missing.
  static Map<String, dynamic> legacyRankedRepair(Map<String, dynamic> data) {
    int read(String key) => (data[key] as num?)?.toInt() ?? 0;
    final updates = <String, dynamic>{};
    if (!data.containsKey('rankedGames')) {
      final games = read('totalGames') - read('casualGames');
      final wins = read('wins') - read('casualWins');
      final losses = read('losses') - read('casualLosses');
      if (games > 0 && wins >= 0 && losses >= 0 && wins + losses <= games) {
        updates['rankedGames'] = games;
        updates['rankedWins'] = wins;
        updates['rankedLosses'] = losses;
      } else {
        updates['rankedGames'] = 0;
        updates['rankedWins'] = 0;
        updates['rankedLosses'] = 0;
      }
    }
    final merged = {...data, ...updates};
    if (data['isRanked'] != true && hasPlayedRanked(merged)) {
      updates['isRanked'] = true;
    }
    return updates;
  }
}

/// A profile with its place on the ranking.
class RankedProfile {
  final int rank;
  final OnlineUserProfile profile;

  const RankedProfile({required this.rank, required this.profile});
}
