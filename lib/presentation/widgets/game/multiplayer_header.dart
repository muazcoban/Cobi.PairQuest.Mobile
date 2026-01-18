import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/player.dart';
import '../../providers/game_provider.dart';

/// Header widget showing all players' scores in multiplayer mode
class MultiplayerHeader extends ConsumerWidget {
  const MultiplayerHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final game = gameState.currentGame;

    if (game == null || !game.isMultiplayer || game.players == null) {
      return const SizedBox.shrink();
    }

    final players = game.players!;
    final currentPlayerIndex = game.currentPlayerIndex;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player score cards
          Row(
            children: players.asMap().entries.map((entry) {
              final index = entry.key;
              final player = entry.value;
              final isCurrentTurn = index == currentPlayerIndex;

              return Expanded(
                child: _PlayerScoreCard(
                  player: player,
                  isCurrentTurn: isCurrentTurn,
                  playerIndex: index,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PlayerScoreCard extends StatelessWidget {
  final Player player;
  final bool isCurrentTurn;
  final int playerIndex;

  const _PlayerScoreCard({
    required this.player,
    required this.isCurrentTurn,
    required this.playerIndex,
  });

  @override
  Widget build(BuildContext context) {
    final color = player.color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? color.withOpacity(0.15)
            : AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentTurn ? color : Colors.transparent,
          width: isCurrentTurn ? 2 : 1,
        ),
        boxShadow: isCurrentTurn
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player name with color dot
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  player.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCurrentTurn ? color : AppColors.textPrimary(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isCurrentTurn) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.play_arrow,
                  color: color,
                  size: 14,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Score
          Text(
            '${player.score}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isCurrentTurn ? color : AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 4),
          // Matches
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                size: 14,
                color: isCurrentTurn ? color : AppColors.textSecondary(context),
              ),
              const SizedBox(width: 4),
              Text(
                '${player.matches}',
                style: TextStyle(
                  fontSize: 12,
                  color: isCurrentTurn ? color : AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
          // Combo indicator
          if (player.combo > 1) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${player.combo}x',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
