import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/domain/entities/game.dart';
import 'package:pair_quest/domain/entities/player_stats.dart';
import 'package:pair_quest/domain/entities/player.dart';
import 'package:pair_quest/presentation/providers/achievement_provider.dart';
import 'package:pair_quest/presentation/providers/stats_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('progress on launch counts the saved stats', (tester) async {
    // Opening Achievements before Statistics computed progress from empty,
    // still-loading stats and showed 0 / 10 after eight wins.
    final saved = PlayerStats(firstPlayedAt: DateTime(2026, 1, 1)).copyWith(
      totalGamesPlayed: 9,
      totalGamesWon: 8,
    );
    SharedPreferences.setMockInitialValues({
      'player_stats': jsonEncode(saved.toJson()),
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);

    c.read(achievementProvider.notifier);
    for (var i = 0; i < 5; i++) {
      await tester.pump();
    }

    expect(c.read(achievementProvider.notifier).getProgress('games_10').currentValue, 8);
  });

  testWidgets('a second win does not report earlier achievements again', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);

    // Same order as GameScreen: achievements are loaded before the game ends
    c.read(statsProvider);
    c.read(achievementProvider.notifier);
    await tester.pump();
    await tester.pump();

    void recordWin() => c.read(statsProvider.notifier).recordGameWin(
          level: 1,
          score: 500,
          moves: 2,
          matches: 2,
          timeSeconds: 10,
          maxCombo: 2,
          stars: 3,
          isPerfectGame: true,
        );

    recordWin();
    final first = await c.read(achievementProvider.notifier).checkAchievements();
    expect(first, isNotEmpty);

    recordWin();
    final second = await c.read(achievementProvider.notifier).checkAchievements();
    final repeated = second.map((a) => a.id).toSet().intersection(first.map((a) => a.id).toSet());
    expect(repeated, isEmpty);
  });

  test('local two-player game with equal top scores has no winner', () {
    Game gameWith(int score1, int score2) => Game(
          id: 'g',
          mode: GameMode.multiplayer,
          level: 3,
          gridSize: const GridSize(rows: 2, cols: 4),
          cards: const [],
          players: [
            Player(id: 'p1', name: 'A', colorIndex: 0, score: score1),
            Player(id: 'p2', name: 'B', colorIndex: 1, score: score2),
          ],
        );

    expect(gameWith(300, 300).winner, isNull);
    expect(gameWith(200, 300).winner?.id, 'p2');
  });
}
