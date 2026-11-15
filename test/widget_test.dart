import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pair_quest/main.dart';

void main() {
  testWidgets('App should render home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PairQuestApp(),
      ),
    );

    expect(find.text('Memoko'), findsOneWidget);
  },
      // The app root builds auth, leaderboard, invitation and notification
      // providers that need a Firebase app. Until they have fakes, screen
      // behaviour is tested one screen at a time under test/widget/.
      skip: true);
}
