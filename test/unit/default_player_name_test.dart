import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/core/moderation/name_filter.dart';
import 'package:pair_quest/presentation/providers/settings_provider.dart';

void main() {
  test('unnamed players get a numbered name in their language', () {
    expect(SettingsNotifier.defaultPlayerName('tr'), matches(RegExp(r'^Oyuncu \d{4}$')));
    expect(SettingsNotifier.defaultPlayerName('en'), matches(RegExp(r'^Player \d{4}$')));
  });

  test('default names differ and pass the name filter', () {
    final names = {for (var i = 0; i < 50; i++) SettingsNotifier.defaultPlayerName('tr')};
    expect(names.length, greaterThan(40));
    expect(names.every(NameFilter.isAllowed), isTrue);
  });

  test('no default name trips the name filter, including digit lookalikes', () {
    expect(NameFilter.isAllowed('Oyuncu 7175'), isFalse, reason: '7175 reads as a slur');
    final names = [for (var i = 0; i < 5000; i++) SettingsNotifier.defaultPlayerName('en')];
    expect(names.every(NameFilter.isAllowed), isTrue);
  });
}
