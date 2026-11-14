import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/presentation/providers/daily_quest_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('recordGameResult reports each quest once, in the game that completes it',
      () async {
    SharedPreferences.setMockInitialValues({});
    final notifier = DailyQuestNotifier();
    for (var i = 0; i < 50 && notifier.state.quests.isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(notifier.state.quests, isNotEmpty);

    final reported = <String>[];
    for (var game = 0; game < 10; game++) {
      reported.addAll(await notifier.recordGameResult(
        won: true,
        matches: 20,
        maxCombo: 10,
        isPerfect: true,
        starsEarned: 3,
        isTimedMode: true,
      ));
    }

    final completed = notifier.state.quests
        .where((quest) => notifier.state.progress[quest.id]?.isCompleted ?? false)
        .map((quest) => quest.id)
        .toSet();
    expect(completed, isNotEmpty);
    expect(reported.toSet(), completed);
    expect(reported.length, completed.length, reason: 'no quest is reported twice');
  });

  // The provider is usually created by the first finished game, so the
  // result arrives while the saved quests are still loading.
  test('the first game after launch counts on a fresh install', () async {
    SharedPreferences.setMockInitialValues({});
    final notifier = DailyQuestNotifier();

    await notifier.recordGameResult(
      won: true,
      matches: 8,
      maxCombo: 3,
      isPerfect: false,
      starsEarned: 2,
    );

    expect(notifier.state.quests, hasLength(3));
    final saved = jsonDecode(
      (await SharedPreferences.getInstance()).getString('daily_quests')!,
    ) as Map<String, dynamic>;
    expect(saved['todayGamesPlayed'], 1);
    expect(saved['todayMatchesMade'], 8);
    expect((saved['quests'] as List), hasLength(3));
  });

  test('the first game after launch adds to the saved counters', () async {
    SharedPreferences.setMockInitialValues({
      'daily_quests': jsonEncode({
        'date': DateTime.now().toIso8601String(),
        'quests': [
          {'id': 'matches_10'},
        ],
        'progress': {},
        'todayGamesPlayed': 2,
        'todayMatchesMade': 5,
      }),
    });
    final notifier = DailyQuestNotifier();

    await notifier.recordGameResult(
      won: true,
      matches: 8,
      maxCombo: 3,
      isPerfect: false,
      starsEarned: 2,
    );

    final saved = jsonDecode(
      (await SharedPreferences.getInstance()).getString('daily_quests')!,
    ) as Map<String, dynamic>;
    expect(saved['todayGamesPlayed'], 3);
    expect(saved['todayMatchesMade'], 13);
  });
}
