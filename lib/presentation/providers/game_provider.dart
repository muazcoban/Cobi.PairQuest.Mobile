import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/game_config.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/utils/card_shuffle.dart';
import '../../domain/entities/card.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/power_up.dart';
import 'power_up_provider.dart';
import 'settings_provider.dart';

/// Game state for the provider
class GameStateData {
  final Game? currentGame;
  final List<GameCard> selectedCards;
  final bool isProcessing;
  final bool isLoading;
  final String? error;
  final double previewProgress; // 0.0 to 1.0 for countdown animation
  final bool showTurnTransition; // Show turn change overlay
  final Set<String> hintedCardIds; // Cards highlighted by hint power-up
  final bool magnetActive; // Magnet power-up active for next selection
  final bool timerFrozen; // Timer is frozen by freeze power-up

  const GameStateData({
    this.currentGame,
    this.selectedCards = const [],
    this.isProcessing = false,
    this.isLoading = false,
    this.error,
    this.previewProgress = 0.0,
    this.showTurnTransition = false,
    this.hintedCardIds = const {},
    this.magnetActive = false,
    this.timerFrozen = false,
  });

  GameStateData copyWith({
    Game? currentGame,
    List<GameCard>? selectedCards,
    bool? isProcessing,
    bool? isLoading,
    String? error,
    double? previewProgress,
    bool? showTurnTransition,
    Set<String>? hintedCardIds,
    bool? magnetActive,
    bool? timerFrozen,
  }) {
    return GameStateData(
      currentGame: currentGame ?? this.currentGame,
      selectedCards: selectedCards ?? this.selectedCards,
      isProcessing: isProcessing ?? this.isProcessing,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      previewProgress: previewProgress ?? this.previewProgress,
      showTurnTransition: showTurnTransition ?? this.showTurnTransition,
      hintedCardIds: hintedCardIds ?? this.hintedCardIds,
      magnetActive: magnetActive ?? this.magnetActive,
      timerFrozen: timerFrozen ?? this.timerFrozen,
    );
  }
}

/// Game notifier for managing game state
class GameNotifier extends StateNotifier<GameStateData> {
  static const _uuid = Uuid();
  Timer? _timer;
  Timer? _previewTimer;
  Timer? _peekTimer;
  Timer? _freezeTimer;
  Timer? _hintTimer;
  final AudioService _audioService;
  final HapticService _hapticService;
  final SettingsState _settings;
  final SettingsNotifier _settingsNotifier;
  final Ref _ref;

  /// Preview duration constants
  static const int _maxPreviewDurationMs = 2000; // Max 2 seconds
  static const int _minPreviewDurationMs = 800;  // Min 0.8 seconds
  static const int _previewUpdateIntervalMs = 50; // Update every 50ms for smooth animation

  GameNotifier(this._audioService, this._hapticService, this._settings, this._settingsNotifier, this._ref)
      : super(const GameStateData()) {
    _audioService.setSoundEnabled(_settings.soundEnabled);
    _audioService.setMusicEnabled(_settings.musicEnabled);
    _hapticService.setEnabled(_settings.vibrationEnabled);
  }

  /// Calculate preview duration based on card count
  /// Fewer cards = shorter preview, more cards = longer preview (max 2 sec)
  int _calculatePreviewDuration(int totalCards) {
    // Scale from 800ms (4 cards) to 2000ms (64 cards)
    // Formula: 800 + (cards - 4) * (1200 / 60)
    final duration = _minPreviewDurationMs +
        ((totalCards - 4) * (_maxPreviewDurationMs - _minPreviewDurationMs) / 60).round();
    return duration.clamp(_minPreviewDurationMs, _maxPreviewDurationMs);
  }

