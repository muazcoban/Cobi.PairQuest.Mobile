import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/utils/card_shuffle.dart';
import '../../domain/entities/matchmaking.dart';
import '../../domain/entities/online_game.dart';
import '../../domain/entities/online_player.dart';

/// Repository for matchmaking operations
///
/// KEY FLOWS:
/// 1. MATCHMAKING: joinQueue -> findMatch -> _createMatchedGame
/// 2. FRIEND INVITE: sendInvitation -> acceptInvitation -> _createFriendGame
/// 3. FRIENDSHIPS: sendFriendRequest -> acceptFriendRequest -> watchFriends
///
/// CRITICAL NOTES:
/// - [acceptInvitation] creates game OUTSIDE transaction (has async calls)
/// - [sendInvitation] auto-cancels pending invites to same user
/// - [watchFriends] uses broadcast StreamController for multiple listeners
class MatchmakingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _matchmakingCollection = 'matchmaking';
  static const String _gamesCollection = 'games';
  static const String _invitationsCollection = 'invitations';
  static const String _friendshipsCollection = 'friendships';

  /// Queue timeout in seconds
  static const int queueTimeoutSeconds = 60;

  /// Rating radius expansion interval (seconds)
  static const int ratingExpansionInterval = 15;

  /// Rating radius expansion amount
  static const int ratingExpansionAmount = 100;

  // ========== MATCHMAKING QUEUE ==========

  /// Join the matchmaking queue
  Future<String> joinQueue({
    required String oddserId,
    required String displayName,
    String? photoUrl,
    required int rating,
    int preferredLevel = 0,
    MatchmakingMode mode = MatchmakingMode.any,
  }) async {
    try {
      final now = DateTime.now();
      final entry = MatchmakingEntry(
        id: '', // Will be set by Firestore
        oddserId: oddserId,
        displayName: displayName,
        photoUrl: photoUrl,
        rating: rating,
        preferredLevel: preferredLevel,
        mode: mode,
        createdAt: now,
        expiresAt: now.add(const Duration(seconds: queueTimeoutSeconds)),
      );

      final docRef = await _firestore
          .collection(_matchmakingCollection)
          .add(entry.toFirestore());

      debugPrint('Joined queue: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error joining queue: $e');
      rethrow;
    }
  }

  /// Leave the matchmaking queue
  Future<void> leaveQueue(String queueId) async {
    try {
      await _firestore.collection(_matchmakingCollection).doc(queueId).delete();
      debugPrint('Left queue: $queueId');
    } catch (e) {
      debugPrint('Error leaving queue: $e');
    }
  }

  /// Watch queue entry status
  Stream<MatchmakingEntry?> watchQueueEntry(String queueId) {
    return _firestore
        .collection(_matchmakingCollection)
        .doc(queueId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return MatchmakingEntry.fromFirestore(doc);
    });
  }

  /// Find a match for the user (client-side matching)
  /// In production, this should be a Cloud Function
  Future<String?> findMatch(String queueId) async {
    try {
      final myDoc = await _firestore
          .collection(_matchmakingCollection)
          .doc(queueId)
          .get();

      if (!myDoc.exists) return null;

      final myEntry = MatchmakingEntry.fromFirestore(myDoc);
      if (!myEntry.isActive) return null;

      // Find compatible waiting players
      // Note: Using client-side filter for oddserId to avoid needing composite index
      final candidates = await _firestore
          .collection(_matchmakingCollection)
          .where('status', isEqualTo: MatchmakingStatus.waiting.name)
          .limit(20)  // Fetch more to account for self-filtering
          .get();

      for (final candidateDoc in candidates.docs) {
        final candidate = MatchmakingEntry.fromFirestore(candidateDoc);
        // Skip self (client-side filter instead of isNotEqualTo query)
        if (candidate.oddserId == myEntry.oddserId) continue;
        if (!candidate.isActive) continue;

        if (myEntry.isCompatibleWith(candidate)) {
          // Use transaction to prevent race condition where both players create separate games
          // Only one player should create the game - the one who wins the transaction
          final gameId = await _firestore.runTransaction<String?>((transaction) async {
            // Re-read both entries inside transaction to check latest status
            final freshMyDoc = await transaction.get(myDoc.reference);
            final freshCandidateDoc = await transaction.get(candidateDoc.reference);

            if (!freshMyDoc.exists || !freshCandidateDoc.exists) {
              return null;
            }

            final freshMyEntry = MatchmakingEntry.fromFirestore(freshMyDoc);
            final freshCandidate = MatchmakingEntry.fromFirestore(freshCandidateDoc);

            // CRITICAL: Check if both are still waiting (not already matched by other player)
            if (freshMyEntry.status != MatchmakingStatus.waiting ||
                freshCandidate.status != MatchmakingStatus.waiting) {
              debugPrint('🎮 Race condition avoided: one player already matched');
              return null;
            }

            // Mark both as "matching" to prevent double-match
            transaction.update(myDoc.reference, {
              'status': MatchmakingStatus.matched.name,
              'matchedOpponentId': candidate.oddserId,
            });
            transaction.update(candidateDoc.reference, {
              'status': MatchmakingStatus.matched.name,
              'matchedOpponentId': myEntry.oddserId,
            });

            // Return a marker to indicate we won the transaction
            return 'CREATE_GAME';
          });

          // If we won the transaction, create the game
          if (gameId == 'CREATE_GAME') {
            final newGameId = await _createMatchedGame(myEntry, candidate);

            // Update both entries with the game ID
            await _firestore.runTransaction((transaction) async {
              transaction.update(myDoc.reference, {'matchedGameId': newGameId});
              transaction.update(candidateDoc.reference, {'matchedGameId': newGameId});
            });

            debugPrint('Match found! Game ID: $newGameId');
            return newGameId;
          } else if (gameId == null) {
            // Race condition - other player created the game, check if we got matched
            final refreshedDoc = await myDoc.reference.get();
            if (refreshedDoc.exists) {
              final refreshedEntry = MatchmakingEntry.fromFirestore(refreshedDoc);
              if (refreshedEntry.matchedGameId != null) {
                debugPrint('Match found via other player! Game ID: ${refreshedEntry.matchedGameId}');
                return refreshedEntry.matchedGameId;
              }
            }
          }
        }
      }

      // No match found, expand rating radius
      final timeInQueue = DateTime.now().difference(myEntry.createdAt).inSeconds;
      final expansions = timeInQueue ~/ ratingExpansionInterval;
      final newRadius = 100 + (expansions * ratingExpansionAmount);

      if (newRadius > myEntry.ratingRadius) {
        await _firestore
            .collection(_matchmakingCollection)
            .doc(queueId)
            .update({'ratingRadius': newRadius});
        debugPrint('Expanded rating radius to $newRadius');
      }

      return null;
    } catch (e) {
      debugPrint('Error finding match: $e');
      return null;
    }
  }

  /// Create a game for matched players
  Future<String> _createMatchedGame(
    MatchmakingEntry player1,
    MatchmakingEntry player2,
  ) async {
    // Determine level (use preference or default to 5)
    int level = 5;
    if (player1.preferredLevel > 0) {
      level = player1.preferredLevel;
    } else if (player2.preferredLevel > 0) {
      level = player2.preferredLevel;
    }

    // Grid size based on level
    final (rows, cols) = _getGridSize(level);

    // Pick a random theme
    final theme = CardShuffle.getRandomTheme();
    final themeEmojis = CardShuffle.themeImages[theme] ?? CardShuffle.themeImages['animals']!;

    // Generate card pairs with emojis (shuffled)
    final totalPairs = (rows * cols) ~/ 2;
    final random = Random();
    final shuffledEmojis = List<String>.from(themeEmojis)..shuffle(random);
    final selectedEmojis = shuffledEmojis.take(totalPairs).toList();

    final cardPairIds = <String>[];
    for (int i = 0; i < totalPairs; i++) {
      final emoji = selectedEmojis[i];
      cardPairIds.add(emoji);
      cardPairIds.add(emoji);
    }
    cardPairIds.shuffle(random);

    // Create players
    final onlinePlayer1 = OnlinePlayer(
      oddserId: player1.oddserId,
      displayName: player1.displayName,
      photoUrl: player1.photoUrl,
      rating: player1.rating,
      colorIndex: 0,
      lastActivityAt: DateTime.now(),
    );

    final onlinePlayer2 = OnlinePlayer(
      oddserId: player2.oddserId,
      displayName: player2.displayName,
      photoUrl: player2.photoUrl,
      rating: player2.rating,
      colorIndex: 1,
      lastActivityAt: DateTime.now(),
    );

    // Determine game mode
    final gameMode = player1.mode == MatchmakingMode.ranked ||
            player2.mode == MatchmakingMode.ranked
        ? OnlineGameMode.ranked
        : OnlineGameMode.casual;

    final game = OnlineGame(
      id: '',
      status: OnlineGameStatus.inProgress,
      mode: gameMode,
      level: level,
      rows: rows,
      cols: cols,
      players: [onlinePlayer1, onlinePlayer2],
      cardPairIds: cardPairIds,
      createdAt: DateTime.now(),
      startedAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );

    final docRef = await _firestore.collection(_gamesCollection).add(
      game.toFirestore(),
    );

    return docRef.id;
  }

  /// Get grid size for level
  (int, int) _getGridSize(int level) {
    const gridSizes = <int, (int, int)>{
      1: (2, 2),
      2: (2, 3),
      3: (2, 4),
      4: (3, 4),
      5: (4, 4),
      6: (4, 5),
      7: (5, 6),
      8: (6, 6),
      9: (6, 7),
      10: (8, 8),
    };
    return gridSizes[level.clamp(1, 10)] ?? (4, 4);
  }

  /// Clean up expired queue entries
  Future<void> cleanupExpiredEntries() async {
    try {
      final now = Timestamp.now();
      final expired = await _firestore
          .collection(_matchmakingCollection)
          .where('expiresAt', isLessThan: now)
          .where('status', isEqualTo: 'waiting')
          .get();

      // Delete expired entries to keep collection small (performance optimization)
      final batch = _firestore.batch();
      for (final doc in expired.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (expired.docs.isNotEmpty) {
        debugPrint('Cleaned up ${expired.docs.length} expired queue entries');
      }
    } catch (e) {
      debugPrint('Error cleaning up expired entries: $e');
    }
  }

  // ========== GAME INVITATIONS ==========

  /// Send game invitation to a friend
  /// Automatically cancels any pending invitations from the same user to the same target
  Future<String> sendInvitation({
    required String fromUserId,
    required String fromDisplayName,
    String? fromPhotoUrl,
    required String toUserId,
    int level = 5,
  }) async {
    try {
      debugPrint('📨 Sending invitation: from=$fromUserId ($fromDisplayName) to=$toUserId');

      // Cancel any existing pending invitations from this user to this target
      await cancelPendingInvitationsFromUser(
        fromUserId: fromUserId,
        toUserId: toUserId,
      );

      final now = DateTime.now();
      final invitation = GameInvitation(
        id: '',
        fromUserId: fromUserId,
        fromDisplayName: fromDisplayName,
        fromPhotoUrl: fromPhotoUrl,
        toUserId: toUserId,
        level: level,
        createdAt: now,
        expiresAt: now.add(const Duration(minutes: 5)),
      );

      final docRef = await _firestore
          .collection(_invitationsCollection)
          .add(invitation.toFirestore());

      debugPrint('📨 Invitation sent successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('📨 Error sending invitation: $e');
      rethrow;
    }
  }

  /// Accept game invitation
  Future<String> acceptInvitation(String invitationId) async {
    debugPrint('📨 Repository.acceptInvitation: $invitationId');
    try {
      final invRef = _firestore.collection(_invitationsCollection).doc(invitationId);

      // Step 1: Use transaction to verify and mark invitation as accepted
      debugPrint('📨 Step 1: Running transaction to mark invitation as accepted');
      final invitation = await _firestore.runTransaction((transaction) async {
        final invDoc = await transaction.get(invRef);

        if (!invDoc.exists) throw Exception('Invitation not found');

        final inv = GameInvitation.fromFirestore(invDoc);
        debugPrint('📨 Invitation status: ${inv.status}, isPending: ${inv.isPending}');
        if (!inv.isPending) throw Exception('Invitation is not pending');

        // Mark as accepted with temporary gameId (to prevent double-accept)
        transaction.update(invDoc.reference, {
          'status': InvitationStatus.accepted.name,
          'gameId': 'CREATING',
        });

        return inv;
      });
      debugPrint('📨 Step 1 complete. Invitation from: ${invitation.fromUserId} to: ${invitation.toUserId}');

      // Step 2: Create game OUTSIDE transaction (has async calls)
      debugPrint('📨 Step 2: Creating friend game');
      final gameId = await _createFriendGame(invitation);
      debugPrint('📨 Step 2 complete. Game ID: $gameId');

      // Step 3: Update invitation with real game ID
      debugPrint('📨 Step 3: Updating invitation with game ID');
      await invRef.update({'gameId': gameId});
      debugPrint('📨 Step 3 complete. Invitation accepted successfully!');

      return gameId;
    } catch (e) {
      debugPrint('📨 Error accepting invitation: $e');
      rethrow;
    }
  }

  /// Decline game invitation
  Future<void> declineInvitation(String invitationId) async {
    try {
      await _firestore
          .collection(_invitationsCollection)
          .doc(invitationId)
          .update({'status': InvitationStatus.declined.name});
    } catch (e) {
      debugPrint('Error declining invitation: $e');
    }
  }

  /// Cancel all pending invitations from a user to another user
  /// This is called before sending a new invitation to prevent duplicates
  Future<void> cancelPendingInvitationsFromUser({
    required String fromUserId,
    required String toUserId,
  }) async {
    try {
      debugPrint('📨 Cancelling pending invitations from $fromUserId to $toUserId');

      // Find all pending invitations from this user to this target
      final snapshot = await _firestore
          .collection(_invitationsCollection)
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .get();

      // Filter for pending ones and cancel them
      final batch = _firestore.batch();
      int cancelledCount = 0;

      for (final doc in snapshot.docs) {
        final invitation = GameInvitation.fromFirestore(doc);
        if (invitation.isPending) {
          batch.update(doc.reference, {'status': InvitationStatus.cancelled.name});
          cancelledCount++;
        }
      }

      if (cancelledCount > 0) {
        await batch.commit();
        debugPrint('📨 Cancelled $cancelledCount pending invitations');
      }
    } catch (e) {
      debugPrint('📨 Error cancelling pending invitations: $e');
      // Don't rethrow - this is a cleanup operation, shouldn't block new invitation
    }
  }

  /// Watch a specific invitation (for sender to know when accepted)
  Stream<GameInvitation?> watchInvitation(String invitationId) {
    return _firestore
        .collection(_invitationsCollection)
        .doc(invitationId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return GameInvitation.fromFirestore(doc);
    });
  }

  /// Watch pending invitations for a user
  /// Uses simplified query to avoid Firestore composite index requirement
  Stream<List<GameInvitation>> watchPendingInvitations(String oddserId) {
    debugPrint('📨 Starting to watch invitations for user: $oddserId');
    // Simplified query - only filter by toUserId, do status/sort client-side
    return _firestore
        .collection(_invitationsCollection)
        .where('toUserId', isEqualTo: oddserId)
        .snapshots()
        .map((snapshot) {
      debugPrint('📨 Received ${snapshot.docs.length} total invitations for user');
      final invitations = snapshot.docs
          .map((doc) => GameInvitation.fromFirestore(doc))
          .where((inv) => inv.isPending && !inv.isExpired)  // Client-side filter
          .toList();
      // Client-side sort by createdAt descending
      invitations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      debugPrint('📨 After filtering: ${invitations.length} pending invitations');
      for (final inv in invitations) {
        debugPrint('📨 Invitation from ${inv.fromDisplayName} (${inv.fromUserId})');
      }
      return invitations;
    });
  }

  /// Create a friend game
  Future<String> _createFriendGame(GameInvitation invitation) async {
    // Get both users' profiles in parallel (performance optimization)
    final userDocs = await Future.wait([
      _firestore.collection('users').doc(invitation.fromUserId).get(),
      _firestore.collection('users').doc(invitation.toUserId).get(),
    ]);
    final fromUserDoc = userDocs[0];
    final toUserDoc = userDocs[1];

    final fromData = fromUserDoc.data() ?? {};
    final toData = toUserDoc.data() ?? {};

    final (rows, cols) = _getGridSize(invitation.level);
    final totalPairs = (rows * cols) ~/ 2;

    // Pick a random theme
    final theme = CardShuffle.getRandomTheme();
    final themeEmojis = CardShuffle.themeImages[theme] ?? CardShuffle.themeImages['animals']!;

    final random = Random();
    final shuffledEmojis = List<String>.from(themeEmojis)..shuffle(random);
    final selectedEmojis = shuffledEmojis.take(totalPairs).toList();

    final cardPairIds = <String>[];
    for (int i = 0; i < totalPairs; i++) {
      final emoji = selectedEmojis[i];
      cardPairIds.add(emoji);
      cardPairIds.add(emoji);
    }
    cardPairIds.shuffle(random);

    final player1 = OnlinePlayer(
      oddserId: invitation.fromUserId,
      displayName: fromData['displayName'] ?? 'Player 1',
      photoUrl: fromData['photoUrl'],
      rating: fromData['rating'] ?? 1200,
      colorIndex: 0,
      lastActivityAt: DateTime.now(),
    );

    final player2 = OnlinePlayer(
      oddserId: invitation.toUserId,
      displayName: toData['displayName'] ?? 'Player 2',
      photoUrl: toData['photoUrl'],
      rating: toData['rating'] ?? 1200,
      colorIndex: 1,
      lastActivityAt: DateTime.now(),
    );

    final game = OnlineGame(
      id: '',
      status: OnlineGameStatus.inProgress,
      mode: OnlineGameMode.friend,
      level: invitation.level,
      rows: rows,
      cols: cols,
      players: [player1, player2],
      cardPairIds: cardPairIds,
      createdAt: DateTime.now(),
      startedAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
      // currentPlayerIndex defaults to 0, meaning player1 (invitation sender) starts
    );

    debugPrint('🎮 Creating friend game: player0=${player1.oddserId} (sender), player1=${player2.oddserId} (receiver), currentPlayerIndex=0');

    final docRef = await _firestore.collection(_gamesCollection).add(
      game.toFirestore(),
    );

    debugPrint('🎮 Friend game created: ${docRef.id}');
    return docRef.id;
  }

  // ========== FRIENDSHIPS ==========

  /// Send friend request
  Future<String> sendFriendRequest({
    required String fromUserId,
    required String toUserId,
    String? fromDisplayName,
    String? toDisplayName,
  }) async {
    try {
      // Ensure consistent ordering of user IDs
      final user1Id = fromUserId.compareTo(toUserId) < 0 ? fromUserId : toUserId;
      final user2Id = fromUserId.compareTo(toUserId) < 0 ? toUserId : fromUserId;

      // Assign display names based on user order
      final user1DisplayName = fromUserId.compareTo(toUserId) < 0 ? fromDisplayName : toDisplayName;
      final user2DisplayName = fromUserId.compareTo(toUserId) < 0 ? toDisplayName : fromDisplayName;

      // Check if friendship already exists
      final existing = await _firestore
          .collection(_friendshipsCollection)
          .where('user1Id', isEqualTo: user1Id)
          .where('user2Id', isEqualTo: user2Id)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('Friend request already exists');
      }

      final friendship = Friendship(
        id: '',
        user1Id: user1Id,
        user2Id: user2Id,
        user1DisplayName: user1DisplayName,
        user2DisplayName: user2DisplayName,
        requestedBy: fromUserId,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(_friendshipsCollection)
          .add(friendship.toFirestore());

      return docRef.id;
    } catch (e) {
      debugPrint('Error sending friend request: $e');
      rethrow;
    }
  }

  /// Accept friend request
  Future<void> acceptFriendRequest(String friendshipId) async {
    try {
      await _firestore.collection(_friendshipsCollection).doc(friendshipId).update({
        'status': FriendshipStatus.accepted.name,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error accepting friend request: $e');
      rethrow;
    }
  }

  /// Decline friend request
  Future<void> declineFriendRequest(String friendshipId) async {
    try {
      await _firestore.collection(_friendshipsCollection).doc(friendshipId).update({
        'status': FriendshipStatus.declined.name,
      });
    } catch (e) {
      debugPrint('Error declining friend request: $e');
    }
  }

  /// Remove friend
  Future<void> removeFriend(String friendshipId) async {
    try {
      await _firestore.collection(_friendshipsCollection).doc(friendshipId).delete();
    } catch (e) {
      debugPrint('Error removing friend: $e');
    }
  }

  /// Watch user's friends
  Stream<List<Friendship>> watchFriends(String oddserId) {
    // Need to query both user1Id and user2Id
    // Firestore doesn't support OR queries, so we use StreamZip to combine
    final stream1 = _firestore
        .collection(_friendshipsCollection)
        .where('user1Id', isEqualTo: oddserId)
        .where('status', isEqualTo: 'accepted')
        .snapshots();

    final stream2 = _firestore
        .collection(_friendshipsCollection)
        .where('user2Id', isEqualTo: oddserId)
        .where('status', isEqualTo: 'accepted')
        .snapshots();

    // Combine both streams using StreamGroup.merge and maintain state
    late QuerySnapshot<Map<String, dynamic>> lastSnapshot1;
    late QuerySnapshot<Map<String, dynamic>> lastSnapshot2;
    bool hasSnapshot1 = false;
    bool hasSnapshot2 = false;

    // Use broadcast controller to allow multiple listeners
    final controller = StreamController<List<Friendship>>.broadcast();

    void emitCombined() {
      if (!hasSnapshot1 || !hasSnapshot2) return;
      final friends = <Friendship>[];
      friends.addAll(lastSnapshot1.docs.map((d) => Friendship.fromFirestore(d)));
      friends.addAll(lastSnapshot2.docs.map((d) => Friendship.fromFirestore(d)));
      if (!controller.isClosed) {
        controller.add(friends);
      }
    }

    final sub1 = stream1.listen(
      (snapshot) {
        lastSnapshot1 = snapshot;
        hasSnapshot1 = true;
        emitCombined();
      },
      onError: (e) {
        if (!controller.isClosed) controller.addError(e);
      },
    );

    final sub2 = stream2.listen(
      (snapshot) {
        lastSnapshot2 = snapshot;
        hasSnapshot2 = true;
        emitCombined();
      },
      onError: (e) {
        if (!controller.isClosed) controller.addError(e);
      },
    );

    controller.onCancel = () {
      sub1.cancel();
      sub2.cancel();
    };

    return controller.stream;
  }

  /// Check if two users are already friends or have pending request
  Future<bool> areFriendsOrPending(String userId1, String userId2) async {
    try {
      final user1Id = userId1.compareTo(userId2) < 0 ? userId1 : userId2;
      final user2Id = userId1.compareTo(userId2) < 0 ? userId2 : userId1;

      final existing = await _firestore
          .collection(_friendshipsCollection)
          .where('user1Id', isEqualTo: user1Id)
          .where('user2Id', isEqualTo: user2Id)
          .limit(1)
          .get();

      return existing.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking friendship: $e');
      return false;
    }
  }

  /// Watch pending friend requests
  Stream<List<Friendship>> watchPendingFriendRequests(String oddserId) {
    final stream1 = _firestore
        .collection(_friendshipsCollection)
        .where('user1Id', isEqualTo: oddserId)
        .where('status', isEqualTo: 'pending')
        .snapshots();

    final stream2 = _firestore
        .collection(_friendshipsCollection)
        .where('user2Id', isEqualTo: oddserId)
        .where('status', isEqualTo: 'pending')
        .snapshots();

    // Combine both streams and maintain state
    late QuerySnapshot<Map<String, dynamic>> lastSnapshot1;
    late QuerySnapshot<Map<String, dynamic>> lastSnapshot2;
    bool hasSnapshot1 = false;
    bool hasSnapshot2 = false;

    // Use broadcast controller to allow multiple listeners
    final controller = StreamController<List<Friendship>>.broadcast();

    void emitCombined() {
      if (!hasSnapshot1 || !hasSnapshot2) return;
      final requests = <Friendship>[];
      requests.addAll(lastSnapshot1.docs.map((d) => Friendship.fromFirestore(d)));
      requests.addAll(lastSnapshot2.docs.map((d) => Friendship.fromFirestore(d)));
      // Filter to show only incoming requests
      if (!controller.isClosed) {
        controller.add(requests.where((r) => r.requestedBy != oddserId).toList());
      }
    }

    final sub1 = stream1.listen(
      (snapshot) {
        lastSnapshot1 = snapshot;
        hasSnapshot1 = true;
        emitCombined();
      },
      onError: (e) {
        if (!controller.isClosed) controller.addError(e);
      },
    );

    final sub2 = stream2.listen(
      (snapshot) {
        lastSnapshot2 = snapshot;
        hasSnapshot2 = true;
        emitCombined();
      },
      onError: (e) {
        if (!controller.isClosed) controller.addError(e);
      },
    );

    controller.onCancel = () {
      sub1.cancel();
      sub2.cancel();
    };

    return controller.stream;
  }
}
