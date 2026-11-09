import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/moderation/name_filter.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

/// Asks for a player name when the signed-in account has none.
///
/// Sign in with Apple shares the name only the first time someone signs in
/// to the app, and people can choose not to share it. Without a name the
/// account shows as "Guest" on the online profile, leaderboards and friend
/// requests. The field starts with the local player name, so saving it is
/// one tap.
Future<void> ensureAccountName(BuildContext context, WidgetRef ref) async {
  final auth = ref.read(authProvider);
  if (!auth.isAuthenticated || auth.isAnonymous || auth.hasAccountName) return;

  final name = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        AccountNameDialog(initialName: ref.read(settingsProvider).playerName),
  );
  if (name == null) return;
  if (await ref.read(authProvider.notifier).setAccountName(name)) {
    await ref.read(settingsProvider.notifier).setPlayerName(name);
  }
}

/// Returns the chosen name, trimmed, when the player saves it.
class AccountNameDialog extends StatefulWidget {
  final String initialName;

  const AccountNameDialog({super.key, required this.initialName});

  @override
  State<AccountNameDialog> createState() => _AccountNameDialogState();
}

class _AccountNameDialogState extends State<AccountNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.enterYourName);
      return;
    }
    // The name is public on the online profile (App Review 1.2).
    if (!NameFilter.isAllowed(name)) {
      setState(() => _error = l10n.nameNotAllowed);
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      // Large Dynamic Type sizes and the keyboard can push it off screen.
      scrollable: true,
      title: Text(l10n.chooseAccountName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.chooseAccountNameDesc),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 20,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: l10n.enterYourName,
              errorText: _error,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _save(),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
