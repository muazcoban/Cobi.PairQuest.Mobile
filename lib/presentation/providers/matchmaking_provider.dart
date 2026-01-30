import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/matchmaking_repository.dart';
import '../../domain/entities/matchmaking.dart';
import '../../domain/entities/online_game.dart';
import 'online_game_provider.dart';

/// Repository provider
final matchmakingRepositoryProvider = Provider<MatchmakingRepository>((ref) {
  return MatchmakingRepository();
});

/// Matchmaking UI state (different from entity's MatchmakingSearchStatus)
enum MatchmakingUIState {
  idle,
  searching,
  matched,
  error,
  timeout,
}

/// Matchmaking search status with details
class MatchmakingSearchStatus {
  final MatchmakingUIState state;
  final String? queueId;
  final String? gameId;
  final String? errorMessage;
  final int searchTimeSeconds;
  final int ratingRadius;

  const MatchmakingSearchStatus({
    this.state = MatchmakingUIState.idle,
    this.queueId,
    this.gameId,
    this.errorMessage,
    this.searchTimeSeconds = 0,
    this.ratingRadius = 100,
  });

  MatchmakingSearchStatus copyWith({
    MatchmakingUIState? state,
    String? queueId,
    String? gameId,
    String? errorMessage,
    int? searchTimeSeconds,
    int? ratingRadius,
  }) {
    return MatchmakingSearchStatus(
      state: state ?? this.state,
      queueId: queueId ?? this.queueId,
      gameId: gameId ?? this.gameId,
      errorMessage: errorMessage ?? this.errorMessage,
      searchTimeSeconds: searchTimeSeconds ?? this.searchTimeSeconds,
      ratingRadius: ratingRadius ?? this.ratingRadius,
    );
  }
}

/// Matchmaking notifier
class MatchmakingNotifier extends StateNotifier<MatchmakingSearchStatus> {
  final MatchmakingRepository _repository;
  final Ref _ref;
  Timer? _searchTimer;
  Timer? _matchCheckTimer;
  StreamSubscription<MatchmakingEntry?>? _queueSubscription;

  MatchmakingNotifier(this._repository, this._ref)
      : super(const MatchmakingSearchStatus());

  /// Start searching for a match
  Future<void> startSearch({
    required String oddserId,
    required String displayName,
    String? photoUrl,
    required int rating,
    int preferredLevel = 0,
    MatchmakingMode mode = MatchmakingMode.any,
  }) async {
    if (state.state == MatchmakingUIState.searching) return;

    try {
      // Join the matchmaking queue
      final queueId = await _repository.joinQueue(
        oddserId: oddserId,
        displayName: displayName,
        photoUrl: photoUrl,
        rating: rating,
        preferredLevel: preferredLevel,
        mode: mode,
      );

      state = MatchmakingSearchStatus(
        state: MatchmakingUIState.searching,
        queueId: queueId,
        searchTimeSeconds: 0,
        ratingRadius: 100,
      );

      // Start search timer
      _searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (state.state != MatchmakingUIState.searching) {
          timer.cancel();
          return;
        }

        final newTime = state.searchTimeSeconds + 1;

        // Check for timeout (60 seconds)
        if (newTime >= 60) {
          _handleTimeout();
          return;
        }

        // Calculate rating radius expansion
        final expansions = newTime ~/ 15;
        final newRadius = 100 + (expansions * 100);

        state = state.copyWith(
          searchTimeSeconds: newTime,
          ratingRadius: newRadius,
        );
      });

      // Start checking for matches every 2 seconds
      _matchCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        if (state.state != MatchmakingUIState.searching || state.queueId == null) {
          timer.cancel();
          return;
        }

