import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/auth/google_sign_in_button.dart';

class AuthScreen extends ConsumerWidget {
  final bool showBackButton;
  final String? returnMessage;

  const AuthScreen({
    super.key,
    this.showBackButton = true,
    this.returnMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryLight,
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      const Icon(
                        Icons.psychology,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        l10n.appTitle,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle / Message
                      Text(
                        returnMessage ?? l10n.signInToSaveProgress,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // Error message
                      if (authState.error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authState.error!,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () {
                                  ref.read(authProvider.notifier).clearError();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Loading indicator
                      if (authState.isLoading) ...[
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 24),
                      ],

                      // Google Sign In Button
                      if (!authState.isLoading)
                        GoogleSignInButton(
                          onPressed: () async {
                            final success =
                                await ref.read(authProvider.notifier).signInWithGoogle();
                            if (success && context.mounted) {
                              // Update player name from Google account
                              final displayName = ref.read(authProvider).displayName;
                              if (displayName != 'Guest') {
                                await ref.read(settingsProvider.notifier).setPlayerName(displayName);
                              }
                              Navigator.of(context).pop(true);
                            }
                          },
                        ),
                      const SizedBox(height: 16),

                      // Continue as Guest Button
                      if (!authState.isLoading)
                        _GuestButton(
                          label: l10n.continueAsGuest,
                          onPressed: () async {
                            await ref.read(authProvider.notifier).signInAnonymously();
                            if (context.mounted) {
                              Navigator.of(context).pop(false);
                            }
                          },
                        ),

                      const SizedBox(height: 48),

                      // Privacy policy link
                      TextButton(
                        onPressed: () {
                          // TODO: Open privacy policy
                        },
                        child: Text(
                          l10n.privacyPolicy,
                          style: const TextStyle(
                            color: Colors.white54,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Back button
              if (showBackButton)
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _GuestButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white54, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
