# PairQuest - Teknik Spesifikasyon Dokümanı (Flutter)

## 1. Teknoloji Stack

### 1.1 Core
- **Framework**: Flutter 3.x
- **Dil**: Dart
- **State Management**: Riverpod / Bloc
- **Local Storage**: Hive / SharedPreferences
- **Backend**: Firebase (Authentication, Firestore, Cloud Functions)

### 1.2 Paketler

| Paket | Kullanım |
|-------|----------|
| `flutter_riverpod` | State management |
| `go_router` | Navigation |
| `hive_flutter` | Local database |
| `firebase_core` | Firebase entegrasyonu |
| `cloud_firestore` | Online veri |
| `firebase_auth` | Kimlik doğrulama |
| `flame` | Oyun animasyonları (opsiyonel) |
| `audioplayers` | Ses efektleri |
| `just_audio` | Arka plan müziği |
| `flutter_animate` | UI animasyonları |
| `lottie` | Lottie animasyonları |
| `confetti` | Kutlama efektleri |
| `share_plus` | Sosyal paylaşım |
| `google_mobile_ads` | Reklamlar |

---

## 2. Mimari (Clean Architecture)

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   ├── game_config.dart
│   │   └── asset_paths.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── text_styles.dart
│   ├── utils/
│   │   ├── extensions.dart
│   │   ├── helpers.dart
│   │   └── validators.dart
│   └── errors/
│       └── failures.dart
│
├── data/
│   ├── models/
│   │   ├── card_model.dart
│   │   ├── game_model.dart
│   │   ├── player_model.dart
│   │   ├── achievement_model.dart
│   │   └── leaderboard_model.dart
│   ├── repositories/
│   │   ├── game_repository_impl.dart
│   │   ├── player_repository_impl.dart
│   │   └── leaderboard_repository_impl.dart
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── game_local_datasource.dart
│   │   │   └── player_local_datasource.dart
│   │   └── remote/
│   │       ├── firebase_datasource.dart
│   │       └── leaderboard_remote_datasource.dart
│   └── dto/
│       └── game_dto.dart
│
├── domain/
│   ├── entities/
│   │   ├── card.dart
│   │   ├── game.dart
│   │   ├── player.dart
│   │   └── achievement.dart
│   ├── repositories/
│   │   ├── game_repository.dart
│   │   ├── player_repository.dart
│   │   └── leaderboard_repository.dart
│   └── usecases/
│       ├── game/
│       │   ├── start_game.dart
│       │   ├── flip_card.dart
│       │   ├── check_match.dart
│       │   └── complete_game.dart
│       ├── player/
│       │   ├── get_player_stats.dart
│       │   └── update_player.dart
│       └── leaderboard/
│           ├── get_leaderboard.dart
│           └── submit_score.dart
│
├── presentation/
│   ├── providers/
│   │   ├── game_provider.dart
│   │   ├── player_provider.dart
│   │   ├── settings_provider.dart
│   │   └── audio_provider.dart
│   ├── screens/
│   │   ├── splash/
│   │   ├── home/
│   │   ├── game/
│   │   ├── levels/
│   │   ├── leaderboard/
│   │   ├── achievements/
│   │   ├── profile/
│   │   └── settings/
│   └── widgets/
│       ├── game/
│       │   ├── game_board.dart
│       │   ├── memory_card.dart
│       │   ├── score_display.dart
│       │   ├── timer_widget.dart
│       │   ├── combo_indicator.dart
│       │   └── power_up_bar.dart
│       ├── common/
│       │   ├── custom_button.dart
│       │   ├── animated_counter.dart
│       │   ├── progress_bar.dart
│       │   └── star_rating.dart
│       └── dialogs/
│           ├── game_over_dialog.dart
│           ├── pause_dialog.dart
│           └── achievement_popup.dart
│
└── services/
    ├── audio_service.dart
    ├── analytics_service.dart
    └── notification_service.dart
```

---

## 3. Veri Modelleri (Dart)

### 3.1 Card Model

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_model.freezed.dart';
part 'card_model.g.dart';

enum CardState { hidden, revealed, matched, locked }

@freezed
class CardModel with _$CardModel {
  const factory CardModel({
    required String id,
    required String pairId,
    required String imageAsset,
    required int position,
    @Default(CardState.hidden) CardState state,
    required String theme,
  }) = _CardModel;

  factory CardModel.fromJson(Map<String, dynamic> json) =>
      _$CardModelFromJson(json);
}
```

