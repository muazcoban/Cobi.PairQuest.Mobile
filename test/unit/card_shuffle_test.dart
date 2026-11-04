import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/core/constants/game_config.dart';
import 'package:pair_quest/core/utils/card_shuffle.dart';
import 'package:pair_quest/domain/entities/game.dart';

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

    test('all themes have enough unique images for the largest level', () {
      final maxPairs = GameConfig.levels
          .map((l) => GridSize(rows: l.rows, cols: l.cols).pairs)
          .reduce((a, b) => a > b ? a : b);

      for (final theme in CardShuffle.themeImages.keys) {
        final images = CardShuffle.themeImages[theme]!;
        expect(images.toSet().length, images.length,
            reason: 'Theme $theme has duplicate images');
        expect(images.length >= maxPairs, true,
            reason: 'Theme $theme has ${images.length} images, '
                'level grids need up to $maxPairs pairs');
      }
    });

    test('every level can be generated with every theme', () {
      for (final level in GameConfig.levels) {
        final pairs = GridSize(rows: level.rows, cols: level.cols).pairs;
        for (final theme in CardShuffle.themeImages.keys) {
          final cards = CardShuffle.generateCards(pairs: pairs, theme: theme);
          expect(cards.length, pairs * 2,
              reason: 'Level ${level.level}, theme $theme');
        }
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
