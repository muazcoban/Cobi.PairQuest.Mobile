import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Removes what the app stores in Firestore for one user, before the
/// Firebase Auth account itself is deleted.
class AccountRepository {
  AccountRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Replaces the name in game records that stay for the opponent.
  static const String deletedPlayerName = 'Deleted player';

  // Firestore accepts at most 500 writes in one batch.
  static const int _batchLimit = 500;

  /// Deletes the profile, cloud wallet, friendships, invitations, queue
  /// entries and global leaderboard scores of [uid].
  ///
  /// Throws when one of these deletes fails, so the caller keeps the account
  /// and the user can try again.
  Future<void> deleteUserData(String uid) async {
    await _anonymizeGames(uid);

    final userRef = _firestore.collection('users').doc(uid);
    final refs = <DocumentReference>[
      userRef.collection('data').doc('wallet'),
      userRef.collection('data').doc('inventory'),
    ];

    final queries = <Query<Map<String, dynamic>>>[
      _firestore.collection('friendships').where('user1Id', isEqualTo: uid),
      _firestore.collection('friendships').where('user2Id', isEqualTo: uid),
      _firestore.collection('invitations').where('fromUserId', isEqualTo: uid),
      _firestore.collection('invitations').where('toUserId', isEqualTo: uid),
      _firestore.collection('matchmaking').where('oddserId', isEqualTo: uid),
      _firestore
          .collection('leaderboards')
          .doc('global')
          .collection('entries')
          .where('userId', isEqualTo: uid),
    ];
    for (final query in queries) {
      final snapshot = await query.get();
      refs.addAll(snapshot.docs.map((doc) => doc.reference));
    }
    refs.add(userRef);

    await _commitInBatches([
      for (final ref in refs) (WriteBatch batch) => batch.delete(ref),
    ]);
  }

  /// Game records stay for the opponent, so only the name and photo of [uid]
  /// are replaced. Games created before `playerIds` existed are not found.
  Future<void> _anonymizeGames(String uid) async {
    try {
      final games = await _firestore
          .collection('games')
          .where('playerIds', arrayContains: uid)
          .get();

      await _commitInBatches([
        for (final doc in games.docs)
          (WriteBatch batch) => batch.update(doc.reference, {
                'players': [
                  for (final player in doc.data()['players'] as List<dynamic>? ?? [])
                    {
                      ...Map<String, dynamic>.from(player as Map),
                      if (player['oddserId'] == uid) ...{
                        'displayName': deletedPlayerName,
                        'photoUrl': null,
                      },
                    },
                ],
              }),
      ]);
    } catch (e) {
      // Not a reason to keep the account: the profile and the rest still go.
      debugPrint('AccountRepository: could not anonymize games: $e');
    }
  }

  Future<void> _commitInBatches(List<void Function(WriteBatch)> writes) async {
    for (var i = 0; i < writes.length; i += _batchLimit) {
      final batch = _firestore.batch();
      for (final write in writes.skip(i).take(_batchLimit)) {
        write(batch);
      }
      await batch.commit();
    }
  }
}
