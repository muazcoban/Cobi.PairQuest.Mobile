import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/currency.dart';
import '../../domain/entities/power_up.dart';

/// Service for syncing wallet and inventory data between local storage and Firestore
///
/// The cloud copy is the account's wallet and inventory. Every change is
/// written to it, and Firestore's offline cache returns this device's
/// pending writes, so a sync takes the cloud copy as it is. Only an account
/// with no cloud copy yet receives the local one: a guest's progress the
/// first time they sign in. Taking the larger of local and cloud, as before,
/// undid spending made on another device and passed coins from one account
/// to the next on a shared device.
class WalletSyncService {
  WalletSyncService({
    FirebaseFirestore? firestore,
    String? Function()? signedInUserId,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _signedInUserId = signedInUserId ?? _firebaseSignedInUserId;

  final FirebaseFirestore _firestore;
  final String? Function() _signedInUserId;

  /// The Google or Apple user; guests keep their wallet on the device only.
  static String? _firebaseSignedInUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user == null || user.isAnonymous ? null : user.uid;
  }

  /// Get the current user's wallet document reference
  DocumentReference<Map<String, dynamic>>? get _walletRef {
    final uid = _signedInUserId();
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('data').doc('wallet');
  }

  /// Get the current user's inventory document reference
  DocumentReference<Map<String, dynamic>>? get _inventoryRef {
    final uid = _signedInUserId();
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('data').doc('inventory');
  }

  /// Check if user is logged in (non-anonymous)
  bool get isLoggedIn => _signedInUserId() != null;

  /// The signed-in (non-anonymous) user's ID, null for guests
  String? get userId => _signedInUserId();

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

  /// Returns the account's cloud wallet, or uploads [localWallet] when the
  /// account has none yet. Offline or on error the local wallet stays.
  Future<PlayerWallet> syncWallet(PlayerWallet localWallet) async {
    final ref = _walletRef;
    if (ref == null) return localWallet;

    try {
      final doc = await ref.get();
      if (!doc.exists) {
        // From the offline cache "missing" means "not cached", not "no
        // wallet"; uploading then would overwrite the real one.
        if (doc.metadata.isFromCache) return localWallet;
        await saveToCloud(localWallet);
        return localWallet;
      }
      final data = doc.data()!;
      return PlayerWallet(coins: data['coins'] ?? 0, gems: data['gems'] ?? 0);
    } catch (e) {
      debugPrint('WalletSyncService: Sync failed, using local: $e');
      return localWallet;
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
  Stream<User?> get authStateChanges => FirebaseAuth.instance.authStateChanges();

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
          // Zero counts are stored on purpose (see cloudQuantities); locally a
          // used-up power-up has no entry
          if (type != null && (entry.value as int) > 0) {
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

  /// Firestore map for an inventory, keyed by power-up name.
  /// Every type is written, zero included: the document is saved with merge,
  /// which keeps keys missing from the new map. A used-up power-up (no local
  /// entry) would otherwise keep its old cloud count and come back on the
  /// next sync.
  static Map<String, int> cloudQuantities(PowerUpInventory inventory) {
    return {
      for (final type in PowerUpType.values) type.name: inventory.getQuantity(type),
    };
  }

  /// Save inventory to Firestore
  Future<bool> saveInventoryToCloud(PowerUpInventory inventory) async {
    if (!isLoggedIn) return false;

    try {
      await _inventoryRef?.set({
        'quantities': cloudQuantities(inventory),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('WalletSyncService: Error saving inventory to cloud: $e');
      return false;
    }
  }

  /// Returns the account's cloud inventory, or uploads [localInventory] when
  /// the account has none yet. Offline or on error the local one stays.
  Future<PowerUpInventory> syncInventory(PowerUpInventory localInventory) async {
    final ref = _inventoryRef;
    if (ref == null) return localInventory;

    try {
      final doc = await ref.get();
      if (!doc.exists) {
        if (doc.metadata.isFromCache) return localInventory;
        await saveInventoryToCloud(localInventory);
        return localInventory;
      }
      return await fetchCloudInventory() ?? localInventory;
    } catch (e) {
      debugPrint('WalletSyncService: Inventory sync failed, using local: $e');
      return localInventory;
    }
  }

  /// Quick save inventory to cloud (fire and forget)
  void saveInventoryToCloudAsync(PowerUpInventory inventory) {
    if (!isLoggedIn) return;

    _inventoryRef?.set({
      'quantities': cloudQuantities(inventory),
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
