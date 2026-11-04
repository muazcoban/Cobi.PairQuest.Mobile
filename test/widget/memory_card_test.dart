import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/domain/entities/card.dart';
import 'package:pair_quest/l10n/generated/app_localizations.dart';
import 'package:pair_quest/presentation/widgets/game/memory_card.dart';

void main() {
  const card = GameCard(
    id: '3f2a9c1e-7b4d-4e8a-9f00-1234567890ab',
    pairId: 'dog',
    imageAsset: '🐶',
    position: 6,
  );

  Widget host(GameCard card, {bool reduceMotion = false, Locale locale = const Locale('tr')}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Center(
          child: SizedBox(
            width: 60,
            height: 72,
            child: MemoryCard(card: card, row: 2, column: 3, onTap: () {}),
          ),
        ),
      ),
    );
  }

  testWidgets('VoiceOver reads the place on the board, not the card ID', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(card));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Satır 2, sütun 3, kapalı'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('3f2a')), findsNothing);
    semantics.dispose();
  });

  testWidgets('a face-up card names its picture, in English too', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(card.copyWith(state: CardState.revealed), locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Row 2, column 3, face up, 🐶'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('with Reduce Motion the card cross-fades instead of flipping', (tester) async {
    await tester.pumpWidget(host(card, reduceMotion: true));
    await tester.pumpWidget(host(card.copyWith(state: CardState.revealed), reduceMotion: true));

    expect(find.byType(AnimatedSwitcher), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('🐶'), findsOneWidget);
  });

  testWidgets('the picture ignores the Dynamic Type size', (tester) async {
    await tester.pumpWidget(host(card.copyWith(state: CardState.revealed), reduceMotion: true));
    await tester.pumpAndSettle();

    final emoji = tester.widget<Text>(find.text('🐶'));
    expect(emoji.textScaler, TextScaler.noScaling);
  });
}
