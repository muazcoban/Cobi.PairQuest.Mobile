import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/l10n/generated/app_localizations.dart';
import 'package:pair_quest/presentation/widgets/auth/account_name_dialog.dart';

void main() {
  Future<Future<String?>> pumpDialog(
    WidgetTester tester,
    String initialName,
  ) async {
    late Future<String?> result;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () {
              result = showDialog<String>(
                context: context,
                barrierDismissible: false,
                builder: (_) => AccountNameDialog(initialName: initialName),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('saves the local player name with one tap', (tester) async {
    final result = await pumpDialog(tester, 'Oyuncu');

    expect(find.text('Oyuncu adını seç'), findsOneWidget);
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(await result, 'Oyuncu');
  });

  testWidgets('returns the typed name without surrounding spaces', (
    tester,
  ) async {
    final result = await pumpDialog(tester, 'Oyuncu');

    await tester.enterText(find.byType(TextField), '  Muaz ');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(await result, 'Muaz');
  });

  testWidgets('does not accept an empty name', (tester) async {
    await pumpDialog(tester, 'Oyuncu');

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.byType(AccountNameDialog), findsOneWidget);
    expect(find.text('Adınızı girin'), findsWidgets);
  });

  testWidgets('does not accept a name the filter rejects', (tester) async {
    await pumpDialog(tester, 'Oyuncu');

    await tester.enterText(find.byType(TextField), 'ŞEREFSIZ');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.byType(AccountNameDialog), findsOneWidget);
    expect(
      find.text('Bu ad kullanılamaz. Başka bir ad seçin.'),
      findsOneWidget,
    );
  });
}
