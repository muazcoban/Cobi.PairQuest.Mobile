import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// Represents a user in the app (for Firebase/Firestore)
@freezed
abstract class AppUser with _$AppUser {
  const AppUser._();

  const factory AppUser({
    /// Firebase user ID
    required String uid,

    /// Display name
    String? displayName,

    /// Email address
    String? email,

    /// Profile photo URL
    String? photoUrl,

    /// Total games played
    @Default(0) int totalGames,

    /// Total score accumulated
    @Default(0) int totalScore,

    /// Highest level completed
    @Default(0) int highestLevel,

    /// Best score ever achieved
    @Default(0) int bestScore,

    /// Total matches found
    @Default(0) int totalMatches,

    /// Account creation timestamp
    @TimestampConverter() DateTime? createdAt,

    /// Last played timestamp
    @TimestampConverter() DateTime? lastPlayedAt,

    /// Is anonymous user
    @Default(true) bool isAnonymous,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

  /// Create from Firebase Auth user
  factory AppUser.fromFirebaseUser({
    required String uid,
    String? displayName,
    String? email,
    String? photoUrl,
    bool isAnonymous = true,
  }) {
    return AppUser(
      uid: uid,
      displayName: displayName,
      email: email,
      photoUrl: photoUrl,
      isAnonymous: isAnonymous,
      createdAt: DateTime.now(),
      lastPlayedAt: DateTime.now(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // Convert DateTime to Timestamp for Firestore
    if (createdAt != null) {
      json['createdAt'] = Timestamp.fromDate(createdAt!);
    }
    if (lastPlayedAt != null) {
      json['lastPlayedAt'] = Timestamp.fromDate(lastPlayedAt!);
    }
    return json;
  }

  /// Create from Firestore document
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['uid'] = doc.id;
    return AppUser.fromJson(data);
  }
}

/// Converter for Firestore Timestamp <-> DateTime
class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.tryParse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return null;
  }

  @override
  dynamic toJson(DateTime? date) {
    if (date == null) return null;
    return date.toIso8601String();
  }
}
