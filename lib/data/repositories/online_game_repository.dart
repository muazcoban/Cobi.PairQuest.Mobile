import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/online_game.dart';
import '../../domain/entities/online_player.dart';
import '../../domain/services/online_ranking.dart';

/// Repository for online multiplayer game operations
///
/// KEY OPERATIONS:
/// - [watchGame] - Real-time game state updates via Firestore stream
/// - [submitMove] - Submit a card flip move (updates moves array)
/// - [applyGameResult] - Record a finished game in one player's stats, once
/// - [getOrCreateProfile] - Create or fetch user profile
///
/// STATS SYSTEM:
/// - Ranked games: Update rankedWins/rankedLosses/rankedGames + ELO rating
/// - Casual games: Update casualWins/casualLosses/casualGames (no rating change)
/// - Legacy fields (wins/losses/totalGames) kept for backward compatibility
class OnlineGameRepository {
  OnlineGameRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _gamesCollection = 'games';
  static const String _usersCollection = 'users';

  /// Reference to games collection
  CollectionReference<Map<String, dynamic>> get _gamesRef =>
      _firestore.collection(_gamesCollection);

  /// Reference to users collection
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(_usersCollection);

  // ========== GAME OPERATIONS ==========

  /// Create a new online game
  Future<String> createGame(OnlineGame game) async {
    try {
      final docRef = await _gamesRef.add(game.toFirestore());
      debugPrint('Created game: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating game: $e');
      rethrow;
    }
  }

  /// Get a game by ID
  Future<OnlineGame?> getGame(String gameId) async {
    try {
      final doc = await _gamesRef.doc(gameId).get();
      if (!doc.exists) return null;
      return OnlineGame.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error getting game: $e');
      return null;
    }
  }

