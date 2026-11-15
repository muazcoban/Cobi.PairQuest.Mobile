import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

/// "Watch an ad for a reward" button used in the result and reward dialogs.
///
/// [onWatch] shows the ad and grants the reward; it returns false when no ad
/// was shown or the player closed it early. The button then explains it
/// inline (a snackbar would sit under the dialog) and can be tried again.
/// After a success it turns into [doneLabel], or disappears if there is none.
class WatchAdButton extends StatefulWidget {
  const WatchAdButton({
    super.key,
    required this.label,
    required this.onWatch,
    this.doneLabel,
  });

  final String label;
  final Future<bool> Function() onWatch;
  final String? doneLabel;

  @override
  State<WatchAdButton> createState() => _WatchAdButtonState();
}

class _WatchAdButtonState extends State<WatchAdButton> {
  bool _busy = false;
  bool _done = false;
  bool _failed = false;

  Future<void> _watch() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    final ok = await widget.onWatch();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _done = ok;
      _failed = !ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_done) {
      final doneLabel = widget.doneLabel;
      if (doneLabel == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.successStrong, size: 20),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                doneLabel,
                style: const TextStyle(
                  color: AppColors.successStrong,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _busy ? null : _watch,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_circle_fill_rounded),
            label: Text(widget.label),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentStrong,
              side: const BorderSide(color: AppColors.accentStrong),
              // 44 pt minimum touch target (HIG), 48 dp on Android.
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        if (_failed)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l10n.adNotAvailable,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
            ),
          ),
      ],
    );
  }
}
