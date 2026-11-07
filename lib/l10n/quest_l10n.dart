/// Daily quest names and descriptions in the app languages.
class QuestTexts {
  QuestTexts._();

  static String title(String id, String languageCode) =>
      (languageCode == 'tr' ? _titlesTr : _titlesEn)[id] ?? id;

  static String description(String id, String languageCode) =>
      (languageCode == 'tr' ? _descriptionsTr : _descriptionsEn)[id] ?? '';

  static const Map<String, String> _titlesTr = {
    'play_1': 'Bir Oyun Oyna',
    'play_3': '3 Oyun Oyna',
    'win_2': '2 Oyun Kazan',
    'win_5': '5 Oyun Kazan',
    'matches_10': '10 Eşleşme Yap',
    'matches_30': '30 Eşleşme Yap',
    'combo_3': '3x Combo Yap',
    'combo_5': '5x Combo Yap',
    'perfect_1': 'Kusursuz Oyun',
    'stars_3': '3 Yıldız Kazan',
    'stars_6': '6 Yıldız Kazan',
    'powerup_1': 'Güç Kullanıcısı',
    'powerup_3': 'Güç Ustası',
    'no_powerup_win': 'Saf Zafer',
    'timed_win_3': 'Hız Koşucusu',
  };

  static const Map<String, String> _titlesEn = {
    'play_1': 'Play a Game',
    'play_3': 'Play 3 Games',
    'win_2': 'Win 2 Games',
    'win_5': 'Win 5 Games',
    'matches_10': 'Make 10 Matches',
    'matches_30': 'Make 30 Matches',
    'combo_3': 'Get 3x Combo',
    'combo_5': 'Get 5x Combo',
    'perfect_1': 'Perfect Game',
    'stars_3': 'Earn 3 Stars',
    'stars_6': 'Earn 6 Stars',
    'powerup_1': 'Power User',
    'powerup_3': 'Power Master',
    'no_powerup_win': 'Purist Victory',
    'timed_win_3': 'Speed Runner',
  };

  static const Map<String, String> _descriptionsTr = {
    'play_1': 'Tamamlamak için herhangi bir oyun oyna',
    'play_3': 'Bugün 3 oyun oyna',
    'win_2': 'Bugün 2 oyun kazan',
    'win_5': 'Bugün 5 oyun kazan',
    'matches_10': '10 çift eşleştir',
    'matches_30': 'Bugün 30 çift eşleştir',
    'combo_3': 'Art arda 3x combo yap',
    'combo_5': 'Art arda 5x combo yap',
    'perfect_1': 'Hiç hata yapmadan bitir',
    'stars_3': 'Toplam 3 yıldız kazan',
    'stars_6': 'Bugün 6 yıldız kazan',
    'powerup_1': 'Bir oyunda herhangi bir güç-up kullan',
    'powerup_3': 'Bugün 3 güç-up kullan',
    'no_powerup_win': 'Güç-up kullanmadan kazan',
    'timed_win_3': "Zamanlı Mod'da 3 oyun kazan",
  };

  static const Map<String, String> _descriptionsEn = {
    'play_1': 'Play any game to complete',
    'play_3': 'Play 3 games today',
    'win_2': 'Win 2 games today',
    'win_5': 'Win 5 games today',
    'matches_10': 'Match 10 pairs',
    'matches_30': 'Match 30 pairs today',
    'combo_3': 'Get a 3x combo streak',
    'combo_5': 'Get a 5x combo streak',
    'perfect_1': 'Complete without mistakes',
    'stars_3': 'Earn 3 stars total',
    'stars_6': 'Earn 6 stars today',
    'powerup_1': 'Use any power-up in a game',
    'powerup_3': 'Use 3 power-ups today',
    'no_powerup_win': 'Win without using power-ups',
    'timed_win_3': 'Win 3 games in Timed Mode',
  };
}
