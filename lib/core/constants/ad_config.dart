import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// AdMob ad units and the "remove ads" product.
///
/// Debug builds always use Google's test units: tapping real ads during
/// development breaks AdMob policy. Release builds use the real units once
/// they are filled in below; until then they also get test ads, which earn
/// nothing but keep the app working. The AdMob app IDs live in
/// AndroidManifest.xml and ios/Runner/Info.plist.
class AdConfig {
  AdConfig._();

  /// Same product ID in App Store Connect and Google Play Console.
  static const String removeAdsProductId = 'remove_ads';

  // Real ad units from the AdMob console (publisher pub-5547492389514605).
  static const String _androidRewarded = 'ca-app-pub-5547492389514605/4470131881';
  static const String _androidInterstitial = 'ca-app-pub-5547492389514605/9610777928';
  static const String _iosRewarded = 'ca-app-pub-5547492389514605/2035365228';
  static const String _iosInterstitial = 'ca-app-pub-5547492389514605/5783038542';

  // Google's public test units:
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  static const String _testAndroidRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testAndroidInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testIosRewarded = 'ca-app-pub-3940256099942544/1712485313';
  static const String _testIosInterstitial = 'ca-app-pub-3940256099942544/4411468910';

  static String get rewardedUnitId => Platform.isIOS
      ? _pick(_iosRewarded, _testIosRewarded)
      : _pick(_androidRewarded, _testAndroidRewarded);

  static String get interstitialUnitId => Platform.isIOS
      ? _pick(_iosInterstitial, _testIosInterstitial)
      : _pick(_androidInterstitial, _testAndroidInterstitial);

  /// True while the release build still serves test ads.
  static bool get usesTestUnits =>
      kDebugMode ||
      (Platform.isIOS ? _iosRewarded.isEmpty : _androidRewarded.isEmpty);

  static String _pick(String real, String test) =>
      kDebugMode || real.isEmpty ? test : real;
}
