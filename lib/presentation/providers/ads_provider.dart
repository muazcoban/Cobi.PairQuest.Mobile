import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/ad_config.dart';
import '../../core/services/ads/ad_service.dart';
import '../../core/services/audio_service.dart';
import 'age_provider.dart';

/// What the settings screen shows for the "remove ads" purchase.
@immutable
class RemoveAdsState {
  const RemoveAdsState({
    this.adsRemoved = false,
    this.price,
    this.storeAvailable = false,
    this.busy = false,
  });

  /// The player owns the "remove ads" product; no interstitials.
  final bool adsRemoved;

  /// Localised price from the store, e.g. "₺49,99"; null until loaded.
  final String? price;

  /// The store answered and the product exists.
  final bool storeAvailable;

  /// A purchase or restore is running.
  final bool busy;

  RemoveAdsState copyWith({bool? adsRemoved, String? price, bool? storeAvailable, bool? busy}) {
    return RemoveAdsState(
      adsRemoved: adsRemoved ?? this.adsRemoved,
      price: price ?? this.price,
      storeAvailable: storeAvailable ?? this.storeAvailable,
      busy: busy ?? this.busy,
    );
  }
}

/// Result of a purchase or restore, for the message the player sees.
enum PurchaseOutcome { success, nothingToRestore, canceled, failed, storeUnavailable }

/// The one-time "remove ads" purchase, on both stores.
///
/// The owned state is cached on the device so the app starts without ads
/// even offline; the store stream confirms purchases and restores. There is
/// no server-side receipt check: for a single low-price unlock the cost of a
/// server outweighs the loss from a few cracked copies.
class RemoveAdsNotifier extends StateNotifier<RemoveAdsState> {
  RemoveAdsNotifier({InAppPurchase? store})
      : _store = store ?? InAppPurchase.instance,
        super(const RemoveAdsState()) {
    _ready = _init();
  }

  static const _ownedKey = 'ads_removed';

  final InAppPurchase _store;
  late final Future<void> _ready;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? _product;
  Completer<PurchaseOutcome>? _pending;

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_ownedKey) ?? false) state = state.copyWith(adsRemoved: true);

    // Listen before anything else: the store replays unfinished purchases
    // on start, and they must be completed or Android refunds them.
    _subscription = _store.purchaseStream.listen(
      _onPurchases,
      onError: (Object e) => _finish(PurchaseOutcome.failed),
    );

    try {
      if (!await _store.isAvailable()) return;
      final response = await _store.queryProductDetails({AdConfig.removeAdsProductId});
      if (response.productDetails.isEmpty) return;
      _product = response.productDetails.first;
      if (mounted) state = state.copyWith(storeAvailable: true, price: _product!.price);
    } catch (e) {
      debugPrint('Store query failed: $e');
    }
  }

  Future<PurchaseOutcome> buy() async {
    await _ready;
    final product = _product;
    if (product == null) return PurchaseOutcome.storeUnavailable;
    if (state.busy) return PurchaseOutcome.canceled;

    state = state.copyWith(busy: true);
    final outcome = (_pending = Completer<PurchaseOutcome>()).future;
    try {
      final started = await _store.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      if (!started) _finish(PurchaseOutcome.failed);
    } catch (e) {
      debugPrint('Purchase failed to start: $e');
      _finish(PurchaseOutcome.failed);
    }
    return outcome;
  }

  /// Asks the store for earlier purchases. The store sends no "nothing found"
  /// event, so a restore that brings nothing in a few seconds counts as none.
  Future<PurchaseOutcome> restore() async {
    await _ready;
    if (state.busy) return PurchaseOutcome.canceled;
    if (!await _store.isAvailable()) return PurchaseOutcome.storeUnavailable;

    state = state.copyWith(busy: true);
    final outcome = (_pending = Completer<PurchaseOutcome>()).future;
    try {
      await _store.restorePurchases();
    } catch (e) {
      debugPrint('Restore failed: $e');
      _finish(PurchaseOutcome.failed);
    }
    return outcome.timeout(
      const Duration(seconds: 6),
      onTimeout: () {
        _finish(PurchaseOutcome.nothingToRestore);
        return state.adsRemoved ? PurchaseOutcome.success : PurchaseOutcome.nothingToRestore;
      },
    );
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != AdConfig.removeAdsProductId) continue;

      switch (purchase.status) {
        case PurchaseStatus.pending:
          if (mounted) state = state.copyWith(busy: true);
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _grant();
          _finish(PurchaseOutcome.success);
        case PurchaseStatus.canceled:
          _finish(PurchaseOutcome.canceled);
        case PurchaseStatus.error:
          debugPrint('Purchase error: ${purchase.error?.message}');
          _finish(PurchaseOutcome.failed);
      }

      if (purchase.pendingCompletePurchase) {
        await _store.completePurchase(purchase);
      }
    }
  }

  Future<void> _grant() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ownedKey, true);
    if (mounted) state = state.copyWith(adsRemoved: true);
  }

  void _finish(PurchaseOutcome outcome) {
    if (mounted) state = state.copyWith(busy: false);
    final pending = _pending;
    _pending = null;
    if (pending != null && !pending.isCompleted) pending.complete(outcome);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final removeAdsProvider = StateNotifierProvider<RemoveAdsNotifier, RemoveAdsState>(
  (ref) => RemoveAdsNotifier(),
);

/// Whether the settings screen needs a "privacy choices" entry.
final adPrivacyOptionsRequiredProvider = FutureProvider<bool>(
  (ref) => ref.read(adServiceProvider).privacyOptionsRequired(),
);

/// AdMob for the app; tests override it with a fake.
final adServiceProvider = Provider<AdService>((ref) {
  return AdMobService(
    adsRemoved: () => ref.read(removeAdsProvider).adsRemoved,
    adsBlocked: () => ref.read(parentApprovalPendingProvider),
    audio: ref.read(audioServiceProvider),
  );
});

/// Whether ad offers ("watch an ad for…") and the "remove ads" purchase
/// show at all. Off while a parent has not approved the update that added
/// them (Texas SB 2420 significant change).
final adOffersAllowedProvider = Provider<bool>(
  (ref) => !ref.watch(parentApprovalPendingProvider),
);