  /// Starts a new game
  Future<void> startGame({
    required int level,
    GameMode mode = GameMode.classic,
    String theme = 'animals',
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Handle random theme selection
      String actualTheme = theme;
      if (theme == 'random') {
        final lastTheme = await _settingsNotifier.getLastRandomTheme();
        actualTheme = CardShuffle.getRandomTheme(excludeTheme: lastTheme);
        await _settingsNotifier.setLastRandomTheme(actualTheme);
      }

      // Get grid configuration for the level
      final gridConfig = GameConfig.levels.firstWhere(
        (l) => l.level == level,
        orElse: () => GameConfig.levels[4], // Default to level 5 (4x4)
      );

      final gridSize = GridSize(rows: gridConfig.rows, cols: gridConfig.cols);

      // Generate cards - initially all hidden
      final cards = CardShuffle.generateCards(
        pairs: gridSize.pairs,
        theme: actualTheme,
      );

      final game = Game(
        id: _uuid.v4(),
        mode: mode,
        level: level,
        gridSize: gridSize,
        cards: cards,
        state: GameState.preview, // Start in preview state
        startTime: DateTime.now(),
        timeLimit: mode == GameMode.timed ? gridConfig.timeLimit : null,
        timeRemaining: mode == GameMode.timed ? gridConfig.timeLimit : null,
        theme: actualTheme,
      );

      state = state.copyWith(
        currentGame: game,
        selectedCards: [],
        isProcessing: false,
        isLoading: false,
        previewProgress: 1.0, // Start at 100%
      );

      // Start background music if enabled
      if (_settings.musicEnabled) {
        _audioService.playBackgroundMusic();
      }

      // Start sequential card reveal animation
      _startSequentialReveal(gridSize.totalCards, mode);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Starts a new multiplayer game
  Future<void> startMultiplayerGame({
    required int level,
    required List<String> playerNames,
    String theme = 'animals',
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Handle random theme selection
      String actualTheme = theme;
      if (theme == 'random') {
        final lastTheme = await _settingsNotifier.getLastRandomTheme();
        actualTheme = CardShuffle.getRandomTheme(excludeTheme: lastTheme);
        await _settingsNotifier.setLastRandomTheme(actualTheme);
      }

      // Get grid configuration for the level
      final gridConfig = GameConfig.levels.firstWhere(
        (l) => l.level == level,
        orElse: () => GameConfig.levels[4],
      );

      final gridSize = GridSize(rows: gridConfig.rows, cols: gridConfig.cols);

      // Generate cards
      final cards = CardShuffle.generateCards(
        pairs: gridSize.pairs,
        theme: actualTheme,
      );

      // Create players
      final players = playerNames.asMap().entries.map((entry) {
        return Player(
          id: _uuid.v4(),
          name: entry.value,
          colorIndex: entry.key,
        );
      }).toList();

      final game = Game(
        id: _uuid.v4(),
        mode: GameMode.multiplayer,
        level: level,
        gridSize: gridSize,
        cards: cards,
        state: GameState.preview,
        startTime: DateTime.now(),
        theme: actualTheme,
        players: players,
        currentPlayerIndex: 0,
      );

      state = state.copyWith(
        currentGame: game,
        selectedCards: [],
        isProcessing: false,
        isLoading: false,
        previewProgress: 1.0,
        showTurnTransition: false,
      );

      // Start background music if enabled
      if (_settings.musicEnabled) {
        _audioService.playBackgroundMusic();
      }

      // Start sequential card reveal animation
      _startSequentialReveal(gridSize.totalCards, GameMode.multiplayer);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Reveal cards one by one with sound, then hide them
  void _startSequentialReveal(int totalCards, GameMode mode) {
    _previewTimer?.cancel();

    // Calculate delay per card (faster for more cards)
    // 4 cards: 80ms each, 64 cards: 30ms each
    final delayPerCard = (80 - (totalCards - 4) * 0.83).clamp(30, 80).toInt();
    var currentCardIndex = 0;

    // Phase 1: Reveal cards one by one
    _previewTimer = Timer.periodic(
      Duration(milliseconds: delayPerCard),
      (timer) {
        final game = state.currentGame;
        if (game == null) {
          timer.cancel();
          return;
        }

        if (currentCardIndex < totalCards) {
          // Reveal the next card
          final updatedCards = List<GameCard>.from(game.cards);
          updatedCards[currentCardIndex] = updatedCards[currentCardIndex].copyWith(
            state: CardState.revealed,
          );

          // Play flip sound for each card (light haptic for every 3rd card)
          _audioService.playSound(SoundEffect.cardFlip);
          if (currentCardIndex % 3 == 0) {
            _hapticService.trigger(HapticType.light);
          }

          // Update progress
          final progress = 1.0 - (currentCardIndex / totalCards * 0.5);

          state = state.copyWith(
            currentGame: game.copyWith(cards: updatedCards),
            previewProgress: progress,
          );

          currentCardIndex++;
        } else {
          // All cards revealed, start countdown then hide
          timer.cancel();
          _startPreviewCountdown(totalCards, mode);
        }
      },
    );
  }

  /// Starts the preview countdown after all cards are revealed
  void _startPreviewCountdown(int totalCards, GameMode mode) {
    _previewTimer?.cancel();

    // Show cards for a moment before hiding
    final showDurationMs = _calculatePreviewDuration(totalCards) ~/ 2;
    final totalSteps = showDurationMs ~/ _previewUpdateIntervalMs;
    var currentStep = 0;

    _previewTimer = Timer.periodic(
      Duration(milliseconds: _previewUpdateIntervalMs),
      (timer) {
        currentStep++;
        final progress = 0.5 - (currentStep / totalSteps * 0.5);

        if (currentStep >= totalSteps) {
          // Preview complete - hide all cards sequentially
          timer.cancel();
          _previewTimer = null;
          _startSequentialHide(totalCards, mode);
        } else {
          // Update preview progress for animation
          state = state.copyWith(previewProgress: progress.clamp(0.0, 1.0));
        }
      },
    );
  }

  /// Hide cards one by one, then start the game
  void _startSequentialHide(int totalCards, GameMode mode) {
    _previewTimer?.cancel();

    // Faster hide animation
    final delayPerCard = (50 - (totalCards - 4) * 0.5).clamp(20, 50).toInt();
    var currentCardIndex = 0;

    _previewTimer = Timer.periodic(
      Duration(milliseconds: delayPerCard),
      (timer) {
        final game = state.currentGame;
        if (game == null) {
          timer.cancel();
          return;
        }

        if (currentCardIndex < totalCards) {
          // Hide the next card
          final updatedCards = List<GameCard>.from(game.cards);
          updatedCards[currentCardIndex] = updatedCards[currentCardIndex].copyWith(
            state: CardState.hidden,
          );

          // Play flip sound for each card
          _audioService.playSound(SoundEffect.cardFlip);

          state = state.copyWith(
            currentGame: game.copyWith(cards: updatedCards),
          );

          currentCardIndex++;
        } else {
          // All cards hidden, start the game
          timer.cancel();
          _previewTimer = null;
          _endPreviewAndStartGame(mode);
        }
      },
    );
  }

  /// Ends the preview phase and starts the actual game
  void _endPreviewAndStartGame(GameMode mode) {
    final game = state.currentGame;
    if (game == null) return;

    // Play a sound to indicate game start
    _hapticService.trigger(HapticType.medium);

    state = state.copyWith(
      currentGame: game.copyWith(
        state: GameState.inProgress,
      ),
      previewProgress: 0.0,
    );

    // Start timer for timed mode
    if (mode == GameMode.timed) {
      _startTimer();
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

    // Clear hint if this card was hinted
    _clearHintIfNeeded(cardId);

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

    // Check for magnet power-up (only on first card selection)
    if (state.magnetActive && newSelectedCards.length == 1) {
      state = state.copyWith(magnetActive: false);
      await _handleMagnetMatch(card);
      return;
    }

    // Check for match if 2 cards are selected
    if (newSelectedCards.length == 2) {
      await _checkMatch(newSelectedCards[0], newSelectedCards[1]);
    }
  }

  /// Checks if two cards match
  Future<void> _checkMatch(GameCard card1, GameCard card2) async {
    state = state.copyWith(isProcessing: true);

    final game = state.currentGame!;
    final isMatch = card1.pairId == card2.pairId;

    // Only wait for mismatch - matches feel snappier without delay
    if (!isMatch) {
      await Future.delayed(
        Duration(milliseconds: GameConfig.cardMatchDelay),
      );
    }
    final isMultiplayer = game.isMultiplayer;

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
      final newCombo = isMultiplayer
          ? (game.currentPlayer?.combo ?? 0) + 1
          : game.combo + 1;
      final points = _calculatePoints(combo: newCombo);

      var updatedGame = game;

      if (isMultiplayer) {
        // Update current player's stats
        final updatedPlayers = _updateCurrentPlayerStats(
          game,
          scoreAdd: points,
          matchesAdd: 1,
          movesAdd: 1,
          newCombo: newCombo,
        );

        updatedGame = game.copyWith(
          cards: updatedCards,
          matches: game.matches + 1,
          players: updatedPlayers,
          extraTurnAwarded: true, // Player gets another turn
        );
      } else {
        updatedGame = game.copyWith(
          cards: updatedCards,
          score: game.score + points,
          moves: game.moves + 1,
          matches: game.matches + 1,
          combo: newCombo,
          maxCombo: newCombo > game.maxCombo ? newCombo : game.maxCombo,
        );
      }

      // Play match sound and haptic
      _audioService.playSound(SoundEffect.cardMatch);
      _hapticService.cardMatch();

      // Play combo sound for combos > 1
      if (newCombo > 1) {
        _audioService.playSound(SoundEffect.comboBonus);
      }

      // Check if game is completed (for both single and multiplayer)
      final totalMatches = isMultiplayer
          ? updatedGame.totalMultiplayerMatches
          : updatedGame.matches;

      final isGameCompleted = totalMatches >= game.gridSize.pairs;

      if (isGameCompleted) {
        _stopTimer();
        // Update state with matched cards but keep game in progress for now
        state = state.copyWith(
          currentGame: updatedGame,
          selectedCards: [],
          isProcessing: false,
        );

        // Play level complete sound and haptic
        _audioService.playSound(SoundEffect.levelComplete);
        _hapticService.levelComplete();

        // Delay before showing completion popup for better UX
        await Future.delayed(
          Duration(milliseconds: GameConfig.gameCompletionDelay),
        );

        // Now mark as completed
        if (mounted) {
          state = state.copyWith(
            currentGame: updatedGame.copyWith(
              state: GameState.completed,
              endTime: DateTime.now(),
              // Add perfect game bonus for single player only
              score: !isMultiplayer && updatedGame.isPerfectGame
                  ? updatedGame.score + GameConfig.perfectGameBonus
                  : updatedGame.score,
            ),
          );
        }
      } else {
        state = state.copyWith(
          currentGame: updatedGame,
          selectedCards: [],
          isProcessing: false,
        );
      }
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

      if (isMultiplayer) {
        // Update current player's stats and switch turn
        final updatedPlayers = _updateCurrentPlayerStats(
          game,
          movesAdd: 1,
          errorsAdd: 1,
          resetCombo: true,
        );

        final nextPlayerIndex = (game.currentPlayerIndex + 1) % game.playerCount;

        state = state.copyWith(
          currentGame: game.copyWith(
            cards: updatedCards,
            players: updatedPlayers,
            currentPlayerIndex: nextPlayerIndex,
            extraTurnAwarded: false,
          ),
          selectedCards: [],
          isProcessing: false,
          showTurnTransition: true,
        );

        // Hide turn transition after delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            state = state.copyWith(showTurnTransition: false);
          }
        });
      } else {
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
  }

  /// Updates the current player's stats in multiplayer mode
  List<Player> _updateCurrentPlayerStats(
    Game game, {
    int scoreAdd = 0,
    int matchesAdd = 0,
    int movesAdd = 0,
    int errorsAdd = 0,
    int? newCombo,
    bool resetCombo = false,
  }) {
    if (!game.isMultiplayer || game.players == null) return [];

    final players = List<Player>.from(game.players!);
    final currentPlayer = players[game.currentPlayerIndex];

    final updatedCombo = resetCombo ? 0 : (newCombo ?? currentPlayer.combo);

    players[game.currentPlayerIndex] = currentPlayer.copyWith(
      score: currentPlayer.score + scoreAdd,
      matches: currentPlayer.matches + matchesAdd,
      moves: currentPlayer.moves + movesAdd,
      errors: currentPlayer.errors + errorsAdd,
      combo: updatedCombo,
      maxCombo: updatedCombo > currentPlayer.maxCombo
          ? updatedCombo
          : currentPlayer.maxCombo,
    );

    return players;
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
    _stopAllPowerUpTimers();

    if (game.isMultiplayer && game.players != null) {
      // Reset multiplayer game with same players
      await startMultiplayerGame(
        level: game.level,
        playerNames: game.players!.map((p) => p.name).toList(),
        theme: game.theme,
      );
    } else {
      await startGame(
        level: game.level,
        mode: game.mode,
        theme: game.theme,
      );
    }
  }

  /// Ends the current game
  void endGame() {
    _stopTimer();
    _stopPreviewTimer();
    _stopAllPowerUpTimers();
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

      // Skip countdown if timer is frozen
      if (state.timerFrozen) return;

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

  /// Stops the preview timer
  void _stopPreviewTimer() {
    _previewTimer?.cancel();
    _previewTimer = null;
  }

  /// Stops all power-up timers
  void _stopAllPowerUpTimers() {
    _peekTimer?.cancel();
    _peekTimer = null;
    _freezeTimer?.cancel();
    _freezeTimer = null;
    _hintTimer?.cancel();
    _hintTimer = null;
  }

  // ========== POWER-UP METHODS ==========

  /// Use a power-up in the game
  /// Note: Inventory and game usage checks are handled by PowerUpBar before calling this
  Future<bool> usePowerUp(PowerUpType type) async {
    final game = state.currentGame;
    if (game == null || game.state != GameState.inProgress) return false;

    switch (type) {
      case PowerUpType.peek:
        return _usePeek();
      case PowerUpType.freeze:
        return _useFreeze();
      case PowerUpType.hint:
        return _useHint();
      case PowerUpType.shuffle:
        return _useShuffle();
      case PowerUpType.timeBonus:
        return _useTimeBonus();
      case PowerUpType.magnet:
        return _useMagnet();
    }
  }

  /// Peek - Show all cards for 3 seconds
  bool _usePeek() {
    final game = state.currentGame;
    if (game == null) return false;

    // Store which cards were already revealed before peek (to not hide them after)
    final preRevealedIds = game.cards
        .where((c) => c.state == CardState.revealed)
        .map((c) => c.id)
        .toSet();

    // Reveal all hidden cards
    final updatedCards = game.cards.map((card) {
      if (card.state == CardState.hidden) {
        return card.copyWith(state: CardState.revealed);
      }
      return card;
    }).toList();

    state = state.copyWith(
      currentGame: game.copyWith(cards: updatedCards),
      isProcessing: true, // Block card selection during peek
      selectedCards: [], // Clear selection during peek
    );

    _audioService.playSound(SoundEffect.cardFlip);
    _hapticService.trigger(HapticType.medium);

    // Hide cards after 3 seconds (except matched ones and pre-revealed ones)
    _peekTimer?.cancel();
    _peekTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      final currentGame = state.currentGame;
      if (currentGame == null) return;

      final hiddenCards = currentGame.cards.map((card) {
        // Don't hide matched cards or cards that were revealed before peek
        if (card.state == CardState.matched || preRevealedIds.contains(card.id)) {
          return card;
        }
        // Hide peek-revealed cards
        if (card.state == CardState.revealed) {
          return card.copyWith(state: CardState.hidden);
        }
        return card;
      }).toList();

      state = state.copyWith(
        currentGame: currentGame.copyWith(cards: hiddenCards),
        isProcessing: false,
      );

      _audioService.playSound(SoundEffect.cardFlip);
    });

    return true;
  }

  /// Freeze - Pause timer for 10 seconds
  bool _useFreeze() {
    final game = state.currentGame;
    if (game == null || game.mode != GameMode.timed) return false;

    // Set frozen state (timer keeps running but doesn't decrement)
    state = state.copyWith(timerFrozen: true);

    _audioService.playSound(SoundEffect.comboBonus);
    _hapticService.trigger(HapticType.medium);

    // Unfreeze after 10 seconds
    _freezeTimer?.cancel();
    _freezeTimer = Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
      final currentGame = state.currentGame;
      if (currentGame == null || currentGame.state != GameState.inProgress) return;

      state = state.copyWith(timerFrozen: false);
    });

    return true;
  }

