import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/game.dart';
import '../../../domain/entities/player.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Dialog showing multiplayer game results
class MultiplayerResultDialog extends StatelessWidget {
  final Game game;
  final VoidCallback onMainMenu;
  final VoidCallback onPlayAgain;

  const MultiplayerResultDialog({
    super.key,
    required this.game,
    required this.onMainMenu,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rankedPlayers = game.rankedPlayers;
    final winner = game.winner;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: winner?.color.withOpacity(0.2) ?? AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events,
                size: 48,
                color: winner?.color ?? AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Winner announcement
            Text(
              l10n.gameOver,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            if (winner != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: winner.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${winner.name} ${l10n.wins}!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: winner.color,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Player rankings
            ...rankedPlayers.asMap().entries.map((entry) {
              final index = entry.key;
              final player = entry.value;
              return _PlayerRankRow(
                rank: index + 1,
                player: player,
                isWinner: index == 0,
              );
            }),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onMainMenu,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: AppColors.primary),
                    ),
                    child: Text(l10n.mainMenu),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPlayAgain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.playAgain,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerRankRow extends StatelessWidget {
  final int rank;
  final Player player;
  final bool isWinner;

  const _PlayerRankRow({
    required this.rank,
    required this.player,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    final rankIcons = ['🥇', '🥈', '🥉', '4️⃣'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isWinner
            ? player.color.withOpacity(0.1)
            : AppColors.background(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? player.color : Colors.transparent,
          width: isWinner ? 2 : 0,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Text(
            rankIcons[rank - 1],
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),

          // Player color dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: player.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),

          // Player name
          Expanded(
            child: Text(
              player.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),

          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${player.score}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? player.color : AppColors.textPrimary(context),
                ),
              ),
              Text(
                '${player.matches} matches',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
