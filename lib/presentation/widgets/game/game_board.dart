import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/card.dart';
import '../../../domain/entities/game.dart';
import '../../providers/game_provider.dart';
import 'memory_card.dart';

/// The main game board displaying the card grid
class GameBoard extends ConsumerWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final game = gameState.currentGame;

    if (game == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // The board is the bottom of the screen: keep cards above the home
    // indicator (HIG Layout, safe areas).
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = BoardLayout.fit(constraints.biggest, game.gridSize);
          final gridSize = layout.gridSizeFor(game.gridSize);

          Widget board = Padding(
            padding: const EdgeInsets.all(BoardLayout.padding),
            child: SizedBox.fromSize(
              size: gridSize,
              child: _CardGrid(
                cards: game.cards,
                gridSize: game.gridSize,
                spacing: layout.spacing,
                isProcessing: gameState.isProcessing,
              ),
            ),
          );

          // Only in very small windows (Stage Manager, Split View) do cards
          // reach the minimum size; scroll rather than shrink them further.
          if (!layout.fitsIn(constraints.biggest, game.gridSize)) {
            board = SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: board,
              ),
            );
          }

          return Center(child: board);
        },
      ),
    );
  }
}

/// Card size and spacing that fit the whole grid into the board area.
class BoardLayout {
  const BoardLayout({required this.cardWidth, required this.spacing});

  final double cardWidth;
  final double spacing;

  static const double padding = 16;

  /// Card height divided by card width.
  static const double cardAspectRatio = 1.2;

  /// HIG Accessibility: 28 pt is the minimum control size (44 pt default).
  static const double minCardWidth = 28;
  static const double maxCardWidth = 160;

  factory BoardLayout.fit(Size board, GridSize grid) {
    // Dense grids use tighter gaps so the cards themselves stay larger.
    final spacing = math.max(grid.rows, grid.cols) >= 7 ? 4.0 : 8.0;
    final byWidth =
        (board.width - 2 * padding - (grid.cols - 1) * spacing) / grid.cols;
    final byHeight =
        (board.height - 2 * padding - (grid.rows - 1) * spacing) /
            grid.rows /
            cardAspectRatio;
    final cardWidth =
        math.min(byWidth, byHeight).clamp(minCardWidth, maxCardWidth).toDouble();
    return BoardLayout(cardWidth: cardWidth, spacing: spacing);
  }

  double get cardHeight => cardWidth * cardAspectRatio;

  Size gridSizeFor(GridSize grid) => Size(
        grid.cols * cardWidth + (grid.cols - 1) * spacing,
        grid.rows * cardHeight + (grid.rows - 1) * spacing,
      );

  bool fitsIn(Size board, GridSize grid) {
    final size = gridSizeFor(grid);
    // Rounding in the division can leave a fraction of a point over.
    const tolerance = 0.5;
    return size.width + 2 * padding <= board.width + tolerance &&
        size.height + 2 * padding <= board.height + tolerance;
  }
}

/// Optimized card grid using GridView.builder for better performance
class _CardGrid extends ConsumerWidget {
  final List<GameCard> cards;
  final GridSize gridSize;
  final double spacing;
  final bool isProcessing;

  const _CardGrid({
    required this.cards,
    required this.gridSize,
    required this.spacing,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hintedCardIds = ref.watch(gameProvider.select((s) => s.hintedCardIds));

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize.cols,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: 1 / BoardLayout.cardAspectRatio,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        final isHinted = hintedCardIds.contains(card.id);
        return _CardItem(
          key: ValueKey(card.id),
          card: card,
          row: index ~/ gridSize.cols + 1,
          column: index % gridSize.cols + 1,
          isProcessing: isProcessing,
          isHinted: isHinted,
        );
      },
    );
  }
}

/// Individual card item - extracted for better rebuild optimization
class _CardItem extends ConsumerWidget {
  final GameCard card;
  final int row;
  final int column;
  final bool isProcessing;
  final bool isHinted;

  const _CardItem({
    super.key,
    required this.card,
    required this.row,
    required this.column,
    required this.isProcessing,
    this.isHinted = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShuffling = ref.watch(isShufflingProvider);
    final isHiddenCard = card.state == CardState.hidden;

    Widget cardWidget = MemoryCard(
      card: card,
      row: row,
      column: column,
      isDisabled: isProcessing || isShuffling,
      isHinted: isHinted,
      onTap: () {
        ref.read(gameProvider.notifier).selectCard(card.id);
      },
    );

    // Apply shuffle animation to hidden cards only; skipped with Reduce Motion
    if (isShuffling &&
        isHiddenCard &&
        !(MediaQuery.maybeDisableAnimationsOf(context) ?? false)) {
      cardWidget = cardWidget
          .animate()
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(0.85, 0.85),
            duration: 150.ms,
          )
          .shake(hz: 6, duration: 200.ms)
          .then()
          .scale(
            begin: const Offset(0.85, 0.85),
            end: const Offset(1.0, 1.0),
            duration: 150.ms,
          );
    }

    return cardWidget;
  }
}
