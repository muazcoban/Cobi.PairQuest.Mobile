import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/wallet_sync_service.dart';
import '../../domain/entities/currency.dart';

/// Provider for wallet sync service
final walletSyncServiceProvider = Provider<WalletSyncService>((ref) {
  return WalletSyncService();
});

/// Provider for player's wallet
final walletProvider = StateNotifierProvider<WalletNotifier, PlayerWallet>((ref) {
  final syncService = ref.watch(walletSyncServiceProvider);
  return WalletNotifier(ref, syncService);
});

/// Notifier for managing player's wallet (coins & gems)
class WalletNotifier extends StateNotifier<PlayerWallet> {
  static const String _storageKey = 'player_wallet';

  // ignore: unused_field - kept for potential future use
  final Ref _ref;
  final WalletSyncService _syncService;
  StreamSubscription? _authSubscription;
  bool _isSyncing = false;

  WalletNotifier(this._ref, this._syncService) : super(const PlayerWallet()) {
    _loadWallet();
    _listenToAuthChanges();
  }

  /// Listen to auth state changes for sync trigger
  void _listenToAuthChanges() {
    _authSubscription = _syncService.authStateChanges.listen((user) async {
      // When user logs in (non-anonymous), trigger sync
      if (user != null && !user.isAnonymous) {
        await syncWithCloud();
      }
    });
  }

  /// Load wallet from local storage
  Future<void> _loadWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final walletJson = prefs.getString(_storageKey);
      if (walletJson != null) {
        final data = jsonDecode(walletJson) as Map<String, dynamic>;
        state = PlayerWallet.fromJson(data);
      }

      // Try to sync with cloud if logged in
      if (_syncService.isLoggedIn) {
        await syncWithCloud();
      }
    } catch (e) {
      debugPrint('WalletNotifier: Error loading wallet: $e');
    }
  }

  /// Save wallet to local storage
  Future<void> _saveWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toJson()));
    } catch (e) {
      debugPrint('WalletNotifier: Error saving wallet: $e');
    }
  }

  /// Save to both local and cloud (async cloud save)
  Future<void> _saveWalletWithSync() async {
    await _saveWallet();
    // Fire and forget cloud save
    _syncService.saveToCloudAsync(state);
  }

  /// Sync wallet with cloud (merge strategy: MAX values)
  Future<void> syncWithCloud() async {
    if (_isSyncing || !_syncService.isLoggedIn) return;

    _isSyncing = true;
    try {
      final mergedWallet = await _syncService.syncWallet(state);

      // Update state if merged is different
      if (mergedWallet.coins != state.coins || mergedWallet.gems != state.gems) {
        state = mergedWallet;
        await _saveWallet(); // Save merged to local
      }
    } catch (e) {
      debugPrint('WalletNotifier: Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Add coins to wallet
  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    state = state.addCoins(amount);
    await _saveWalletWithSync();
  }

  /// Add gems to wallet
  Future<void> addGems(int amount) async {
    if (amount <= 0) return;
    state = state.addGems(amount);
    await _saveWalletWithSync();
  }

  /// Spend coins (returns true if successful)
  Future<bool> spendCoins(int amount) async {
    final newWallet = state.spendCoins(amount);
    if (newWallet == null) return false;
    state = newWallet;
    await _saveWalletWithSync();
    return true;
  }

  /// Spend gems (returns true if successful)
  Future<bool> spendGems(int amount) async {
    final newWallet = state.spendGems(amount);
    if (newWallet == null) return false;
    state = newWallet;
    await _saveWalletWithSync();
    return true;
  }

  /// Check if can afford coins
  bool canAffordCoins(int amount) => state.canAffordCoins(amount);

  /// Check if can afford gems
  bool canAffordGems(int amount) => state.canAffordGems(amount);

  /// Award coins for game completion
  Future<int> awardGameCompletion({
    required int level,
    required int stars,
    required bool isPerfect,
    required int maxCombo,
  }) async {
    int coins = CoinRewards.calculateGameWinCoins(level, stars, isPerfect);

    // Add combo bonus
    if (maxCombo > 1) {
      coins += (maxCombo - 1) * CoinRewards.comboBonus;
    }

    await addCoins(coins);
    return coins;
  }

  /// Award coins for daily reward
  Future<void> awardDailyReward(int day) async {
    final dayIndex = (day - 1) % CoinRewards.dailyCoins.length;
    final coins = CoinRewards.dailyCoins[dayIndex];
    await addCoins(coins);

    // Day 7 also gives gems
    if (day % 7 == 0) {
      await addGems(5);
    }
  }

  /// Award coins for quest completion
  Future<void> awardQuestCompletion(String difficulty) async {
    int coins;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        coins = CoinRewards.questEasy;
        break;
      case 'medium':
        coins = CoinRewards.questMedium;
        break;
      case 'hard':
        coins = CoinRewards.questHard;
        break;
      default:
        coins = CoinRewards.questEasy;
    }
    await addCoins(coins);
  }

  /// Award coins for achievement unlock
  Future<void> awardAchievement(String rarity) async {
    int coins;
    switch (rarity.toLowerCase()) {
      case 'common':
        coins = CoinRewards.achievementCommon;
        break;
      case 'rare':
        coins = CoinRewards.achievementRare;
        break;
      case 'epic':
        coins = CoinRewards.achievementEpic;
        break;
      case 'legendary':
        coins = CoinRewards.achievementLegendary;
        break;
      default:
        coins = CoinRewards.achievementCommon;
    }
    await addCoins(coins);
  }

  /// Reset wallet (for testing)
  Future<void> resetWallet() async {
    state = const PlayerWallet();
    await _saveWalletWithSync();
  }

  /// Migrate old points to coins (one-time migration)
  Future<void> migrateFromPoints(int oldPoints) async {
    // Direct 1:1 conversion from old points to coins
    await addCoins(oldPoints);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
