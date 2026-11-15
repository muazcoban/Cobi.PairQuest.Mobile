import 'package:url_launcher/url_launcher.dart';

/// Pages outside the app.
class AppLinks {
  AppLinks._();

  /// The same address as the privacy policy URL in App Store Connect.
  static final Uri privacyPolicy = Uri.parse(
    'https://github.com/muazcoban/Cobi.PairQuest.Mobile/blob/master/docs/PRIVACY.md',
  );

  /// Support address, also in the privacy policy.
  static final Uri contactEmail = Uri(
    scheme: 'mailto',
    path: 'muazcoban@gmail.com',
    query: 'subject=Memoko',
  );

  /// Report of an inappropriate ad, required next to ads by App Review 2.5.18.
  /// The subject is encoded by hand: queryParameters would turn spaces into
  /// "+", which some mail apps show as is.
  static final Uri reportAdEmail = Uri(
    scheme: 'mailto',
    path: 'muazcoban@gmail.com',
    query: 'subject=${Uri.encodeComponent('Memoko - inappropriate ad')}',
  );

  /// Opens [uri] in an in-app browser, or a mailto link in the mail app;
  /// returns false if it could not open.
  static Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(
        uri,
        mode: uri.scheme == 'mailto'
            ? LaunchMode.externalApplication
            : LaunchMode.inAppBrowserView,
      );
    } catch (_) {
      return false;
    }
  }
}
