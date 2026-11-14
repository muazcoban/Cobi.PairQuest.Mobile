import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Asks for a store rating at a natural break, following Apple's Human
/// Interface Guidelines for ratings and reviews:
/// - only after people have shown engagement: [minWins] won levels;
/// - never on the first win, when the notification permission alert comes;
/// - only after a good game: at least [minStars] stars;
/// - at most once every [minInterval];
/// - never during play: it is called when a level is won, before the result
///   dialog, so no timer is running.
///
/// The system prompt decides on its own whether to appear. iOS shows it at
/// most three times in 365 days; Google Play has its own quota and shows it
/// only in apps installed from Play.
class ReviewPromptService {
  ReviewPromptService({InAppReview? inAppReview})
      : _inAppReview = inAppReview ?? InAppReview.instance;

  final InAppReview _inAppReview;

  static const int minWins = 3;
  static const int minStars = 2;
  static const Duration minInterval = Duration(days: 14);

  static const String _winCountKey = 'review_prompt_win_count';
  static const String _lastAskedKey = 'review_prompt_last_asked_ms';

  /// Whether a won level with [stars] is a good moment to ask.
  @visibleForTesting
  static bool shouldAsk({
    required int winCount,
    required int stars,
    required DateTime now,
    DateTime? lastAskedAt,
  }) {
    if (winCount < minWins || stars < minStars) return false;
    if (lastAskedAt != null && now.difference(lastAskedAt) < minInterval) {
      return false;
    }
    return true;
  }

  /// Counts a won single-player level and asks for a rating when
  /// [shouldAsk] allows it.
  Future<void> onLevelWon({required int stars}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final winCount = (prefs.getInt(_winCountKey) ?? 0) + 1;
      await prefs.setInt(_winCountKey, winCount);

      final lastAskedMs = prefs.getInt(_lastAskedKey);
      final now = DateTime.now();
      final ask = shouldAsk(
        winCount: winCount,
        stars: stars,
        now: now,
        lastAskedAt: lastAskedMs == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(lastAskedMs),
      );
      if (!ask || !await _inAppReview.isAvailable()) return;

      await prefs.setInt(_lastAskedKey, now.millisecondsSinceEpoch);
      await _inAppReview.requestReview();
    } catch (e) {
      debugPrint('ReviewPromptService: could not request a review: $e');
    }
  }
}
