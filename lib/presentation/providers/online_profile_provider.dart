import 'dart:async';

import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/online_game_repository.dart';
import '../../domain/entities/online_player.dart';
import 'auth_provider.dart';
import 'online_game_provider.dart';

/// A player's online profile. Auto-disposed: friend tiles, request tiles and
/// the result screen open one listener per player, and a listener that
/// outlives its screen is billed for every presence write of that player.
final onlineProfileProvider = StreamProvider.autoDispose
    .family<OnlineUserProfile?, String>((ref, oddserId) {
  final repository = ref.watch(onlineGameRepositoryProvider);
  return repository.watchProfile(oddserId);
});

/// Profile actions notifier
///
/// Also keeps the player's presence: while the app is in the foreground it
/// refreshes lastSeenAt every [OnlineUserProfile.presenceHeartbeat], and it
/// writes "offline" when the app leaves the screen. Readers treat a status
/// older than [OnlineUserProfile.onlineTimeout] as offline, which covers an
/// app that was killed before it could write.
class OnlineProfileNotifier extends StateNotifier<AsyncValue<OnlineUserProfile?>>
    with WidgetsBindingObserver {
  final OnlineGameRepository _repository;
  final Ref _ref;
  StreamSubscription<OnlineUserProfile?>? _profileSub;
  String? _currentOddserId;
  String? _presenceUserId;
  Timer? _heartbeat;

  OnlineProfileNotifier(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  void _startPresence(String oddserId) {
    if (_presenceUserId == null) WidgetsBinding.instance.addObserver(this);
    _presenceUserId = oddserId;
    _startHeartbeat();
  }

  void _startHeartbeat() {
    final oddserId = _presenceUserId;
    if (oddserId == null) return;
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(OnlineUserProfile.presenceHeartbeat, (_) {
      _repository.updatePresence(oddserId, ConnectionStatus.online);
    });
  }

  /// Stop refreshing presence without writing, for when the signed-in user
  /// changed and can no longer write the old profile.
  void stopPresence() {
    _heartbeat?.cancel();
    _heartbeat = null;
    if (_presenceUserId != null) WidgetsBinding.instance.removeObserver(this);
    _presenceUserId = null;
  }

  @override
  // `state` would shadow StateNotifier.state.
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    final oddserId = _presenceUserId;
    if (oddserId == null) return;
    switch (lifecycle) {
      case AppLifecycleState.resumed:
        _repository.updatePresence(oddserId, ConnectionStatus.online);
        _startHeartbeat();
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // iOS reports hidden, then paused: write once.
        if (_heartbeat == null) return;
        _heartbeat?.cancel();
        _heartbeat = null;
        _repository.updatePresence(oddserId, ConnectionStatus.offline);
      case AppLifecycleState.inactive:
        break;
    }
  }

  /// Forget the previous account: the signed-in user changed or signed out.
  /// Its profile listener would fail with permission-denied and leave that
  /// error in the lobby for the next account, so it is cancelled here.
  void reset() {
    stopPresence();
    _stopListeningToProfile();
    if (mounted) _safeSetState(const AsyncValue.data(null));
  }

  void _stopListeningToProfile() {
    _profileSub?.cancel();
    _profileSub = null;
    _currentOddserId = null;
  }

  @override
  void dispose() {
    stopPresence();
    _stopListeningToProfile();
    super.dispose();
  }

  /// Get or create profile on login
  Future<OnlineUserProfile?> initializeProfile({
    required String oddserId,
    required String displayName,
    String? photoUrl,
  }) async {
    // Use safe state update helper
    _safeSetState(const AsyncValue.loading());

    try {
      OnlineUserProfile profile;
      try {
        profile = await _repository.getOrCreateProfile(
          oddserId,
          displayName: displayName,
          photoUrl: photoUrl,
        );
      } on FirebaseException catch (e) {
        // A request that reached Firestore before the new sign-in's token
        // did is refused; a fresh token and one more try settle it.
        if (e.code != 'permission-denied') rethrow;
        await _ref.read(authProvider).user?.getIdToken(true);
        profile = await _repository.getOrCreateProfile(
          oddserId,
          displayName: displayName,
          photoUrl: photoUrl,
        );
      }

      // The account changed while the profile loaded: reset() has already
      // cleared this one, so nothing of it may come back.
      if (!_isSignedInAs(oddserId)) return null;

      // Set current player ID for game provider
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _ref.read(currentPlayerIdProvider.notifier).state = oddserId;
      });

      // Set online status
      await _repository.updateOnlineStatus(oddserId, ConnectionStatus.online);
      if (!_isSignedInAs(oddserId)) return null;
      _startPresence(oddserId);

      _safeSetState(AsyncValue.data(profile));

      // Start listening to profile changes from Firestore
      _startListeningToProfile(oddserId);

      // Games that ended while this app was closed or elsewhere: their
      // results are recorded now. The profile listener shows the new stats.
      unawaited(_repository.applyPendingResults(oddserId));

      return profile;
    } catch (e, st) {
      _safeSetState(AsyncValue.error(e, st));
      return null;
    }
  }

  bool _isSignedInAs(String oddserId) =>
      mounted && _ref.read(authProvider).user?.uid == oddserId;

  /// Start listening to real-time profile updates from Firestore
  void _startListeningToProfile(String oddserId) {
    // Don't re-subscribe if already listening to same user
    if (_currentOddserId == oddserId && _profileSub != null) return;
    _stopListeningToProfile();
    _currentOddserId = oddserId;

    _profileSub = _repository.watchProfile(oddserId).listen(
      (profile) {
        if (mounted && profile != null && _currentOddserId == oddserId) {
          _safeSetState(AsyncValue.data(profile));
        }
      },
      onError: (Object e, StackTrace st) {
        // A dead listener is dropped, so the next initializeProfile starts
        // a new one instead of returning early.
        if (_currentOddserId != oddserId) return;
        _stopListeningToProfile();
        if (mounted) _safeSetState(AsyncValue.error(e, st));
      },
    );
  }

  /// Safely update state, deferring if during build phase
  void _safeSetState(AsyncValue<OnlineUserProfile?> newState) {
    // Check if we're in the middle of a build phase
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      // We're during build, defer the update
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) state = newState;
      });
    } else {
      // Safe to update immediately
      state = newState;
    }
  }

  /// Update display name
  Future<void> updateDisplayName(String oddserId, String displayName) async {
    try {
      await _repository.updateProfile(oddserId, {'displayName': displayName});
    } catch (_) {}
  }

  /// Update photo URL
  Future<void> updatePhotoUrl(String oddserId, String? photoUrl) async {
    try {
      await _repository.updateProfile(oddserId, {'photoUrl': photoUrl});
    } catch (_) {}
  }

  /// Set online status
  Future<void> setOnlineStatus(String oddserId, ConnectionStatus status) async {
    try {
      await _repository.updateOnlineStatus(oddserId, status);
    } catch (_) {}
  }

  /// Set current game
  Future<void> setCurrentGame(String oddserId, String? gameId) async {
    try {
      await _repository.updateOnlineStatus(
        oddserId,
        ConnectionStatus.online,
        currentGameId: gameId,
      );
    } catch (_) {}
  }

  /// Record a finished game in this player's stats. Safe to call more than
  /// once: the repository applies each game once per player.
  Future<bool> recordGameResult({
    required String gameId,
    required String oddserId,
  }) =>
      _repository.applyGameResult(gameId, oddserId);

  /// Mark user as offline (on app close/logout)
  Future<void> goOffline(String oddserId) async {
    stopPresence();
    _stopListeningToProfile();
    try {
      await _repository.updateOnlineStatus(oddserId, ConnectionStatus.offline);
      _ref.read(currentPlayerIdProvider.notifier).state = null;
    } catch (_) {}
  }
}

