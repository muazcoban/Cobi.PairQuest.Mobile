import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'matchmaking.freezed.dart';
part 'matchmaking.g.dart';

/// Matchmaking queue status
enum MatchmakingStatus {
  /// Waiting for a match
  waiting,

  /// Currently being matched
  matching,

  /// Match found
  matched,

  /// Queue expired (timeout)
  expired,

  /// Cancelled by user
  cancelled,
}

/// Timestamp converter for Firestore
class _TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const _TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

/// Represents a player in the matchmaking queue
@freezed
abstract class MatchmakingEntry with _$MatchmakingEntry {
  const MatchmakingEntry._();

  const factory MatchmakingEntry({
    /// Queue entry ID (Firestore document ID)
    required String id,

    /// User ID
    required String oddserId,

    /// User's display name
    required String displayName,

    /// User's photo URL
    String? photoUrl,

    /// User's current rating
    required int rating,

    /// Preferred level (1-20, or 0 for any)
    @Default(0) int preferredLevel,

    /// Game mode preference
    @Default(MatchmakingMode.any) MatchmakingMode mode,

    /// Current status
    @Default(MatchmakingStatus.waiting) MatchmakingStatus status,

    /// Matched game ID (when status is matched)
    String? matchedGameId,

    /// Matched opponent ID
    String? matchedOpponentId,

    /// Queue join time
    @_TimestampConverter() required DateTime createdAt,

    /// Queue expiration time (60 seconds from creation)
    @_TimestampConverter() required DateTime expiresAt,

    /// Search radius for rating (starts at 100, expands over time)
    @Default(100) int ratingRadius,
  }) = _MatchmakingEntry;

  factory MatchmakingEntry.fromJson(Map<String, dynamic> json) =>
      _$MatchmakingEntryFromJson(json);

  /// Create from Firestore document
  factory MatchmakingEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchmakingEntry.fromJson({...data, 'id': doc.id});
  }

  /// Check if entry is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if entry is still active
  bool get isActive =>
      status == MatchmakingStatus.waiting && !isExpired;

  /// Time remaining in queue (seconds)
  int get secondsRemaining {
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Check if another player is compatible for matching
  bool isCompatibleWith(MatchmakingEntry other) {
    // Don't match with self
    if (oddserId == other.oddserId) return false;

    // Check rating range (both players' ranges)
    final ratingDiff = (rating - other.rating).abs();
    final maxRadius = ratingRadius > other.ratingRadius
        ? ratingRadius
        : other.ratingRadius;
    if (ratingDiff > maxRadius) return false;

    // Check level preference (0 means any)
    if (preferredLevel != 0 &&
        other.preferredLevel != 0 &&
        preferredLevel != other.preferredLevel) {
      return false;
    }

    // Check game mode
    if (mode != MatchmakingMode.any &&
        other.mode != MatchmakingMode.any &&
        mode != other.mode) {
      return false;
    }

    return true;
  }

  /// Convert to Firestore map (without id)
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}

/// Matchmaking mode preference
enum MatchmakingMode {
  /// Any mode
  any,

  /// Casual only
  casual,

  /// Ranked only
  ranked,
}

/// Game invitation for friend matches
@freezed
abstract class GameInvitation with _$GameInvitation {
  const GameInvitation._();

  const factory GameInvitation({
    /// Invitation ID
    required String id,

    /// Sender user ID
    required String fromUserId,

    /// Sender display name
    required String fromDisplayName,

    /// Sender photo URL
    String? fromPhotoUrl,

    /// Recipient user ID
    required String toUserId,

    /// Proposed level
    @Default(5) int level,

    /// Invitation status
    @Default(InvitationStatus.pending) InvitationStatus status,

    /// Created game ID (when accepted)
    String? gameId,

    /// Invitation creation time
    @_TimestampConverter() required DateTime createdAt,

    /// Expiration time (5 minutes)
    @_TimestampConverter() required DateTime expiresAt,
  }) = _GameInvitation;

  factory GameInvitation.fromJson(Map<String, dynamic> json) =>
      _$GameInvitationFromJson(json);

  /// Create from Firestore document
  factory GameInvitation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameInvitation.fromJson({...data, 'id': doc.id});
  }

  /// Check if invitation is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if invitation is still pending
  bool get isPending =>
      status == InvitationStatus.pending && !isExpired;

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}

/// Invitation status
enum InvitationStatus {
  /// Waiting for response
  pending,

  /// Accepted
  accepted,

  /// Declined
  declined,

  /// Expired
  expired,

  /// Cancelled by sender (replaced by new invitation)
  cancelled,
}

/// Friend relationship
@freezed
abstract class Friendship with _$Friendship {
  const Friendship._();

  const factory Friendship({
    /// Friendship ID
    required String id,

    /// First user ID (alphabetically smaller)
    required String user1Id,

    /// Second user ID
    required String user2Id,

    /// First user's display name
    String? user1DisplayName,

    /// Second user's display name
    String? user2DisplayName,

    /// Friendship status
    @Default(FriendshipStatus.pending) FriendshipStatus status,

    /// Who sent the friend request
    required String requestedBy,

    /// Creation time
    @_TimestampConverter() required DateTime createdAt,

    /// Accepted time
    @_TimestampConverter() DateTime? acceptedAt,
  }) = _Friendship;

  factory Friendship.fromJson(Map<String, dynamic> json) =>
      _$FriendshipFromJson(json);

  /// Create from Firestore document
  factory Friendship.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Friendship.fromJson({...data, 'id': doc.id});
  }

  /// Get the other user's ID
  String getOtherUserId(String myUserId) =>
      myUserId == user1Id ? user2Id : user1Id;

  /// Get the friend's display name (the other user, not me)
  String? getDisplayName(String myUserId) {
    if (myUserId == user1Id) {
      return user2DisplayName;
    } else {
      return user1DisplayName;
    }
  }

  /// Get the requester's display name
  String? getRequesterDisplayName() {
    if (requestedBy == user1Id) {
      return user1DisplayName;
    } else {
      return user2DisplayName;
    }
  }

  /// Check if this user sent the request
  bool didSendRequest(String myUserId) => requestedBy == myUserId;

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}

/// Friendship status
enum FriendshipStatus {
  /// Request pending
  pending,

  /// Friends
  accepted,

  /// Request declined
  declined,

  /// Blocked
  blocked,
}