### 3.2 Game Model

```dart
enum GameMode { classic, timed, challenge, story, endless, multiplayer }
enum GameState { notStarted, inProgress, paused, completed, failed }
enum Difficulty { tutorial, veryEasy, easy, medium, hard, veryHard, expert }

@freezed
class GameModel with _$GameModel {
  const factory GameModel({
    required String id,
    required GameMode mode,
    required Difficulty difficulty,
    required GridSize gridSize,
    required List<CardModel> cards,
    @Default(GameState.notStarted) GameState state,
    @Default(0) int score,
    @Default(0) int moves,
    @Default(0) int matches,
    @Default(0) int combo,
    @Default(0) int maxCombo,
    required DateTime startTime,
    DateTime? endTime,
    int? timeLimit,
    int? timeRemaining,
    @Default([]) List<String> powerUpsUsed,
    required String playerId,
  }) = _GameModel;

  factory GameModel.fromJson(Map<String, dynamic> json) =>
      _$GameModelFromJson(json);
}

@freezed
class GridSize with _$GridSize {
  const factory GridSize({
    required int rows,
    required int cols,
  }) = _GridSize;

  int get totalCards => rows * cols;
  int get pairs => totalCards ~/ 2;
}
```

### 3.3 Player Model

```dart
@freezed
class PlayerModel with _$PlayerModel {
  const factory PlayerModel({
    required String id,
    required String username,
    String? email,
    String? avatarUrl,
    required DateTime createdAt,
    required DateTime lastActiveAt,
    required PlayerStats stats,
    @Default([]) List<String> unlockedAchievements,
    @Default(['animals']) List<String> unlockedThemes,
    @Default({}) Map<String, int> powerUps,
    required PlayerSettings settings,
    @Default(false) bool isPremium,
  }) = _PlayerModel;

  factory PlayerModel.fromJson(Map<String, dynamic> json) =>
      _$PlayerModelFromJson(json);
}

@freezed
class PlayerStats with _$PlayerStats {
  const factory PlayerStats({
    @Default(0) int totalGamesPlayed,
    @Default(0) int totalGamesWon,
    @Default(0) int totalScore,
    @Default(0) int highestScore,
    @Default(0) int totalMatches,
    @Default(0) int perfectGames,
    @Default(0) int maxCombo,
    @Default(0) int totalPlayTimeMinutes,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default({}) Map<int, LevelProgress> levelProgress,
  }) = _PlayerStats;
}

@freezed
class LevelProgress with _$LevelProgress {
  const factory LevelProgress({
    required int level,
    @Default(0) int bestScore,
    @Default(0) int bestMoves,
    @Default(0) int bestTimeSeconds,
    @Default(0) int stars,
    DateTime? completedAt,
  }) = _LevelProgress;
}
```

---

## 4. State Management (Riverpod)

### 4.1 Game Provider

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Game State
@freezed
class GameStateData with _$GameStateData {
  const factory GameStateData({
    GameModel? currentGame,
    @Default([]) List<CardModel> selectedCards,
    @Default(false) bool isProcessing,
    @Default(false) bool isLoading,
    String? error,
  }) = _GameStateData;
}

// Game Notifier
class GameNotifier extends StateNotifier<GameStateData> {
  final GameRepository _gameRepository;
  final AudioService _audioService;

  GameNotifier(this._gameRepository, this._audioService)
      : super(const GameStateData());

