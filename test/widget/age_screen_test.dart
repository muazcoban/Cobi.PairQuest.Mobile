import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/core/services/age_gate.dart';
import 'package:pair_quest/l10n/generated/app_localizations.dart';
import 'package:pair_quest/presentation/providers/age_provider.dart';
import 'package:pair_quest/presentation/screens/onboarding/age_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime(2026, 11, 15);
  late ProviderContainer container;

  Future<void> openAgeScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
    addTearDown(container.dispose);

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
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AgeScreen(now: now)),
              ),
              child: const Text('home'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('home'));
    await tester.pumpAndSettle();
  }

  Future<void> pickYear(WidgetTester tester, int year) async {
    await tester.scrollUntilVisible(
      find.text('$year'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('$year'));
    await tester.pump();
  }

  testWidgets('nothing is preselected and the screen cannot be skipped', (tester) async {
    await openAgeScreen(tester);

    final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue'));
    expect(button.onPressed, isNull, reason: 'no default year');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(AgeScreen), findsOneWidget, reason: 'back does not skip it');
    expect(container.read(ageGroupProvider), isNull);
  });

  testWidgets('a child birth year closes online features', (tester) async {
    await openAgeScreen(tester);

    await pickYear(tester, 2017);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(AgeScreen), findsNothing);
    expect(container.read(ageGroupProvider), AgeGroup.child);
    expect(container.read(onlineAllowedProvider), isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('age_group'), 'child', reason: 'only the group is stored');
    expect(prefs.getKeys().any((k) => prefs.get(k).toString().contains('2017')), isFalse);
  });

  testWidgets('an adult birth year keeps online features', (tester) async {
    await openAgeScreen(tester);

    await pickYear(tester, 1990);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(container.read(ageGroupProvider), AgeGroup.teenOrAdult);
    expect(container.read(onlineAllowedProvider), isTrue);
  });

  testWidgets('the answer survives a restart and is not asked again', (tester) async {
    SharedPreferences.setMockInitialValues({'age_group': 'child'});
    final restarted = ProviderContainer();
    addTearDown(restarted.dispose);

    await restarted.read(ageGroupProvider.notifier).ready;
    expect(restarted.read(ageGroupProvider), AgeGroup.child);
  });
}
