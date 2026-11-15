import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/core/services/review_prompt_service.dart';

void main() {
  final now = DateTime(2026, 11, 14, 20);

  test('does not ask before the third win', () {
    for (final wins in [1, 2]) {
      expect(
        ReviewPromptService.shouldAsk(winCount: wins, stars: 3, now: now),
        isFalse,
        reason: 'win $wins',
      );
    }
  });

  test('asks on the third win with a good score', () {
    expect(
      ReviewPromptService.shouldAsk(winCount: 3, stars: 2, now: now),
      isTrue,
    );
  });

  test('does not ask after a one-star game', () {
    expect(
      ReviewPromptService.shouldAsk(winCount: 5, stars: 1, now: now),
      isFalse,
    );
  });

  test('waits two weeks between requests', () {
    expect(
      ReviewPromptService.shouldAsk(
        winCount: 8,
        stars: 3,
        now: now,
        lastAskedAt: now.subtract(const Duration(days: 13)),
      ),
      isFalse,
    );
    expect(
      ReviewPromptService.shouldAsk(
        winCount: 8,
        stars: 3,
        now: now,
        lastAskedAt: now.subtract(const Duration(days: 14)),
      ),
      isTrue,
    );
  });
}
