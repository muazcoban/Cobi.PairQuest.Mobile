import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    // The header sits under the status bar, so it sets the icon color.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(context),
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
          // Equal columns, so large Dynamic Type sizes wrap labels instead of
          // pushing the row off the screen.
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score
              Expanded(
                child: _StatItem(
                  icon: Icons.stars,
                  label: l10n.score,
                  value: game.score.toString(),
                  color: AppColors.accent,
                ),
              ),

              // Moves
              Expanded(
                child: _StatItem(
                  icon: Icons.touch_app,
                  label: l10n.moves,
                  value: game.moves.toString(),
                  color: AppColors.primaryText(context),
                ),
              ),

              // Timer (if timed mode)
              Expanded(
                child: game.mode == GameMode.timed
                    ? _TimerWidget(
                        timeRemaining: game.timeRemaining ?? 0,
                        timeLabel: l10n.time,
                      )
                    : _StatItem(
                        icon: Icons.grid_view,
                        label: l10n.remaining,
                        value: '${game.remainingPairs}',
                        color: AppColors.textSecondary(context),
                      ),
              ),

              // Combo
              Expanded(
                child: game.combo > 0
                    ? Center(child: _ComboWidget(combo: game.combo))
                    : _StatItem(
                        icon: Icons.bolt,
                        label: l10n.combo,
                        value: '-',
                        color: AppColors.comboColor,
                      ),
              ),
            ],
          ),
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
    // VoiceOver reads "12, Moves" as one element.
    return MergeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Bold 18 pt text needs 3:1 and the 11 pt label 4.5:1, in both themes.
    Color timerColor;
    if (isFrozen) {
      timerColor = isDark ? Colors.cyan : Colors.cyan.shade800;
    } else if (timeRemaining <= GameConfig.timerDangerThreshold) {
      timerColor = isDark ? const Color(0xFFF87171) : AppColors.timerDanger;
    } else if (timeRemaining <= GameConfig.timerWarningThreshold) {
      timerColor = isDark ? AppColors.timerWarning : AppColors.accentStrong;
    } else {
      timerColor = AppColors.primaryText(context);
    }

    return MergeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFrozen ? Icons.ac_unit : Icons.timer,
            color: timerColor,
            size: 20,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: timerColor,
              ),
              child: Text(timeString),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isFrozen)
                Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Icon(Icons.pause, size: 11, color: timerColor),
                ),
              Flexible(
                child: Text(
                  isFrozen
                      ? AppLocalizations.of(context)!.timerFrozen
                      : timeLabel,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 11,
                    color: isFrozen
                        ? timerColor
                        : AppColors.textSecondary(context),
                    fontWeight: isFrozen ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${combo}x',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
