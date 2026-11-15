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
  });

  /// Youngest age in the range; null when unknown.
  final int? ageLower;

  /// Oldest age in the range; null for the open top range (18+).
  final int? ageUpper;

  /// The user is in a state with an app store law but has not verified
  /// their age with the store yet; the app must assume the strictest case.
  final bool verificationRequired;

  final SignificantChange significantChange;

  /// A parent has not (yet) approved the latest significant change.
  bool get awaitsParentApproval =>
      significantChange == SignificantChange.pending ||
      significantChange == SignificantChange.declined;
}

/// Where the app store's age signal comes from; tests use a fake.
abstract class AgeSignalsSource {
  /// The store's signal, or null when the store shares none: most users
  /// outside the US states with app store laws, a user who declines to
  /// share, an app not installed from the store, a timeout or an error.
  Future<StoreAgeSignal?> check();
}

/// Google Play Age Signals on Android, through MainActivity.kt. iOS has no
/// source yet: Apple's Declared Age Range needs the iOS 26.2 SDK (Xcode 26.2).
class PlatformAgeSignals implements AgeSignalsSource {
  const PlatformAgeSignals();

  static const _channel = MethodChannel('memoko/age_signals');

  // AgeSignalsStatus values from the Play library.
  static const _shared = 1;
  static const _verificationRequired = 3;

  @override
  Future<StoreAgeSignal?> check() async {
    if (kIsWeb || !Platform.isAndroid) return null;
    try {
      // Step 1: access. In states with a law Play answers without any UI;
      // elsewhere it may ask the user, so the wait is generous.
      final access = await _channel
          .invokeMapMethod<String, Object?>('requestAccess')
          .timeout(const Duration(seconds: 60), onTimeout: () => null);
      final status = access?['status'] as int?;
      if (status == _verificationRequired) {
        return const StoreAgeSignal(verificationRequired: true);
      }
      if (status != _shared) return null;

      // Step 2: the age range itself.
      final raw = await _channel
          .invokeMapMethod<String, Object?>('check')
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      if (raw == null || raw['errorCode'] != null) return null;
      final change = raw['significantChangeStatus'] as int?;
      return StoreAgeSignal(
        ageLower: raw['ageLower'] as int?,
        ageUpper: raw['ageUpper'] as int?,
        significantChange: change != null && change >= 0 && change < SignificantChange.values.length
            ? SignificantChange.values[change]
            : SignificantChange.unspecified,
      );
    } catch (e) {
      debugPrint('Age signals unavailable: $e');
      return null;
    }
  }
}
