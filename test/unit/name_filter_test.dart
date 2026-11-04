import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/core/moderation/name_filter.dart';

void main() {
  group('NameFilter.isAllowed', () {
    test('allows ordinary names', () {
      for (final name in [
        'Ahmet', 'Ayşe Yılmaz', 'İlker', 'Işıl', 'Eksik Parça', 'Sikke Ustası',
        'Adam', 'Dickens', 'Scunthorpe', 'Peacock', 'Classic Player',
        'Therapist', 'Gotham', 'Hamza', 'OC Gamer', 'Player 1', '',
      ]) {
        expect(NameFilter.isAllowed(name), isTrue, reason: name);
      }
    });

    test('rejects profanity in Turkish and English', () {
      for (final name in [
        'orospu', 'Siktir Git', 'yarrak42', 'PEZEVENK', 'şerefsiz', 'göt',
        'fuck', 'Bitch Please', 'nigger', 'shit', 'Hitler',
      ]) {
        expect(NameFilter.isAllowed(name), isFalse, reason: name);
      }
    });

    test('sees through spacing, look-alike digits and repeated letters', () {
      for (final name in ['o r o s p u', 'f.u.c.k', 'b1tch', 'fuuuuck', r'$h1t', 'yarrrrak']) {
        expect(NameFilter.isAllowed(name), isFalse, reason: name);
      }
    });

    test('handles Turkish capital I and İ', () {
      expect(NameFilter.isAllowed('SİKTİR'), isFalse);
      expect(NameFilter.isAllowed('ŞEREFSIZ'), isFalse);
    });
  });
}
