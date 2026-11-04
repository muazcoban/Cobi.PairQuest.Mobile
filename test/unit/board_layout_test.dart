import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/core/constants/game_config.dart';
import 'package:pair_quest/domain/entities/game.dart';
import 'package:pair_quest/presentation/widgets/game/game_board.dart';

void main() {
  // Board area left for the cards: screen minus status bar, home indicator,
  // header (88), controls (64) and the power-up bar (56).
  const phones = {
    'iPhone SE': Size(375, 667 - 20 - 88 - 64 - 56),
    'iPhone 13 mini': Size(375, 812 - 50 - 34 - 88 - 64 - 56),
    'iPhone 16 Pro': Size(402, 874 - 62 - 34 - 88 - 64 - 56),
  };
  const tablets = {
    'iPad mini portrait': Size(744, 1133 - 24 - 20 - 88 - 64 - 56),
    'iPad 13" portrait': Size(1032, 1376 - 24 - 20 - 88 - 64 - 56),
    'iPad 13" landscape': Size(1376, 1032 - 24 - 20 - 88 - 64 - 56),
  };

  GridSize grid(GridConfig level) => GridSize(rows: level.rows, cols: level.cols);

  group('BoardLayout.fit', () {
    for (final device in {...phones, ...tablets}.entries) {
      test('every level fits on ${device.key} with cards of at least 28 pt', () {
        for (final level in GameConfig.levels) {
          final layout = BoardLayout.fit(device.value, grid(level));
          expect(layout.cardWidth, greaterThanOrEqualTo(BoardLayout.minCardWidth),
              reason: 'level ${level.level}');
          expect(layout.fitsIn(device.value, grid(level)), isTrue,
              reason: 'level ${level.level}');
        }
      });
    }

    for (final device in tablets.entries) {
      test('cards reach the 44 pt default on ${device.key}', () {
        for (final level in GameConfig.levels) {
          expect(BoardLayout.fit(device.value, grid(level)).cardWidth,
              greaterThanOrEqualTo(44), reason: 'level ${level.level}');
        }
      });
    }

    test('a height-limited board sizes cards by height', () {
      const board = Size(1376, 400);
      final layout = BoardLayout.fit(board, const GridSize(rows: 4, cols: 4));
      expect(layout.gridSizeFor(const GridSize(rows: 4, cols: 4)).height,
          lessThanOrEqualTo(board.height - 2 * BoardLayout.padding + 0.5));
    });

    test('a window too small for 28 pt cards keeps 28 pt and reports overflow', () {
      const board = Size(200, 200);
      const tenByTen = GridSize(rows: 10, cols: 10);
      final layout = BoardLayout.fit(board, tenByTen);
      expect(layout.cardWidth, BoardLayout.minCardWidth);
      expect(layout.fitsIn(board, tenByTen), isFalse);
    });
  });
}
