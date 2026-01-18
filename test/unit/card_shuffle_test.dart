import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/core/utils/card_shuffle.dart';

void main() {
  group('CardShuffle', () {
    test('generateCards returns correct number of pairs', () {
      const pairs = 8;
      final cards = CardShuffle.generateCards(
        pairs: pairs,
        theme: 'animals',
      );

      expect(cards.length, pairs * 2);
    });

    test('generateCards creates matching pairs', () {
      final cards = CardShuffle.generateCards(
        pairs: 4,
        theme: 'animals',
      );

      // Count pairs by pairId
      final pairCounts = <String, int>{};
      for (final card in cards) {
        pairCounts[card.pairId] = (pairCounts[card.pairId] ?? 0) + 1;
      }

      // Each pair should appear exactly twice
      for (final count in pairCounts.values) {
        expect(count, 2);
      }
    });

    test('generateCards uses theme images', () {
      final cards = CardShuffle.generateCards(
        pairs: 4,
        theme: 'animals',
      );

      final animalImages = CardShuffle.themeImages['animals']!;
      for (final card in cards) {
        expect(animalImages.contains(card.imageAsset), true);
      }
    });

    test('all themes have sufficient images', () {
      final themes = CardShuffle.themeImages.keys;

      for (final theme in themes) {
        final images = CardShuffle.themeImages[theme]!;
        // Each theme should have at least 32 images (for 8x8 grid)
        expect(images.length >= 32, true,
            reason: 'Theme $theme has only ${images.length} images');
      }
    });

    test('different themes have different images', () {
      final animals = CardShuffle.themeImages['animals']!;
      final fruits = CardShuffle.themeImages['fruits']!;

      // First few images should be different between themes
      expect(animals.first != fruits.first, true);
    });
  });
}
