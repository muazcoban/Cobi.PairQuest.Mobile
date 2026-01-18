import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Haptic feedback types
enum HapticType {
  light,
  medium,
  heavy,
  selection,
  success,
  warning,
  error,
}

/// Haptic feedback service
class HapticService {
  bool _enabled = true;

  /// Set haptic enabled state
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Trigger haptic feedback
  Future<void> trigger(HapticType type) async {
    if (!_enabled) return;

    switch (type) {
      case HapticType.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
        await HapticFeedback.heavyImpact();
        break;
      case HapticType.selection:
        await HapticFeedback.selectionClick();
        break;
      case HapticType.success:
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.lightImpact();
        break;
      case HapticType.warning:
        await HapticFeedback.heavyImpact();
        break;
      case HapticType.error:
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();
        break;
    }
  }

  /// Card flip feedback
  Future<void> cardFlip() => trigger(HapticType.light);

  /// Card match feedback
  Future<void> cardMatch() => trigger(HapticType.success);

  /// Card mismatch feedback
  Future<void> cardMismatch() => trigger(HapticType.error);

  /// Button tap feedback
  Future<void> buttonTap() => trigger(HapticType.selection);

  /// Level complete feedback
  Future<void> levelComplete() async {
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }
}

/// Haptic service provider
final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService();
});
