/// Currency types in the game
enum CurrencyType {
  /// Coins - earned through gameplay, daily rewards, quests
  coins,

  /// Gems - premium currency, rare rewards
  gems,
}

/// Player's wallet containing all currencies
class PlayerWallet {
  final int coins;
  final int gems;

  const PlayerWallet({
    this.coins = 0,
    this.gems = 0,
  });

  PlayerWallet copyWith({
    int? coins,
    int? gems,
  }) {
    return PlayerWallet(
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
    );
  }

  /// Add coins to wallet
  PlayerWallet addCoins(int amount) {
    return copyWith(coins: coins + amount);
  }

  /// Add gems to wallet
  PlayerWallet addGems(int amount) {
    return copyWith(gems: gems + amount);
  }

  /// Spend coins (returns null if insufficient)
  PlayerWallet? spendCoins(int amount) {
    if (coins < amount) return null;
    return copyWith(coins: coins - amount);
  }

  /// Spend gems (returns null if insufficient)
  PlayerWallet? spendGems(int amount) {
    if (gems < amount) return null;
    return copyWith(gems: gems - amount);
  }

  /// Check if can afford coins
  bool canAffordCoins(int amount) => coins >= amount;

  /// Check if can afford gems
  bool canAffordGems(int amount) => gems >= amount;

  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'gems': gems,
    };
  }

  factory PlayerWallet.fromJson(Map<String, dynamic> json) {
    return PlayerWallet(
      coins: json['coins'] ?? 0,
      gems: json['gems'] ?? 0,
    );
  }

  @override
  String toString() => 'PlayerWallet(coins: $coins, gems: $gems)';
}

/// Coin rewards configuration
class CoinRewards {
  // Game completion rewards (base, multiplied by level)
  static const int gameWinBase = 10;
  static const int gameWinPerLevel = 5;
  static const int threeStarBonus = 20;
  static const int perfectGameBonus = 50;

  // Combo rewards
  static const int comboBonus = 2; // per combo level

  // Daily rewards (converted from old points system)
  static const List<int> dailyCoins = [50, 75, 100, 150, 125, 150, 300];

  // Quest rewards
  static const int questEasy = 20;
  static const int questMedium = 50;
  static const int questHard = 100;

  // Achievement rewards by rarity
  static const int achievementCommon = 50;
  static const int achievementRare = 100;
  static const int achievementEpic = 250;
  static const int achievementLegendary = 500;

  /// Calculate game win coins based on level
  static int calculateGameWinCoins(int level, int stars, bool isPerfect) {
    int coins = gameWinBase + (level * gameWinPerLevel);

    if (stars == 3) {
      coins += threeStarBonus;
    }

    if (isPerfect) {
      coins += perfectGameBonus;
    }

    return coins;
  }
}
