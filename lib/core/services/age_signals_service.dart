import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Parent approval of the app's latest "significant change" (a new feature
/// such as ads or purchases), for supervised minors in states with an app
/// store law. Values match Google Play's SignificantChangeStatus.
enum SignificantChange { unspecified, approved, pending, declined }

/// What the app store says about the user's age, for this session only.
///
/// Texas SB 2420 (§121.055) allows this data only for age restrictions and
/// asks for its deletion after use, and Google Play forbids any other use,
/// so it is never written to disk or sent anywhere.
@immutable
class StoreAgeSignal {
  const StoreAgeSignal({
    this.ageLower,
    this.ageUpper,
    this.verificationRequired = false,
    this.significantChange = SignificantChange.unspecified,
    this.parentalConsentRequired = false,
    this.adultNotificationRequired = false,
  });

  /// Youngest age in the range; null when unknown.
  final int? ageLower;

  /// Oldest age in the range; null for the open top range (18+).
  final int? ageUpper;

  /// The user is in a state with an app store law but has not verified
  /// their age with the store yet; the app must assume the strictest case.
  final bool verificationRequired;

  final SignificantChange significantChange;

  /// iOS: the law where the user lives requires a parent's consent to
  /// significant changes for minors.
  final bool parentalConsentRequired;

  /// iOS: the law requires telling adults about significant changes.
  final bool adultNotificationRequired;

  bool get _isMinor => (ageUpper != null && ageUpper! < 18) || (ageLower != null && ageLower! < 18);

  bool get isAdult => ageLower != null && ageLower! >= 18;

  /// A parent has not (yet) approved the latest significant change. The app
  /// never asks for that approval itself, so on iOS a minor who needs it
  /// simply stays without the features the change added.
  bool get awaitsParentApproval =>
      significantChange == SignificantChange.pending ||
      significantChange == SignificantChange.declined ||
      (parentalConsentRequired && _isMinor);
}

/// Where the app store's age signal comes from; tests use a fake.
abstract class AgeSignalsSource {
  /// The store's signal, or null when the store shares none: most users
  /// outside the US states with app store laws, a user who declines to
  /// share, an app not installed from the store, a timeout or an error.
  Future<StoreAgeSignal?> check();
}

/// Google Play Age Signals on Android (MainActivity.kt) and Apple's Declared
/// Age Range on iOS (AppDelegate.swift). An iOS build made with an SDK older
/// than 26.2 always reports no signal.
class PlatformAgeSignals implements AgeSignalsSource {
  const PlatformAgeSignals();

  static const _channel = MethodChannel('memoko/age_signals');

  // AgeSignalsStatus values from the Play library.
  static const _shared = 1;
  static const _verificationRequired = 3;

  @override
  Future<StoreAgeSignal?> check() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return null;
    try {
      // Step 1: access. In states with a law Play answers without any UI;
      // elsewhere it may ask the user, so the wait is generous. iOS answers
      // without UI everywhere but has been seen to hang.
      final access = await _channel
          .invokeMapMethod<String, Object?>('requestAccess')
          .timeout(Duration(seconds: Platform.isIOS ? 10 : 60), onTimeout: () => null);
      final status = access?['status'] as int?;
      if (status == _verificationRequired) {
        return const StoreAgeSignal(verificationRequired: true);
      }
      if (status != _shared) return null;

      // Step 2: the age range itself. On iOS this shows Apple's prompt.
      final raw = await _channel
          .invokeMapMethod<String, Object?>('check')
          .timeout(Duration(seconds: Platform.isIOS ? 120 : 5), onTimeout: () => null);
      if (raw == null || raw['errorCode'] != null) return null;
      final change = raw['significantChangeStatus'] as int?;
      return StoreAgeSignal(
        ageLower: raw['ageLower'] as int?,
        ageUpper: raw['ageUpper'] as int?,
        significantChange: change != null && change >= 0 && change < SignificantChange.values.length
            ? SignificantChange.values[change]
            : SignificantChange.unspecified,
        parentalConsentRequired: access?['parentalConsentRequired'] == true,
        adultNotificationRequired: access?['adultNotificationRequired'] == true,
      );
    } catch (e) {
      debugPrint('Age signals unavailable: $e');
      return null;
    }
  }
}

/// Apple's sheet that tells an adult about a significant update (iOS 26.4+,
/// where the law asks for it). Shown once per change; returns whether it was.
Future<bool> acknowledgeSignificantUpdate(String description) async {
  if (kIsWeb || !Platform.isIOS) return false;
  try {
    return await const MethodChannel('memoko/age_signals')
            .invokeMethod<bool>('acknowledgeUpdate', {'description': description}) ??
        false;
  } catch (_) {
    return false;
  }
}
