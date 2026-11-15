import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/presentation/providers/progress_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Quick play from the home screen creates the notifier only when the game
  // ends, so the level is completed while the saved progress still loads.
  test('a level completed during the load keeps the saved levels', () async {
    SharedPreferences.setMockInitialValues({
      'game_progress': jsonEncode({
        'levels': {
          '1': {'level': 1, 'stars': 3, 'bestScore': 750, 'timesPlayed': 1, 'timesCompleted': 1},
        },
        'totalStars': 3,
        'highestUnlockedLevel': 2,
      }),
    });
    final notifier = ProgressNotifier();

    await notifier.completeLevelProgress(
      level: 5,
      score: 1200,
      moves: 12,
      pairs: 8,
      timeSpent: 40,
      isPerfectGame: false,
    );

    expect(notifier.state.levels[1]?.stars, 3);
    expect(notifier.state.levels[5]?.bestScore, 1200);

    final saved = jsonDecode(
      (await SharedPreferences.getInstance()).getString('game_progress')!,
    ) as Map<String, dynamic>;
    expect((saved['levels'] as Map).keys, containsAll(['1', '5']));
  });
}
