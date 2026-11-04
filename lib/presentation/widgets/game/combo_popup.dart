import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

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

  String _comboText(AppLocalizations l10n) {
    if (widget.combo >= 5) return l10n.comboAmazing;
    if (widget.combo >= 4) return l10n.comboFantastic;
    if (widget.combo >= 3) return l10n.comboGreat;
    return l10n.comboTitle;
  }

  /// Behind the white "3x": bold text needs 3:1.
  Color get _badgeColor {
    if (widget.combo >= 5) return AppColors.error;
    if (widget.combo >= 4) return AppColors.accentStrong;
    if (widget.combo >= 3) return AppColors.successStrong;
    return AppColors.primary;
  }

  /// The title sits on the game background, light or dark.
  Color _titleColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) return _badgeColor;
    if (widget.combo >= 5) return AppColors.error;
    if (widget.combo >= 4) return AppColors.accent;
    if (widget.combo >= 3) return AppColors.success;
    return AppColors.primaryOnDark;
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = _titleColor(context);
    final title = Text(
      _comboText(AppLocalizations.of(context)!),
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: titleColor,
        shadows: [
          Shadow(
            color: titleColor.withOpacity(0.5),
            blurRadius: 20,
          ),
        ],
      ),
    );
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: _badgeColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _badgeColor.withOpacity(0.4),
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
    );

    // Reduce Motion: no zoom or slide, only the fade out.
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [title, const SizedBox(height: 8), badge],
      ).animate(delay: 800.ms).fadeOut(duration: 400.ms);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        title
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
        badge
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
