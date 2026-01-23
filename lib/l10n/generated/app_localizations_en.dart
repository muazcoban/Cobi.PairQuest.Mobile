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
  String get randomTheme => 'Random';

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
  String get playGamesToSeeScores => 'Play games to see your scores!';

  @override
  String get allLevels => 'All Levels';

  @override
  String get you => 'You';

  @override
  String get playerName => 'Player Name';

  @override
  String get tapToChange => 'Tap to change';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

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

  @override
  String get memorize => 'Memorize!';

  @override
  String get localMultiplayer => 'Local Multiplayer';

  @override
  String get localMultiplayerDesc => 'Play with friends';

  @override
  String get playerCount => 'Number of Players';

  @override
  String get players => 'Players';

  @override
  String get startGame => 'Start Game';

  @override
  String get yourTurn => 'Your Turn';

  @override
  String get gameOver => 'Game Over';

  @override
  String get wins => 'wins';

  @override
  String get player => 'Player';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get signInToSaveProgress =>
      'Sign in to save your progress and compete on leaderboards';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get account => 'Account';

  @override
  String get guest => 'Guest';

  @override
  String get linkAccount => 'Link Account';

  @override
  String get linkAccountDesc => 'Link your account to save progress';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get accountLinked => 'Account linked successfully!';

  @override
  String get signInRequired => 'Sign in required';

  @override
  String get signInToSubmitScore =>
      'Sign in to submit your score to the global leaderboard';

  @override
  String get globalLeaderboard => 'Global Leaderboard';

  @override
  String get localLeaderboard => 'Local Scores';

  @override
  String get notifications => 'Notifications';

  @override
  String get dailyReminder => 'Daily Reminder';

  @override
  String get dailyReminderDesc => 'Remind me to play';

  @override
  String get achievementAlerts => 'Achievement Alerts';

  @override
  String get achievementAlertsDesc => 'Notify when achievements unlock';

  @override
  String get questAlerts => 'Quest Alerts';

  @override
  String get questAlertsDesc => 'Notify when quests complete';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get coins => 'Coins';

  @override
  String get gems => 'Gems';

  @override
  String get wallet => 'Wallet';

  @override
  String get notEnoughCoins => 'Not enough coins';

  @override
  String get notEnoughGems => 'Not enough gems';

  @override
  String get purchase => 'Purchase';

  @override
  String get purchaseSuccess => 'Purchase successful!';

  @override
  String get powerUps => 'Power-Ups';

  @override
  String get powerUpPeek => 'Peek';

  @override
  String get powerUpPeekDesc => 'Show all cards for a few seconds';

  @override
  String get powerUpFreeze => 'Freeze';

  @override
  String get powerUpFreezeDesc => 'Pause the timer for 10 seconds';

  @override
  String get powerUpHint => 'Hint';

  @override
  String get powerUpHintDesc => 'Highlight a matching pair';

  @override
  String get powerUpShuffle => 'Shuffle';

  @override
  String get powerUpShuffleDesc => 'Reshuffle unmatched cards';

  @override
  String get powerUpTimeBonus => 'Time Bonus';

  @override
  String get powerUpTimeBonusDesc => 'Add extra time';

  @override
  String get powerUpMagnet => 'Magnet';

  @override
  String get powerUpMagnetDesc => 'Next card automatically finds its match';

  @override
  String get powerUpUsed => 'Power-up used!';

  @override
  String powerUpActive(Object seconds) {
    return 'Active: ${seconds}s';
  }

  @override
  String get powerUpLimitReached => 'Limit reached for this game';

  @override
  String get timedModeOnly => 'Only available in Timed Mode';

  @override
  String get buyPowerUp => 'Buy Power-Up';

  @override
  String get usePowerUp => 'Use';

  @override
  String owned(Object count) {
    return 'Owned: $count';
  }

  @override
  String get shop => 'Shop';

  @override
  String get inventory => 'Inventory';

  @override
  String get emptyInventory => 'No power-ups yet';
}
