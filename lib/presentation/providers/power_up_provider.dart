import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/wallet_sync_service.dart';
import '../../domain/entities/power_up.dart';
import 'wallet_provider.dart';

/// Provider for player's power-up inventory
final powerUpInventoryProvider =
    StateNotifierProvider<PowerUpInventoryNotifier, PowerUpInventory>((ref) {
  final syncService = ref.watch(walletSyncServiceProvider);
  return PowerUpInventoryNotifier(ref, syncService);
});

/// Provider for current game's power-up usage
final gamePowerUpUsageProvider =
    StateNotifierProvider<GamePowerUpUsageNotifier, GamePowerUpUsage>((ref) {
  return GamePowerUpUsageNotifier();
});

/// Notifier for managing player's power-up inventory
class PowerUpInventoryNotifier extends StateNotifier<PowerUpInventory> {
  static const String _storageKey = 'power_up_inventory';
  final Ref _ref;
  final WalletSyncService _syncService;
  StreamSubscription? _authSubscription;
  bool _isSyncing = false;

  PowerUpInventoryNotifier(this._ref, this._syncService) : super(const PowerUpInventory()) {
    _loadInventory();
    _listenToAuthChanges();
  }

  /// Listen to auth state changes for sync trigger
  void _listenToAuthChanges() {
    _authSubscription = _syncService.authStateChanges.listen((user) async {
      if (user != null && !user.isAnonymous) {
        await syncWithCloud();
      }
    });
  }

  /// Load inventory from local storage
  Future<void> _loadInventory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inventoryJson = prefs.getString(_storageKey);
      if (inventoryJson != null) {
        final data = jsonDecode(inventoryJson) as Map<String, dynamic>;
        state = PowerUpInventory.fromJson(data);
      }

      // Try to sync with cloud if logged in
      if (_syncService.isLoggedIn) {
        await syncWithCloud();
      }
    } catch (e) {
      debugPrint('PowerUpInventoryNotifier: Error loading inventory: $e');
    }
  }

  /// Save inventory to local storage
  Future<void> _saveInventory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toJson()));
    } catch (e) {
      debugPrint('PowerUpInventoryNotifier: Error saving inventory: $e');
    }
  }

  /// Save to both local and cloud (async cloud save)
  Future<void> _saveInventoryWithSync() async {
    await _saveInventory();
    _syncService.saveInventoryToCloudAsync(state);
  }

  /// Sync inventory with cloud (merge strategy: MAX values)
  Future<void> syncWithCloud() async {
    if (_isSyncing || !_syncService.isLoggedIn) return;

    _isSyncing = true;
    try {
      final mergedInventory = await _syncService.syncInventory(state);

      // Update state if merged is different
      bool isDifferent = false;
      for (final type in PowerUpType.values) {
        if (mergedInventory.getQuantity(type) != state.getQuantity(type)) {
          isDifferent = true;
          break;
        }
      }

      if (isDifferent) {
        state = mergedInventory;
        await _saveInventory();
      }
    } catch (e) {
      debugPrint('PowerUpInventoryNotifier: Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Purchase a power-up with coins
  Future<bool> purchaseWithCoins(PowerUpType type, {int quantity = 1}) async {
    final powerUp = PowerUps.getByType(type);
    final totalCost = powerUp.coinCost * quantity;

    final walletNotifier = _ref.read(walletProvider.notifier);
    final success = await walletNotifier.spendCoins(totalCost);

    if (success) {
      state = state.add(type, quantity);
      await _saveInventoryWithSync();
      return true;
    }
    return false;
  }

  /// Purchase a power-up with gems
  Future<bool> purchaseWithGems(PowerUpType type, {int quantity = 1}) async {
    final powerUp = PowerUps.getByType(type);
    if (powerUp.gemCost <= 0) return false;

    final totalCost = powerUp.gemCost * quantity;

    final walletNotifier = _ref.read(walletProvider.notifier);
    final success = await walletNotifier.spendGems(totalCost);

    if (success) {
      state = state.add(type, quantity);
      await _saveInventoryWithSync();
      return true;
    }
    return false;
  }

  /// Add power-ups directly (for rewards, daily bonuses, etc.)
  Future<void> addPowerUp(PowerUpType type, int quantity) async {
    if (quantity <= 0) return;
    state = state.add(type, quantity);
    await _saveInventoryWithSync();
  }

  /// Use a power-up from inventory
  Future<bool> usePowerUp(PowerUpType type) async {
    final newInventory = state.use(type);
    if (newInventory == null) return false;

    state = newInventory;
    await _saveInventoryWithSync();
    return true;
  }

  /// Check if player has a specific power-up
  bool hasPowerUp(PowerUpType type) => state.has(type);

  /// Get quantity of a specific power-up
  int getQuantity(PowerUpType type) => state.getQuantity(type);

  /// Check if player can afford a power-up with coins
  bool canAffordWithCoins(PowerUpType type) {
    final powerUp = PowerUps.getByType(type);
    return _ref.read(walletProvider).canAffordCoins(powerUp.coinCost);
  }

  /// Check if player can afford a power-up with gems
  bool canAffordWithGems(PowerUpType type) {
    final powerUp = PowerUps.getByType(type);
    if (powerUp.gemCost <= 0) return false;
    return _ref.read(walletProvider).canAffordGems(powerUp.gemCost);
  }

  /// Reset inventory (for testing)
  Future<void> resetInventory() async {
    state = const PowerUpInventory();
    await _saveInventoryWithSync();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Notifier for tracking power-up usage during a single game
class GamePowerUpUsageNotifier extends StateNotifier<GamePowerUpUsage> {
  GamePowerUpUsageNotifier() : super(const GamePowerUpUsage());

  /// Reset for new game
  void resetForNewGame() {
    state = const GamePowerUpUsage();
  }

  /// Check if a power-up can be used in this game
  bool canUseInGame(PowerUpType type) => state.canUse(type);

  /// Mark a power-up as used in this game
  void markUsed(PowerUpType type) {
    state = state.markUsed(type);
  }

  /// Activate a power-up with duration
  void activatePowerUp(PowerUpType type, int durationSeconds) {
    state = state.setActive(type, durationSeconds);
  }

  /// Clear active power-up
  void clearActivePowerUp() {
    state = state.clearActive();
  }

  /// Check if there's an active power-up
  bool get hasActivePowerUp => state.hasActivePowerUp;

  /// Get current active power-up type
  PowerUpType? get activePowerUp => state.activePowerUp;

  /// Get remaining seconds for active power-up
  int get activeRemainingSeconds => state.activeRemainingSeconds;

  /// Check if a specific power-up is currently active
  bool isPowerUpActive(PowerUpType type) {
    return state.hasActivePowerUp && state.activePowerUp == type;
  }
}

/// Helper provider to check power-up availability during game
final canUsePowerUpProvider =
    Provider.family<bool, PowerUpType>((ref, type) {
  final inventory = ref.watch(powerUpInventoryProvider);
  final gameUsage = ref.watch(gamePowerUpUsageProvider);

  // Must have in inventory and not exceeded game limit
  return inventory.has(type) && gameUsage.canUse(type);
});

/// Helper provider to get available power-ups for purchase
final availablePowerUpsProvider = Provider<List<PowerUp>>((ref) {
  return PowerUps.all;
});

/// Helper provider to get power-ups player owns
final ownedPowerUpsProvider = Provider<List<MapEntry<PowerUpType, int>>>((ref) {
  final inventory = ref.watch(powerUpInventoryProvider);
  return inventory.quantities.entries
      .where((e) => e.value > 0)
      .toList();
});
