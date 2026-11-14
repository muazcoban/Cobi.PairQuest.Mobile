import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/presentation/providers/progress_provider.dart';

void main() {
  test('a completed level stays open', () {
    const progress = GameProgress(levels: {5: LevelProgress(level: 5, stars: 3)});

    expect(progress.isLevelUnlocked(1), isTrue);
    expect(progress.isLevelUnlocked(4), isFalse);
    expect(progress.isLevelUnlocked(5), isTrue);
    expect(progress.isLevelUnlocked(6), isTrue);
    expect(progress.isLevelUnlocked(7), isFalse);
  });

  test('levels skipped by the old quick play open up to the highest unlocked', () {
    // Before 2.3.0, Classic mode on the home screen started on level 5: a win
    // saved highestUnlockedLevel 6 while levels 2-4 had no stars.
    const progress = GameProgress(
      levels: {5: LevelProgress(level: 5, stars: 2)},
      highestUnlockedLevel: 6,
    );

    for (var level = 1; level <= 6; level++) {
      expect(progress.isLevelUnlocked(level), isTrue, reason: 'level $level');
    }
    expect(progress.isLevelUnlocked(7), isFalse);
  });
}
