import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/core/services/audio_service.dart';
import 'package:pair_quest/domain/entities/card.dart';
import 'package:pair_quest/domain/entities/game.dart';
import 'package:pair_quest/domain/entities/power_up.dart';
import 'package:pair_quest/presentation/providers/game_provider.dart';
import 'package:pair_quest/presentation/providers/power_up_provider.dart';
import 'package:pair_quest/presentation/providers/settings_provider.dart';
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
  void dispose() {}
}

/// Creates a container whose settings are already loaded. gameProvider
/// watches settingsProvider, so a late settings load would rebuild the
/// notifier and drop the running game.
Future<ProviderContainer> _createContainer(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final container = ProviderContainer(overrides: [
    audioServiceProvider.overrideWithValue(_SilentAudioService()),
  ]);
  addTearDown(container.dispose);

  container.read(settingsProvider);
  await tester.pump();
  await tester.pump();
  return container;
}

GameStateData _state(ProviderContainer c) => c.read(gameProvider);
Game _game(ProviderContainer c) => _state(c).currentGame!;

/// Starts a level and waits until the preview has finished.
Future<GameNotifier> _startLevel(
  WidgetTester tester,
  ProviderContainer c, {
  required int level,
  GameMode mode = GameMode.classic,
}) async {
  final notifier = c.read(gameProvider.notifier);
  await notifier.startGame(level: level, mode: mode, theme: 'animals');
  await _waitUntilInProgress(tester, c);
  return notifier;
}

Future<void> _waitUntilInProgress(WidgetTester tester, ProviderContainer c) async {
  for (var i = 0; i < 100; i++) {
    if (_state(c).currentGame?.state == GameState.inProgress) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('Game did not leave the preview phase');
}

/// Selects a card and lets every delay it starts run out.
Future<void> _tap(WidgetTester tester, GameNotifier n, String cardId) async {
  final selection = n.selectCard(cardId);
  await tester.pump(const Duration(milliseconds: 1500));
  await selection;
}

/// Matches every remaining pair, starting with the pair of the selected card.
Future<void> _finishGame(
    WidgetTester tester, ProviderContainer c, GameNotifier n) async {
  final selected = _state(c).selectedCards;
  if (selected.isNotEmpty) {
    final partner = _game(c).cards.firstWhere(
        (card) => card.pairId == selected.first.pairId && card.id != selected.first.id);
    await _tap(tester, n, partner.id);
  }

  while (true) {
    final hidden = _game(c).cards.where((card) => card.state == CardState.hidden).toList();
    if (hidden.isEmpty) break;
    final first = hidden.first;
    final partner = hidden.firstWhere(
        (card) => card.pairId == first.pairId && card.id != first.id);
    await _tap(tester, n, first.id);
    await _tap(tester, n, partner.id);
  }
}

void main() {
  testWidgets('peek with one card face up keeps it selectable and the game can finish',
      (tester) async {
    final c = await _createContainer(tester);
    final n = await _startLevel(tester, c, level: 2);

    final first = _game(c).cards.first;
    await _tap(tester, n, first.id);

    expect(await n.usePowerUp(PowerUpType.peek), isTrue);
    await tester.pump(const Duration(seconds: 3));

    expect(_state(c).isProcessing, isFalse);
    expect(_state(c).selectedCards.map((card) => card.id), [first.id]);
    expect(
      _game(c).cards.where((card) => card.state == CardState.revealed).map((card) => card.id),
      [first.id],
    );

    await _finishGame(tester, c, n);
    expect(_game(c).state, GameState.completed);
  });

  testWidgets('shuffle with one card face up turns it back and the game can finish',
      (tester) async {
    final c = await _createContainer(tester);
    final n = await _startLevel(tester, c, level: 2);

    await _tap(tester, n, _game(c).cards.first.id);

    expect(await n.usePowerUp(PowerUpType.shuffle), isTrue);
    await tester.pump(const Duration(milliseconds: 400));

    expect(_state(c).isProcessing, isFalse);
    expect(_state(c).isShuffling, isFalse);
    expect(_state(c).selectedCards, isEmpty);
    expect(_game(c).cards.every((card) => card.state == CardState.hidden), isTrue);

    await _finishGame(tester, c, n);
    expect(_game(c).state, GameState.completed);
  });

  testWidgets('power-ups are refused while a mismatched pair is being shown',
      (tester) async {
    final c = await _createContainer(tester);
    final n = await _startLevel(tester, c, level: 2);

    final cards = _game(c).cards;
    final a = cards.first;
    final b = cards.firstWhere((card) => card.pairId != a.pairId);

    await _tap(tester, n, a.id);
    final mismatch = n.selectCard(b.id);
    await tester.pump(const Duration(milliseconds: 100));

    expect(await n.usePowerUp(PowerUpType.hint), isFalse);

    await tester.pump(const Duration(seconds: 1));
    await mismatch;
    expect(_state(c).isProcessing, isFalse);
  });

  testWidgets('pausing while a mismatched pair is shown keeps the game paused',
      (tester) async {
    final c = await _createContainer(tester);
    final n = await _startLevel(tester, c, level: 2, mode: GameMode.timed);

    final cards = _game(c).cards;
    final a = cards.first;
    final b = cards.firstWhere((card) => card.pairId != a.pairId);

    await _tap(tester, n, a.id);
    final mismatch = n.selectCard(b.id);
    await tester.pump(const Duration(milliseconds: 100));
    n.pauseGame();
    await tester.pump(const Duration(seconds: 1));
    await mismatch;

    expect(_game(c).state, GameState.paused);
    expect(_game(c).cards.every((card) => card.state == CardState.hidden), isTrue);

    n.resumeGame();
    expect(_game(c).state, GameState.inProgress);

    final before = _game(c).timeRemaining!;
    await tester.pump(const Duration(seconds: 2));
    expect(_game(c).timeRemaining!, lessThan(before));

    n.endGame(); // stop the countdown timer before the test ends
  });

  testWidgets('play again starts without power-up effects from the previous game',
      (tester) async {
    final c = await _createContainer(tester);
    final n = await _startLevel(tester, c, level: 1, mode: GameMode.timed);

    expect(await n.usePowerUp(PowerUpType.freeze), isTrue);
    expect(await n.usePowerUp(PowerUpType.magnet), isTrue);
    c.read(gamePowerUpUsageProvider.notifier).markUsed(PowerUpType.freeze);
    expect(_state(c).timerFrozen, isTrue);

    await n.resetGame();
    await _waitUntilInProgress(tester, c);

    expect(_state(c).timerFrozen, isFalse);
    expect(_state(c).magnetActive, isFalse);
    expect(_state(c).powerUpsUsedCount, 0);
    expect(c.read(gamePowerUpUsageProvider).canUse(PowerUpType.freeze), isTrue);

    final before = _game(c).timeRemaining!;
    await tester.pump(const Duration(seconds: 2));
    expect(_game(c).timeRemaining!, lessThan(before));

    n.endGame(); // stop the countdown timer before the test ends
  });
}
