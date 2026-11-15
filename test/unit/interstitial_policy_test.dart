import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/core/services/ads/interstitial_policy.dart';

void main() {
  const policy = InterstitialPolicy();
  final firstOpen = DateTime(2026, 11, 1, 10);
  final later = firstOpen.add(const Duration(days: 3));

  bool canShow({
    bool adsRemoved = false,
    int games = 5,
    DateTime? lastShown,
    DateTime? now,
  }) =>
      policy.canShow(
        adsRemoved: adsRemoved,
        gamesFinished: games,
        firstOpen: firstOpen,
        lastShown: lastShown,
        now: now ?? later,
      );

  test('a player who played enough after the grace period sees an ad', () {
    expect(canShow(), isTrue);
  });

  test('no ad after buying "remove ads"', () {
    expect(canShow(adsRemoved: true), isFalse);
  });

  test('no ad during the first three games', () {
    expect(canShow(games: 2), isFalse);
    expect(canShow(games: 3), isTrue);
  });

  test('no ad in the first two days', () {
    expect(canShow(now: firstOpen.add(const Duration(days: 1, hours: 23))), isFalse);
    expect(canShow(now: firstOpen.add(const Duration(days: 2))), isTrue);
  });

  test('at least three minutes between two ads', () {
    expect(canShow(lastShown: later.subtract(const Duration(minutes: 2))), isFalse);
    expect(canShow(lastShown: later.subtract(const Duration(minutes: 3))), isTrue);
  });
}