  Future<void> startGame({
    required GameMode mode,
    required Difficulty difficulty,
    required String theme,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final gridSize = _getGridSizeForDifficulty(difficulty);
      final cards = await _gameRepository.generateCards(
        pairs: gridSize.pairs,
        theme: theme,
      );

      final game = GameModel(
        id: const Uuid().v4(),
        mode: mode,
        difficulty: difficulty,
        gridSize: gridSize,
        cards: cards,
        state: GameState.inProgress,
        startTime: DateTime.now(),
        timeLimit: mode == GameMode.timed ? _getTimeLimit(difficulty) : null,
        timeRemaining: mode == GameMode.timed ? _getTimeLimit(difficulty) : null,
        playerId: _getCurrentPlayerId(),
      );

      state = state.copyWith(
        currentGame: game,
        selectedCards: [],
        isProcessing: false,
        isLoading: false,
      );

      _audioService.playSound(SoundEffect.gameStart);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> selectCard(String cardId) async {
    if (state.isProcessing || state.currentGame == null) return;

    final game = state.currentGame!;
    final card = game.cards.firstWhere((c) => c.id == cardId);

    if (!_canSelectCard(card)) return;

    _audioService.playSound(SoundEffect.cardFlip);

    // Kartı aç
    final updatedCards = game.cards.map((c) {
      if (c.id == cardId) {
        return c.copyWith(state: CardState.revealed);
      }
      return c;
    }).toList();

    final newSelectedCards = [...state.selectedCards, card];

    state = state.copyWith(
      currentGame: game.copyWith(cards: updatedCards),
      selectedCards: newSelectedCards,
    );

    // 2 kart seçildiyse eşleşme kontrolü
    if (newSelectedCards.length == 2) {
      await _checkMatch(newSelectedCards[0], newSelectedCards[1]);
    }
  }

  Future<void> _checkMatch(CardModel card1, CardModel card2) async {
    state = state.copyWith(isProcessing: true);

    await Future.delayed(const Duration(milliseconds: 800));

    final game = state.currentGame!;
    final isMatch = card1.pairId == card2.pairId;

    if (isMatch) {
      _audioService.playSound(SoundEffect.match);

      final newCombo = game.combo + 1;
      final points = _calculatePoints(isMatch: true, combo: newCombo);

      final updatedCards = game.cards.map((c) {
        if (c.id == card1.id || c.id == card2.id) {
          return c.copyWith(state: CardState.matched);
        }
        return c;
      }).toList();

      final updatedGame = game.copyWith(
        cards: updatedCards,
        score: game.score + points,
        moves: game.moves + 1,
        matches: game.matches + 1,
        combo: newCombo,
        maxCombo: newCombo > game.maxCombo ? newCombo : game.maxCombo,
      );

      // Oyun bitti mi kontrol et
      final isCompleted = updatedCards.every(
        (c) => c.state == CardState.matched,
      );

      state = state.copyWith(
        currentGame: isCompleted
            ? updatedGame.copyWith(
                state: GameState.completed,
                endTime: DateTime.now(),
              )
            : updatedGame,
        selectedCards: [],
        isProcessing: false,
      );

      if (isCompleted) {
        _audioService.playSound(SoundEffect.gameComplete);
      }
    } else {
      _audioService.playSound(SoundEffect.noMatch);

      final updatedCards = game.cards.map((c) {
        if (c.id == card1.id || c.id == card2.id) {
          return c.copyWith(state: CardState.hidden);
        }
        return c;
      }).toList();

      state = state.copyWith(
        currentGame: game.copyWith(
          cards: updatedCards,
          moves: game.moves + 1,
          combo: 0,
          score: game.score - 10,
        ),
        selectedCards: [],
        isProcessing: false,
      );
    }
  }

  bool _canSelectCard(CardModel card) {
    return card.state == CardState.hidden &&
        state.selectedCards.length < 2 &&
        !state.selectedCards.any((c) => c.id == card.id);
  }

  GridSize _getGridSizeForDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.tutorial:
        return const GridSize(rows: 2, cols: 2);
      case Difficulty.veryEasy:
        return const GridSize(rows: 2, cols: 3);
      case Difficulty.easy:
        return const GridSize(rows: 3, cols: 4);
      case Difficulty.medium:
        return const GridSize(rows: 4, cols: 4);
      case Difficulty.hard:
        return const GridSize(rows: 4, cols: 5);
      case Difficulty.veryHard:
        return const GridSize(rows: 5, cols: 6);
      case Difficulty.expert:
        return const GridSize(rows: 6, cols: 6);
    }
  }

  int _calculatePoints({required bool isMatch, required int combo}) {
    if (!isMatch) return -10;

    int points = 100;
    if (combo > 1) {
      points += (combo - 1) * 50;
    }
    return points;
  }
}

