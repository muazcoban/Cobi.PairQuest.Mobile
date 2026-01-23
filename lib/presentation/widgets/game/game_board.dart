import 'package:flutter/material.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardSize = _calculateCardSize(
          constraints: constraints,
          gridSize: game.gridSize,
        );

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _CardGrid(
              cards: game.cards,
              gridSize: game.gridSize,
              cardSize: cardSize,
              isProcessing: gameState.isProcessing,
            ),
          ),
        );
      },
    );
  }

  double _calculateCardSize({
    required BoxConstraints constraints,
    required GridSize gridSize,
  }) {
    const horizontalPadding = 32.0;
    const verticalPadding = 32.0;
    const spacing = 8.0;

    final availableWidth =
        constraints.maxWidth - horizontalPadding - (gridSize.cols - 1) * spacing;
    final availableHeight =
        constraints.maxHeight - verticalPadding - (gridSize.rows - 1) * spacing;

    final cardWidth = availableWidth / gridSize.cols;
    final cardHeight = availableHeight / gridSize.rows / 1.2;

    final cardSize = cardWidth < cardHeight ? cardWidth : cardHeight;

    return cardSize.clamp(50.0, 120.0);
  }
}

/// Optimized card grid using GridView.builder for better performance
class _CardGrid extends ConsumerWidget {
  final List<GameCard> cards;
  final GridSize gridSize;
  final double cardSize;
  final bool isProcessing;

  const _CardGrid({
    required this.cards,
    required this.gridSize,
    required this.cardSize,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hintedCardIds = ref.watch(gameProvider.select((s) => s.hintedCardIds));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize.cols,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1 / 1.2,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        final isHinted = hintedCardIds.contains(card.id);
        return _CardItem(
          key: ValueKey(card.id),
          card: card,
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
  final bool isProcessing;
  final bool isHinted;

  const _CardItem({
    super.key,
    required this.card,
    required this.isProcessing,
    this.isHinted = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MemoryCard(
      card: card,
      isDisabled: isProcessing,
      isHinted: isHinted,
      onTap: () {
        ref.read(gameProvider.notifier).selectCard(card.id);
      },
    );
  }
}
