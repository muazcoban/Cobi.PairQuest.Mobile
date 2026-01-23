import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/game_config.dart';
import '../../../domain/entities/card.dart';

/// A single memory card widget with flip animation
class MemoryCard extends StatefulWidget {
  final GameCard card;
  final VoidCallback? onTap;
  final bool isDisabled;
  final bool isHinted;

  const MemoryCard({
    super.key,
    required this.card,
    this.onTap,
    this.isDisabled = false,
    this.isHinted = false,
  });

  @override
  State<MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<MemoryCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _matchController;
  late AnimationController _shakeController;
  late Animation<double> _flipAnimation;
  late Animation<double> _matchScaleAnimation;
  late Animation<double> _shakeAnimation;
  bool _showFront = false;
  bool _wasMatched = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: GameConfig.cardFlipDuration),
      vsync: this,
    );

    _matchController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _matchScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _matchController, curve: Curves.easeInOut));

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 8, end: -4), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 25),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    _controller.addListener(() {
      if (_controller.value >= 0.5 && !_showFront) {
        setState(() => _showFront = true);
      } else if (_controller.value < 0.5 && _showFront) {
        setState(() => _showFront = false);
      }
    });

    // Set initial state based on card state
    _updateAnimationState();
  }

  @override
  void didUpdateWidget(MemoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.card.state != oldWidget.card.state) {
      _updateAnimationState();
    }
  }

  void _updateAnimationState() {
    if (widget.card.state == CardState.revealed ||
        widget.card.state == CardState.matched) {
      _controller.forward();

      // Play match animation when card becomes matched
      if (widget.card.state == CardState.matched && !_wasMatched) {
        _wasMatched = true;
        _matchController.forward(from: 0);
      }
    } else if (widget.card.state == CardState.hidden) {
      // Play shake animation when card is hidden again (mismatch)
      if (_showFront) {
        _shakeController.forward(from: 0);
      }
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _matchController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMatched = widget.card.state == CardState.matched;
    final canTap =
        widget.card.state == CardState.hidden && !widget.isDisabled;

    return Semantics(
      label: _getSemanticLabel(),
      button: canTap,
      enabled: canTap,
      child: RepaintBoundary(
        child: GestureDetector(
          onTap: canTap ? widget.onTap : null,
          child: AnimatedBuilder(
        animation: Listenable.merge([_flipAnimation, _matchScaleAnimation, _shakeAnimation]),
        builder: (context, child) {
          final angle = _flipAnimation.value * math.pi;
          final scale = _matchScaleAnimation.value;
          final shakeOffset = _shakeAnimation.value;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..translate(shakeOffset, 0, 0)
            ..rotateY(angle);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: Transform.scale(
              scale: scale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    if (isMatched)
                      BoxShadow(
                        color: AppColors.cardMatched.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _showFront ? _buildFront() : _buildBack(),
                ),
              ),
            ),
          );
        },
      ),
      ),
    ),
    );
  }

  String _getSemanticLabel() {
    switch (widget.card.state) {
      case CardState.hidden:
        return 'Card ${widget.card.id}, face down. Tap to reveal.';
      case CardState.revealed:
        return 'Card ${widget.card.id}, showing ${widget.card.imageAsset}';
      case CardState.matched:
        return 'Card ${widget.card.id}, matched';
    }
  }

  Widget _buildFront() {
    final isMatched = widget.card.state == CardState.matched;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: Container(
        decoration: BoxDecoration(
          color: isMatched
              ? AppColors.cardMatched.withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isMatched ? AppColors.cardMatched : Colors.grey.shade300,
            width: isMatched ? 3 : 1,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Make emoji fill most of the card
            final size = constraints.maxWidth * 0.6;
            return Center(
              child: Text(
                widget.card.imageAsset,
                style: TextStyle(fontSize: size.clamp(24.0, 60.0)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.isHinted ? null : AppColors.cardBackGradient,
        color: widget.isHinted ? Colors.orange.shade400 : null,
        border: widget.isHinted
            ? Border.all(color: Colors.orange.shade700, width: 3)
            : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final iconSize = constraints.maxWidth * 0.4;
          return Center(
            child: Icon(
              widget.isHinted ? Icons.lightbulb_rounded : Icons.psychology_rounded,
              color: Colors.white.withValues(alpha: 0.9),
              size: iconSize.clamp(20.0, 40.0),
            ),
          );
        },
      ),
    );
  }
}
