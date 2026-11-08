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
      reported.addAll(notifier.recordGameResult(
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
}
