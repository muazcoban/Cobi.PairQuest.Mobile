import '../domain/entities/power_up.dart';
import 'generated/app_localizations.dart';

/// Localized power-up names, shared by the shop and the in-game bar.
extension PowerUpL10n on AppLocalizations {
  String powerUpName(PowerUpType type) {
    switch (type) {
      case PowerUpType.peek:
        return powerUpPeek;
      case PowerUpType.freeze:
        return powerUpFreeze;
      case PowerUpType.hint:
        return powerUpHint;
      case PowerUpType.shuffle:
        return powerUpShuffle;
      case PowerUpType.timeBonus:
        return powerUpTimeBonus;
      case PowerUpType.magnet:
        return powerUpMagnet;
    }
  }
}
