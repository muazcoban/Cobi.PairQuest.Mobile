import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Sign in with Apple, offered on iOS wherever Google sign-in is (App Review
/// 4.8). The package draws Apple's approved button; it is as large as the
/// Google button and comes before it (HIG Sign in with Apple).
class AppleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  /// White button on dark or colored backgrounds, black on light ones.
  final bool onDarkBackground;

  const AppleSignInButton({
    super.key,
    required this.onPressed,
    this.onDarkBackground = false,
  });

  static bool get isAvailable => Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    return SignInWithAppleButton(
      onPressed: onPressed,
      text: AppLocalizations.of(context)!.signInWithApple,
      height: 56,
      style: onDarkBackground
          ? SignInWithAppleButtonStyle.white
          : SignInWithAppleButtonStyle.black,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
    );
  }
}
