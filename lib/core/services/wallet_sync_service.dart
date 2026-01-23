import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/currency.dart';
import '../../domain/entities/power_up.dart';

/// Service for syncing wallet and inventory data between local storage and Firestore
class WalletSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user's wallet document reference
  DocumentReference<Map<String, dynamic>>? get _walletRef {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return null;
    return _firestore.collection('users').doc(user.uid).collection('data').doc('wallet');
  }

  /// Get the current user's inventory document reference
  DocumentReference<Map<String, dynamic>>? get _inventoryRef {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return null;
    return _firestore.collection('users').doc(user.uid).collection('data').doc('inventory');
  }

  /// Check if user is logged in (non-anonymous)
  bool get isLoggedIn {
    final user = _auth.currentUser;
    return user != null && !user.isAnonymous;
  }

  /// Get current user ID (null if not logged in)
  String? get userId => _auth.currentUser?.uid;

  /// Fetch wallet from Firestore
  /// Returns null if user is not logged in or no cloud data exists
  Future<PlayerWallet?> fetchCloudWallet() async {
    if (!isLoggedIn) return null;

    try {
      final doc = await _walletRef?.get();
      if (doc == null || !doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      return PlayerWallet(
        coins: data['coins'] ?? 0,
        gems: data['gems'] ?? 0,
      );
    } catch (e) {
      debugPrint('WalletSyncService: Error fetching cloud wallet: $e');
      return null;
    }
  }

  /// Save wallet to Firestore
  /// Does nothing if user is not logged in
  Future<bool> saveToCloud(PlayerWallet wallet) async {
    if (!isLoggedIn) return false;

    try {
      await _walletRef?.set({
        'coins': wallet.coins,
        'gems': wallet.gems,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('WalletSyncService: Error saving to cloud: $e');
      return false;
    }
  }

  /// Merge local and cloud wallets (takes MAX of each currency - user-friendly)
  /// This ensures players never lose currency when syncing
  PlayerWallet mergeWallets(PlayerWallet local, PlayerWallet cloud) {
    return PlayerWallet(
      coins: local.coins > cloud.coins ? local.coins : cloud.coins,
      gems: local.gems > cloud.gems ? local.gems : cloud.gems,
    );
  }

  /// Full sync operation: fetch cloud, merge with local, save merged to cloud
  /// Returns the merged wallet or local wallet if offline/not logged in
  Future<PlayerWallet> syncWallet(PlayerWallet localWallet) async {
    if (!isLoggedIn) {
      return localWallet; // Return local as-is for anonymous users
    }

    try {
      final cloudWallet = await fetchCloudWallet();

      if (cloudWallet == null) {
        // First time sync - just upload local to cloud
        await saveToCloud(localWallet);
        return localWallet;
      }

      // Merge wallets (take MAX values)
      final mergedWallet = mergeWallets(localWallet, cloudWallet);

      // Save merged to cloud
      await saveToCloud(mergedWallet);

      return mergedWallet;
    } catch (e) {
      debugPrint('WalletSyncService: Sync failed, using local: $e');
      return localWallet; // Fallback to local on error
    }
  }

  /// Quick save to cloud (fire and forget, doesn't wait for response)
  /// Used for incremental updates during gameplay
  void saveToCloudAsync(PlayerWallet wallet) {
    if (!isLoggedIn) return;

    _walletRef?.set({
      'coins': wallet.coins,
      'gems': wallet.gems,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)).catchError((e) {
      debugPrint('WalletSyncService: Async save failed: $e');
    });
  }

  /// Listen to auth state changes for triggering sync
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ========== INVENTORY SYNC METHODS ==========

  /// Fetch inventory from Firestore
  Future<PowerUpInventory?> fetchCloudInventory() async {
    if (!isLoggedIn) return null;

    try {
      final doc = await _inventoryRef?.get();
      if (doc == null || !doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      // Convert string keys back to PowerUpType
      final quantities = <PowerUpType, int>{};
      final rawQuantities = data['quantities'] as Map<String, dynamic>?;
      if (rawQuantities != null) {
        for (final entry in rawQuantities.entries) {
          final type = _stringToPowerUpType(entry.key);
          if (type != null) {
            quantities[type] = entry.value as int;
          }
        }
      }

      return PowerUpInventory(quantities: quantities);
    } catch (e) {
      debugPrint('WalletSyncService: Error fetching cloud inventory: $e');
      return null;
    }
  }

  /// Save inventory to Firestore
  Future<bool> saveInventoryToCloud(PowerUpInventory inventory) async {
    if (!isLoggedIn) return false;

    try {
      // Convert PowerUpType keys to strings for Firestore
      final stringQuantities = <String, int>{};
      for (final entry in inventory.quantities.entries) {
        stringQuantities[entry.key.name] = entry.value;
      }

      await _inventoryRef?.set({
        'quantities': stringQuantities,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('WalletSyncService: Error saving inventory to cloud: $e');
      return false;
    }
  }

  /// Merge local and cloud inventories (takes MAX of each power-up)
  PowerUpInventory mergeInventories(PowerUpInventory local, PowerUpInventory cloud) {
    final mergedQuantities = <PowerUpType, int>{};

    // Get all power-up types
    for (final type in PowerUpType.values) {
      final localQty = local.getQuantity(type);
      final cloudQty = cloud.getQuantity(type);
      final maxQty = localQty > cloudQty ? localQty : cloudQty;
      if (maxQty > 0) {
        mergedQuantities[type] = maxQty;
      }
    }

    return PowerUpInventory(quantities: mergedQuantities);
  }

  /// Full inventory sync operation
  Future<PowerUpInventory> syncInventory(PowerUpInventory localInventory) async {
    if (!isLoggedIn) {
      return localInventory;
    }

    try {
      final cloudInventory = await fetchCloudInventory();

      if (cloudInventory == null) {
        await saveInventoryToCloud(localInventory);
        return localInventory;
      }

      final mergedInventory = mergeInventories(localInventory, cloudInventory);
      await saveInventoryToCloud(mergedInventory);
      return mergedInventory;
    } catch (e) {
      debugPrint('WalletSyncService: Inventory sync failed, using local: $e');
      return localInventory;
    }
  }

  /// Quick save inventory to cloud (fire and forget)
  void saveInventoryToCloudAsync(PowerUpInventory inventory) {
    if (!isLoggedIn) return;

    final stringQuantities = <String, int>{};
    for (final entry in inventory.quantities.entries) {
      stringQuantities[entry.key.name] = entry.value;
    }

    _inventoryRef?.set({
      'quantities': stringQuantities,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)).catchError((e) {
      debugPrint('WalletSyncService: Async inventory save failed: $e');
    });
  }

  /// Helper to convert string to PowerUpType
  PowerUpType? _stringToPowerUpType(String name) {
    try {
      return PowerUpType.values.firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }
}
