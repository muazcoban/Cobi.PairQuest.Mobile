// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PairQuest';

  @override
  String get appSubtitle => 'Memory Matching Game';

  @override
  String get classicMode => 'Classic Mode';

  @override
  String get classicModeDesc => 'Play without time limit';

  @override
  String get timedMode => 'Timed Mode';

  @override
  String get timedModeDesc => 'Race against the clock';

  @override
  String get selectLevel => 'Select Level';

  @override
  String get selectLevelDesc => 'Choose your level';

  @override
  String get settings => 'Settings';

  @override
  String get level => 'Level';

  @override
  String levelNumber(int number) {
    return 'Level $number';
  }

  @override
  String get score => 'Score';

  @override
  String get moves => 'Moves';

  @override
  String get pairs => 'Pairs';

  @override
  String get remaining => 'Left';

  @override
  String get time => 'Time';

  @override
  String get combo => 'Combo';

  @override
  String get maxCombo => 'Max Combo';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get restart => 'Restart';

  @override
  String get quit => 'Quit';

  @override
  String get mainMenu => 'Main Menu';

  @override
  String get gamePaused => 'Game Paused';

  @override
  String get continueQuestion => 'Do you want to continue?';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String levelCompleted(int level) {
    return 'Level $level completed!';
  }

  @override
  String get perfectGame => 'Perfect Game!';

  @override
  String get playAgain => 'Play Again';

  @override
  String get nextLevel => 'Next Level';

  @override
  String get timeUp => 'Time\'s Up!';

  @override
  String get timeUpMessage => 'Unfortunately, time ran out.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get matched => 'Matched';

  @override
  String get tutorial => 'Tutorial';

  @override
  String get veryEasy => 'Very Easy';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get veryHard => 'Very Hard';

  @override
  String get expert => 'Expert';

  @override
  String get language => 'Language';

  @override
  String get turkish => 'Türkçe';

  @override
  String get english => 'English';

  @override
  String get sound => 'Sound';

  @override
  String get music => 'Music';

  @override
  String get vibration => 'Vibration';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemDefault => 'System Default';

  @override
  String get cardTheme => 'Card Theme';

  @override
  String get animals => 'Animals';

  @override
  String get fruits => 'Fruits';

  @override
  String get flags => 'Flags';

  @override
  String get sports => 'Sports';

  @override
  String get nature => 'Nature';

  @override
  String get travel => 'Transportation';

  @override
  String get food => 'Food';

  @override
  String get objects => 'Objects';

  @override
  String get stars => 'Stars';

  @override
  String get bestScore => 'Best Score';

  @override
  String get bestTime => 'Best Time';

  @override
  String get statistics => 'Statistics';

  @override
  String get totalGames => 'Total Games';

  @override
  String get gamesWon => 'Games Won';

  @override
  String get totalPlayTime => 'Total Play Time';

  @override
  String get locked => 'Locked';

  @override
  String get unlocked => 'Unlocked';

  @override
  String get overview => 'Overview';

  @override
  String get performance => 'Performance';

  @override
  String get records => 'Records';

  @override
  String get progress => 'Progress';

  @override
  String get playTime => 'Play Time';

  @override
  String get winRate => 'Win Rate';

  @override
  String get avgMoves => 'Avg. Moves';

  @override
  String get totalMatches => 'Total Matches';

  @override
  String get starsEarned => 'Stars Earned';

  @override
  String get highestCombo => 'Best Combo';

  @override
  String get longestStreak => 'Best Streak';

  @override
  String get perfectGames => 'Perfect Games';

  @override
  String get threeStarLevels => '3-Star Levels';

  @override
  String get levelProgress => 'Level Progress';

  @override
  String get achievements => 'Achievements';

  @override
  String get achievementUnlocked => 'Achievement Unlocked!';

  @override
  String achievementsEarned(Object count, Object total) {
    return '$count / $total Earned';
  }

  @override
  String get locked_achievement => 'Keep playing to unlock';

  @override
  String get dailyQuests => 'Daily Quests';

  @override
  String questsCompleted(Object count, Object total) {
    return '$count / $total Completed';
  }

  @override
  String get claimReward => 'Claim';

  @override
  String get claimed => 'Claimed';

  @override
  String questRefresh(Object hours, Object minutes) {
    return 'New quests in ${hours}h ${minutes}m';
  }

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get yourRank => 'Your Rank';

  @override
  String get topPlayers => 'Top Players';

  @override
  String get noScoresYet => 'No scores yet';

  @override
  String get dailyReward => 'Daily Reward';

  @override
  String get dailyRewardClaimed => 'Come back tomorrow!';

  @override
  String get claimDailyReward => 'Claim Your Reward';

  @override
  String streakBonus(Object day) {
    return 'Streak Bonus: Day $day';
  }
}
