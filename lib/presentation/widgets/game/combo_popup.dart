import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

/// Animated combo popup that appears when player gets combos
class ComboPopup extends StatelessWidget {
  final int combo;
  final VoidCallback onComplete;

  const ComboPopup({
    super.key,
    required this.combo,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (combo < 2) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: _ComboContent(combo: combo, onComplete: onComplete),
        ),
      ),
    );
  }
}

class _ComboContent extends StatefulWidget {
  final int combo;
  final VoidCallback onComplete;

  const _ComboContent({
    required this.combo,
    required this.onComplete,
  });

  @override
  State<_ComboContent> createState() => _ComboContentState();
}

class _ComboContentState extends State<_ComboContent> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), widget.onComplete);
  }

  String get _comboText {
    if (widget.combo >= 5) return 'AMAZING!';
    if (widget.combo >= 4) return 'FANTASTIC!';
    if (widget.combo >= 3) return 'GREAT!';
    return 'COMBO!';
  }

  Color get _comboColor {
    if (widget.combo >= 5) return AppColors.error;
    if (widget.combo >= 4) return AppColors.accent;
    if (widget.combo >= 3) return AppColors.success;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _comboText,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: _comboColor,
            shadows: [
              Shadow(
                color: _comboColor.withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.2, 1.2),
              duration: 300.ms,
              curve: Curves.elasticOut,
            )
            .then()
            .scale(
              begin: const Offset(1.2, 1.2),
              end: const Offset(1.0, 1.0),
              duration: 200.ms,
            ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: _comboColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _comboColor.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '${widget.combo}x',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        )
            .animate(delay: 100.ms)
            .slideY(begin: 0.5, end: 0, duration: 300.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 200.ms),
      ],
    )
        .animate(delay: 800.ms)
        .fadeOut(duration: 400.ms)
        .slideY(begin: 0, end: -0.5, duration: 400.ms);
  }
}