final onlineProfileNotifierProvider =
    StateNotifierProvider<OnlineProfileNotifier, AsyncValue<OnlineUserProfile?>>((ref) {
  final repository = ref.watch(onlineGameRepositoryProvider);
  final notifier = OnlineProfileNotifier(repository, ref);
  // Signing out, deleting the account or switching accounts ends the old
  // profile: its heartbeat, its listener and any error it left behind.
  ref.listen<String?>(authProvider.select((auth) => auth.user?.uid),
      (previous, next) {
    if (previous != null && previous != next) {
      notifier.reset();
      Future.microtask(() {
        final current = ref.read(currentPlayerIdProvider);
        if (current == previous) {
          ref.read(currentPlayerIdProvider.notifier).state = null;
        }
      });
    }
  });
  return notifier;
});

/// User tier name based on rating
final userTierNameProvider = Provider.family<String, int>((ref, rating) {
  if (rating < 1000) return 'Bronze';
  if (rating < 1500) return 'Silver';
  if (rating < 2000) return 'Gold';
  if (rating < 2500) return 'Platinum';
  if (rating < 3000) return 'Diamond';
  return 'Master';
});

/// User's current rating from profile
final currentUserRatingProvider = Provider<int>((ref) {
  final profileAsync = ref.watch(onlineProfileNotifierProvider);
  return profileAsync.valueOrNull?.rating ?? 1200;
});

/// User's win rate
final userWinRateProvider = Provider.family<double, OnlineUserProfile?>((ref, profile) {
  if (profile == null || profile.totalGames == 0) return 0.0;
  return profile.wins / profile.totalGames;
});
