import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/leaderboard_entry.dart';

/// Repository for global leaderboard operations
class LeaderboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'leaderboards';
  static const String _globalDoc = 'global';
  static const String _entriesSubcollection = 'entries';

  /// Reference to global leaderboard entries
  CollectionReference<Map<String, dynamic>> get _entriesRef =>
      _firestore.collection(_collection).doc(_globalDoc).collection(_entriesSubcollection);

  /// Submit a score to the global leaderboard
  Future<bool> submitScore({
    required LeaderboardEntry entry,
    required String? userId,
  }) async {
    try {
      final data = entry.toJson();
      data['userId'] = userId;
      data['playedAt'] = FieldValue.serverTimestamp();

      await _entriesRef.doc(entry.id).set(data);
      return true;
    } catch (e) {
      print('Error submitting score: $e');
      return false;
    }
  }

  /// Get top scores from global leaderboard
  Future<List<LeaderboardEntry>> getTopScores({
    int limit = 50,
    int? level,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _entriesRef.orderBy('score', descending: true);

      if (level != null) {
        query = query.where('level', isEqualTo: level);
      }

      query = query.limit(limit);

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Handle Firestore Timestamp
        if (data['playedAt'] is Timestamp) {
          data['playedAt'] = (data['playedAt'] as Timestamp).toDate().toIso8601String();
        }
        data['id'] = doc.id;
        return LeaderboardEntry.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting top scores: $e');
      return [];
    }
  }

  /// Get user's rank in leaderboard
  Future<int?> getUserRank(String? userId) async {
    if (userId == null) return null;

    try {
      // Get user's best score
      final userScores = await _entriesRef
          .where('userId', isEqualTo: userId)
          .orderBy('score', descending: true)
          .limit(1)
          .get();

      if (userScores.docs.isEmpty) return null;

      final userBestScore = userScores.docs.first.data()['score'] as int;

      // Count how many have higher scores
      final higherScores = await _entriesRef
          .where('score', isGreaterThan: userBestScore)
          .count()
          .get();

      return (higherScores.count ?? 0) + 1;
    } catch (e) {
      print('Error getting user rank: $e');
      return null;
    }
  }

  /// Get user's scores
  Future<List<LeaderboardEntry>> getUserScores(String? userId, {int limit = 10}) async {
    if (userId == null) return [];

    try {
      final snapshot = await _entriesRef
          .where('userId', isEqualTo: userId)
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (data['playedAt'] is Timestamp) {
          data['playedAt'] = (data['playedAt'] as Timestamp).toDate().toIso8601String();
        }
        data['id'] = doc.id;
        return LeaderboardEntry.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting user scores: $e');
      return [];
    }
  }

  /// Stream of top scores for real-time updates
  Stream<List<LeaderboardEntry>> watchTopScores({int limit = 50, int? level}) {
    Query<Map<String, dynamic>> query = _entriesRef.orderBy('score', descending: true);

    if (level != null) {
      query = query.where('level', isEqualTo: level);
    }

    query = query.limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (data['playedAt'] is Timestamp) {
          data['playedAt'] = (data['playedAt'] as Timestamp).toDate().toIso8601String();
        }
        data['id'] = doc.id;
        return LeaderboardEntry.fromJson(data);
      }).toList();
    });
  }
}
