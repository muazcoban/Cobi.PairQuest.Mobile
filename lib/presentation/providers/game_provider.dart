import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/game_config.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/utils/card_shuffle.dart';
import '../../domain/entities/card.dart';
import '../../domain/entities/game.dart';
import 'settings_provider.dart';

/// Game state for the provider
class GameStateData {
  final Game? currentGame;
  final List<GameCard> selectedCards;
  final bool isProcessing;
  final bool isLoading;
  final String? error;

  const GameStateData({
    this.currentGame,
    this.selectedCards = const [],
    this.isProcessing = false,
    this.isLoading = false,
    this.error,
  });

  GameStateData copyWith({
    Game? currentGame,
    List<GameCard>? selectedCards,
    bool? isProcessing,
    bool? isLoading,
    String? error,
  }) {
    return GameStateData(
      currentGame: currentGame ?? this.currentGame,
      selectedCards: selectedCards ?? this.selectedCards,
      isProcessing: isProcessing ?? this.isProcessing,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Game notifier for managing game state
class GameNotifier extends StateNotifier<GameStateData> {
  static const _uuid = Uuid();
  Timer? _timer;
  final AudioService _audioService;
  final HapticService _hapticService;
  final SettingsState _settings;

  GameNotifier(this._audioService, this._hapticService, this._settings)
      : super(const GameStateData()) {
    _audioService.setSoundEnabled(_settings.soundEnabled);
    _audioService.setMusicEnabled(_settings.musicEnabled);
    _hapticService.setEnabled(_settings.vibrationEnabled);
  }

  /// Starts a new game
  Future<void> startGame({
    required int level,
    GameMode mode = GameMode.classic,
    String theme = 'animals',
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get grid configuration for the level
      final gridConfig = GameConfig.levels.firstWhere(
        (l) => l.level == level,
        orElse: () => GameConfig.levels[4], // Default to level 5 (4x4)
      );

      final gridSize = GridSize(rows: gridConfig.rows, cols: gridConfig.cols);

      // Generate cards
      final cards = CardShuffle.generateCards(
        pairs: gridSize.pairs,
        theme: theme,
      );

      final game = Game(
        id: _uuid.v4(),
        mode: mode,
        level: level,
        gridSize: gridSize,
        cards: cards,
        state: GameState.inProgress,
        startTime: DateTime.now(),
        timeLimit: mode == GameMode.timed ? gridConfig.timeLimit : null,
        timeRemaining: mode == GameMode.timed ? gridConfig.timeLimit : null,
        theme: theme,
      );

      state = state.copyWith(
        currentGame: game,
        selectedCards: [],
        isProcessing: false,
        isLoading: false,
      );

      // Start background music if enabled
      if (_settings.musicEnabled) {
        _audioService.playBackgroundMusic();
      }

      // Start timer for timed mode
      if (mode == GameMode.timed) {
        _startTimer();
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Selects a card
  Future<void> selectCard(String cardId) async {
    if (state.isProcessing || state.currentGame == null) return;

    final game = state.currentGame!;
    if (!game.isPlayable) return;

    // Find the card
    final cardIndex = game.cards.indexWhere((c) => c.id == cardId);
    if (cardIndex == -1) return;

    final card = game.cards[cardIndex];

    // Check if card can be selected
    if (!_canSelectCard(card)) return;

    // Reveal the card
    final updatedCards = List<GameCard>.from(game.cards);
    updatedCards[cardIndex] = card.copyWith(state: CardState.revealed);

    final newSelectedCards = [...state.selectedCards, card];

    // Play flip sound and haptic
    _audioService.playSound(SoundEffect.cardFlip);
    _hapticService.cardFlip();

    state = state.copyWith(
      currentGame: game.copyWith(cards: updatedCards),
      selectedCards: newSelectedCards,
    );

    // Check for match if 2 cards are selected
    if (newSelectedCards.length == 2) {
      await _checkMatch(newSelectedCards[0], newSelectedCards[1]);
    }
  }

  /// Checks if two cards match
  Future<void> _checkMatch(GameCard card1, GameCard card2) async {
    state = state.copyWith(isProcessing: true);

    // Wait a bit to show the cards
    await Future.delayed(
      Duration(milliseconds: GameConfig.cardMatchDelay),
    );

    final game = state.currentGame!;
    final isMatch = card1.pairId == card2.pairId;

    final updatedCards = List<GameCard>.from(game.cards);

    if (isMatch) {
      // Mark cards as matched
      final index1 = updatedCards.indexWhere((c) => c.id == card1.id);
      final index2 = updatedCards.indexWhere((c) => c.id == card2.id);

      updatedCards[index1] = updatedCards[index1].copyWith(
        state: CardState.matched,
      );
      updatedCards[index2] = updatedCards[index2].copyWith(
        state: CardState.matched,
      );

      // Calculate points
      final newCombo = game.combo + 1;
      final points = _calculatePoints(combo: newCombo);

      var updatedGame = game.copyWith(
        cards: updatedCards,
        score: game.score + points,
        moves: game.moves + 1,
        matches: game.matches + 1,
        combo: newCombo,
        maxCombo: newCombo > game.maxCombo ? newCombo : game.maxCombo,
      );

      // Play match sound and haptic
      _audioService.playSound(SoundEffect.cardMatch);
      _hapticService.cardMatch();

      // Play combo sound for combos > 1
      if (newCombo > 1) {
        _audioService.playSound(SoundEffect.comboBonus);
      }

      // Check if game is completed
      if (updatedGame.isCompleted) {
        _stopTimer();
        updatedGame = updatedGame.copyWith(
          state: GameState.completed,
          endTime: DateTime.now(),
          // Add perfect game bonus
          score: updatedGame.isPerfectGame
              ? updatedGame.score + GameConfig.perfectGameBonus
              : updatedGame.score,
        );

        // Play level complete sound and haptic
        _audioService.playSound(SoundEffect.levelComplete);
        _hapticService.levelComplete();
      }

      state = state.copyWith(
        currentGame: updatedGame,
        selectedCards: [],
        isProcessing: false,
      );
    } else {
      // Hide cards again
      final index1 = updatedCards.indexWhere((c) => c.id == card1.id);
      final index2 = updatedCards.indexWhere((c) => c.id == card2.id);

      updatedCards[index1] = updatedCards[index1].copyWith(
        state: CardState.hidden,
      );
      updatedCards[index2] = updatedCards[index2].copyWith(
        state: CardState.hidden,
      );

      // Play mismatch sound and haptic
      _audioService.playSound(SoundEffect.cardMismatch);
      _hapticService.cardMismatch();

      state = state.copyWith(
        currentGame: game.copyWith(
          cards: updatedCards,
          moves: game.moves + 1,
          combo: 0,
          errors: game.errors + 1,
          score: (game.score - GameConfig.errorPenalty).clamp(0, game.score),
        ),
        selectedCards: [],
        isProcessing: false,
      );
    }
  }

  /// Calculates points for a match
  int _calculatePoints({required int combo}) {
    int points = GameConfig.matchPoints;

    // Combo bonus
    if (combo > 1) {
      points += (combo - 1) * GameConfig.comboBonus;
    }

    return points;
  }

  /// Checks if a card can be selected
  bool _canSelectCard(GameCard card) {
    if (card.state != CardState.hidden) return false;
    if (state.selectedCards.length >= 2) return false;
    if (state.selectedCards.any((c) => c.id == card.id)) return false;
    return true;
  }

  /// Pauses the game
  void pauseGame() {
    if (state.currentGame?.state != GameState.inProgress) return;

    _stopTimer();
    _audioService.pauseBackgroundMusic();
    state = state.copyWith(
      currentGame: state.currentGame!.copyWith(state: GameState.paused),
    );
  }

  /// Resumes the game
  void resumeGame() {
    if (state.currentGame?.state != GameState.paused) return;

    state = state.copyWith(
      currentGame: state.currentGame!.copyWith(state: GameState.inProgress),
    );

    _audioService.resumeBackgroundMusic();

    if (state.currentGame!.mode == GameMode.timed) {
      _startTimer();
    }
  }

  /// Resets the current game
  Future<void> resetGame() async {
    final game = state.currentGame;
    if (game == null) return;

    _stopTimer();
    await startGame(
      level: game.level,
      mode: game.mode,
      theme: game.theme,
    );
  }

  /// Ends the current game
  void endGame() {
    _stopTimer();
    _audioService.stopBackgroundMusic();
    state = const GameStateData();
  }

  /// Starts the timer for timed mode
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final game = state.currentGame;
      if (game == null || game.state != GameState.inProgress) {
        _stopTimer();
        return;
      }

      final newTimeRemaining = (game.timeRemaining ?? 0) - 1;

      if (newTimeRemaining <= 0) {
        // Time's up!
        _stopTimer();

        // Play game over sound
        _audioService.playSound(SoundEffect.gameOver);
        _hapticService.trigger(HapticType.heavy);

        state = state.copyWith(
          currentGame: game.copyWith(
            state: GameState.failed,
            timeRemaining: 0,
            endTime: DateTime.now(),
          ),
        );
      } else {
        state = state.copyWith(
          currentGame: game.copyWith(timeRemaining: newTimeRemaining),
        );
      }
    });
  }

  /// Stops the timer
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

/// Provider for the game state
final gameProvider = StateNotifierProvider<GameNotifier, GameStateData>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final hapticService = ref.watch(hapticServiceProvider);
  final settings = ref.watch(settingsProvider);

  return GameNotifier(audioService, hapticService, settings);
});

/// Provider for just the current game
final currentGameProvider = Provider<Game?>((ref) {
  return ref.watch(gameProvider).currentGame;
});

/// Provider for checking if game is in progress
final isGameInProgressProvider = Provider<bool>((ref) {
  final game = ref.watch(currentGameProvider);
  return game?.state == GameState.inProgress;
});
