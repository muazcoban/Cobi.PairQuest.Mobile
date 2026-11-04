/// Achievement names and descriptions in the app languages, shared by the
/// achievements screen and the unlock notification.
class AchievementTexts {
  AchievementTexts._();

  static String title(String id, String languageCode) =>
      (languageCode == 'tr' ? _titlesTr : _titlesEn)[id] ?? id;

  static String description(String id, String languageCode) =>
      (languageCode == 'tr' ? _descriptionsTr : _descriptionsEn)[id] ?? '';

  static const Map<String, String> _titlesTr = {
    'first_game': 'İlk Adım',
    'games_10': 'Başlangıç',
    'games_50': 'Sadık Oyuncu',
    'games_100': 'Hafıza Ustası',
    'matches_100': 'Eşleştirici',
    'matches_500': 'Desen Uzmanı',
    'matches_1000': 'Hafıza Dehası',
    'combo_3': 'Combo Başlangıcı',
    'combo_5': 'Combo Kralı',
    'combo_8': 'Ateşte',
    'combo_10': 'Durdurulamaz',
    'perfect_1': 'Mükemmeliyetçi',
    'perfect_5': 'Kusursuz',
    'perfect_10': 'Efsanevi Zeka',
    'streak_3': 'Sıcak Seri',
    'streak_7': 'Haftalık Savaşçı',
    'streak_10': 'Şampiyon',
    'level_5': 'Yarı Yolda',
    'level_10': 'Büyük Usta',
    'stars_30': 'Yıldız Toplayıcı',
  };

  static const Map<String, String> _titlesEn = {
    'first_game': 'First Steps',
    'games_10': 'Getting Started',
    'games_50': 'Dedicated Player',
    'games_100': 'Memory Master',
    'matches_100': 'Match Maker',
    'matches_500': 'Pattern Expert',
    'matches_1000': 'Memory Genius',
    'combo_3': 'Combo Starter',
    'combo_5': 'Combo King',
    'combo_8': 'On Fire',
    'combo_10': 'Unstoppable',
    'perfect_1': 'Perfectionist',
    'perfect_5': 'Flawless',
    'perfect_10': 'Legendary Mind',
    'streak_3': 'Hot Streak',
    'streak_7': 'Week Warrior',
    'streak_10': 'Champion',
    'level_5': 'Halfway There',
    'level_10': 'Grand Master',
    'stars_30': 'Star Collector',
  };

  static const Map<String, String> _descriptionsTr = {
    'first_game': 'İlk oyununu kazan',
    'games_10': '10 oyun kazan',
    'games_50': '50 oyun kazan',
    'games_100': '100 oyun kazan',
    'matches_100': '100 eşleşme yap',
    'matches_500': '500 eşleşme yap',
    'matches_1000': '1000 eşleşme yap',
    'combo_3': '3x combo yap',
    'combo_5': '5x combo yap',
    'combo_8': '8x combo yap',
    'combo_10': '10x combo yap',
    'perfect_1': 'Mükemmel bir oyun tamamla',
    'perfect_5': '5 mükemmel oyun tamamla',
    'perfect_10': '10 mükemmel oyun tamamla',
    'streak_3': 'Ard arda 3 oyun kazan',
    'streak_7': 'Ard arda 7 oyun kazan',
    'streak_10': 'Ard arda 10 oyun kazan',
    'level_5': 'Seviye 5\'i tamamla',
    'level_10': 'Seviye 10\'u tamamla',
    'stars_30': '30 yıldız topla',
  };

  static const Map<String, String> _descriptionsEn = {
    'first_game': 'Win your first game',
    'games_10': 'Win 10 games',
    'games_50': 'Win 50 games',
    'games_100': 'Win 100 games',
    'matches_100': 'Make 100 matches',
    'matches_500': 'Make 500 matches',
    'matches_1000': 'Make 1000 matches',
    'combo_3': 'Get a 3x combo',
    'combo_5': 'Get a 5x combo',
    'combo_8': 'Get an 8x combo',
    'combo_10': 'Get a 10x combo',
    'perfect_1': 'Complete a perfect game',
    'perfect_5': 'Complete 5 perfect games',
    'perfect_10': 'Complete 10 perfect games',
    'streak_3': 'Win 3 games in a row',
    'streak_7': 'Win 7 games in a row',
    'streak_10': 'Win 10 games in a row',
    'level_5': 'Complete level 5',
    'level_10': 'Complete level 10',
    'stars_30': 'Earn 30 stars',
  };
}
