import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/power_up.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/power_up_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/common/wallet_display.dart';

/// Shop screen for purchasing power-ups
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shop),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: WalletDisplay(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Wallet display large
            const Padding(
              padding: EdgeInsets.all(16),
              child: WalletDisplayLarge(),
            ),

            // Power-ups grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: PowerUps.all.length,
                itemBuilder: (context, index) {
                  final powerUp = PowerUps.all[index];
                  return _PowerUpCard(powerUp: powerUp);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PowerUpCard extends ConsumerWidget {
  final PowerUp powerUp;

  const _PowerUpCard({required this.powerUp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final inventory = ref.watch(powerUpInventoryProvider);
    final wallet = ref.watch(walletProvider);
    final ownedCount = inventory.getQuantity(powerUp.type);
    final canAffordCoins = wallet.canAffordCoins(powerUp.coinCost);
    final canAffordGems = powerUp.gemCost > 0 && wallet.canAffordGems(powerUp.gemCost);

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon & Name
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getPowerUpColor(powerUp.type).withValues(alpha: 0.1),
                    _getPowerUpColor(powerUp.type).withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    powerUp.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getLocalizedName(l10n, powerUp.type),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (ownedCount > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.owned(ownedCount),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Description
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                _getLocalizedDescription(l10n, powerUp.type),
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary(context),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Buy buttons
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Coins button
                _BuyButton(
                  icon: Icons.monetization_on_rounded,
                  iconColor: Colors.amber,
                  amount: powerUp.coinCost,
                  enabled: canAffordCoins,
                  onPressed: () => _buyWithCoins(context, ref, powerUp),
                ),

                // Gems button (if available)
                if (powerUp.gemCost > 0) ...[
                  const SizedBox(height: 4),
                  _BuyButton(
                    icon: Icons.diamond_rounded,
                    iconColor: Colors.purple,
                    amount: powerUp.gemCost,
                    enabled: canAffordGems,
                    onPressed: () => _buyWithGems(context, ref, powerUp),
                  ),
                ],
              ],
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

  Future<void> _buyWithCoins(BuildContext context, WidgetRef ref, PowerUp powerUp) async {
    final l10n = AppLocalizations.of(context)!;
    final success = await ref.read(powerUpInventoryProvider.notifier).purchaseWithCoins(powerUp.type);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? l10n.purchaseSuccess : l10n.notEnoughCoins),
          backgroundColor: success ? AppColors.success : AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _buyWithGems(BuildContext context, WidgetRef ref, PowerUp powerUp) async {
    final l10n = AppLocalizations.of(context)!;
    final success = await ref.read(powerUpInventoryProvider.notifier).purchaseWithGems(powerUp.type);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? l10n.purchaseSuccess : l10n.notEnoughGems),
          backgroundColor: success ? AppColors.success : AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class _BuyButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int amount;
  final bool enabled;
  final VoidCallback onPressed;

  const _BuyButton({
    required this.icon,
    required this.iconColor,
    required this.amount,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 32,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? AppColors.primary : Colors.grey.shade300,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: enabled ? iconColor : Colors.grey, size: 16),
            const SizedBox(width: 4),
            Text(
              amount.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
