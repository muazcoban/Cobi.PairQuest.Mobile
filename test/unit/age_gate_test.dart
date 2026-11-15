import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/core/services/age_gate.dart';

void main() {
  final now = DateTime(2026, 11, 15);

  AgeGroup group(int year) => AgeGate.groupFor(birthYear: year, now: now);

  test('a birth year that is surely 13 or older opens online features', () {
    expect(group(2012), AgeGroup.teenOrAdult, reason: '13 or 14 in 2026');
    expect(group(1990), AgeGroup.teenOrAdult);
  });

  test('a birth year that may still be 12 counts as a child', () {
    expect(group(2013), AgeGroup.child, reason: '12 or 13 in 2026');
    expect(group(2018), AgeGroup.child);
    expect(group(2026), AgeGroup.child);
  });

  test('the picker goes back 100 years', () {
    expect(AgeGate.firstYear(now), 1926);
  });
}
