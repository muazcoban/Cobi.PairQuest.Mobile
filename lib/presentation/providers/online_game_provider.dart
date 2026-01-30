import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/online_game_repository.dart';
import '../../domain/entities/online_game.dart';
import '../../domain/entities/online_player.dart';

/// Repository provider
final onlineGameRepositoryProvider = Provider<OnlineGameRepository>((ref) {
  return OnlineGameRepository();
});

/// Current active game ID
final activeGameIdProvider = StateProvider<String?>((ref) => null);

/// Online game state
final onlineGameProvider =
    StreamProvider.family<OnlineGame?, String>((ref, gameId) {
  final repository = ref.watch(onlineGameRepositoryProvider);
  return repository.watchGame(gameId);
});

/// Current player's user ID (from auth)
///
/// CRITICAL: This provider MUST be set BEFORE entering [OnlineGameScreen].
/// If null, turn detection ([isMyTurnProvider]) will always return false.
///
/// Set in these locations:
/// - [OnlineProfileNotifier.initializeProfile] - normal matchmaking flow
/// - [GameInvitationDialog._accept] - when accepting invitation
/// - [_InvitationWaitingDialog] - when invitation is accepted (sender side)
final currentPlayerIdProvider = StateProvider<String?>((ref) => null);

/// Check if it's current player's turn
final isMyTurnProvider = Provider.family<bool, String>((ref, gameId) {
  final game = ref.watch(onlineGameProvider(gameId)).valueOrNull;
  final myId = ref.watch(currentPlayerIdProvider);

  if (game == null || myId == null) return false;
  return game.isPlayerTurn(myId);
});

/// Get opponent player
final opponentPlayerProvider = Provider.family<OnlinePlayer?, String>((ref, gameId) {
  final game = ref.watch(onlineGameProvider(gameId)).valueOrNull;
  final myId = ref.watch(currentPlayerIdProvider);

  if (game == null || myId == null) return null;

  try {
    return game.players.firstWhere((p) => p.oddserId != myId);
  } catch (_) {
    return null;
  }
});

/// Get my player data
final myPlayerProvider = Provider.family<OnlinePlayer?, String>((ref, gameId) {
  final game = ref.watch(onlineGameProvider(gameId)).valueOrNull;
  final myId = ref.watch(currentPlayerIdProvider);

  if (game == null || myId == null) return null;

  try {
    return game.players.firstWhere((p) => p.oddserId == myId);
  } catch (_) {
    return null;
  }
});

/// Online game notifier for actions
class OnlineGameNotifier extends StateNotifier<AsyncValue<void>> {
  final OnlineGameRepository _repository;
  final Ref _ref;

  OnlineGameNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  /// Submit a move
  Future<bool> submitMove(String gameId, GameMove move) async {
    state = const AsyncValue.loading();
    try {
      await _repository.submitMove(gameId, move);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Leave/forfeit the game
  Future<void> leaveGame(String gameId) async {
    final myId = _ref.read(currentPlayerIdProvider);
    if (myId == null) return;

    state = const AsyncValue.loading();
    try {
      await _repository.leaveGame(gameId, myId);
      _ref.read(activeGameIdProvider.notifier).state = null;
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update connection status
  Future<void> updateConnection(String gameId, ConnectionStatus status) async {
    final myId = _ref.read(currentPlayerIdProvider);
    if (myId == null) return;

    try {
      await _repository.updatePlayerConnection(gameId, myId, status);
    } catch (_) {}
  }

  /// Join an existing game
  Future<bool> joinGame(String gameId, OnlinePlayer player) async {
    state = const AsyncValue.loading();
    try {
      await _repository.joinGame(gameId, player);
      _ref.read(activeGameIdProvider.notifier).state = gameId;
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final onlineGameNotifierProvider =
    StateNotifierProvider<OnlineGameNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(onlineGameRepositoryProvider);
  return OnlineGameNotifier(repository, ref);
});

/// Game timer for online games (separate from single player)
class OnlineGameTimerNotifier extends StateNotifier<int> {
  Timer? _timer;

  OnlineGameTimerNotifier() : super(0);

  void startTimer(int initialSeconds) {
    state = initialSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state > 0) {
        state--;
      } else {
        _timer?.cancel();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void addTime(int seconds) {
    state += seconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final onlineGameTimerProvider =
    StateNotifierProvider<OnlineGameTimerNotifier, int>((ref) {
  return OnlineGameTimerNotifier();
});

/// Revealed cards state for online game
final onlineRevealedCardsProvider = StateProvider<List<int>>((ref) => []);

/// Processing state (waiting for opponent, etc.)
final onlineGameProcessingProvider = StateProvider<bool>((ref) => false);

/// Last move result for animations
class LastMoveResult {
  final int card1Position;
  final int card2Position;
  final bool matched;
  final String playerId;

  LastMoveResult({
    required this.card1Position,
    required this.card2Position,
    required this.matched,
    required this.playerId,
  });
}

final lastMoveResultProvider = StateProvider<LastMoveResult?>((ref) => null);
