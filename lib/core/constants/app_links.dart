import 'package:url_launcher/url_launcher.dart';

/// Pages outside the app.
class AppLinks {
  AppLinks._();

  /// The same address as the privacy policy URL in App Store Connect.
  static final Uri privacyPolicy = Uri.parse(
    'https://github.com/muazcoban/Cobi.PairQuest.Mobile/blob/master/docs/PRIVACY.md',
  );

  /// Opens [uri] in an in-app browser; returns false if it could not open.
  static Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } catch (_) {
      return false;
    }
  }
}
