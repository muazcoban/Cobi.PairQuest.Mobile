import 'package:flutter_test/flutter_test.dart';
import 'package:pair_quest/domain/entities/daily_quest.dart';
import 'package:pair_quest/l10n/quest_l10n.dart';

void main() {
  final quests = [
    ...QuestTemplates.easy,
    ...QuestTemplates.medium,
    ...QuestTemplates.hard,
  ];

  for (final languageCode in ['tr', 'en']) {
    test('every quest has a $languageCode name and description', () {
      for (final quest in quests) {
        expect(QuestTexts.title(quest.id, languageCode), isNot(quest.id),
            reason: quest.id);
        expect(QuestTexts.description(quest.id, languageCode), isNotEmpty,
            reason: quest.id);
      }
    });
  }
}
