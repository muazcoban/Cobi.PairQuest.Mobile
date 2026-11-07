import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/l10n/generated/app_localizations.dart';
import 'package:pair_quest/l10n/reminder_l10n.dart';

void main() {
  final tr = lookupAppLocalizations(const Locale('tr'));

  test('one reminder per weekday', () {
    expect(tr.weeklyReminders(signedIn: false), hasLength(7));
  });

  test('only Friday asks a signed-out player to sign in', () {
    final reminders = tr.weeklyReminders(signedIn: false);

    final signInDays = [
      for (var i = 0; i < reminders.length; i++)
        if (reminders[i].body == tr.reminderSignInBody) i,
    ];
    expect(signInDays, [4]);
    expect(reminders[4].payload, 'leaderboard');
  });

  test('a signed-in player never gets the sign-in reminder', () {
    final reminders = tr.weeklyReminders(signedIn: true);

    expect(reminders.map((r) => r.body), isNot(contains(tr.reminderSignInBody)));
  });
}
