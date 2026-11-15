/// Decides whether a full-screen ad may appear between two games.
///
/// Kept free of Flutter and plugin code so the rules can be unit tested.
/// The limits are deliberately loose on the player: no ad until the game has
/// been played a little, and never two ads close together.
class InterstitialPolicy {
  const InterstitialPolicy({
    this.minGamesFinished = 3,
    this.gracePeriod = const Duration(days: 2),
    this.minGap = const Duration(minutes: 3),
  });

  /// Finished single-player games before the first ad.
  final int minGamesFinished;

  /// Ad-free time after the first launch of a version with ads.
  final Duration gracePeriod;

  /// Shortest time between two full-screen ads.
  final Duration minGap;

  bool canShow({
    required bool adsRemoved,
    required int gamesFinished,
    required DateTime firstOpen,
    required DateTime? lastShown,
    required DateTime now,
  }) {
    if (adsRemoved) return false;
    if (gamesFinished < minGamesFinished) return false;
    if (now.difference(firstOpen) < gracePeriod) return false;
    if (lastShown != null && now.difference(lastShown) < minGap) return false;
    return true;
  }
}
