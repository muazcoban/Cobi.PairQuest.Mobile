import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/auth_screen.dart';

/// Invites a player who has not signed in to do so, with what they gain.
///
/// The game stays fully playable without an account (HIG, Managing
/// accounts), so the card can be dismissed; it comes back after
/// [hiddenFor].
class SignInPromptCard extends ConsumerStatefulWidget {
  const SignInPromptCard({super.key});

  static const Duration hiddenFor = Duration(days: 7);
  static const String dismissedAtKey = 'sign_in_prompt_dismissed_at';

  /// Whether a card dismissed at [dismissedAt] shows again at [now].
  static bool isDue(DateTime? dismissedAt, DateTime now) =>
      dismissedAt == null || now.difference(dismissedAt) >= hiddenFor;

  @override
  ConsumerState<SignInPromptCard> createState() => _SignInPromptCardState();
}

class _SignInPromptCardState extends ConsumerState<SignInPromptCard> {
  // Hidden until the dismissal date is read, so the card never flashes.
  bool _due = false;

  @override
  void initState() {
    super.initState();
    _loadDismissal();
  }

  Future<void> _loadDismissal() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(SignInPromptCard.dismissedAtKey);
    final dismissedAt = stored == null ? null : DateTime.tryParse(stored);
    if (!mounted) return;
    setState(() => _due = SignInPromptCard.isDue(dismissedAt, DateTime.now()));
  }

  Future<void> _dismiss() async {
    setState(() => _due = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      SignInPromptCard.dismissedAtKey,
      DateTime.now().toIso8601String(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final signedIn = authState.isAuthenticated && !authState.isAnonymous;
    if (signedIn || !_due) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ExcludeSemantics(
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.signInPromptTitle,
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.signInPromptBody,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textLightSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: _dismiss,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size(44, 44),
                    ),
                    child: Text(l10n.notNow),
                  ),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    ),
                    icon: const Icon(Icons.login),
                    label: Text(l10n.signIn),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(44, 44),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
