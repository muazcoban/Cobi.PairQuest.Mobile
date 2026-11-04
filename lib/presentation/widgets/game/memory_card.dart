import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/game_config.dart';
import '../../../domain/entities/card.dart';
import '../../../l10n/generated/app_localizations.dart';

/// A single memory card widget with flip animation
class MemoryCard extends StatefulWidget {
  final GameCard card;
  final VoidCallback? onTap;
  final bool isDisabled;
  final bool isHinted;

  /// Place on the board, starting at 1; VoiceOver reads it instead of the ID.
  final int row;
  final int column;

  const MemoryCard({
    super.key,
    required this.card,
    required this.row,
    required this.column,
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
  late AnimationController _hintGlowController;
  late Animation<double> _flipAnimation;
  late Animation<double> _matchScaleAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _hintGlowAnimation;
  bool _showFront = false;
  bool _wasMatched = false;

  /// Reduce Motion is on: no 3D flip, bounce, shake or pulsing glow.
  bool _reduceMotion = false;

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

    _hintGlowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _hintGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hintGlowController, curve: Curves.easeInOut),
    );

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _syncHintGlow();
  }

  @override
  void didUpdateWidget(MemoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.card.state != oldWidget.card.state) {
      _updateAnimationState();
    }

    if (widget.isHinted != oldWidget.isHinted) {
      _syncHintGlow();
    }
  }

  /// A hinted card pulses; with Reduce Motion it keeps a still highlight.
  void _syncHintGlow() {
    if (widget.isHinted && !_reduceMotion) {
      if (!_hintGlowController.isAnimating) {
        _hintGlowController.repeat(reverse: true);
      }
    } else {
      _hintGlowController
        ..stop()
        ..reset();
    }
  }

  void _updateAnimationState() {
    if (widget.card.state == CardState.revealed ||
        widget.card.state == CardState.matched) {
      _controller.forward();

      // Play match animation when card becomes matched
      if (widget.card.state == CardState.matched && !_wasMatched) {
        _wasMatched = true;
        if (!_reduceMotion) _matchController.forward(from: 0);
      }
    } else if (widget.card.state == CardState.hidden) {
      // Play shake animation when card is hidden again (mismatch)
      if (_showFront && !_reduceMotion) {
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
    _hintGlowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canTap =
        widget.card.state == CardState.hidden && !widget.isDisabled;

    return Semantics(
      label: _getSemanticLabel(AppLocalizations.of(context)!),
      button: canTap,
      enabled: canTap,
      onTap: canTap ? widget.onTap : null,
      // The label already says what the card shows.
      excludeSemantics: true,
      child: RepaintBoundary(
        child: GestureDetector(
          onTap: canTap ? widget.onTap : null,
          child: _reduceMotion ? _buildStill() : _buildAnimated(),
        ),
      ),
    );
  }

  /// Reduce Motion: a short cross-fade replaces the flip (HIG Accessibility:
  /// "Replacing transitions in x-, y-, and z-axes with fades").
  Widget _buildStill() {
    final faceUp = widget.card.state != CardState.hidden;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: KeyedSubtree(
        key: ValueKey(faceUp),
        child: _buildSurface(faceUp, mirrored: false),
      ),
    );
  }

  Widget _buildAnimated() {
    return AnimatedBuilder(
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
            child: _buildSurface(_showFront, mirrored: true),
          ),
        );
      },
    );
  }

  Widget _buildSurface(bool showFront, {required bool mirrored}) {
    final isMatched = widget.card.state == CardState.matched;

    return AnimatedContainer(
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
        child: showFront ? _buildFront(mirrored: mirrored) : _buildBack(),
      ),
    );
  }

  String _getSemanticLabel(AppLocalizations l10n) {
    final position = l10n.cardPosition(widget.row, widget.column);
    final image = widget.card.imageAsset;
    switch (widget.card.state) {
      case CardState.hidden:
        return '$position, ${l10n.cardFaceDown}';
      case CardState.revealed:
        return '$position, ${l10n.cardFaceUp(image)}';
      case CardState.matched:
        return '$position, ${l10n.cardMatchedState(image)}';
    }
  }

  Widget _buildFront({required bool mirrored}) {
    final isMatched = widget.card.state == CardState.matched;

    final face = Container(
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
          // The emoji is the card's picture: sized to the card, not to the
          // Dynamic Type setting, so it never spills over the edges.
          final size = math.min(constraints.maxWidth, constraints.maxHeight) * 0.6;
          return Center(
            child: Text(
              widget.card.imageAsset,
              textScaler: TextScaler.noScaling,
              style: TextStyle(fontSize: size),
            ),
          );
        },
      ),
    );

    // The flip turns the card by 180 degrees, so the face is drawn mirrored.
    if (!mirrored) return face;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: face,
    );
  }

  Widget _buildBack() {
    if (!widget.isHinted) {
      // Normal card back - no animation needed
      return Container(
        decoration: BoxDecoration(
          gradient: AppColors.cardBackGradient,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final iconSize = constraints.maxWidth * 0.4;
            return Center(
              child: Icon(
                Icons.psychology_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: iconSize.clamp(12.0, 48.0),
              ),
            );
          },
        ),
      );
    }

    // Hinted card back - with glow/pulse animation
    return AnimatedBuilder(
      animation: _hintGlowAnimation,
      builder: (context, child) {
        final glowIntensity = _hintGlowAnimation.value;
        final baseColor = Color.lerp(
          Colors.orange.shade400,
          Colors.amber.shade300,
          glowIntensity,
        )!;

        return Container(
          decoration: BoxDecoration(
            color: baseColor,
            border: Border.all(
              color: Color.lerp(
                Colors.orange.shade700,
                Colors.amber.shade500,
                glowIntensity,
              )!,
              width: 3 + glowIntensity,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4 + glowIntensity * 0.3),
                blurRadius: 12 + glowIntensity * 8,
                spreadRadius: 2 + glowIntensity * 3,
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final iconSize = constraints.maxWidth * 0.4;
              return Center(
                child: Transform.scale(
                  scale: 1.0 + glowIntensity * 0.1,
                  child: Icon(
                    Icons.lightbulb_rounded,
                    color: Colors.white.withValues(alpha: 0.9 + glowIntensity * 0.1),
                    size: iconSize.clamp(12.0, 48.0),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
