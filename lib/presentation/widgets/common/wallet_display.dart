import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/wallet_provider.dart';

/// Compact wallet display showing coins and gems with auto-animation
class WalletDisplay extends ConsumerStatefulWidget {
  final bool showCoins;
  final bool showGems;
  final VoidCallback? onTap;

  const WalletDisplay({
    super.key,
    this.showCoins = true,
    this.showGems = true,
    this.onTap,
  });

  @override
  ConsumerState<WalletDisplay> createState() => _WalletDisplayState();
}

class _WalletDisplayState extends ConsumerState<WalletDisplay> {
  int? _animatingCoins;
  int? _animatingGems;
  int _previousCoins = 0;
  int _previousGems = 0;
  bool _isFirstBuild = true;

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);

    // Detect coin/gem changes after first build
    if (!_isFirstBuild) {
      // Check for coin increase
      if (wallet.coins > _previousCoins && _previousCoins > 0) {
        final diff = wallet.coins - _previousCoins;
        if (_animatingCoins == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _animatingCoins = diff);
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted) setState(() => _animatingCoins = null);
              });
            }
          });
        }
      }

      // Check for gem increase
      if (wallet.gems > _previousGems && _previousGems > 0) {
        final diff = wallet.gems - _previousGems;
        if (_animatingGems == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _animatingGems = diff);
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted) setState(() => _animatingGems = null);
              });
            }
          });
        }
      }
    }

    _previousCoins = wallet.coins;
    _previousGems = wallet.gems;
    _isFirstBuild = false;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.cardBorder(context),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showCoins) ...[
                  _CurrencyItem(
                    icon: Icons.monetization_on_rounded,
                    color: Colors.amber,
                    amount: wallet.coins,
                  ),
                  if (widget.showGems) const SizedBox(width: 12),
                ],
                if (widget.showGems)
                  _CurrencyItem(
                    icon: Icons.diamond_rounded,
                    color: Colors.purple,
                    amount: wallet.gems,
                  ),
              ],
            ),
          ),
        ),
        // Coin animation overlay
        if (_animatingCoins != null && widget.showCoins)
          Positioned(
            top: -25,
            left: 0,
            right: widget.showGems ? null : 0,
            child: CurrencyAddAnimation(
              amount: _animatingCoins!,
              isGem: false,
            ),
          ),
        // Gem animation overlay
        if (_animatingGems != null && widget.showGems)
          Positioned(
            top: -25,
            right: 0,
            child: CurrencyAddAnimation(
              amount: _animatingGems!,
              isGem: true,
            ),
          ),
      ],
    );
  }
}

class _CurrencyItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int amount;

  const _CurrencyItem({
    required this.icon,
    required this.color,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          _formatAmount(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toString();
  }
}

/// Large wallet display for shop/profile screens
class WalletDisplayLarge extends ConsumerWidget {
  final VoidCallback? onAddCoins;
  final VoidCallback? onAddGems;

  const WalletDisplayLarge({
    super.key,
    this.onAddCoins,
    this.onAddGems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.accent.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _LargeCurrencyItem(
              icon: Icons.monetization_on_rounded,
              color: Colors.amber,
              amount: wallet.coins,
              label: 'Coins',
              onAdd: onAddCoins,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.cardBorder(context),
          ),
          Expanded(
            child: _LargeCurrencyItem(
              icon: Icons.diamond_rounded,
              color: Colors.purple,
              amount: wallet.gems,
              label: 'Gems',
              onAdd: onAddGems,
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeCurrencyItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int amount;
  final String label;
  final VoidCallback? onAdd;

  const _LargeCurrencyItem({
    required this.icon,
    required this.color,
    required this.amount,
    required this.label,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: color,
          size: 32,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              amount.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
        if (onAdd != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.success,
                size: 16,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Animated coin/gem add effect
class CurrencyAddAnimation extends StatefulWidget {
  final int amount;
  final bool isGem;
  final VoidCallback? onComplete;

  const CurrencyAddAnimation({
    super.key,
    required this.amount,
    this.isGem = false,
    this.onComplete,
  });

  @override
  State<CurrencyAddAnimation> createState() => _CurrencyAddAnimationState();
}

class _CurrencyAddAnimationState extends State<CurrencyAddAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isGem
                        ? Icons.diamond_rounded
                        : Icons.monetization_on_rounded,
                    color: widget.isGem ? Colors.purple : Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${widget.amount}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.isGem ? Colors.purple : Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
