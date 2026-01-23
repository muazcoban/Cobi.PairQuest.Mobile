import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/game.dart';
import '../../../domain/entities/power_up.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/game_provider.dart';
import '../../providers/power_up_provider.dart';

/// Power-up bar displayed during gameplay
class PowerUpBar extends ConsumerStatefulWidget {
  final bool isTimedMode;
  final VoidCallback? onPowerUpUsed;

  const PowerUpBar({
    super.key,
    this.isTimedMode = false,
    this.onPowerUpUsed,
  });

  @override
  ConsumerState<PowerUpBar> createState() => _PowerUpBarState();
}

class _PowerUpBarState extends ConsumerState<PowerUpBar> {
  Timer? _activeTimer;

  @override
  void dispose() {
    _activeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(powerUpInventoryProvider);
    final gameUsage = ref.watch(gamePowerUpUsageProvider);
    final game = ref.watch(currentGameProvider);

    // Don't show if game not in progress
    if (game?.state != GameState.inProgress) {
      return const SizedBox.shrink();
    }

    // Filter available power-ups
    final availablePowerUps = PowerUps.all.where((powerUp) {
      // Check if player has it
      if (!inventory.has(powerUp.type)) return false;

      // Check if timed mode only
      if (powerUp.timedModeOnly && !widget.isTimedMode) return false;

      // Check if can still use in this game
      if (!gameUsage.canUse(powerUp.type)) return false;

      return true;
    }).toList();

    if (availablePowerUps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Active power-up indicator
          if (gameUsage.hasActivePowerUp)
            _ActivePowerUpIndicator(
              type: gameUsage.activePowerUp!,
              remainingSeconds: gameUsage.activeRemainingSeconds,
            ),

          // Power-up buttons
          ...availablePowerUps.map((powerUp) {
            final quantity = inventory.getQuantity(powerUp.type);
            final isActive = gameUsage.activePowerUp == powerUp.type;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _PowerUpButton(
                powerUp: powerUp,
                quantity: quantity,
                isActive: isActive,
                onTap: isActive ? null : () => _usePowerUp(powerUp),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _usePowerUp(PowerUp powerUp) async {
    final inventoryNotifier = ref.read(powerUpInventoryProvider.notifier);
    final gameUsageNotifier = ref.read(gamePowerUpUsageProvider.notifier);
    final gameNotifier = ref.read(gameProvider.notifier);

    // Use from inventory first
    final inventorySuccess = await inventoryNotifier.usePowerUp(powerUp.type);
    if (!inventorySuccess) return;

    // Execute the power-up effect
    final effectSuccess = await gameNotifier.usePowerUp(powerUp.type);
    if (!effectSuccess) {
      // Refund if effect failed
      await inventoryNotifier.addPowerUp(powerUp.type, 1);
      return;
    }

    // Mark as used in this game (after successful effect)
    gameUsageNotifier.markUsed(powerUp.type);

    // Activate if has duration (for visual indicator)
    if (powerUp.duration != null) {
      gameUsageNotifier.activatePowerUp(powerUp.type, powerUp.duration!);

      // Start timer to clear active indicator
      _activeTimer?.cancel();
      _activeTimer = Timer(Duration(seconds: powerUp.duration!), () {
        if (mounted) {
          ref.read(gamePowerUpUsageProvider.notifier).clearActivePowerUp();
        }
      });
    }

    // Notify parent
    widget.onPowerUpUsed?.call();

    // Show feedback
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(powerUp.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(l10n.powerUpUsed),
            ],
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _PowerUpButton extends StatelessWidget {
  final PowerUp powerUp;
  final int quantity;
  final bool isActive;
  final VoidCallback? onTap;

  const _PowerUpButton({
    required this.powerUp,
    required this.quantity,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive
              ? _getPowerUpColor(powerUp.type).withValues(alpha: 0.3)
              : AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? _getPowerUpColor(powerUp.type)
                : AppColors.cardBorder(context),
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: _getPowerUpColor(powerUp.type).withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Icon
            Center(
              child: Text(
                powerUp.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),

            // Quantity badge
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'x$quantity',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPowerUpColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.peek:
        return Colors.blue;
      case PowerUpType.freeze:
        return Colors.cyan;
      case PowerUpType.hint:
        return Colors.orange;
      case PowerUpType.shuffle:
        return Colors.green;
      case PowerUpType.timeBonus:
        return Colors.purple;
      case PowerUpType.magnet:
        return Colors.red;
    }
  }
}

class _ActivePowerUpIndicator extends StatefulWidget {
  final PowerUpType type;
  final int remainingSeconds;

  const _ActivePowerUpIndicator({
    required this.type,
    required this.remainingSeconds,
  });

  @override
  State<_ActivePowerUpIndicator> createState() => _ActivePowerUpIndicatorState();
}

class _ActivePowerUpIndicatorState extends State<_ActivePowerUpIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final powerUp = PowerUps.getByType(widget.type);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getPowerUpColor(widget.type).withValues(alpha: 0.3 + _controller.value * 0.2),
                _getPowerUpColor(widget.type).withValues(alpha: 0.1 + _controller.value * 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getPowerUpColor(widget.type),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(powerUp.icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                '${widget.remainingSeconds}s',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getPowerUpColor(widget.type),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getPowerUpColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.peek:
        return Colors.blue;
      case PowerUpType.freeze:
        return Colors.cyan;
      case PowerUpType.hint:
        return Colors.orange;
      case PowerUpType.shuffle:
        return Colors.green;
      case PowerUpType.timeBonus:
        return Colors.purple;
      case PowerUpType.magnet:
        return Colors.red;
    }
  }
}
