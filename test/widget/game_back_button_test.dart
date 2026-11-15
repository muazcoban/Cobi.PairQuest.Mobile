import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/core/services/audio_service.dart';
import 'package:pair_quest/core/services/wallet_sync_service.dart';
import 'package:pair_quest/domain/entities/game.dart';
import 'package:pair_quest/l10n/generated/app_localizations.dart';
import 'package:pair_quest/presentation/providers/game_provider.dart';
import 'package:pair_quest/presentation/providers/settings_provider.dart';
import 'package:pair_quest/presentation/providers/wallet_provider.dart';
import 'package:pair_quest/presentation/screens/game/game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Audio stand-in: the real service creates platform audio players.
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

/// A guest who never signs in, so the power-up bar needs no Firebase app.
class _GuestWalletSync extends WalletSyncService {
  _GuestWalletSync() : super(firestore: FakeFirebaseFirestore(), signedInUserId: () => null);

  @override
  Stream<User?> get authStateChanges => const Stream.empty();
}

void main() {
  late ProviderContainer container;

  GameState? stateOf() => container.read(gameProvider).currentGame?.state;

  /// Opens level 1 from a home page and waits until the preview is over.
  Future<void> openGame(WidgetTester tester) async {
    // A large phone. The test font draws every glyph as a full square, so a
    // narrower screen overflows the header in tests but not on a device.
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer(overrides: [
      audioServiceProvider.overrideWithValue(_SilentAudioService()),
      walletSyncServiceProvider.overrideWithValue(_GuestWalletSync()),
    ]);
    addTearDown(container.dispose);
    // gameProvider watches settings; a late load would rebuild the notifier.
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
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GameScreen(level: 1)),
                ),
                child: const Text('home'),
              ),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('home'));
    for (var i = 0; i < 100 && stateOf() != GameState.inProgress; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(stateOf(), GameState.inProgress);
  }

  /// The Android back button and the iOS/Android back gesture go through here.
  Future<void> systemBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('system back during a game pauses it and asks instead of leaving', (tester) async {
    await openGame(tester);

    await systemBack(tester);

    expect(find.byType(GameScreen), findsOneWidget);
    expect(stateOf(), GameState.paused);
    expect(find.text('Game Paused'), findsOneWidget);
  });

  testWidgets('system back on the pause dialog resumes the game', (tester) async {
    await openGame(tester);
    await systemBack(tester);

    await systemBack(tester);

    expect(find.text('Game Paused'), findsNothing);
    expect(find.byType(GameScreen), findsOneWidget);
    expect(stateOf(), GameState.inProgress);
  });

  testWidgets('the back arrow also asks first, and Quit leaves the game', (tester) async {
    await openGame(tester);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Game Paused'), findsOneWidget);
    expect(stateOf(), GameState.paused);

    await tester.tap(find.text('Quit'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(GameScreen), findsNothing);
    expect(find.text('home'), findsOneWidget);
    expect(container.read(gameProvider).currentGame, isNull);
  });
}
