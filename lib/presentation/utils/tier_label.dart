import '../../l10n/generated/app_localizations.dart';
import '../providers/online_leaderboard_provider.dart';

/// The tier's name in the app language ("Gümüş", "Silver").
String tierLabel(AppLocalizations l10n, PlayerTier tier) => switch (tier) {
      PlayerTier.bronze => l10n.tierBronze,
      PlayerTier.silver => l10n.tierSilver,
      PlayerTier.gold => l10n.tierGold,
      PlayerTier.platinum => l10n.tierPlatinum,
      PlayerTier.diamond => l10n.tierDiamond,
      PlayerTier.master => l10n.tierMaster,
    };
