import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/age_gate.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/age_provider.dart';

/// One-time neutral age screen, shown before the home screen is used.
///
/// Neutral in the FTC sense: it asks for the birth year without hinting at
/// which years unlock what, preselects nothing, and cannot be skipped or
/// answered again. Players under 13 get the game without accounts or online
/// features.
class AgeScreen extends ConsumerStatefulWidget {
  const AgeScreen({super.key, this.now});

  /// Fixed date for tests; the real clock otherwise.
  final DateTime? now;

  @override
  ConsumerState<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends ConsumerState<AgeScreen> {
  int? _selected;
  bool _saving = false;

  Future<void> _continue() async {
    final selected = _selected;
    if (selected == null) return;
    setState(() => _saving = true);

    final group = AgeGate.groupFor(birthYear: selected, now: widget.now ?? DateTime.now());
    await ref.read(ageGroupProvider.notifier).answer(group);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = widget.now ?? DateTime.now();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.ageScreenTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText(context),
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.ageScreenBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _YearGrid(
                    now: now,
                    selected: _selected,
                    onSelected: (year) => setState(() => _selected = year),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _selected == null || _saving ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    l10n.ageScreenContinue,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Birth years, newest first, three per row. Material's YearPicker opens at
/// the oldest year when nothing is selected, so everyone scrolled a century.
class _YearGrid extends StatelessWidget {
  const _YearGrid({required this.now, required this.selected, required this.onSelected});

  final DateTime now;
  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final years = [for (var y = now.year; y >= AgeGate.firstYear(now); y--) y];

    return GridView.builder(
      itemCount: years.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 52, // above the 44 pt / 48 dp touch minimum
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final year = years[index];
        final isSelected = year == selected;
        return Semantics(
          selected: isSelected,
          button: true,
          child: Material(
            color: isSelected ? AppColors.primary : AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSelected(year),
              child: Center(
                child: Text(
                  '$year',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.primaryText(context),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
