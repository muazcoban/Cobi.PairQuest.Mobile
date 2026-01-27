// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'PairQuest';

  @override
  String get appSubtitle => 'Hafıza Eşleştirme Oyunu';

  @override
  String get classicMode => 'Klasik Mod';

  @override
  String get classicModeDesc => 'Zamansız oyna';

  @override
  String get timedMode => 'Zamanlı Mod';

  @override
  String get timedModeDesc => 'Süreye karşı yarış';

  @override
  String get selectLevel => 'Seviye Seç';

  @override
  String get selectLevelDesc => 'Istediğin seviyeyi seç';

  @override
  String get settings => 'Ayarlar';

  @override
  String get level => 'Seviye';

  @override
  String levelNumber(int number) {
    return 'Seviye $number';
  }

  @override
  String get score => 'Skor';

  @override
  String get moves => 'Hamle';

  @override
  String get pairs => 'Eşleşme';

  @override
  String get remaining => 'Kalan';

  @override
  String get time => 'Süre';

  @override
  String get combo => 'Combo';

  @override
  String get maxCombo => 'Maks Combo';

  @override
  String get pause => 'Duraklat';

  @override
  String get resume => 'Devam Et';

  @override
  String get restart => 'Yeniden Başla';

  @override
  String get quit => 'Çıkış';

  @override
  String get mainMenu => 'Ana Menü';

  @override
  String get gamePaused => 'Oyun Duraklatıldı';

  @override
  String get continueQuestion => 'Devam etmek istiyor musunuz?';

  @override
  String get congratulations => 'Tebrikler!';

  @override
  String levelCompleted(int level) {
    return 'Seviye $level tamamlandı!';
  }

  @override
  String get perfectGame => 'Mükemmel Oyun!';

  @override
  String get playAgain => 'Tekrar Oyna';

  @override
  String get nextLevel => 'Sonraki Seviye';

  @override
  String get timeUp => 'Süre Doldu!';

  @override
  String get timeUpMessage => 'Maalesef süren doldu.';

  @override
  String get tryAgain => 'Tekrar Dene';

  @override
  String get matched => 'Eşleşen';

  @override
  String get tutorial => 'Başlangıç';

  @override
  String get veryEasy => 'Çok Kolay';

  @override
  String get easy => 'Kolay';

  @override
  String get medium => 'Orta';

  @override
  String get hard => 'Zor';

  @override
  String get veryHard => 'Çok Zor';

  @override
  String get expert => 'Uzman';

  @override
  String get legendary => 'Efsanevi';

  @override
  String get master => 'Usta';

  @override
  String get language => 'Dil';

  @override
  String get turkish => 'Türkçe';

  @override
  String get english => 'English';

  @override
  String get sound => 'Ses';

  @override
  String get music => 'Müzik';

  @override
  String get vibration => 'Titreşim';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String get lightMode => 'Aydınlık Mod';

  @override
  String get systemDefault => 'Sistem Varsayılanı';

  @override
  String get cardTheme => 'Kart Teması';

  @override
  String get randomTheme => 'Rastgele';

  @override
  String get animals => 'Hayvanlar';

  @override
  String get fruits => 'Meyveler';

  @override
  String get flags => 'Bayraklar';

  @override
  String get sports => 'Sporlar';

  @override
  String get nature => 'Doğa';

  @override
  String get travel => 'Ulaşım';

  @override
  String get food => 'Yiyecekler';

  @override
  String get objects => 'Objeler';

  @override
  String get stars => 'Yıldız';

  @override
  String get bestScore => 'En İyi Skor';

  @override
  String get bestTime => 'En İyi Süre';

  @override
  String get statistics => 'İstatistikler';

  @override
  String get totalGames => 'Toplam Oyun';

  @override
  String get gamesWon => 'Kazanılan';

  @override
  String get totalPlayTime => 'Toplam Süre';

  @override
  String get locked => 'Kilitli';

  @override
  String get unlocked => 'Açık';

  @override
  String get overview => 'Genel Bakış';

  @override
  String get performance => 'Performans';

  @override
  String get records => 'Rekorlar';

  @override
  String get progress => 'İlerleme';

  @override
  String get playTime => 'Oynama Süresi';

  @override
  String get winRate => 'Kazanma Oranı';

  @override
  String get avgMoves => 'Ort. Hamle';

  @override
  String get totalMatches => 'Toplam Eşleşme';

  @override
  String get starsEarned => 'Kazanılan Yıldız';

  @override
  String get highestCombo => 'En İyi Combo';

  @override
  String get longestStreak => 'En Uzun Seri';

  @override
  String get perfectGames => 'Mükemmel Oyun';

  @override
  String get threeStarLevels => '3 Yıldızlı Seviye';

  @override
  String get levelProgress => 'Seviye İlerlemesi';

  @override
  String get achievements => 'Başarımlar';

  @override
  String get achievementUnlocked => 'Başarım Kazanıldı!';

  @override
  String achievementsEarned(Object count, Object total) {
    return '$count / $total Kazanıldı';
  }

  @override
  String get locked_achievement => 'Oynamaya devam et';

  @override
  String get dailyQuests => 'Günlük Görevler';

  @override
  String questsCompleted(Object count, Object total) {
    return '$count / $total Tamamlandı';
  }

  @override
  String get claimReward => 'Al';

  @override
  String get claimed => 'Alındı';

  @override
  String questRefresh(Object hours, Object minutes) {
    return 'Yeni görevler: ${hours}s ${minutes}dk';
  }

  @override
  String get leaderboard => 'Liderlik Tablosu';

  @override
  String get yourRank => 'Sıralamanız';

  @override
  String get topPlayers => 'En İyi Oyuncular';

  @override
  String get noScoresYet => 'Henüz skor yok';

  @override
  String get playGamesToSeeScores => 'Skorlarını görmek için oyna!';

  @override
  String get allLevels => 'Tüm Seviyeler';

  @override
  String get you => 'Sen';

  @override
  String get playerName => 'Oyuncu Adı';

  @override
  String get tapToChange => 'Değiştirmek için dokun';

  @override
  String get enterYourName => 'Adınızı girin';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'İptal';

  @override
  String get dailyReward => 'Günlük Ödül';

  @override
  String get dailyRewardClaimed => 'Yarın tekrar gel!';

  @override
  String get claimDailyReward => 'Ödülünü Al';

  @override
  String streakBonus(Object day) {
    return 'Seri Bonusu: Gün $day';
  }

  @override
  String get memorize => 'Ezberle!';

  @override
  String get localMultiplayer => 'Yerel Çok Oyunculu';

  @override
  String get localMultiplayerDesc => 'Arkadaşlarınla oyna';

  @override
  String get playerCount => 'Oyuncu Sayısı';

  @override
  String get players => 'Oyuncular';

  @override
  String get startGame => 'Oyunu Başlat';

  @override
  String get yourTurn => 'Senin Sıran';

  @override
  String get gameOver => 'Oyun Bitti';

  @override
  String get wins => 'kazandı';

  @override
  String get player => 'Oyuncu';

  @override
  String get signIn => 'Giriş Yap';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get signInWithGoogle => 'Google ile Giriş';

  @override
  String get continueAsGuest => 'Misafir Olarak Devam Et';

  @override
  String get signInToSaveProgress =>
      'İlerlemenizi kaydetmek ve skor tablosunda yarışmak için giriş yapın';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get account => 'Hesap';

  @override
  String get guest => 'Misafir';

  @override
  String get linkAccount => 'Hesap Bağla';

  @override
  String get linkAccountDesc =>
      'İlerlemenizi kaydetmek için hesabınızı bağlayın';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get deleteAccountConfirm =>
      'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get accountLinked => 'Hesap başarıyla bağlandı!';

  @override
  String get signInRequired => 'Giriş gerekli';

  @override
  String get signInToSubmitScore =>
      'Skorunuzu global skor tablosuna göndermek için giriş yapın';

  @override
  String get globalLeaderboard => 'Global Skor Tablosu';

  @override
  String get localLeaderboard => 'Yerel Skorlar';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get dailyReminder => 'Günlük Hatırlatıcı';

  @override
  String get dailyReminderDesc => 'Oynamam için hatırlat';

  @override
  String get achievementAlerts => 'Başarım Uyarıları';

  @override
  String get achievementAlertsDesc => 'Başarımlar açıldığında bildir';

  @override
  String get questAlerts => 'Görev Uyarıları';

  @override
  String get questAlertsDesc => 'Görevler tamamlandığında bildir';

  @override
  String get reminderTime => 'Hatırlatma Saati';

  @override
  String get coins => 'Altın';

  @override
  String get gems => 'Elmas';

  @override
  String get wallet => 'Cüzdan';

  @override
  String get notEnoughCoins => 'Yeterli altın yok';

  @override
  String get notEnoughGems => 'Yeterli elmas yok';

  @override
  String get purchase => 'Satın Al';

  @override
  String get purchaseSuccess => 'Satın alma başarılı!';

  @override
  String get powerUps => 'Güç-Uplar';

  @override
  String get powerUpPeek => 'Göz At';

  @override
  String get powerUpPeekDesc => 'Tüm kartları birkaç saniye göster';

  @override
  String get powerUpFreeze => 'Dondur';

  @override
  String get powerUpFreezeDesc => 'Zamanlayıcıyı 10 saniye durdur';

  @override
  String get powerUpHint => 'İpucu';

  @override
  String get powerUpHintDesc => 'Eşleşen bir çifti vurgula';

  @override
  String get powerUpShuffle => 'Karıştır';

  @override
  String get powerUpShuffleDesc => 'Eşleşmemiş kartları yeniden karıştır';

  @override
  String get powerUpTimeBonus => 'Süre Bonusu';

  @override
  String get powerUpTimeBonusDesc => 'Ekstra süre ekle';

  @override
  String get powerUpMagnet => 'Mıknatıs';

  @override
  String get powerUpMagnetDesc => 'Sonraki kart otomatik eşini bulur';

  @override
  String get powerUpUsed => 'Güç-up kullanıldı!';

  @override
  String powerUpActive(Object seconds) {
    return 'Aktif: ${seconds}sn';
  }

  @override
  String get powerUpLimitReached => 'Bu oyun için limit doldu';

  @override
  String get timedModeOnly => 'Sadece Zamanlı Modda';

  @override
  String get buyPowerUp => 'Güç-Up Satın Al';

  @override
  String get usePowerUp => 'Kullan';

  @override
  String owned(Object count) {
    return 'Sahip: $count';
  }

  @override
  String get shop => 'Mağaza';

  @override
  String get inventory => 'Envanter';

  @override
  String get emptyInventory => 'Henüz güç-up yok';

  @override
  String get timeFrozen => 'SÜRE DONDURULDU';

  @override
  String get tapAnyCard => 'HERHANGİ BİR KARTA DOKUN';
}
