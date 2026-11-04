/// Rejects player names with profanity or slurs, in Turkish and English.
///
/// Player names are public on leaderboards, online profiles, friend requests
/// and game invitations. App Review 1.2 asks apps with user-generated content
/// for "a method for filtering objectionable material"; reports and blocking
/// handle what a word list cannot.
class NameFilter {
  NameFilter._();

  /// Roots long enough to match inside other words ("xOROSPUx").
  static const List<String> _roots = [
    // Turkish
    'orospu', 'orosbu', 'amcik', 'aminakoy',
    'siktir', 'sikerim', 'sikeyim', 'sikik', 'sikis', 'yarrak', 'dalyarak',
    'pezevenk', 'kahpe', 'gotveren', 'kaltak', 'yavsak', 'serefsiz',
    'ananisik', 'ibnelik',
    // English
    'fuck', 'motherf', 'bitch', 'asshole', 'bastard', 'nigger', 'nigga',
    'faggot', 'whore', 'pussy', 'retard', 'hitler',
  ];

  /// Words that only match as a whole word, so "eksik", "Dickens" or
  /// "Therapist" stay allowed.
  static const Set<String> _words = {
    // Turkish
    'sik', 'amk', 'aq', 'pic', 'ibne', 'gavat', 'pust', 'got', 'yarak',
    // English
    'dick', 'cunt', 'fag', 'cock', 'slut', 'nazi', 'cum', 'tits', 'ass',
    'shit', 'rapist',
  };

  static const Map<String, String> _lookalikes = {
    'ı': 'i', 'i̇': 'i', 'ğ': 'g', 'ş': 's', 'ç': 'c', 'ö': 'o', 'ü': 'u',
    'â': 'a', 'î': 'i', 'û': 'u',
    '0': 'o', '1': 'i', '3': 'e', '4': 'a', '5': 's', '7': 't', '@': 'a',
    r'$': 's', '!': 'i',
  };

  static bool isAllowed(String name) {
    final words = _normalize(name)
        .split(RegExp('[^a-z]+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return true;

    if (words.any((w) => _words.contains(w) || _words.contains(_squeeze(w)))) {
      return false;
    }

    // Joined, so spacing letters out ("o r o s p u") does not get through.
    final joined = words.join();
    final squeezed = _squeeze(joined);
    return !_roots.any(
      (root) => joined.contains(root) || squeezed.contains(_squeeze(root)),
    );
  }

  static String _normalize(String name) {
    // Turkish capital I and İ: lowercase them before the generic lowercase.
    var s = name.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();
    _lookalikes.forEach((from, to) => s = s.replaceAll(from, to));
    return s;
  }

  /// "fuuuck" -> "fuck"
  static String _squeeze(String s) => s.replaceAllMapped(
        RegExp(r'(.)\1+'),
        (m) => m.group(1)!,
      );
}
