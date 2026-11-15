import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/age_gate.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/age_provider.dart';

/// One-time neutral age screen, shown before the home screen is used.
///
/// Neutral in the FTC sense: it asks for the birth year without hinting at
/// which years unlock what, starts on an empty "pick your year" row so no
/// year is preselected, and cannot be skipped or answered again. Players
/// under 13 get the game without accounts or online features.
class AgeScreen extends ConsumerStatefulWidget {
  const AgeScreen({super.key, this.now});

  /// Fixed date for tests; the real clock otherwise.
  final DateTime? now;

  @override
  ConsumerState<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends ConsumerState<AgeScreen> {
  /// Row height of the year wheel; 44 pt is the HIG touch target.
  static const double itemExtent = 44;

  final _wheel = FixedExtentScrollController();
  int? _selected;
  bool _saving = false;

  DateTime get _now => widget.now ?? DateTime.now();

  late final List<int> _years = [
    for (var y = _now.year; y >= AgeGate.firstYear(_now); y--) y,
  ];

  @override
  void dispose() {
    _wheel.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final selected = _selected;
    if (selected == null) return;
    setState(() => _saving = true);

    final group = AgeGate.groupFor(birthYear: selected, now: _now);
    await ref.read(ageGroupProvider.notifier).answer(group);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              // Same gradient as the home screen, so the first screen
              // already looks like Memoko.
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            ExcludeSemantics(
                              child: Image.asset(
                                'assets/images/memo_mascot.png',
                                height: 150,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Semantics(
                              header: true,
                              child: Text(
                                l10n.ageScreenTitle,
                                textAlign: TextAlign.center,
                                style: textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.ageScreenBody,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.textLightSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _yearWheel(l10n),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _selected == null || _saving ? null : _continue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              disabledBackgroundColor: Colors.white.withValues(alpha: 0.35),
                              disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
                              minimumSize: const Size.fromHeight(54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              l10n.ageScreenContinue,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// A wheel like the iOS date picker. Row 0 is an empty "pick your year"
  /// prompt, so nothing counts as chosen until the player scrolls.
  Widget _yearWheel(AppLocalizations l10n) {
    // Rows have a fixed height; very large text is capped so it still fits.
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.4);
    TextStyle rowStyle(bool prompt) => TextStyle(
          fontSize: prompt ? 18 : 22,
          fontWeight: prompt ? FontWeight.w500 : FontWeight.w600,
          color: prompt ? AppColors.textSecondaryLight : AppColors.textPrimaryLight,
        );

    return Container(
      height: itemExtent * 5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: scaler),
        child: CupertinoPicker(
          scrollController: _wheel,
          itemExtent: itemExtent,
          magnification: 1.15,
          useMagnifier: true,
          squeeze: 1.1,
          selectionOverlay: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSelectedItemChanged: (index) {
            HapticFeedback.selectionClick();
            setState(() => _selected = index == 0 ? null : _years[index - 1]);
          },
          children: [
            Center(child: Text(l10n.ageScreenPickYear, style: rowStyle(true))),
            for (final year in _years) Center(child: Text('$year', style: rowStyle(false))),
          ],
        ),
      ),
    );
  }
}
