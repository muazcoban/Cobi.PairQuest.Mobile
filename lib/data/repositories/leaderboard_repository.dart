import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/leaderboard_entry.dart';

/// Repository for global leaderboard operations
///
/// Each player has one document per level, `{userId}_{level}`, holding their
/// best score there. App versions before this one saved every finished game
/// as its own document with a random ID, so one player filled many rows;
/// [getTopScores] still keeps only each player's best of those.
class LeaderboardRepository {
  LeaderboardRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'leaderboards';
  static const String _globalDoc = 'global';
  static const String _entriesSubcollection = 'entries';

  /// Reference to global leaderboard entries
  CollectionReference<Map<String, dynamic>> get _entriesRef =>
      _firestore.collection(_collection).doc(_globalDoc).collection(_entriesSubcollection);

  /// The document that holds [userId]'s best score on [level].
  static String entryId(String userId, int level) => '${userId}_$level';

  /// Saves [entry] if it beats the player's best on its level. A lower score
  /// only updates the name, so a renamed player shows up with the new name.
  Future<bool> submitScore({
    required LeaderboardEntry entry,
    required String? userId,
  }) async {
    if (userId == null) return false;

    try {
      final ref = _entriesRef.doc(entryId(userId, entry.level));
      await _firestore.runTransaction((transaction) async {
        final current = (await transaction.get(ref)).data();
        final best = current?['score'] as int?;
        if (best != null && best >= entry.score) {
          if (current!['playerName'] != entry.playerName) {
            transaction.update(ref, {'playerName': entry.playerName});
          }
          return;
        }
        transaction.set(ref, _scoreData(entry, userId));
      });
      return true;
    } catch (e) {
      debugPrint('Error submitting score: $e');
      return false;
    }
  }

  /// Moves [userId]'s scores saved by older app versions (one document per
  /// game) to the one-per-level documents under [playerName], then deletes
  /// them. Returns false when it could not finish; it can run again.
  Future<bool> migrateLegacyScores({
    required String userId,
    required String playerName,
  }) async {
    try {
      // One equality filter: no composite index needed.
      final snapshot = await _entriesRef.where('userId', isEqualTo: userId).get();

      final legacy = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      final bestByLevel = <int, Map<String, dynamic>>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final level = data['level'] as int? ?? 1;
        if (doc.id != entryId(userId, level)) legacy.add(doc);
        final best = bestByLevel[level];
        if (best == null || (data['score'] as int? ?? 0) > (best['score'] as int? ?? 0)) {
          bestByLevel[level] = data;
        }
      }
      if (legacy.isEmpty) return true;

      // Best scores first: if a later chunk fails, nothing is lost.
      await _commitInChunks([
        for (final MapEntry(key: level, value: data) in bestByLevel.entries)
          (WriteBatch batch) => batch.set(_entriesRef.doc(entryId(userId, level)), {
                ...data,
                'userId': userId,
                'playerName': playerName,
              }),
        for (final doc in legacy) (WriteBatch batch) => batch.delete(doc.reference),
      ]);
      return true;
    } catch (e) {
      debugPrint('Error migrating leaderboard scores: $e');
      return false;
    }
  }

  /// Shows [userId]'s scores on every level under [playerName].
  Future<void> renamePlayer({
    required String userId,
    required String playerName,
  }) async {
    try {
      final snapshot = await _entriesRef.where('userId', isEqualTo: userId).get();
      await _commitInChunks([
        for (final doc in snapshot.docs)
          if (doc.data()['playerName'] != playerName)
            (WriteBatch batch) => batch.update(doc.reference, {'playerName': playerName}),
      ]);
    } catch (e) {
      debugPrint('Error renaming player on the leaderboard: $e');
    }
  }

  /// Each player's best score, highest first.
  Future<List<LeaderboardEntry>> getTopScores({
    int limit = 50,
    int? level,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _entriesRef.orderBy('score', descending: true);

      if (level != null) {
        query = query.where('level', isEqualTo: level);
      }

      // Read more than [limit]: without a level, every level of a player is a
      // document, and older versions saved one per game.
      final snapshot = await query.limit(limit * 4).get();

      return bestPerPlayer(snapshot.docs.map(_entryFromDoc), limit);
    } catch (e) {
      debugPrint('Error getting top scores: $e');
      return [];
    }
  }

  /// Keeps the first, so highest, entry of each player in [entriesByScore].
  @visibleForTesting
  static List<LeaderboardEntry> bestPerPlayer(
    Iterable<LeaderboardEntry> entriesByScore,
    int limit,
  ) {
    final seen = <String>{};
    final result = <LeaderboardEntry>[];
    for (final entry in entriesByScore) {
      if (!seen.add(entry.userId ?? entry.id)) continue;
      result.add(entry);
      if (result.length == limit) break;
    }
    return result;
  }

  // Firestore accepts at most 500 writes in one batch.
  Future<void> _commitInChunks(List<void Function(WriteBatch)> writes) async {
    for (var i = 0; i < writes.length; i += 500) {
      final batch = _firestore.batch();
      for (final write in writes.skip(i).take(500)) {
        write(batch);
      }
      await batch.commit();
    }
  }

  Map<String, dynamic> _scoreData(LeaderboardEntry entry, String userId) {
    final data = entry.toJson();
    data['userId'] = userId;
    data['playedAt'] = FieldValue.serverTimestamp();
    return data;
  }

  LeaderboardEntry _entryFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    // Handle Firestore Timestamp
    if (data['playedAt'] is Timestamp) {
      data['playedAt'] = (data['playedAt'] as Timestamp).toDate().toIso8601String();
    }
    data['id'] = doc.id;
    return LeaderboardEntry.fromJson(data);
  }
}
