import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/core/services/age_gate.dart';

void main() {
  final now = DateTime(2026, 11, 15);

  AgeGroup forYear(int year) => AgeGate.groupFor(birthYear: year, now: now);

  test('a birth year that is surely 13 or older opens online features', () {
    expect(forYear(2012), AgeGroup.teenOrAdult, reason: '13 or 14 in 2026');
    expect(forYear(1990), AgeGroup.teenOrAdult);
  });

  test('a birth year that may still be 12 counts as a child', () {
    expect(forYear(2013), AgeGroup.child, reason: '12 or 13 in 2026');
    expect(forYear(2018), AgeGroup.child);
    expect(forYear(2026), AgeGroup.child);
  });

  test('the picker goes back 100 years', () {
    expect(AgeGate.firstYear(now), 1926);
  });

  group('app store age range', () {
    AgeGroup? range(int? lower, int? upper) =>
        AgeGate.groupForStoreRange(ageLower: lower, ageUpper: upper);

    test('a range below 13 is a child, a range from 13 up is not', () {
      expect(range(0, 12), AgeGroup.child);
      expect(range(13, 15), AgeGroup.teenOrAdult);
      expect(range(18, null), AgeGroup.teenOrAdult);
    });

    test('a store that asks the user to verify first gives child mode', () {
      expect(AgeGate.groupForStoreRange(verificationRequired: true), AgeGroup.child);
    });

    test('a range across 13 or no range says nothing', () {
      expect(range(10, 17), isNull);
      expect(range(null, null), isNull);
    });
  });

  group('stored answer and store signal', () {
    test('the stricter one wins', () {
      expect(AgeGate.combine(stored: AgeGroup.teenOrAdult, store: AgeGroup.child), AgeGroup.child);
      expect(AgeGate.combine(stored: AgeGroup.child, store: AgeGroup.teenOrAdult), AgeGroup.child,
          reason: 'a child on a parent\'s phone stays a child');
    });

    test('either one alone is used', () {
      expect(AgeGate.combine(stored: null, store: AgeGroup.teenOrAdult), AgeGroup.teenOrAdult);
      expect(AgeGate.combine(stored: AgeGroup.teenOrAdult, store: null), AgeGroup.teenOrAdult);
      expect(AgeGate.combine(stored: null, store: null), isNull);
    });
  });
}
