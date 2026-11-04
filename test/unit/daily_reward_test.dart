import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/domain/entities/daily_reward.dart';

void main() {
  DailyRewardProgress claimedOn(Duration offset) => DailyRewardProgress(
        currentStreak: 1,
        lastClaimedAt: DateTime.now().add(offset),
        totalClaimed: 1,
      );

  group('DailyRewardProgress.canClaimToday', () {
    test('a first reward can be claimed', () {
      expect(const DailyRewardProgress().canClaimToday, isTrue);
    });

    test('a reward claimed yesterday allows a new one', () {
      expect(claimedOn(const Duration(days: -1)).canClaimToday, isTrue);
    });

    test('a reward claimed today does not', () {
      expect(claimedOn(Duration.zero).canClaimToday, isFalse);
    });

    test('a reward claimed on a later date (clock set back) does not', () {
      expect(claimedOn(const Duration(days: 1)).canClaimToday, isFalse);
      expect(claimedOn(const Duration(days: 30)).canClaimToday, isFalse);
    });
  });
}