// Providers
final gameNotifierProvider =
    StateNotifierProvider<GameNotifier, GameStateData>((ref) {
  return GameNotifier(
    ref.watch(gameRepositoryProvider),
    ref.watch(audioServiceProvider),
  );
});
```

---

## 5. Widget Yapısı

### 5.1 Memory Card Widget

```dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class MemoryCard extends StatefulWidget {
  final CardModel card;
  final VoidCallback onTap;
  final String cardBackAsset;

  const MemoryCard({
    super.key,
    required this.card,
    required this.onTap,
    this.cardBackAsset = 'assets/images/card_back.png',
  });

  @override
  State<MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<MemoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool _showFront = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addListener(() {
      if (_controller.value >= 0.5 && !_showFront) {
        setState(() => _showFront = true);
      } else if (_controller.value < 0.5 && _showFront) {
        setState(() => _showFront = false);
      }
    });
  }

  @override
  void didUpdateWidget(MemoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.card.state != oldWidget.card.state) {
      if (widget.card.state == CardState.revealed ||
          widget.card.state == CardState.matched) {
        _controller.forward();
      } else if (widget.card.state == CardState.hidden) {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMatched = widget.card.state == CardState.matched;

    return GestureDetector(
      onTap: widget.card.state == CardState.hidden ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * math.pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: isMatched
                    ? [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.6),
                          blurRadius: 15,
                          spreadRadius: 2,
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _showFront ? _buildFront() : _buildBack(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: Image.asset(
        widget.card.imageAsset,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildBack() {
    return Image.asset(
      widget.cardBackAsset,
      fit: BoxFit.cover,
    );
  }
}
```

### 5.2 Game Board Widget

```dart
class GameBoard extends ConsumerWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final game = gameState.currentGame;

    if (game == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardSize = _calculateCardSize(
          constraints: constraints,
          gridSize: game.gridSize,
        );

        return Center(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: game.cards.map((card) {
              return SizedBox(
                width: cardSize,
                height: cardSize * 1.3,
                child: MemoryCard(
                  card: card,
                  onTap: () {
                    ref.read(gameNotifierProvider.notifier).selectCard(card.id);
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  double _calculateCardSize({
    required BoxConstraints constraints,
    required GridSize gridSize,
  }) {
    final maxWidth = constraints.maxWidth - (gridSize.cols - 1) * 8;
    final maxHeight = constraints.maxHeight - (gridSize.rows - 1) * 8;

    final cardWidth = maxWidth / gridSize.cols;
    final cardHeight = maxHeight / gridSize.rows / 1.3;

    return math.min(cardWidth, cardHeight);
  }
}
```

---

## 6. Seviye Konfigürasyonu

```dart
class LevelConfig {
  static const List<LevelData> levels = [
    LevelData(
      level: 1,
      gridSize: GridSize(rows: 2, cols: 2),
      theme: 'animals',
      timeLimit: null,
      description: 'Başlangıç',
      starThresholds: StarThresholds(one: 100, two: 200, three: 300),
    ),
    LevelData(
      level: 2,
      gridSize: GridSize(rows: 2, cols: 3),
      theme: 'animals',
      timeLimit: 60,
      description: 'Kolay',
      starThresholds: StarThresholds(one: 200, two: 400, three: 600),
    ),
    LevelData(
      level: 3,
      gridSize: GridSize(rows: 2, cols: 4),
      theme: 'fruits',
      timeLimit: 90,
      description: 'Kolay',
      starThresholds: StarThresholds(one: 300, two: 600, three: 900),
    ),
    // ... daha fazla seviye
  ];
}

@freezed
class LevelData with _$LevelData {
  const factory LevelData({
    required int level,
    required GridSize gridSize,
    required String theme,
    int? timeLimit,
    required String description,
    required StarThresholds starThresholds,
    @Default(false) bool isLocked,
    @Default([]) List<String> specialCards,
  }) = _LevelData;
}

@freezed
class StarThresholds with _$StarThresholds {
  const factory StarThresholds({
    required int one,
    required int two,
    required int three,
  }) = _StarThresholds;
}
```

---

## 7. Firebase Entegrasyonu

### 7.1 Firestore Yapısı

```
firestore/
├── users/
│   └── {userId}/
│       ├── username: string
│       ├── email: string
│       ├── avatarUrl: string
│       ├── createdAt: timestamp
│       ├── lastActiveAt: timestamp
│       ├── stats: map
│       ├── achievements: array
│       └── settings: map
│
├── leaderboards/
│   ├── global/
│   │   └── {period}/ (allTime, weekly, daily)
│   │       └── {entryId}/
│   │           ├── userId: string
│   │           ├── username: string
│   │           ├── score: number
│   │           ├── level: number
│   │           └── achievedAt: timestamp
│   │
│   └── levels/
│       └── {levelId}/
│           └── {entryId}/
│               └── ...
│
├── games/
│   └── {gameId}/
│       ├── playerId: string
│       ├── mode: string
│       ├── score: number
│       ├── moves: number
│       ├── completedAt: timestamp
│       └── replay: array (opsiyonel)
│
└── dailyChallenges/
    └── {date}/
        ├── seed: string
        ├── gridSize: map
        └── theme: string
```

### 7.2 Leaderboard Service

```dart
class LeaderboardService {
  final FirebaseFirestore _firestore;

  LeaderboardService(this._firestore);

  Future<List<LeaderboardEntry>> getGlobalLeaderboard({
    LeaderboardPeriod period = LeaderboardPeriod.allTime,
    int limit = 100,
  }) async {
    final snapshot = await _firestore
        .collection('leaderboards')
        .doc('global')
        .collection(period.name)
        .orderBy('score', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .asMap()
        .entries
        .map((e) => LeaderboardEntry.fromFirestore(e.value, e.key + 1))
        .toList();
  }

  Future<void> submitScore({
    required String odur,
    required String username,
    required int score,
    required int level,
  }) async {
    final entry = {
      'userId': userId,
      'username': username,
      'score': score,
      'level': level,
      'achievedAt': FieldValue.serverTimestamp(),
    };

    // Global leaderboard
    await _firestore
        .collection('leaderboards')
        .doc('global')
        .collection('allTime')
        .add(entry);

    // Level leaderboard
    await _firestore
        .collection('leaderboards')
        .doc('levels')
        .collection('level_$level')
        .add(entry);
  }

  Future<int?> getPlayerRank(String odur) async {
    final snapshot = await _firestore
        .collection('leaderboards')
        .doc('global')
        .collection('allTime')
        .orderBy('score', descending: true)
        .get();

    final index = snapshot.docs.indexWhere(
      (doc) => doc.data()['userId'] == odur,
    );

    return index >= 0 ? index + 1 : null;
  }
}
```

---

## 8. Ses Servisi

```dart
import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart' as just_audio;

enum SoundEffect {
  cardFlip,
  match,
  noMatch,
  combo,
  gameStart,
  gameComplete,
  gameFail,
  buttonClick,
  achievement,
  timerWarning,
}

class AudioService {
  final AudioPlayer _effectPlayer = AudioPlayer();
  final just_audio.AudioPlayer _musicPlayer = just_audio.AudioPlayer();

  double _effectVolume = 1.0;
  double _musicVolume = 0.5;
  bool _isMuted = false;

  static const Map<SoundEffect, String> _soundPaths = {
    SoundEffect.cardFlip: 'sounds/card_flip.mp3',
    SoundEffect.match: 'sounds/match.mp3',
    SoundEffect.noMatch: 'sounds/no_match.mp3',
    SoundEffect.combo: 'sounds/combo.mp3',
    SoundEffect.gameStart: 'sounds/game_start.mp3',
    SoundEffect.gameComplete: 'sounds/game_complete.mp3',
    SoundEffect.gameFail: 'sounds/game_fail.mp3',
    SoundEffect.buttonClick: 'sounds/button_click.mp3',
    SoundEffect.achievement: 'sounds/achievement.mp3',
    SoundEffect.timerWarning: 'sounds/timer_warning.mp3',
  };

  Future<void> playSound(SoundEffect effect) async {
    if (_isMuted) return;

    final path = _soundPaths[effect];
    if (path != null) {
      await _effectPlayer.setVolume(_effectVolume);
      await _effectPlayer.play(AssetSource(path));
    }
  }

  Future<void> playBackgroundMusic(String trackName) async {
    if (_isMuted) return;

    await _musicPlayer.setAsset('assets/music/$trackName.mp3');
    await _musicPlayer.setVolume(_musicVolume);
    await _musicPlayer.setLoopMode(just_audio.LoopMode.one);
    await _musicPlayer.play();
  }

  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
  }

  void setEffectVolume(double volume) {
    _effectVolume = volume.clamp(0.0, 1.0);
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _musicPlayer.setVolume(_musicVolume);
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _musicPlayer.pause();
    } else {
      _musicPlayer.play();
    }
  }

  void dispose() {
    _effectPlayer.dispose();
    _musicPlayer.dispose();
  }
}
```

---

## 9. Animasyon Özellikleri

### 9.1 Kart Animasyonları

```dart
// flutter_animate kullanarak
extension CardAnimations on Widget {
  Widget flipAnimation({required bool isFlipped}) {
    return animate(
      target: isFlipped ? 1 : 0,
    )
        .rotate(
          begin: 0,
          end: 0.5,
          duration: 400.ms,
          curve: Curves.easeInOut,
        )
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 200.ms,
        )
        .then()
        .scale(
          begin: const Offset(1.05, 1.05),
          end: const Offset(1, 1),
          duration: 200.ms,
        );
  }

  Widget matchAnimation() {
    return animate()
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.2, 1.2),
          duration: 300.ms,
          curve: Curves.elasticOut,
        )
        .shimmer(
          duration: 600.ms,
          color: Colors.amber.withOpacity(0.5),
        );
  }

  Widget shakeAnimation() {
    return animate()
        .shake(
          hz: 4,
          offset: const Offset(10, 0),
          duration: 400.ms,
        );
  }
}
```

### 9.2 Skor Popup Animasyonu

```dart
class ScorePopup extends StatelessWidget {
  final int points;
  final Offset position;

  const ScorePopup({
    super.key,
    required this.points,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = points > 0;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Text(
        isPositive ? '+$points' : '$points',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isPositive ? Colors.green : Colors.red,
        ),
      )
          .animate()
          .fadeIn(duration: 200.ms)
          .slideY(begin: 0, end: -1, duration: 800.ms)
          .fadeOut(delay: 600.ms, duration: 200.ms),
    );
  }
}
```

---

## 10. Tema Sistemi

```dart
class ThemeConfig {
  static const Map<String, CardTheme> themes = {
    'animals': CardTheme(
      id: 'animals',
      name: 'Hayvanlar',
      icon: '🐾',
      cardBackAsset: 'assets/themes/animals/back.png',
      imageAssets: [
        'assets/themes/animals/cat.png',
        'assets/themes/animals/dog.png',
        'assets/themes/animals/bird.png',
        // ... 32 farklı hayvan
      ],
      isUnlocked: true,
    ),
    'fruits': CardTheme(
      id: 'fruits',
      name: 'Meyveler',
      icon: '🍎',
      cardBackAsset: 'assets/themes/fruits/back.png',
      imageAssets: [...],
      unlockRequirement: UnlockRequirement.level(5),
    ),
    // ... diğer temalar
  };
}

@freezed
class CardTheme with _$CardTheme {
  const factory CardTheme({
    required String id,
    required String name,
    required String icon,
    required String cardBackAsset,
    required List<String> imageAssets,
    @Default(true) bool isUnlocked,
    UnlockRequirement? unlockRequirement,
  }) = _CardTheme;
}
```

---

## 11. Test Yapısı

```
test/
├── unit/
│   ├── models/
│   │   └── card_model_test.dart
│   ├── services/
│   │   ├── score_service_test.dart
│   │   └── shuffle_service_test.dart
│   └── providers/
│       └── game_provider_test.dart
│
├── widget/
│   ├── memory_card_test.dart
│   ├── game_board_test.dart
│   └── score_display_test.dart
│
└── integration/
    ├── game_flow_test.dart
    └── leaderboard_test.dart
```

---

## 12. Performans Hedefleri

| Metrik | Hedef |
|--------|-------|
| App başlatma süresi | < 2s |
| Kart çevirme FPS | 60 FPS |
| Memory kullanımı | < 150MB |
| APK boyutu | < 30MB |
| iOS IPA boyutu | < 50MB |

---

*Doküman Versiyonu: 1.0 (Flutter)*
*Son Güncelleme: 18 Ocak 2026*
