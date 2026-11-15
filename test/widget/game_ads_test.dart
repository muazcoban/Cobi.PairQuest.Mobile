import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/core/services/ads/ad_service.dart';
import 'package:pair_quest/core/services/audio_service.dart';
import 'package:pair_quest/core/services/wallet_sync_service.dart';
import 'package:pair_quest/domain/entities/game.dart';
import 'package:pair_quest/domain/entities/power_up.dart';
import 'package:pair_quest/l10n/generated/app_localizations.dart';
import 'package:pair_quest/presentation/providers/ads_provider.dart';
import 'package:pair_quest/presentation/providers/game_provider.dart';
import 'package:pair_quest/presentation/providers/power_up_provider.dart';
import 'package:pair_quest/presentation/providers/settings_provider.dart';
import 'package:pair_quest/presentation/providers/wallet_provider.dart';
import 'package:pair_quest/presentation/screens/game/game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SilentAudioService implements AudioService {
  @override
  void setSoundEnabled(bool enabled) {}
  @override
  void setMusicEnabled(bool enabled) {}
  @override
  Future<void> playSound(SoundEffect effect) async {}
  @override
  Future<void> playBackgroundMusic() async {}
  @override
  Future<void> stopBackgroundMusic() async {}
  @override
  Future<void> pauseBackgroundMusic() async {}
  @override
  Future<void> resumeBackgroundMusic() async {}
  @override
  bool get isMusicPlaying => false;
  @override
  void dispose() {}
}

class _GuestWalletSync extends WalletSyncService {
  _GuestWalletSync() : super(firestore: FakeFirebaseFirestore(), signedInUserId: () => null);

  @override
  Stream<User?> get authStateChanges => const Stream.empty();
}

/// Stands in for AdMob: "shows" a rewarded ad at once, or has none.
class _FakeAds implements AdService {
  _FakeAds({required this.fill});

  bool fill;
  int rewardedShown = 0;
  GameState? stateWhileShowing;
  late ProviderContainer container;

  @override
  bool get isShowingFullScreenAd => false;
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> showRewarded({bool Function()? beforeShow}) async {
    if (!fill) return false;
    if (beforeShow != null && !beforeShow()) return false;
    rewardedShown++;
    stateWhileShowing = container.read(gameProvider).currentGame?.state;
    return true;
  }

  @override
  Future<void> recordGameFinished() async {}
  @override
  Future<void> showInterstitialIfAllowed() async {}
  @override
  Future<bool> privacyOptionsRequired() async => false;
  @override
  Future<void> showPrivacyOptions() async {}
}

void main() {
  late ProviderContainer container;
  late _FakeAds ads;

  GameState? stateOf() => container.read(gameProvider).currentGame?.state;

  Future<void> openGame(WidgetTester tester, {required String mode, bool fill = true}) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    ads = _FakeAds(fill: fill);
    container = ProviderContainer(overrides: [
      audioServiceProvider.overrideWithValue(_SilentAudioService()),
      walletSyncServiceProvider.overrideWithValue(_GuestWalletSync()),
      adServiceProvider.overrideWithValue(ads),
    ]);
    ads.container = container;
    addTearDown(container.dispose);
    container.read(settingsProvider);
    await tester.pump();

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: GameScreen(level: 1, mode: mode),
      ),
    ));
    for (var i = 0; i < 100 && stateOf() != GameState.inProgress; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(stateOf(), GameState.inProgress);
  }

  testWidgets('out of hints, a watched ad pauses the game and uses one hint', (tester) async {
    await openGame(tester, mode: 'classic');
    expect(container.read(powerUpInventoryProvider).has(PowerUpType.hint), isFalse);

    await tester.tap(find.byTooltip('Free hint for watching an ad'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(ads.rewardedShown, 1);
    expect(ads.stateWhileShowing, GameState.paused, reason: 'no play under the ad');
    expect(stateOf(), GameState.inProgress);
    expect(container.read(gamePowerUpUsageProvider).usedCount[PowerUpType.hint], 1,
        reason: 'the granted hint was used in this game');
    expect(container.read(powerUpInventoryProvider).has(PowerUpType.hint), isFalse);

    container.read(gameProvider.notifier).endGame();
  });

  testWidgets('with no ad available the game keeps running and says so', (tester) async {
    await openGame(tester, mode: 'classic', fill: false);

    await tester.tap(find.byTooltip('Free hint for watching an ad'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(stateOf(), GameState.inProgress);
    expect(find.text('No ad is available right now. Try again in a moment.'), findsOneWidget);
    expect(container.read(gamePowerUpUsageProvider).usedCount[PowerUpType.hint], isNull);

    container.read(gameProvider.notifier).endGame();
    await tester.pump(const Duration(seconds: 5)); // let the snackbar timer finish
  });

  testWidgets('time up: a watched ad continues the game with 30 seconds, once', (tester) async {
    await openGame(tester, mode: 'timed');

    await tester.pump(Duration(seconds: container.read(gameProvider).currentGame!.timeRemaining! + 1));
    await tester.pump(const Duration(milliseconds: 500));
    expect(stateOf(), GameState.failed);

    await tester.tap(find.text('Watch an ad: +30 s'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Watch an ad: +30 s'), findsNothing, reason: 'dialog closed');
    expect(stateOf(), GameState.inProgress);
    expect(container.read(gameProvider).currentGame!.timeRemaining, inInclusiveRange(29, 30));

    // The second time-up offers no continue.
    await tester.pump(const Duration(seconds: 31));
    await tester.pump(const Duration(milliseconds: 500));
    expect(stateOf(), GameState.failed);
    expect(find.text('Watch an ad: +30 s'), findsNothing);
    expect(find.text('Try Again'), findsOneWidget);

    container.read(gameProvider.notifier).endGame();
  });
}
