import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/daily_quest.dart';
import '../../domain/entities/power_up.dart';

/// Provider for daily quests
final dailyQuestProvider =
    StateNotifierProvider<DailyQuestNotifier, DailyQuestsData>((ref) {
  return DailyQuestNotifier();
});

/// Notifier for managing daily quests
class DailyQuestNotifier extends StateNotifier<DailyQuestsData> {
  static const String _storageKey = 'daily_quests';
  final Random _random = Random();

  // Track daily progress
  int _todayGamesPlayed = 0;
  int _todayGamesWon = 0;
  int _todayMatchesMade = 0;
  int _todayHighestCombo = 0;
  int _todayPerfectGames = 0;
  int _todayStarsEarned = 0;
  int _todayPowerUpsUsed = 0;
  int _todayWinsWithoutPowerUp = 0;
  int _todayTimedModeWins = 0;

  DailyQuestNotifier()
      : super(DailyQuestsData(
          date: DateTime.now(),
          quests: const [],
        )) {
    _loadQuests();
  }

  /// Load quests from local storage
  Future<void> _loadQuests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final questsJson = prefs.getString(_storageKey);

      if (questsJson != null) {
        final data = jsonDecode(questsJson) as Map<String, dynamic>;
        final savedDate = DateTime.parse(data['date']);

        // Check if we need new quests (new day)
        final now = DateTime.now();
        if (savedDate.year == now.year &&
            savedDate.month == now.month &&
            savedDate.day == now.day) {
          // Load saved quests
          final questsData = (data['quests'] as List<dynamic>?) ?? [];
          final quests = _reconstructQuests(questsData);

          final progressMap = <String, QuestProgress>{};
          if (data['progress'] != null) {
            (data['progress'] as Map<String, dynamic>).forEach((key, value) {
              progressMap[key] = QuestProgress.fromJson(value);
            });
          }

          // Load daily counters
          _todayGamesPlayed = data['todayGamesPlayed'] ?? 0;
          _todayGamesWon = data['todayGamesWon'] ?? 0;
          _todayMatchesMade = data['todayMatchesMade'] ?? 0;
          _todayHighestCombo = data['todayHighestCombo'] ?? 0;
          _todayPerfectGames = data['todayPerfectGames'] ?? 0;
          _todayStarsEarned = data['todayStarsEarned'] ?? 0;
          _todayPowerUpsUsed = data['todayPowerUpsUsed'] ?? 0;
          _todayWinsWithoutPowerUp = data['todayWinsWithoutPowerUp'] ?? 0;
          _todayTimedModeWins = data['todayTimedModeWins'] ?? 0;

          state = DailyQuestsData(
            date: savedDate,
            quests: quests,
            progress: progressMap,
          );
          return;
        }
      }

