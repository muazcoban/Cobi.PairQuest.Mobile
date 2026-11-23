import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/ad_config.dart';
import '../audio_service.dart';
import 'interstitial_policy.dart';

/// Ads as the game sees them. The game screen and dialogs depend on this
/// interface so tests can replace AdMob with a fake.
abstract class AdService {
  /// True while a full-screen ad covers the app. Android reports the app as
  /// paused at that moment; the game must not treat it as leaving.
  bool get isShowingFullScreenAd;

  /// Starts AdMob once; later calls return the same future.
  Future<void> initialize();

  /// True while a rewarded ad is loaded and can play at once. "Watch an
  /// ad" offers show only then, so a tap does not end in "no ad available".
  ValueListenable<bool> get rewardedReady;

  /// Shows a rewarded ad. True only when the player watched it to the end;
  /// false when no ad was available or the player closed it early.
  /// [beforeShow] runs right before the ad covers the screen, after any
  /// loading wait: a running game pauses there, and returns false if the
  /// moment has passed (the clock ran out meanwhile). The ad is then kept
  /// for the next request.
  Future<bool> showRewarded({bool Function()? beforeShow});

  /// Counts a finished single-player game toward the interstitial limits.
  Future<void> recordGameFinished();

  /// Shows an interstitial if the limits allow one; completes when it is
  /// closed, or at once when no ad is due.
  Future<void> showInterstitialIfAllowed();

  /// Whether Google's consent tool asks for a privacy choices entry in the
  /// app (for some regions); the settings screen shows one only then.
  Future<bool> privacyOptionsRequired();

  /// Opens Google's privacy choices form.
  Future<void> showPrivacyOptions();
}

/// Google AdMob with child-safe settings on every request.
///
/// Children play the game, so every request asks for child treatment
/// (no personalised ads, no remarketing) and family-friendly (G) content,
/// whatever the store age rating says.
class AdMobService implements AdService {
  AdMobService({
    required bool Function() adsRemoved,
    required AudioService audio,
    bool Function()? adsBlocked,
    InterstitialPolicy policy = const InterstitialPolicy(),
    DateTime Function()? clock,
  })  : _adsRemoved = adsRemoved,
        _adsBlocked = adsBlocked ?? _never,
        _audio = audio,
        _policy = policy,
        _now = clock ?? DateTime.now;

  static const _gamesKey = 'ads_games_finished';
  static const _firstOpenKey = 'ads_first_open';
  static const _lastShownKey = 'ads_last_interstitial';

  /// How long a tap on "watch ad" waits for an ad that was not preloaded.
  static const _loadTimeout = Duration(seconds: 8);

  /// Wait before loading a rewarded ad again after a failed load. It
  /// doubles on each failure up to [_maxRetryDelay], so a long outage (no
  /// network, no fill, account under review) does not send a request every
  /// few seconds.
  static const _minRetryDelay = Duration(seconds: 30);
  static const _maxRetryDelay = Duration(minutes: 10);

  final bool Function() _adsRemoved;

  /// No ads at all for this user: a parent has not approved the update that
  /// added them (Texas SB 2420 significant change).
  final bool Function() _adsBlocked;
  static bool _never() => false;
  final AudioService _audio;
  final InterstitialPolicy _policy;
  final DateTime Function() _now;

  Future<void>? _init;
  bool _canRequestAds = false;
  bool _showing = false;

  RewardedAd? _rewarded;
  Future<RewardedAd?>? _rewardedLoading;
  final ValueNotifier<bool> _rewardedReady = ValueNotifier(false);
  Duration _retryDelay = _minRetryDelay;
  Timer? _retryTimer;
  InterstitialAd? _interstitial;
  Future<InterstitialAd?>? _interstitialLoading;

  @override
  bool get isShowingFullScreenAd => _showing;

  @override
  ValueListenable<bool> get rewardedReady => _rewardedReady;

