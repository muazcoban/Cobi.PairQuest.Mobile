/// Types of power-ups available in the game
enum PowerUpType {
  /// Peek - Show all cards for a few seconds
  peek,

  /// Freeze - Pause the timer in timed mode
  freeze,

  /// Hint - Highlight a matching pair
  hint,

  /// Shuffle - Reshuffle unmatched cards
  shuffle,

  /// Time Bonus - Add extra time in timed mode
  timeBonus,

  /// Magnet - Next card automatically finds its match
  magnet,
}

/// Power-up definition with properties
class PowerUp {
  final PowerUpType type;
  final String nameKey;
  final String descriptionKey;
  final String icon;
  final int coinCost;
  final int gemCost;
  final int? duration; // Duration in seconds (null = instant)
  final int maxPerGame; // Maximum uses per game
  final bool timedModeOnly; // Only available in timed mode

  const PowerUp({
    required this.type,
    required this.nameKey,
    required this.descriptionKey,
    required this.icon,
    required this.coinCost,
    this.gemCost = 0,
    this.duration,
    this.maxPerGame = 1,
    this.timedModeOnly = false,
  });

  /// Check if this power-up requires timed mode
  bool get requiresTimedMode => timedModeOnly;
}

/// All available power-ups in the game
class PowerUps {
  static const PowerUp peek = PowerUp(
    type: PowerUpType.peek,
    nameKey: 'powerUpPeek',
    descriptionKey: 'powerUpPeekDesc',
    icon: '👁️',
    coinCost: 50,
    duration: 3,
    maxPerGame: 1,
  );

  static const PowerUp freeze = PowerUp(
    type: PowerUpType.freeze,
    nameKey: 'powerUpFreeze',
    descriptionKey: 'powerUpFreezeDesc',
    icon: '❄️',
    coinCost: 75,
    duration: 10,
    maxPerGame: 1,
    timedModeOnly: true,
  );

  static const PowerUp hint = PowerUp(
    type: PowerUpType.hint,
    nameKey: 'powerUpHint',
    descriptionKey: 'powerUpHintDesc',
    icon: '💡',
    coinCost: 30,
    duration: 3,
    maxPerGame: 2,
  );

  static const PowerUp shuffle = PowerUp(
    type: PowerUpType.shuffle,
    nameKey: 'powerUpShuffle',
    descriptionKey: 'powerUpShuffleDesc',
    icon: '🔀',
    coinCost: 40,
    maxPerGame: 1,
  );

  static const PowerUp timeBonus = PowerUp(
    type: PowerUpType.timeBonus,
    nameKey: 'powerUpTimeBonus',
    descriptionKey: 'powerUpTimeBonusDesc',
    icon: '⏱️',
    coinCost: 60,
    maxPerGame: 1,
    timedModeOnly: true,
  );

  static const PowerUp magnet = PowerUp(
    type: PowerUpType.magnet,
    nameKey: 'powerUpMagnet',
    descriptionKey: 'powerUpMagnetDesc',
    icon: '🧲',
    coinCost: 100,
    gemCost: 1,
    maxPerGame: 1,
  );

  /// List of all power-ups
  static const List<PowerUp> all = [
    peek,
    freeze,
    hint,
    shuffle,
    timeBonus,
    magnet,
  ];

  /// Get power-up by type
  static PowerUp getByType(PowerUpType type) {
    return all.firstWhere((p) => p.type == type);
  }
}

/// Player's power-up inventory
class PowerUpInventory {
  final Map<PowerUpType, int> quantities;

  const PowerUpInventory({
    this.quantities = const {},
  });

  /// Get quantity of a specific power-up
  int getQuantity(PowerUpType type) => quantities[type] ?? 0;

  /// Check if player has at least one of a power-up
  bool has(PowerUpType type) => getQuantity(type) > 0;

  /// Add power-ups to inventory
  PowerUpInventory add(PowerUpType type, int amount) {
    final newQuantities = Map<PowerUpType, int>.from(quantities);
    newQuantities[type] = (newQuantities[type] ?? 0) + amount;
    return PowerUpInventory(quantities: newQuantities);
  }

  /// Use a power-up (decrease by 1)
  PowerUpInventory? use(PowerUpType type) {
    if (!has(type)) return null;
    final newQuantities = Map<PowerUpType, int>.from(quantities);
    newQuantities[type] = newQuantities[type]! - 1;
    if (newQuantities[type] == 0) {
      newQuantities.remove(type);
    }
    return PowerUpInventory(quantities: newQuantities);
  }

  /// Get total power-ups count
  int get totalCount => quantities.values.fold(0, (a, b) => a + b);

  Map<String, dynamic> toJson() {
    return quantities.map((key, value) => MapEntry(key.name, value));
  }

  factory PowerUpInventory.fromJson(Map<String, dynamic> json) {
    final quantities = <PowerUpType, int>{};
    json.forEach((key, value) {
      try {
        final type = PowerUpType.values.firstWhere((t) => t.name == key);
        quantities[type] = value as int;
      } catch (_) {
        // Ignore invalid keys
      }
    });
    return PowerUpInventory(quantities: quantities);
  }

  @override
  String toString() => 'PowerUpInventory($quantities)';
}

/// Tracks power-up usage during a single game
class GamePowerUpUsage {
  final Map<PowerUpType, int> usedCount;
  final PowerUpType? activePowerUp;
  final DateTime? activeUntil;

  const GamePowerUpUsage({
    this.usedCount = const {},
    this.activePowerUp,
    this.activeUntil,
  });

  /// Check if a power-up can still be used in this game
  bool canUse(PowerUpType type) {
    final powerUp = PowerUps.getByType(type);
    final used = usedCount[type] ?? 0;
    return used < powerUp.maxPerGame;
  }

  /// Mark a power-up as used
  GamePowerUpUsage markUsed(PowerUpType type) {
    final newUsedCount = Map<PowerUpType, int>.from(usedCount);
    newUsedCount[type] = (newUsedCount[type] ?? 0) + 1;
    return GamePowerUpUsage(
      usedCount: newUsedCount,
      activePowerUp: activePowerUp,
      activeUntil: activeUntil,
    );
  }

  /// Set active power-up with duration
  GamePowerUpUsage setActive(PowerUpType type, int durationSeconds) {
    return GamePowerUpUsage(
      usedCount: usedCount,
      activePowerUp: type,
      activeUntil: DateTime.now().add(Duration(seconds: durationSeconds)),
    );
  }

  /// Clear active power-up
  GamePowerUpUsage clearActive() {
    return GamePowerUpUsage(
      usedCount: usedCount,
      activePowerUp: null,
      activeUntil: null,
    );
  }

  /// Check if there's an active power-up
  bool get hasActivePowerUp {
    if (activePowerUp == null || activeUntil == null) return false;
    return DateTime.now().isBefore(activeUntil!);
  }

  /// Get remaining seconds for active power-up
  int get activeRemainingSeconds {
    if (!hasActivePowerUp) return 0;
    return activeUntil!.difference(DateTime.now()).inSeconds;
  }

  /// Check if any power-up was used in this game
  bool get anyUsed => usedCount.isNotEmpty;

  /// Total power-ups used in this game
  int get totalUsed => usedCount.values.fold(0, (a, b) => a + b);
}