  /// Hint - Highlight a matching pair for 3 seconds
  bool _useHint() {
    final game = state.currentGame;
    if (game == null) return false;

    // Find an unmatched pair
    final hiddenCards = game.cards.where((c) => c.state == CardState.hidden).toList();
    if (hiddenCards.isEmpty) return false;

    // Group by pairId
    final pairGroups = <String, List<GameCard>>{};
    for (final card in hiddenCards) {
      pairGroups.putIfAbsent(card.pairId, () => []).add(card);
    }

    // Find a pair with 2 cards
    MapEntry<String, List<GameCard>>? matchingPair;
    for (final entry in pairGroups.entries) {
      if (entry.value.length == 2) {
        matchingPair = entry;
        break;
      }
    }

    if (matchingPair == null) return false;

    final hintedIds = matchingPair.value.map((c) => c.id).toSet();
    state = state.copyWith(hintedCardIds: hintedIds);

    _audioService.playSound(SoundEffect.comboBonus);
    _hapticService.trigger(HapticType.light);

    // Clear hint after 3 seconds
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      state = state.copyWith(hintedCardIds: const {});
    });

    return true;
  }

  /// Shuffle - Reshuffle unmatched cards
  bool _useShuffle() {
    final game = state.currentGame;
    if (game == null) return false;

    final cards = List<GameCard>.from(game.cards);

    // Get indices of hidden (unmatched) cards
    final hiddenIndices = <int>[];
    for (var i = 0; i < cards.length; i++) {
      if (cards[i].state == CardState.hidden) {
        hiddenIndices.add(i);
      }
    }

    if (hiddenIndices.length < 2) return false;

    // Collect the hidden cards
    final hiddenCards = hiddenIndices.map((i) => cards[i]).toList();

    // Shuffle them
    final random = Random();
    hiddenCards.shuffle(random);

    // Put them back in the indices
    for (var i = 0; i < hiddenIndices.length; i++) {
      final originalIndex = hiddenIndices[i];
      cards[originalIndex] = hiddenCards[i];
    }

    state = state.copyWith(
      currentGame: game.copyWith(cards: cards),
      selectedCards: [], // Clear any selection
    );

    _audioService.playSound(SoundEffect.cardFlip);
    _hapticService.trigger(HapticType.medium);

    return true;
  }

  /// Time Bonus - Add 15 seconds to timer
  bool _useTimeBonus() {
    final game = state.currentGame;
    if (game == null || game.mode != GameMode.timed) return false;
    if (game.timeRemaining == null) return false;

    final newTime = game.timeRemaining! + 15;

    state = state.copyWith(
      currentGame: game.copyWith(timeRemaining: newTime),
    );

    _audioService.playSound(SoundEffect.comboBonus);
    _hapticService.trigger(HapticType.success);

    return true;
  }

  /// Magnet - Next card selection auto-matches
  bool _useMagnet() {
    state = state.copyWith(magnetActive: true);

    _audioService.playSound(SoundEffect.comboBonus);
    _hapticService.trigger(HapticType.medium);

    return true;
  }

  /// Clear hint highlight (called when hinted card is selected)
  void _clearHintIfNeeded(String cardId) {
    if (state.hintedCardIds.contains(cardId)) {
      state = state.copyWith(hintedCardIds: const {});
    }
  }

  /// Handle magnet auto-match
  Future<void> _handleMagnetMatch(GameCard selectedCard) async {
    final game = state.currentGame;
    if (game == null) return;

    // Find the matching card
    final matchingCard = game.cards.firstWhere(
      (c) => c.pairId == selectedCard.pairId &&
             c.id != selectedCard.id &&
             c.state == CardState.hidden,
      orElse: () => selectedCard,
    );

    if (matchingCard.id == selectedCard.id) return;

    // Brief delay for effect
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    final currentGame = state.currentGame;
    if (currentGame == null) return;

    // Auto-reveal and match the pair
    final updatedCards = List<GameCard>.from(currentGame.cards);
    final index2 = updatedCards.indexWhere((c) => c.id == matchingCard.id);

    // First reveal the matching card
    updatedCards[index2] = updatedCards[index2].copyWith(state: CardState.revealed);

    state = state.copyWith(
      currentGame: currentGame.copyWith(cards: updatedCards),
      selectedCards: [selectedCard, matchingCard],
    );

    _audioService.playSound(SoundEffect.cardFlip);

    // Then match them
    await Future.delayed(const Duration(milliseconds: 200));
    await _checkMatch(selectedCard, matchingCard);
  }

  @override
  void dispose() {
    _stopTimer();
    _stopPreviewTimer();
    _stopAllPowerUpTimers();
    super.dispose();
  }
}

/// Provider for the game state
final gameProvider = StateNotifierProvider<GameNotifier, GameStateData>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final hapticService = ref.watch(hapticServiceProvider);
  final settings = ref.watch(settingsProvider);
  final settingsNotifier = ref.read(settingsProvider.notifier);

  return GameNotifier(audioService, hapticService, settings, settingsNotifier, ref);
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

/// Provider for checking if timer is frozen
final isTimerFrozenProvider = Provider<bool>((ref) {
  return ref.watch(gameProvider.select((s) => s.timerFrozen));
});

/// Provider for checking if magnet is active
final isMagnetActiveProvider = Provider<bool>((ref) {
  return ref.watch(gameProvider.select((s) => s.magnetActive));
});