  /// Watch a game for real-time updates
  Stream<OnlineGame?> watchGame(String gameId) {
    return _gamesRef.doc(gameId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return OnlineGame.fromFirestore(doc);
    });
  }

  /// Update game status
  Future<void> updateGameStatus(
    String gameId,
    OnlineGameStatus status, {
    String? winnerId,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status.name,
        'lastActivityAt': FieldValue.serverTimestamp(),
      };

      if (status == OnlineGameStatus.inProgress) {
        updates['startedAt'] = FieldValue.serverTimestamp();
      } else if (status == OnlineGameStatus.completed) {
        updates['completedAt'] = FieldValue.serverTimestamp();
        if (winnerId != null) {
          updates['winnerId'] = winnerId;
        }
      }

      await _gamesRef.doc(gameId).update(updates);
    } catch (e) {
      debugPrint('Error updating game status: $e');
      rethrow;
    }
  }

  /// Submit a move to the game
  Future<void> submitMove(String gameId, GameMove move) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final gameDoc = await transaction.get(_gamesRef.doc(gameId));
        if (!gameDoc.exists) throw Exception('Game not found');

        final game = OnlineGame.fromFirestore(gameDoc);

        // Find the player who made the move
        final playerIndex = game.players.indexWhere(
          (p) => p.oddserId == move.oddserId,
        );
        if (playerIndex == -1) throw Exception('Player not found');

        // CRITICAL: Verify it's actually this player's turn
        if (game.currentPlayerIndex != playerIndex) {
          debugPrint('🎮 Move rejected: Not player\'s turn. Current: ${game.currentPlayerIndex}, Attempted: $playerIndex');
          throw Exception('Not your turn');
        }

        // Update game state
        final newMoves = [...game.moves, move];
        final newMatchedPairIds = move.matched
            ? [...game.matchedPairIds, move.pairId]
            : game.matchedPairIds;

        final updatedPlayers = List<OnlinePlayer>.from(game.players);
        updatedPlayers[playerIndex] = updatedPlayers[playerIndex].addScore(
          move.scoreAwarded,
          matched: move.matched,
        );

        // Determine next player
        int nextPlayerIndex;
        bool extraTurnAwarded = false;
        if (move.matched) {
          // Same player gets another turn
          nextPlayerIndex = playerIndex;
          extraTurnAwarded = true;
        } else {
          // Next player's turn
          nextPlayerIndex = (playerIndex + 1) % game.players.length;
        }

        debugPrint('🎮 Move submitted: player=$playerIndex, matched=${move.matched}, nextPlayer=$nextPlayerIndex');

        // Check if game is completed
        final isCompleted = newMatchedPairIds.length >= game.totalPairs;
        final newStatus = isCompleted
            ? OnlineGameStatus.completed
            : OnlineGameStatus.inProgress;

        // Determine winner if completed
        String? winnerId;
        if (isCompleted) {
          final sortedPlayers = List<OnlinePlayer>.from(updatedPlayers)
            ..sort((a, b) => b.score.compareTo(a.score));
          // Check for draw - if top two scores are equal, no winner
          if (sortedPlayers.length >= 2 &&
              sortedPlayers[0].score == sortedPlayers[1].score) {
            // Draw - winnerId stays null
            debugPrint('🎮 Game ended in draw: ${sortedPlayers[0].score} - ${sortedPlayers[1].score}');
          } else {
            winnerId = sortedPlayers.first.oddserId;
            debugPrint('🎮 Winner: $winnerId with score ${sortedPlayers.first.score}');
          }
        }

        transaction.update(_gamesRef.doc(gameId), {
          'moves': newMoves.map((m) => m.toJson()).toList(),
          'matchedPairIds': newMatchedPairIds,
          'players': updatedPlayers.map((p) => p.toJson()).toList(),
          'currentPlayerIndex': nextPlayerIndex,
          'extraTurnAwarded': extraTurnAwarded,
          'status': newStatus.name,
          'lastActivityAt': FieldValue.serverTimestamp(),
          if (winnerId != null) 'winnerId': winnerId,
          if (isCompleted) 'completedAt': FieldValue.serverTimestamp(),
          if (isCompleted) 'statsPending': _statsPending(updatedPlayers),
        });
      });
    } catch (e) {
      debugPrint('Error submitting move: $e');
      rethrow;
    }
  }

  /// Join an existing game
  Future<void> joinGame(String gameId, OnlinePlayer player) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final gameDoc = await transaction.get(_gamesRef.doc(gameId));
        if (!gameDoc.exists) throw Exception('Game not found');

        final game = OnlineGame.fromFirestore(gameDoc);
        if (game.isFull) throw Exception('Game is full');

        // Assign color index based on player count
        final playerWithColor = player.copyWith(
          colorIndex: game.players.length,
        );

        transaction.update(_gamesRef.doc(gameId), {
          'players': FieldValue.arrayUnion([playerWithColor.toJson()]),
          'lastActivityAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint('Error joining game: $e');
      rethrow;
    }
  }

  /// Leave a game (forfeit)
  /// The leaving player loses, the remaining player wins.
  /// A game that has already ended keeps its result: leaving the result
  /// screen must not turn a win into a forfeit.
  Future<void> leaveGame(String gameId, String oddserId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final gameDoc = await transaction.get(_gamesRef.doc(gameId));
        if (!gameDoc.exists) {
          debugPrint('🎮 leaveGame: Game not found');
          return;
        }

        final game = OnlineGame.fromFirestore(gameDoc);
        if (game.status != OnlineGameStatus.inProgress &&
            game.status != OnlineGameStatus.waiting) {
          debugPrint('🎮 leaveGame: Game already ended (${game.status.name})');
          return;
        }

        // Find the opponent (they win by forfeit)
        final opponent = game.players.firstWhere(
          (p) => p.oddserId != oddserId,
          orElse: () => game.players.first,
        );

        debugPrint('🎮 Player $oddserId leaving game. Winner by forfeit: ${opponent.oddserId}');

        transaction.update(gameDoc.reference, {
          'status': OnlineGameStatus.abandoned.name,
          'winnerId': opponent.oddserId, // Opponent wins by forfeit
          'completedAt': FieldValue.serverTimestamp(),
          'lastActivityAt': FieldValue.serverTimestamp(),
          'statsPending': _statsPending(game.players),
        });
      });
    } catch (e) {
      debugPrint('Error leaving game: $e');
      rethrow;
    }
  }

  /// Pass the turn to the opponent when [oddserId]'s turn timer runs out.
  /// Does nothing if the turn already moved on (a move or another skip got
  /// there first), which [expectedMoveCount] detects.
  Future<void> skipTurn(
    String gameId,
    String oddserId, {
    required int expectedMoveCount,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final gameDoc = await transaction.get(_gamesRef.doc(gameId));
        if (!gameDoc.exists) return;

        final game = OnlineGame.fromFirestore(gameDoc);
        final playerIndex = game.players.indexWhere((p) => p.oddserId == oddserId);
        if (game.status != OnlineGameStatus.inProgress ||
            playerIndex == -1 ||
            game.currentPlayerIndex != playerIndex ||
            game.moves.length != expectedMoveCount) {
          return;
        }

        debugPrint('🎮 Turn timed out for $oddserId, passing the turn');
        transaction.update(gameDoc.reference, {
          'currentPlayerIndex': (playerIndex + 1) % game.players.length,
          'extraTurnAwarded': false,
          'lastActivityAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint('Error skipping turn: $e');
    }
  }

  /// End the game in [claimerId]'s favour because the opponent stopped
  /// playing on their own turn (app closed, connection lost).
  /// Only succeeds if the game is still exactly where the claimer saw it
  /// stall: same move count and same player to move.
  Future<bool> claimForfeitWin(
    String gameId,
    String claimerId, {
    required int expectedMoveCount,
    required int expectedPlayerIndex,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final gameDoc = await transaction.get(_gamesRef.doc(gameId));
        if (!gameDoc.exists) return false;

        final game = OnlineGame.fromFirestore(gameDoc);
        final claimerIndex = game.players.indexWhere((p) => p.oddserId == claimerId);
        if (game.status != OnlineGameStatus.inProgress ||
            claimerIndex == -1 ||
            game.currentPlayerIndex == claimerIndex ||
            game.currentPlayerIndex != expectedPlayerIndex ||
            game.moves.length != expectedMoveCount) {
          return false;
        }

        // An opponent who never made a move may never have seen the game
        // (their search was cancelled or timed out as the match was made).
        // Nobody wins such a game, so neither side gets a result.
        final stalledId = game.players[game.currentPlayerIndex].oddserId;
        final stalledEverMoved = game.moves.any((m) => m.oddserId == stalledId);
        debugPrint(stalledEverMoved
            ? '🎮 $claimerId wins by forfeit: opponent stopped responding'
            : '🎮 Opponent never played; game ends without a result');
        transaction.update(gameDoc.reference, {
          'status': OnlineGameStatus.abandoned.name,
          'winnerId': stalledEverMoved ? claimerId : null,
          'completedAt': FieldValue.serverTimestamp(),
          'lastActivityAt': FieldValue.serverTimestamp(),
          'statsPending': _statsPending(game.players),
        });
        return true;
      });
    } catch (e) {
      debugPrint('Error claiming forfeit win: $e');
      return false;
    }
  }

  /// Update player connection status
  Future<void> updatePlayerConnection(
    String gameId,
    String oddserId,
    ConnectionStatus status,
  ) async {
    try {
      final game = await getGame(gameId);
      if (game == null) return;

      final playerIndex = game.players.indexWhere((p) => p.oddserId == oddserId);
      if (playerIndex == -1) return;

      final updatedPlayers = List<OnlinePlayer>.from(game.players);
      updatedPlayers[playerIndex] = updatedPlayers[playerIndex].copyWith(
        connectionStatus: status,
        lastActivityAt: DateTime.now(),
      );

      await _gamesRef.doc(gameId).update({
        'players': updatedPlayers.map((p) => p.toJson()).toList(),
        'lastActivityAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating player connection: $e');
    }
  }

  // ========== USER PROFILE OPERATIONS ==========

  /// Get or create user profile
  Future<OnlineUserProfile> getOrCreateProfile(String oddserId, {
    required String displayName,
    String? photoUrl,
  }) async {
    try {
      final doc = await _usersRef.doc(oddserId).get();

      if (doc.exists) {
        final existingProfile = OnlineUserProfile.fromFirestore(doc);
        // Ranked counters an old version left out, and the flag the
        // ranking query uses.
        final repair = {
          ...OnlineRanking.legacyRankedRepair(doc.data()!),
          // From now on this app records the player's results; see
          // applyPendingResults.
          if (!doc.data()!.containsKey(resultsSinceField))
            resultsSinceField: FieldValue.serverTimestamp(),
        };

        // Update profile if displayName changed (e.g., Guest -> Gmail name).
        // Profiles are readable by every signed-in user, so an e-mail address
        // that older versions stored here is removed.
        final needsUpdate = existingProfile.displayName != displayName ||
            (photoUrl != null && existingProfile.photoUrl != photoUrl) ||
            existingProfile.email != null ||
            repair.isNotEmpty;

        if (needsUpdate) {
          final updates = <String, dynamic>{
            'displayName': displayName,
            'lastSeenAt': FieldValue.serverTimestamp(),
            ...repair,
          };
          if (photoUrl != null) updates['photoUrl'] = photoUrl;
          if (existingProfile.email != null) updates['email'] = FieldValue.delete();

          await _usersRef.doc(oddserId).update(updates);
          debugPrint('🔄 Updated profile: displayName=$displayName');

          return existingProfile.copyWith(
            displayName: displayName,
            photoUrl: photoUrl ?? existingProfile.photoUrl,
            email: null,
            rankedGames: (repair['rankedGames'] as int?) ??
                existingProfile.rankedGames,
            rankedWins: (repair['rankedWins'] as int?) ?? existingProfile.rankedWins,
            rankedLosses:
                (repair['rankedLosses'] as int?) ?? existingProfile.rankedLosses,
          );
        }

        return existingProfile;
      }

      // Create new profile
      final profile = OnlineUserProfile(
        oddserId: oddserId,
        displayName: displayName,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
        lastSeenAt: DateTime.now(),
      );

      await _usersRef.doc(oddserId).set({
        ...profile.toFirestore(),
        resultsSinceField: FieldValue.serverTimestamp(),
      });
      debugPrint('🆕 Created new profile: displayName=$displayName');
      return profile;
    } catch (e) {
      debugPrint('Error getting/creating profile: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile(String oddserId, Map<String, dynamic> updates) async {
    try {
      updates['lastSeenAt'] = FieldValue.serverTimestamp();
      await _usersRef.doc(oddserId).update(updates);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  /// Update user online status
  Future<void> updateOnlineStatus(
    String oddserId,
    ConnectionStatus status, {
    String? currentGameId,
  }) async {
    try {
      await _usersRef.doc(oddserId).update({
        'status': status.name,
        'lastSeenAt': FieldValue.serverTimestamp(),
        if (currentGameId != null) 'currentGameId': currentGameId,
        if (currentGameId == null) 'currentGameId': FieldValue.delete(),
      });
    } catch (e) {
      debugPrint('Error updating online status: $e');
    }
  }

  /// Write the presence status and refresh lastSeenAt, leaving the current
  /// game alone (updateOnlineStatus clears it).
  Future<void> updatePresence(String oddserId, ConnectionStatus status) async {
    try {
      await _usersRef.doc(oddserId).update({
        'status': status.name,
        'lastSeenAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating presence: $e');
    }
  }

  /// Marks every player of a game that just ended as still owing the
  /// result to their own stats. Each player's app records it and removes
  /// its own mark, even when that player was not watching the end.
  static Map<String, bool> _statsPending(List<OnlinePlayer> players) => {
        for (final player in players) player.oddserId: true,
      };

  /// Records a finished game in [oddserId]'s stats, once.
  ///
  /// Each player's app writes only that player's profile, so the result is
  /// applied by each side separately. The game remembers who has applied
  /// it (`statsAppliedFor`), which makes a second call, from the result
  /// screen and from [applyPendingResults], a no-op. Ranked games move the
  /// rating by the Elo change between the ratings stored in the game; the
  /// change is added to the current rating, so a stale copy of the profile
  /// cannot overwrite a newer rating. Returns whether anything was written.
  Future<bool> applyGameResult(String gameId, String oddserId) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final gameRef = _gamesRef.doc(gameId);
        final userRef = _usersRef.doc(oddserId);
        final gameDoc = await transaction.get(gameRef);
        if (!gameDoc.exists) return false;
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) return false;

        final game = gameDoc.data()!;
        final status = game['status'];
        if (status != OnlineGameStatus.completed.name &&
            status != OnlineGameStatus.abandoned.name) {
          return false;
        }
        final applied = List<String>.from(
          (game['statsAppliedFor'] as List?) ?? const <String>[],
        );
        // Firebase user IDs are letters and digits, so the dotted path
        // names the map entry.
        final markApplied = <String, dynamic>{
          'statsAppliedFor': FieldValue.arrayUnion([oddserId]),
          'statsPending.$oddserId': FieldValue.delete(),
        };
        if (applied.contains(oddserId)) return false;

        final players = [
          for (final p in (game['players'] as List? ?? const []))
            Map<String, dynamic>.from(p as Map),
        ];
        final me = players.where((p) => p['oddserId'] == oddserId).firstOrNull;
        final opponent =
            players.where((p) => p['oddserId'] != oddserId).firstOrNull;
        final winnerId = game['winnerId'] as String?;
        // No opponent, or an abandoned game nobody won: nothing to record.
        if (me == null ||
            opponent == null ||
            (winnerId == null && status == OnlineGameStatus.abandoned.name)) {
          transaction.update(gameRef, markApplied);
          return false;
        }

        final isRanked = game['mode'] == OnlineGameMode.ranked.name;
        final isDraw = winnerId == null;
        final isWin = winnerId == oddserId;
        final updates = <String, dynamic>{
          'lastSeenAt': FieldValue.serverTimestamp(),
          // Totals over every mode, read by older app versions.
          'totalGames': FieldValue.increment(1),
          if (isDraw) 'draws': FieldValue.increment(1),
          if (isWin) 'wins': FieldValue.increment(1),
          if (!isDraw && !isWin) 'losses': FieldValue.increment(1),
        };
        if (isRanked) {
          final user = userDoc.data()!;
          final current =
              (user['rating'] as num?)?.toInt() ?? OnlineRanking.startRating;
          final delta = OnlineRanking.ratingDelta(
            rating: (me['rating'] as num?)?.toInt() ?? current,
            opponentRating: (opponent['rating'] as num?)?.toInt() ??
                OnlineRanking.startRating,
            score: isDraw ? 0.5 : (isWin ? 1 : 0),
          );
          updates['rating'] = OnlineRanking.applyDelta(current, delta);
          updates['isRanked'] = true;
          updates['rankedGames'] = FieldValue.increment(1);
          if (isWin) updates['rankedWins'] = FieldValue.increment(1);
          if (!isDraw && !isWin) {
            updates['rankedLosses'] = FieldValue.increment(1);
          }
        } else {
          updates['casualGames'] = FieldValue.increment(1);
          if (isWin) updates['casualWins'] = FieldValue.increment(1);
          if (!isDraw && !isWin) {
            updates['casualLosses'] = FieldValue.increment(1);
          }
        }

        transaction.update(userRef, updates);
        transaction.update(gameRef, markApplied);
        debugPrint('🎮 Result recorded: game=$gameId ranked=$isRanked '
            'win=$isWin draw=$isDraw');
        return true;
      });
    } catch (e) {
      debugPrint('Error recording game result: $e');
      return false;
    }
  }

  /// When this app version started recording the player's results, set
  /// on the profile at the first setup.
  static const String resultsSinceField = 'resultsSince';

  /// Records the games that ended while [oddserId]'s app was closed or on
  /// another screen. Returns how many were recorded.
  ///
  /// Only games that ended after [resultsSinceField] count. Before that the
  /// player ran an older version, which wrote its own stats at the end of
  /// a game it watched but did not take the game's pending mark away;
  /// recording those games again would count them twice. Older pending
  /// games are only unmarked.
  Future<int> applyPendingResults(String oddserId, {int limit = 20}) async {
    try {
      final userDoc = await _usersRef.doc(oddserId).get();
      final since = userDoc.data()?[resultsSinceField];
      if (since is! Timestamp) return 0;

      final pending = await _gamesRef
          .where('playerIds', arrayContains: oddserId)
          .where(FieldPath(['statsPending', oddserId]), isEqualTo: true)
          .limit(limit)
          .get();
      var recorded = 0;
      for (final doc in pending.docs) {
        final endedAt = doc.data()['completedAt'];
        if (endedAt is! Timestamp || endedAt.compareTo(since) < 0) {
          await _gamesRef.doc(doc.id).update({
            'statsAppliedFor': FieldValue.arrayUnion([oddserId]),
            'statsPending.$oddserId': FieldValue.delete(),
          });
          continue;
        }
        if (await applyGameResult(doc.id, oddserId)) recorded++;
      }
      return recorded;
    } catch (e) {
      debugPrint('Error recording pending results: $e');
      return 0;
    }
  }

  /// Watch user profile
  Stream<OnlineUserProfile?> watchProfile(String oddserId) {
    return _usersRef.doc(oddserId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return OnlineUserProfile.fromFirestore(doc);
    });
  }

  /// Get user's active game
  Future<OnlineGame?> getUserActiveGame(String oddserId) async {
    try {
      final profile = await _usersRef.doc(oddserId).get();
      if (!profile.exists) return null;

      final data = profile.data();
      final gameId = data?['currentGameId'] as String?;
      if (gameId == null) return null;

      return await getGame(gameId);
    } catch (e) {
      debugPrint('Error getting user active game: $e');
      return null;
    }
  }
}
