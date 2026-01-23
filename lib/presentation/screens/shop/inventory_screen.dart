import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/power_up.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/power_up_provider.dart';
import '../../widgets/common/wallet_display.dart';

/// Inventory screen showing owned power-ups
class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final ownedPowerUps = ref.watch(ownedPowerUpsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inventory),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: WalletDisplay(),
          ),
        ],
      ),
      body: SafeArea(
        child: ownedPowerUps.isEmpty
            ? _EmptyInventory()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ownedPowerUps.length,
                itemBuilder: (context, index) {
                  final entry = ownedPowerUps[index];
                  final powerUp = PowerUps.getByType(entry.key);
                  return _InventoryItem(
                    powerUp: powerUp,
                    quantity: entry.value,
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyInventory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emptyInventory,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.shopping_bag_rounded),
            label: Text(l10n.shop),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryItem extends StatelessWidget {
  final PowerUp powerUp;
  final int quantity;

  const _InventoryItem({
    required this.powerUp,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorder(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getPowerUpColor(powerUp.type).withValues(alpha: 0.2),
                  _getPowerUpColor(powerUp.type).withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                powerUp.icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLocalizedName(l10n, powerUp.type),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getLocalizedDescription(l10n, powerUp.type),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (powerUp.duration != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 12,
                        color: AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${powerUp.duration}s',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      if (powerUp.timedModeOnly) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.timedModeOnly,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Quantity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'x$quantity',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
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

  String _getLocalizedName(AppLocalizations l10n, PowerUpType type) {
    switch (type) {
      case PowerUpType.peek:
        return l10n.powerUpPeek;
      case PowerUpType.freeze:
        return l10n.powerUpFreeze;
      case PowerUpType.hint:
        return l10n.powerUpHint;
      case PowerUpType.shuffle:
        return l10n.powerUpShuffle;
      case PowerUpType.timeBonus:
        return l10n.powerUpTimeBonus;
      case PowerUpType.magnet:
        return l10n.powerUpMagnet;
    }
  }

  String _getLocalizedDescription(AppLocalizations l10n, PowerUpType type) {
    switch (type) {
      case PowerUpType.peek:
        return l10n.powerUpPeekDesc;
      case PowerUpType.freeze:
        return l10n.powerUpFreezeDesc;
      case PowerUpType.hint:
        return l10n.powerUpHintDesc;
      case PowerUpType.shuffle:
        return l10n.powerUpShuffleDesc;
      case PowerUpType.timeBonus:
        return l10n.powerUpTimeBonusDesc;
      case PowerUpType.magnet:
        return l10n.powerUpMagnetDesc;
    }
  }
}
