/// Neutral age screen logic, kept free of Flutter so it can be unit tested.
///
/// The game is played by children too, so the app asks for a birth year
/// once and turns off everything that needs an account for players under 13
/// (COPPA, Google Play Families policy). Only the resulting group is stored
/// on the device; the birth year itself is not kept or sent anywhere.
enum AgeGroup {
  /// Under 13, or a birth year that may still be under 13.
  child,

  /// 13 or older.
  teenOrAdult,
}

class AgeGate {
  AgeGate._();

  /// Age at which account and online features open.
  static const int minAgeForOnline = 13;

  /// How many birth years the picker offers, back from the current year.
  static const int yearsShown = 100;

  /// Without the month a birth year is ambiguous: someone born in
  /// `now.year - 13` may still be 12. That year counts as a child.
  static AgeGroup groupFor({required int birthYear, required DateTime now}) {
    final oldestPossibleAge = now.year - birthYear;
    return oldestPossibleAge > minAgeForOnline ? AgeGroup.teenOrAdult : AgeGroup.child;
  }

  static int firstYear(DateTime now) => now.year - yearsShown;

  /// The group an app store age range points to, or null when the range
  /// spans 13 (or is empty) and says nothing either way. A store that asks
  /// the user to verify their age first gives the strictest group.
  static AgeGroup? groupForStoreRange({
    int? ageLower,
    int? ageUpper,
    bool verificationRequired = false,
  }) {
    if (verificationRequired) return AgeGroup.child;
    if (ageUpper != null && ageUpper < minAgeForOnline) return AgeGroup.child;
    if (ageLower != null && ageLower >= minAgeForOnline) return AgeGroup.teenOrAdult;
    return null;
  }

  /// Combines the stored answer with the store's signal. The stricter one
  /// wins: a store signal can turn a player into a child, never the other
  /// way, because a child may be using a parent's phone and account.
  static AgeGroup? combine({AgeGroup? stored, AgeGroup? store}) {
    if (stored == AgeGroup.child || store == AgeGroup.child) return AgeGroup.child;
    return stored ?? store;
  }
}
