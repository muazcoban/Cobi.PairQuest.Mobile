import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/game_config.dart';
import '../../../domain/entities/game.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/game_provider.dart';

/// Header widget showing score, moves, timer, and combo
class GameHeader extends ConsumerWidget {
  const GameHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(currentGameProvider);
    final l10n = AppLocalizations.of(context)!;

    if (game == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Score
            _StatItem(
              icon: Icons.stars,
              label: l10n.score,
              value: game.score.toString(),
              color: AppColors.accent,
            ),

            // Moves
            _StatItem(
              icon: Icons.touch_app,
              label: l10n.moves,
              value: game.moves.toString(),
              color: AppColors.primary,
            ),

            // Timer (if timed mode)
            if (game.mode == GameMode.timed)
              _TimerWidget(
                timeRemaining: game.timeRemaining ?? 0,
                timeLabel: l10n.time,
              )
            else
              _StatItem(
                icon: Icons.grid_view,
                label: l10n.remaining,
                value: '${game.remainingPairs}',
                color: AppColors.secondary,
              ),

            // Combo
            if (game.combo > 0)
              _ComboWidget(combo: game.combo)
            else
              _StatItem(
                icon: Icons.bolt,
                label: l10n.combo,
                value: '-',
                color: AppColors.comboColor,
              ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class _TimerWidget extends ConsumerWidget {
  final int timeRemaining;
  final String timeLabel;

  const _TimerWidget({required this.timeRemaining, required this.timeLabel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFrozen = ref.watch(isTimerFrozenProvider);
    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    Color timerColor;
    if (isFrozen) {
      timerColor = Colors.cyan;
    } else if (timeRemaining <= GameConfig.timerDangerThreshold) {
      timerColor = AppColors.timerDanger;
    } else if (timeRemaining <= GameConfig.timerWarningThreshold) {
      timerColor = AppColors.timerWarning;
    } else {
      timerColor = AppColors.timerNormal;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isFrozen ? Icons.ac_unit : Icons.timer,
          color: timerColor,
          size: 20,
        ),
        const SizedBox(height: 2),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: timerColor,
          ),
          child: Text(timeString),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isFrozen)
              const Padding(
                padding: EdgeInsets.only(right: 2),
                child: Icon(Icons.pause, size: 10, color: Colors.cyan),
              ),
            Text(
              isFrozen ? 'FROZEN' : timeLabel,
              style: TextStyle(
                fontSize: 10,
                color: isFrozen ? Colors.cyan : AppColors.textSecondaryLight,
                fontWeight: isFrozen ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ComboWidget extends StatelessWidget {
  final int combo;

  const _ComboWidget({required this.combo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColors.successGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            '${combo}x',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
