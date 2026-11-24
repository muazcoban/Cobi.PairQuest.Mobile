import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/domain/entities/online_player.dart';
import 'package:pair_quest/domain/services/online_ranking.dart';

OnlineUserProfile profile(String name, int rating, {int rankedWins = 0}) =>
    OnlineUserProfile(
      oddserId: name,
      displayName: name,
      rating: rating,
      rankedWins: rankedWins,
      createdAt: DateTime(2026, 11, 1),
      lastSeenAt: DateTime(2026, 11, 1),
    );

void main() {
  group('hasPlayedRanked', () {
    test('a new profile at the start rating with no ranked games is not ranked', () {
      expect(
        OnlineRanking.hasPlayedRanked({'rating': 1200, 'rankedGames': 0}),
        isFalse,
      );
      expect(OnlineRanking.hasPlayedRanked({'rating': 1200}), isFalse);
    });

    test('a ranked game, the flag or a moved rating counts', () {
      expect(OnlineRanking.hasPlayedRanked({'rating': 1200, 'rankedGames': 2}), isTrue);
      expect(OnlineRanking.hasPlayedRanked({'isRanked': true}), isTrue);
      // Old versions moved the rating without counting ranked games.
      expect(OnlineRanking.hasPlayedRanked({'rating': 1184}), isTrue);
      expect(OnlineRanking.hasPlayedRanked({'rating': 1216}), isTrue);
    });
  });

  group('Elo', () {
    test('equal ratings: a win gives +16 and a loss -16', () {
      expect(
        OnlineRanking.ratingDelta(rating: 1200, opponentRating: 1200, score: 1),
        16,
      );
      expect(
        OnlineRanking.ratingDelta(rating: 1200, opponentRating: 1200, score: 0),
        -16,
      );
    });

    test('a draw between equal players changes nothing', () {
      expect(
        OnlineRanking.ratingDelta(rating: 1400, opponentRating: 1400, score: 0.5),
        0,
      );
    });

    test('the two sides of a game move by the same amount', () {
      final winner =
          OnlineRanking.ratingDelta(rating: 1350, opponentRating: 1180, score: 1);
      final loser =
          OnlineRanking.ratingDelta(rating: 1180, opponentRating: 1350, score: 0);
      expect(winner, -loser);
      expect(winner, lessThan(16)); // the favourite gains less
    });

    test('ratings stay inside the allowed range', () {
      expect(OnlineRanking.applyDelta(110, -32), OnlineRanking.minRating);
      expect(OnlineRanking.applyDelta(9990, 32), OnlineRanking.maxRating);
    });
  });

  group('rank', () {
    test('orders by rating and lets equal ratings share a rank', () {
      final ranked = OnlineRanking.rank([
        profile('c', 1200),
        profile('a', 1300),
        profile('b', 1200, rankedWins: 3),
        profile('d', 1100),
      ]);
      expect(ranked.map((r) => r.profile.oddserId), ['a', 'b', 'c', 'd']);
      expect(ranked.map((r) => r.rank), [1, 2, 2, 4]);
    });
  });

  group('legacyRankedRepair', () {
    test('rebuilds ranked counters an old version kept only in the totals', () {
      // Seen in production: 7 games, 6 of them casual, rating moved by one
      // ranked game.
      final updates = OnlineRanking.legacyRankedRepair({
        'rating': 1216,
        'totalGames': 7,
        'wins': 3,
        'losses': 4,
        'casualGames': 6,
        'casualWins': 2,
        'casualLosses': 4,
      });
      expect(updates, {
        'rankedGames': 1,
        'rankedWins': 1,
        'rankedLosses': 0,
        'isRanked': true,
      });
    });

    test('adds zero counters and no flag to a profile that never played ranked', () {
      final updates = OnlineRanking.legacyRankedRepair({
        'rating': 1200,
        'totalGames': 2,
        'wins': 2,
        'losses': 0,
        'casualGames': 2,
        'casualWins': 2,
        'casualLosses': 0,
      });
      expect(updates, {'rankedGames': 0, 'rankedWins': 0, 'rankedLosses': 0});
    });

    test('writes nothing for a current profile', () {
      expect(
        OnlineRanking.legacyRankedRepair({
          'rating': 1232,
          'rankedGames': 2,
          'rankedWins': 2,
          'rankedLosses': 0,
          'isRanked': true,
        }),
        isEmpty,
      );
    });
  });
}