        final gameId = await _repository.findMatch(state.queueId!);
        if (gameId != null) {
          _handleMatchFound(gameId);
        }
      });

      // Also watch queue entry for external match (opponent found us)
      _queueSubscription = _repository.watchQueueEntry(queueId).listen((entry) {
        if (entry != null && entry.status == MatchmakingStatus.matched) {
          // Wait for gameId to be set (other player may still be creating the game)
          if (entry.matchedGameId != null && entry.matchedGameId != 'CREATING') {
            debugPrint('🎮 Match found via stream! Game ID: ${entry.matchedGameId}');
            _handleMatchFound(entry.matchedGameId!);
          } else {
            debugPrint('🎮 Status matched but waiting for gameId...');
          }
        }
      });
    } catch (e) {
      state = MatchmakingSearchStatus(
        state: MatchmakingUIState.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Cancel search
  Future<void> cancelSearch() async {
    _cleanup();

    if (state.queueId != null) {
      await _repository.leaveQueue(state.queueId!);
    }

    state = const MatchmakingSearchStatus(state: MatchmakingUIState.idle);
  }

  void _handleMatchFound(String gameId) {
    _cleanup();
    state = MatchmakingSearchStatus(
      state: MatchmakingUIState.matched,
      gameId: gameId,
    );

    // Set active game
    _ref.read(activeGameIdProvider.notifier).state = gameId;
  }

  void _handleTimeout() {
    _cleanup();

    if (state.queueId != null) {
      _repository.leaveQueue(state.queueId!);
    }

    state = const MatchmakingSearchStatus(state: MatchmakingUIState.timeout);
  }

  void _cleanup() {
    _searchTimer?.cancel();
    _matchCheckTimer?.cancel();
    _queueSubscription?.cancel();
    _searchTimer = null;
    _matchCheckTimer = null;
    _queueSubscription = null;
  }

  /// Reset to idle state
  void reset() {
    _cleanup();
    state = const MatchmakingSearchStatus(state: MatchmakingUIState.idle);
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}

final matchmakingProvider =
    StateNotifierProvider<MatchmakingNotifier, MatchmakingSearchStatus>((ref) {
  final repository = ref.watch(matchmakingRepositoryProvider);
  return MatchmakingNotifier(repository, ref);
});

/// Game invitations provider
final pendingInvitationsProvider =
    StreamProvider.family<List<GameInvitation>, String>((ref, oddserId) {
  final repository = ref.watch(matchmakingRepositoryProvider);
  return repository.watchPendingInvitations(oddserId);
});

/// Watch a specific invitation (for sender to know when accepted)
final watchInvitationProvider =
    StreamProvider.family<GameInvitation?, String>((ref, invitationId) {
  final repository = ref.watch(matchmakingRepositoryProvider);
  return repository.watchInvitation(invitationId);
});

/// Invitation notifier for sending/responding
class InvitationNotifier extends StateNotifier<AsyncValue<void>> {
  final MatchmakingRepository _repository;
  final Ref _ref;

  InvitationNotifier(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  /// Send invitation to a friend
  Future<String?> sendInvitation({
    required String fromUserId,
    required String fromDisplayName,
    String? fromPhotoUrl,
    required String toUserId,
    int level = 5,
  }) async {
    state = const AsyncValue.loading();
    try {
      final invitationId = await _repository.sendInvitation(
        fromUserId: fromUserId,
        fromDisplayName: fromDisplayName,
        fromPhotoUrl: fromPhotoUrl,
        toUserId: toUserId,
        level: level,
      );
      state = const AsyncValue.data(null);
      return invitationId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Accept invitation
  Future<String?> acceptInvitation(String invitationId) async {
    debugPrint('📨 InvitationNotifier.acceptInvitation: $invitationId');
    state = const AsyncValue.loading();
    try {
      final gameId = await _repository.acceptInvitation(invitationId);
      debugPrint('📨 InvitationNotifier: Game created with ID: $gameId');
      _ref.read(activeGameIdProvider.notifier).state = gameId;
      state = const AsyncValue.data(null);
      return gameId;
    } catch (e, st) {
      debugPrint('📨 InvitationNotifier.acceptInvitation ERROR: $e');
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Decline invitation
  Future<void> declineInvitation(String invitationId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.declineInvitation(invitationId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final invitationNotifierProvider =
    StateNotifierProvider<InvitationNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(matchmakingRepositoryProvider);
  return InvitationNotifier(repository, ref);
});

/// Selected game mode for matchmaking
final selectedGameModeProvider = StateProvider<OnlineGameMode>((ref) {
  return OnlineGameMode.casual;
});

/// Selected matchmaking mode
final selectedMatchmakingModeProvider = StateProvider<MatchmakingMode>((ref) {
  return MatchmakingMode.any;
});

/// Selected level for matchmaking (0 = any)
final selectedLevelProvider = StateProvider<int>((ref) => 0);
