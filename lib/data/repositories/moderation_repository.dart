import 'package:cloud_firestore/cloud_firestore.dart';

/// Why a player is reported.
enum ReportReason { offensiveName, offensivePhoto, harassment, cheating, other }

/// Where the reported player was seen, so the report can be checked.
enum ReportSource { leaderboard, friends, friendRequest, invitation, game, search }

/// A player someone has blocked.
class BlockedPlayer {
  const BlockedPlayer({required this.userId, required this.displayName});

  final String userId;
  final String displayName;
}

/// Reports and blocks (App Review 1.2: a way to report offensive content and
/// to block abusive users).
///
/// Reports go to `reports`, which only the reporter can read; the developer
/// reviews them in the Firebase console. Blocks are private to the blocker
/// under `users/{uid}/blocked`.
class ModerationRepository {
  ModerationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _blocked(String uid) =>
      _firestore.collection('users').doc(uid).collection('blocked');

  Future<void> reportPlayer({
    required String reporterId,
    required String reportedUserId,
    required String reportedName,
    required ReportReason reason,
    required ReportSource source,
  }) {
    return _firestore.collection('reports').add({
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'reportedName': reportedName,
      'reason': reason.name,
      'source': source.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Blocks [blockedId]: ends the friendship and declines their pending
  /// invitations. From then on their requests and invitations are hidden and
  /// matchmaking skips them.
  Future<void> blockPlayer({
    required String uid,
    required String blockedId,
    required String displayName,
  }) async {
    await _blocked(uid).doc(blockedId).set({
      'displayName': displayName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final ids = [uid, blockedId]..sort();
    final friendships = await _firestore
        .collection('friendships')
        .where('user1Id', isEqualTo: ids[0])
        .where('user2Id', isEqualTo: ids[1])
        .get();
    final invitations = await _firestore
        .collection('invitations')
        .where('fromUserId', isEqualTo: blockedId)
        .where('toUserId', isEqualTo: uid)
        .get();

    final batch = _firestore.batch();
    for (final doc in friendships.docs) {
      batch.delete(doc.reference);
    }
    for (final doc in invitations.docs) {
      if (doc.data()['status'] == 'pending') {
        batch.update(doc.reference, {'status': 'declined'});
      }
    }
    await batch.commit();
  }

  Future<void> unblockPlayer({required String uid, required String blockedId}) {
    return _blocked(uid).doc(blockedId).delete();
  }

  Stream<List<BlockedPlayer>> watchBlockedPlayers(String uid) {
    return _blocked(uid).snapshots().map((snapshot) => [
          for (final doc in snapshot.docs)
            BlockedPlayer(
              userId: doc.id,
              displayName: doc.data()['displayName'] as String? ?? '',
            ),
        ]);
  }
}
