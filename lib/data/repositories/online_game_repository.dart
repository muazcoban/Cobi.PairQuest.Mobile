import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/online_game.dart';
import '../../domain/entities/online_player.dart';

/// Repository for online multiplayer game operations
///
/// KEY OPERATIONS:
/// - [watchGame] - Real-time game state updates via Firestore stream
/// - [submitMove] - Submit a card flip move (updates moves array)
/// - [updateGameStats] - Update win/loss stats (ranked vs casual)
/// - [getOrCreateProfile] - Create or fetch user profile
///
/// STATS SYSTEM:
/// - Ranked games: Update rankedWins/rankedLosses/rankedGames + ELO rating
/// - Casual games: Update casualWins/casualLosses/casualGames (no rating change)
/// - Legacy fields (wins/losses/totalGames) kept for backward compatibility
class OnlineGameRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  /// The leaving player loses, the remaining player wins
  Future<void> leaveGame(String gameId, String oddserId) async {
    try {
      // Get the game to find the opponent (winner)
      final game = await getGame(gameId);
      if (game == null) {
        debugPrint('🎮 leaveGame: Game not found');
        return;
      }

      // Find the opponent (they win by forfeit)
      final opponent = game.players.firstWhere(
        (p) => p.oddserId != oddserId,
        orElse: () => game.players.first,
      );

      debugPrint('🎮 Player $oddserId leaving game. Winner by forfeit: ${opponent.oddserId}');

      // Update game status with winner
      await _gamesRef.doc(gameId).update({
        'status': OnlineGameStatus.abandoned.name,
        'winnerId': opponent.oddserId,  // Opponent wins by forfeit
        'completedAt': FieldValue.serverTimestamp(),
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      debugPrint('🎮 Game marked as abandoned. Winner: ${opponent.oddserId}');
    } catch (e) {
      debugPrint('Error leaving game: $e');
      rethrow;
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
    String? email,
  }) async {
    try {
      final doc = await _usersRef.doc(oddserId).get();

      if (doc.exists) {
        final existingProfile = OnlineUserProfile.fromFirestore(doc);

        // Update profile if displayName changed (e.g., Guest -> Gmail name)
        final needsUpdate = existingProfile.displayName != displayName ||
            (photoUrl != null && existingProfile.photoUrl != photoUrl) ||
            (email != null && existingProfile.email != email);

        if (needsUpdate) {
          final updates = <String, dynamic>{
            'displayName': displayName,
            'lastSeenAt': FieldValue.serverTimestamp(),
          };
          if (photoUrl != null) updates['photoUrl'] = photoUrl;
          if (email != null) updates['email'] = email;

          await _usersRef.doc(oddserId).update(updates);
          debugPrint('🔄 Updated profile: displayName=$displayName, email=$email');

          return existingProfile.copyWith(
            displayName: displayName,
            photoUrl: photoUrl ?? existingProfile.photoUrl,
            email: email ?? existingProfile.email,
          );
        }

        return existingProfile;
      }

      // Create new profile
      final profile = OnlineUserProfile(
        oddserId: oddserId,
        displayName: displayName,
        photoUrl: photoUrl,
        email: email,
        createdAt: DateTime.now(),
        lastSeenAt: DateTime.now(),
      );

      await _usersRef.doc(oddserId).set(profile.toFirestore());
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

  /// Update user stats after game
  /// [isRanked] determines which stats to update (ranked vs casual)
  /// Rating only changes for ranked games
  Future<void> updateGameStats(
    String oddserId, {
    required bool isWin,
    required bool isRanked,
    int? newRating,
  }) async {
    try {
      final updates = <String, dynamic>{
        'lastSeenAt': FieldValue.serverTimestamp(),
        // Legacy fields (for backward compatibility)
        if (isWin) 'wins': FieldValue.increment(1),
        if (!isWin) 'losses': FieldValue.increment(1),
        'totalGames': FieldValue.increment(1),
      };

      if (isRanked) {
        // Ranked game stats
        if (newRating != null) {
          updates['rating'] = newRating;
        }
        if (isWin) {
          updates['rankedWins'] = FieldValue.increment(1);
        } else {
          updates['rankedLosses'] = FieldValue.increment(1);
        }
        updates['rankedGames'] = FieldValue.increment(1);
      } else {
        // Casual game stats
        if (isWin) {
          updates['casualWins'] = FieldValue.increment(1);
        } else {
          updates['casualLosses'] = FieldValue.increment(1);
        }
        updates['casualGames'] = FieldValue.increment(1);
      }

      await _usersRef.doc(oddserId).update(updates);
      debugPrint('🎮 Stats updated: isRanked=$isRanked, isWin=$isWin');
    } catch (e) {
      debugPrint('Error updating game stats: $e');
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
