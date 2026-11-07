import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/presentation/providers/progress_provider.dart';

void main() {
  test('a level completed from the home screen stays open', () {
    // Classic mode starts on level 5 without levels 1-4 being played.
    const progress = GameProgress(levels: {5: LevelProgress(level: 5, stars: 3)});

    expect(progress.isLevelUnlocked(1), isTrue);
    expect(progress.isLevelUnlocked(4), isFalse);
    expect(progress.isLevelUnlocked(5), isTrue);
    expect(progress.isLevelUnlocked(6), isTrue);
    expect(progress.isLevelUnlocked(7), isFalse);
  });
}
