import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/presentation/widgets/home/sign_in_prompt_card.dart';

void main() {
  final now = DateTime(2026, 11, 7, 12);

  test('shows when it was never dismissed', () {
    expect(SignInPromptCard.isDue(null, now), isTrue);
  });

  test('stays hidden for a week after it is dismissed', () {
    expect(SignInPromptCard.isDue(now.subtract(const Duration(days: 6)), now), isFalse);
    expect(SignInPromptCard.isDue(now.subtract(const Duration(days: 7)), now), isTrue);
  });
}
