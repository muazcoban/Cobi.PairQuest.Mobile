import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/online_game_repository.dart';
import '../../domain/entities/online_player.dart';
import 'online_game_provider.dart';

/// Current user's online profile
final onlineProfileProvider =
    StreamProvider.family<OnlineUserProfile?, String>((ref, oddserId) {
  final repository = ref.watch(onlineGameRepositoryProvider);
  return repository.watchProfile(oddserId);
});

/// Profile actions notifier
class OnlineProfileNotifier extends StateNotifier<AsyncValue<OnlineUserProfile?>> {
  final OnlineGameRepository _repository;
  final Ref _ref;
  Stream<OnlineUserProfile?>? _profileStream;
  String? _currentOddserId;

  OnlineProfileNotifier(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  /// Get or create profile on login
  Future<OnlineUserProfile?> initializeProfile({
    required String oddserId,
    required String displayName,
    String? photoUrl,
    String? email,
  }) async {
    // Use safe state update helper
    _safeSetState(const AsyncValue.loading());

    try {
      final profile = await _repository.getOrCreateProfile(
        oddserId,
        displayName: displayName,
        photoUrl: photoUrl,
        email: email,
      );

      // Set current player ID for game provider
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _ref.read(currentPlayerIdProvider.notifier).state = oddserId;
      });

      // Set online status
      await _repository.updateOnlineStatus(oddserId, ConnectionStatus.online);

      _safeSetState(AsyncValue.data(profile));

      // Start listening to profile changes from Firestore
      _startListeningToProfile(oddserId);

      return profile;
    } catch (e, st) {
      _safeSetState(AsyncValue.error(e, st));
      return null;
    }
  }

  /// Start listening to real-time profile updates from Firestore
  void _startListeningToProfile(String oddserId) {
    // Don't re-subscribe if already listening to same user
    if (_currentOddserId == oddserId) return;
    _currentOddserId = oddserId;

    _profileStream = _repository.watchProfile(oddserId);
    _profileStream?.listen(
      (profile) {
        if (mounted && profile != null) {
          _safeSetState(AsyncValue.data(profile));
        }
      },
      onError: (e, st) {
        if (mounted) {
          _safeSetState(AsyncValue.error(e, st));
        }
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

  /// Update stats after game
  /// [isRanked] determines if this is a ranked or casual game
  /// Rating only changes for ranked games
  Future<void> updateGameStats({
    required String oddserId,
    required bool isWin,
    required bool isRanked,
    int? newRating,
  }) async {
    try {
      await _repository.updateGameStats(
        oddserId,
        isWin: isWin,
        isRanked: isRanked,
        newRating: newRating,
      );
    } catch (_) {}
  }

  /// Mark user as offline (on app close/logout)
  Future<void> goOffline(String oddserId) async {
    try {
      await _repository.updateOnlineStatus(oddserId, ConnectionStatus.offline);
      _ref.read(currentPlayerIdProvider.notifier).state = null;
      // Stop listening to profile updates
      _currentOddserId = null;
      _profileStream = null;
    } catch (_) {}
  }
}

final onlineProfileNotifierProvider =
    StateNotifierProvider<OnlineProfileNotifier, AsyncValue<OnlineUserProfile?>>((ref) {
  final repository = ref.watch(onlineGameRepositoryProvider);
  return OnlineProfileNotifier(repository, ref);
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

/// ELO rating calculator
class EloCalculator {
  static const int kFactor = 32;

  /// Calculate new ratings after a game
  /// Returns (winnerNewRating, loserNewRating)
  static (int, int) calculateNewRatings({
    required int winnerRating,
    required int loserRating,
  }) {
    final expectedWinner = _expectedScore(winnerRating, loserRating);
    final expectedLoser = _expectedScore(loserRating, winnerRating);

    final newWinnerRating = (winnerRating + kFactor * (1 - expectedWinner)).round();
    final newLoserRating = (loserRating + kFactor * (0 - expectedLoser)).round();

    // Minimum rating is 100
    return (
      newWinnerRating.clamp(100, 9999),
      newLoserRating.clamp(100, 9999),
    );
  }

  /// Calculate expected score (probability of winning)
  static double _expectedScore(int playerRating, int opponentRating) {
    return 1 / (1 + _power(10, (opponentRating - playerRating) / 400));
  }

  static double _power(double base, double exponent) {
    return _exp(exponent * _ln(base));
  }

  static double _exp(double x) {
    // Using Dart's built-in
    return 2.718281828459045 * x.abs() < 700
        ? _expImpl(x)
        : (x > 0 ? double.infinity : 0);
  }

  static double _expImpl(double x) {
    double result = 1;
    double term = 1;
    for (int i = 1; i <= 100; i++) {
      term *= x / i;
      result += term;
      if (term.abs() < 1e-15) break;
    }
    return result;
  }

  static double _ln(double x) {
    if (x <= 0) return double.negativeInfinity;
    if (x == 1) return 0;

    // Using identity: ln(x) = 2 * arctanh((x-1)/(x+1))
    double y = (x - 1) / (x + 1);
    double y2 = y * y;
    double result = 0;
    double term = y;
    for (int i = 1; i <= 100; i += 2) {
      result += term / i;
      term *= y2;
      if (term.abs() < 1e-15) break;
    }
    return 2 * result;
  }
}

/// Provider to calculate rating change preview
final ratingChangePreviewProvider =
    Provider.family<(int, int), (int, int)>((ref, ratings) {
  final (winnerRating, loserRating) = ratings;
  return EloCalculator.calculateNewRatings(
    winnerRating: winnerRating,
    loserRating: loserRating,
  );
});
