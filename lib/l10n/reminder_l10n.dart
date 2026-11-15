import '../core/services/notification_service.dart';
import 'generated/app_localizations.dart';

/// The daily reminder's text for each weekday, Monday first, so the same
/// sentence does not arrive every day.
extension ReminderL10n on AppLocalizations {
  /// Players who have not signed in get one sign-in reminder a week, on
  /// Friday, about the leaderboard. HIG asks apps not to send promotional
  /// notifications without consent, so it stays at one day and about the game.
  /// Players under 13 ([onlineAllowed] false) have no sign-in, so their
  /// Friday reminder is about the levels instead.
  List<ReminderMessage> weeklyReminders({
    required bool signedIn,
    bool onlineAllowed = true,
  }) => [
    ReminderMessage(reminderRewardTitle, reminderRewardBody),
    ReminderMessage(reminderQuestsTitle, reminderQuestsBody, payload: 'quests'),
    ReminderMessage(reminderLevelTitle, reminderLevelBody),
    ReminderMessage(reminderRewardTitle, reminderStreakBody),
    if (signedIn)
      ReminderMessage(
        reminderRankTitle,
        reminderRankBody,
        payload: 'leaderboard',
      )
    else if (onlineAllowed)
      ReminderMessage(
        signInPromptTitle,
        reminderSignInBody,
        payload: 'leaderboard',
      )
    else
      ReminderMessage(reminderLevelTitle, reminderLevelBody),
    ReminderMessage(reminderFriendTitle, reminderFriendBody),
    ReminderMessage(reminderRewardTitle, reminderRewardBody),
  ];
}
