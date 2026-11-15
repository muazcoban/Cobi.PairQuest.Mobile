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
}
