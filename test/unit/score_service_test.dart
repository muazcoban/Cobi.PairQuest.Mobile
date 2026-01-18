import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/services/score_service.dart';

void main() {
  group('ScoreService', () {
    late ScoreService scoreService;

    setUp(() {
      scoreService = ScoreService();
    });

    group('calculateMatchPoints', () {
      test('returns negative points for mismatch', () {
        final result = scoreService.calculateMatchPoints(
          isMatch: false,
          currentCombo: 0,
          isFirstTry: false,
          difficulty: 'easy',
        );

        expect(result.isMatch, false);
        expect(result.points < 0, true);
        expect(result.newCombo, 0);
      });

      test('returns positive points for match', () {
        final result = scoreService.calculateMatchPoints(
          isMatch: true,
          currentCombo: 0,
          isFirstTry: false,
          difficulty: 'easy',
        );

        expect(result.isMatch, true);
        expect(result.points > 0, true);
        expect(result.newCombo, 1);
      });

      test('combo increases with consecutive matches', () {
        final result1 = scoreService.calculateMatchPoints(
          isMatch: true,
          currentCombo: 0,
          isFirstTry: false,
          difficulty: 'easy',
        );

        final result2 = scoreService.calculateMatchPoints(
          isMatch: true,
          currentCombo: result1.newCombo,
          isFirstTry: false,
          difficulty: 'easy',
        );

        expect(result2.newCombo > result1.newCombo, true);
        expect(result2.points > result1.points, true);
      });

      test('first try bonus adds extra points', () {
        final withoutFirstTry = scoreService.calculateMatchPoints(
          isMatch: true,
          currentCombo: 0,
          isFirstTry: false,
          difficulty: 'easy',
        );

        final withFirstTry = scoreService.calculateMatchPoints(
          isMatch: true,
          currentCombo: 0,
          isFirstTry: true,
          difficulty: 'easy',
        );

        expect(withFirstTry.points > withoutFirstTry.points, true);
      });
    });

    group('MatchResult', () {
      test('has correct properties', () {
        const result = MatchResult(
          isMatch: true,
          points: 100,
          newCombo: 1,
          bonuses: [],
        );

        expect(result.isMatch, true);
        expect(result.points, 100);
        expect(result.newCombo, 1);
        expect(result.bonuses, isEmpty);
      });
    });

    group('ScoreBonus', () {
      test('has correct properties', () {
        const bonus = ScoreBonus(
          type: 'combo',
          value: 50,
          label: '2x Combo!',
        );

        expect(bonus.type, 'combo');
        expect(bonus.value, 50);
        expect(bonus.label, '2x Combo!');
      });
    });
  });
}