      // Generate new quests for today
      _generateNewQuests();
    } catch (e) {
      _generateNewQuests();
    }
  }

  /// Reconstruct quest objects from saved data
  List<DailyQuest> _reconstructQuests(List<dynamic> questsData) {
    final allTemplates = [
      ...QuestTemplates.easy,
      ...QuestTemplates.medium,
      ...QuestTemplates.hard,
    ];

    return questsData.map((q) {
      final id = q['id'] as String;
      return allTemplates.firstWhere(
        (t) => t.id == id,
        orElse: () => QuestTemplates.easy.first,
      );
    }).toList();
  }

  /// Generate new daily quests
  void _generateNewQuests() {
    // Reset daily counters
    _todayGamesPlayed = 0;
    _todayGamesWon = 0;
    _todayMatchesMade = 0;
    _todayHighestCombo = 0;
    _todayPerfectGames = 0;
    _todayStarsEarned = 0;
    _todayPowerUpsUsed = 0;
    _todayWinsWithoutPowerUp = 0;
    _todayTimedModeWins = 0;

    // Select random quests
    final quests = <DailyQuest>[];

    // One easy quest
    quests.add(QuestTemplates.easy[_random.nextInt(QuestTemplates.easy.length)]);

    // One medium quest
    quests.add(QuestTemplates.medium[_random.nextInt(QuestTemplates.medium.length)]);

    // One hard quest
    quests.add(QuestTemplates.hard[_random.nextInt(QuestTemplates.hard.length)]);

    // Initialize progress
    final progress = <String, QuestProgress>{};
    for (final quest in quests) {
      progress[quest.id] = QuestProgress(questId: quest.id);
    }

    state = DailyQuestsData(
      date: DateTime.now(),
      quests: quests,
      progress: progress,
    );

    _saveQuests();
  }

  /// Save quests to local storage
  Future<void> _saveQuests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'date': state.date.toIso8601String(),
        'quests': state.quests.map((q) => {
          'id': q.id,
          'type': q.type.index,
          'targetValue': q.targetValue,
          'rewardPoints': q.rewardPoints,
        }).toList(),
        'progress': state.progress.map((key, value) => MapEntry(key, value.toJson())),
        'todayGamesPlayed': _todayGamesPlayed,
        'todayGamesWon': _todayGamesWon,
        'todayMatchesMade': _todayMatchesMade,
        'todayHighestCombo': _todayHighestCombo,
        'todayPerfectGames': _todayPerfectGames,
        'todayStarsEarned': _todayStarsEarned,
        'todayPowerUpsUsed': _todayPowerUpsUsed,
        'todayWinsWithoutPowerUp': _todayWinsWithoutPowerUp,
        'todayTimedModeWins': _todayTimedModeWins,
      };
      await prefs.setString(_storageKey, jsonEncode(data));
    } catch (e) {
      // Ignore save errors
    }
  }

  /// Update quest progress after a game
  void recordGameResult({
    required bool won,
    required int matches,
    required int maxCombo,
    required bool isPerfect,
    required int starsEarned,
    int powerUpsUsed = 0,
    bool isTimedMode = false,
  }) {
    // Check if quests need refresh
    if (state.needsRefresh) {
      _generateNewQuests();
      return;
    }

    // Update daily counters
    _todayGamesPlayed++;
    if (won) _todayGamesWon++;
    _todayMatchesMade += matches;
    if (maxCombo > _todayHighestCombo) _todayHighestCombo = maxCombo;
    if (isPerfect) _todayPerfectGames++;
    _todayStarsEarned += starsEarned;
    _todayPowerUpsUsed += powerUpsUsed;
    if (won && powerUpsUsed == 0) _todayWinsWithoutPowerUp++;
    if (won && isTimedMode) _todayTimedModeWins++;

    // Update quest progress
    final newProgress = Map<String, QuestProgress>.from(state.progress);

    for (final quest in state.quests) {
      if (newProgress[quest.id]?.isCompleted ?? false) continue;

      int currentValue = 0;
      switch (quest.type) {
        case QuestType.playGames:
          currentValue = _todayGamesPlayed;
          break;
        case QuestType.winGames:
          currentValue = _todayGamesWon;
          break;
        case QuestType.makeMatches:
          currentValue = _todayMatchesMade;
          break;
        case QuestType.getCombo:
          currentValue = _todayHighestCombo;
          break;
        case QuestType.perfectGame:
          currentValue = _todayPerfectGames;
          break;
        case QuestType.earnStars:
          currentValue = _todayStarsEarned;
          break;
        case QuestType.usePowerUps:
          currentValue = _todayPowerUpsUsed;
          break;
        case QuestType.winWithoutPowerUp:
          currentValue = _todayWinsWithoutPowerUp;
          break;
        case QuestType.timedModeWin:
          currentValue = _todayTimedModeWins;
          break;
      }

      final isCompleted = currentValue >= quest.targetValue;
      newProgress[quest.id] = QuestProgress(
        questId: quest.id,
        currentValue: currentValue,
        isCompleted: isCompleted,
        isRewardClaimed: newProgress[quest.id]?.isRewardClaimed ?? false,
      );
    }

    state = state.copyWith(progress: newProgress);
    _saveQuests();
  }

  /// Claim reward for completed quest
  /// Returns a record with (coins, powerUpType, powerUpQuantity)
  ({int coins, PowerUpType? powerUp, int powerUpQuantity}) claimReward(String questId) {
    final quest = state.quests.firstWhere(
      (q) => q.id == questId,
      orElse: () => QuestTemplates.easy.first,
    );

    final progress = state.progress[questId];
    if (progress == null || !progress.isCompleted || progress.isRewardClaimed) {
      return (coins: 0, powerUp: null, powerUpQuantity: 0);
    }

    final newProgress = Map<String, QuestProgress>.from(state.progress);
    newProgress[questId] = progress.copyWith(isRewardClaimed: true);

    state = state.copyWith(progress: newProgress);
    _saveQuests();

    return (
      coins: quest.rewardPoints,
      powerUp: quest.rewardPowerUp,
      powerUpQuantity: quest.rewardPowerUpQuantity,
    );
  }

  /// Check if quests need refresh and refresh if needed
  void checkAndRefresh() {
    if (state.needsRefresh) {
      _generateNewQuests();
    }
  }

  /// Get quest progress by id
  QuestProgress getProgress(String questId) {
    return state.progress[questId] ?? QuestProgress(questId: questId);
  }
}