  @override
  Future<void> initialize() => _init ??= _initialize();

  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(_firstOpenKey)) {
        await prefs.setString(_firstOpenKey, _now().toIso8601String());
      }

      await _updateConsent();
      if (!await ConsentInformation.instance.canRequestAds()) return;

      await MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
        ageRestrictedTreatment: AgeRestrictedTreatment.child,
        maxAdContentRating: MaxAdContentRating.g,
      ));
      await MobileAds.instance.initialize();
      _canRequestAds = true;

      if (_adsBlocked()) return;
      unawaited(_loadRewarded());
      if (!_adsRemoved()) unawaited(_loadInterstitial());
    } catch (e) {
      // Ads are optional: the game works the same without them.
      debugPrint('AdMob init failed: $e');
    }
  }

  /// Asks Google's consent tool (UMP) whether a message is needed. Every
  /// user is tagged under the age of consent, matching the child treatment
  /// of the ad requests.
  Future<void> _updateConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(tagForUnderAgeOfConsent: true),
      () => ConsentForm.loadAndShowConsentFormIfRequired((error) {
        if (error != null) debugPrint('Consent form: ${error.message}');
        if (!done.isCompleted) done.complete();
      }),
      (error) {
        debugPrint('Consent info: ${error.message}');
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future;
  }

  // Rewarded ---------------------------------------------------------------

  Future<RewardedAd?> _loadRewarded() {
    if (_rewarded != null) return Future.value(_rewarded);
    return _rewardedLoading ??= () {
      final result = Completer<RewardedAd?>();
      RewardedAd.load(
        adUnitId: AdConfig.rewardedUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewarded = ad;
            _rewardedReady.value = true;
            _retryDelay = _minRetryDelay;
            result.complete(ad);
          },
          onAdFailedToLoad: (error) {
            debugPrint('Rewarded ad failed to load: ${error.message}');
            result.complete(null);
            _scheduleRewardedRetry();
          },
        ),
      );
      return result.future.whenComplete(() => _rewardedLoading = null);
    }();
  }

  void _scheduleRewardedRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryDelay, () {
      if (_rewarded == null && !_adsBlocked()) unawaited(_loadRewarded());
    });
    final doubled = _retryDelay * 2;
    _retryDelay = doubled > _maxRetryDelay ? _maxRetryDelay : doubled;
  }

  @override
  Future<bool> showRewarded({bool Function()? beforeShow}) async {
    await initialize();
    if (!_canRequestAds || _showing || _adsBlocked()) return false;

    // Both test and real units answer "no fill" now and then; one more try
    // within the wait keeps a single miss from failing the button.
    final deadline = DateTime.now().add(_loadTimeout);
    RewardedAd? ad;
    for (var attempt = 0; attempt < 2 && ad == null; attempt++) {
      final left = deadline.difference(DateTime.now());
      if (left <= Duration.zero) break;
      ad = await _loadRewarded().timeout(left, onTimeout: () => null);
    }
    if (ad == null) return false;
    if (beforeShow != null && !beforeShow()) return false;
    _rewarded = null;
    _rewardedReady.value = false;

    var earned = false;
    final closed = Completer<void>();
    final musicWasPlaying = await _beforeFullScreen();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded ad failed to show: ${error.message}');
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
      },
    );
    await ad.show(onUserEarnedReward: (_, _) => earned = true);
    await closed.future;
    await _afterFullScreen(musicWasPlaying);
    unawaited(_loadRewarded());
    return earned;
  }

  // Interstitial -----------------------------------------------------------

  Future<InterstitialAd?> _loadInterstitial() {
    if (_interstitial != null) return Future.value(_interstitial);
    return _interstitialLoading ??= () {
      final result = Completer<InterstitialAd?>();
      InterstitialAd.load(
        adUnitId: AdConfig.interstitialUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitial = ad;
            result.complete(ad);
          },
          onAdFailedToLoad: (error) {
            debugPrint('Interstitial failed to load: ${error.message}');
            result.complete(null);
          },
        ),
      );
      return result.future.whenComplete(() => _interstitialLoading = null);
    }();
  }

  @override
  Future<void> recordGameFinished() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_gamesKey, (prefs.getInt(_gamesKey) ?? 0) + 1);
  }

  @override
  Future<void> showInterstitialIfAllowed() async {
    // Never wait for initialisation here: the player is moving on.
    if (!_canRequestAds || _showing || _adsBlocked()) return;

    final prefs = await SharedPreferences.getInstance();
    final now = _now();
    final firstOpen = DateTime.tryParse(prefs.getString(_firstOpenKey) ?? '') ?? now;
    final lastShown = DateTime.tryParse(prefs.getString(_lastShownKey) ?? '');
    final allowed = _policy.canShow(
      adsRemoved: _adsRemoved(),
      gamesFinished: prefs.getInt(_gamesKey) ?? 0,
      firstOpen: firstOpen,
      lastShown: lastShown,
      now: now,
    );
    if (!allowed) return;

    // Only a preloaded ad: a loading spinner between games is worse than
    // skipping the ad.
    final ad = _interstitial;
    if (ad == null) {
      unawaited(_loadInterstitial());
      return;
    }
    _interstitial = null;

    final closed = Completer<void>();
    final musicWasPlaying = await _beforeFullScreen();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        prefs.setString(_lastShownKey, _now().toIso8601String());
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial failed to show: ${error.message}');
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
      },
    );
    await ad.show();
    await closed.future;
    await _afterFullScreen(musicWasPlaying);
    if (!_adsRemoved()) unawaited(_loadInterstitial());
  }

  // Privacy choices -------------------------------------------------------

  @override
  Future<bool> privacyOptionsRequired() async {
    try {
      await initialize();
      return await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> showPrivacyOptions() {
    final done = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((error) {
      if (error != null) debugPrint('Privacy options: ${error.message}');
      if (!done.isCompleted) done.complete();
    });
    return done.future;
  }

  // Shared -----------------------------------------------------------------

  Future<bool> _beforeFullScreen() async {
    _showing = true;
    final musicWasPlaying = _audio.isMusicPlaying;
    if (musicWasPlaying) await _audio.pauseBackgroundMusic();
    return musicWasPlaying;
  }

  Future<void> _afterFullScreen(bool musicWasPlaying) async {
    if (musicWasPlaying) await _audio.resumeBackgroundMusic();
    // Android delivers the "resumed" lifecycle event just after the ad
    // closes; keep the flag up until then so it does not pause the game.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _showing = false;
  }
}
