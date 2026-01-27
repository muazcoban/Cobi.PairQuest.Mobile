import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// Uygulama başlığı
  ///
  /// In tr, this message translates to:
  /// **'PairQuest'**
  String get appTitle;

  /// Uygulama alt başlığı
  ///
  /// In tr, this message translates to:
  /// **'Hafıza Eşleştirme Oyunu'**
  String get appSubtitle;

  /// Klasik mod butonu
  ///
  /// In tr, this message translates to:
  /// **'Klasik Mod'**
  String get classicMode;

  /// Klasik mod açıklaması
  ///
  /// In tr, this message translates to:
  /// **'Zamansız oyna'**
  String get classicModeDesc;

  /// Zamanlı mod butonu
  ///
  /// In tr, this message translates to:
  /// **'Zamanlı Mod'**
  String get timedMode;

  /// Zamanlı mod açıklaması
  ///
  /// In tr, this message translates to:
  /// **'Süreye karşı yarış'**
  String get timedModeDesc;

  /// Seviye seçim butonu
  ///
  /// In tr, this message translates to:
  /// **'Seviye Seç'**
  String get selectLevel;

  /// Seviye seçim açıklaması
  ///
  /// In tr, this message translates to:
  /// **'Istediğin seviyeyi seç'**
  String get selectLevelDesc;

  /// Ayarlar butonu
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// Seviye etiketi
  ///
  /// In tr, this message translates to:
  /// **'Seviye'**
  String get level;

  /// Numaralı seviye
  ///
  /// In tr, this message translates to:
  /// **'Seviye {number}'**
  String levelNumber(int number);

  /// Skor etiketi
  ///
  /// In tr, this message translates to:
  /// **'Skor'**
  String get score;

  /// Hamle etiketi
  ///
  /// In tr, this message translates to:
  /// **'Hamle'**
  String get moves;

  /// Eşleşme etiketi
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme'**
  String get pairs;

  /// Kalan çift etiketi
  ///
  /// In tr, this message translates to:
  /// **'Kalan'**
  String get remaining;

  /// Süre etiketi
  ///
  /// In tr, this message translates to:
  /// **'Süre'**
  String get time;

  /// Combo etiketi
  ///
  /// In tr, this message translates to:
  /// **'Combo'**
  String get combo;

  /// Maksimum combo etiketi
  ///
  /// In tr, this message translates to:
  /// **'Maks Combo'**
  String get maxCombo;

  /// Duraklat butonu
  ///
  /// In tr, this message translates to:
  /// **'Duraklat'**
  String get pause;

  /// Devam et butonu
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get resume;

  /// Yeniden başla butonu
  ///
  /// In tr, this message translates to:
  /// **'Yeniden Başla'**
  String get restart;

  /// Çıkış butonu
  ///
  /// In tr, this message translates to:
  /// **'Çıkış'**
  String get quit;

  /// Ana menü butonu
  ///
  /// In tr, this message translates to:
  /// **'Ana Menü'**
  String get mainMenu;

  /// Oyun duraklatıldı başlığı
  ///
  /// In tr, this message translates to:
  /// **'Oyun Duraklatıldı'**
  String get gamePaused;

  /// Devam sorusu
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek istiyor musunuz?'**
  String get continueQuestion;

  /// Tebrikler başlığı
  ///
  /// In tr, this message translates to:
  /// **'Tebrikler!'**
  String get congratulations;

  /// Seviye tamamlandı mesajı
  ///
  /// In tr, this message translates to:
  /// **'Seviye {level} tamamlandı!'**
  String levelCompleted(int level);

  /// Mükemmel oyun mesajı
  ///
  /// In tr, this message translates to:
  /// **'Mükemmel Oyun!'**
  String get perfectGame;

  /// Tekrar oyna butonu
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Oyna'**
  String get playAgain;

  /// Sonraki seviye butonu
  ///
  /// In tr, this message translates to:
  /// **'Sonraki Seviye'**
  String get nextLevel;

  /// Süre doldu başlığı
  ///
  /// In tr, this message translates to:
  /// **'Süre Doldu!'**
  String get timeUp;

  /// Süre doldu mesajı
  ///
  /// In tr, this message translates to:
  /// **'Maalesef süren doldu.'**
  String get timeUpMessage;

  /// Tekrar dene butonu
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get tryAgain;

  /// Eşleşen çift etiketi
  ///
  /// In tr, this message translates to:
  /// **'Eşleşen'**
  String get matched;

  /// Tutorial zorluk
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get tutorial;

  /// Çok kolay zorluk
  ///
  /// In tr, this message translates to:
  /// **'Çok Kolay'**
  String get veryEasy;

  /// Kolay zorluk
  ///
  /// In tr, this message translates to:
  /// **'Kolay'**
  String get easy;

  /// Orta zorluk
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get medium;

  /// Zor zorluk
  ///
  /// In tr, this message translates to:
  /// **'Zor'**
  String get hard;

  /// Çok zor zorluk
  ///
  /// In tr, this message translates to:
  /// **'Çok Zor'**
  String get veryHard;

  /// Uzman zorluk
  ///
  /// In tr, this message translates to:
  /// **'Uzman'**
  String get expert;

  /// Efsanevi zorluk
  ///
  /// In tr, this message translates to:
  /// **'Efsanevi'**
  String get legendary;

  /// Usta zorluk
  ///
  /// In tr, this message translates to:
  /// **'Usta'**
  String get master;

  /// Dil ayarı
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// Türkçe dil seçeneği
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// İngilizce dil seçeneği
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get english;

  /// Ses ayarı
  ///
  /// In tr, this message translates to:
  /// **'Ses'**
  String get sound;

  /// Müzik ayarı
  ///
  /// In tr, this message translates to:
  /// **'Müzik'**
  String get music;

  /// Titreşim ayarı
  ///
  /// In tr, this message translates to:
  /// **'Titreşim'**
  String get vibration;

  /// Tema ayarı
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get theme;

  /// Karanlık mod ayarı
  ///
  /// In tr, this message translates to:
  /// **'Karanlık Mod'**
  String get darkMode;

  /// Aydınlık mod ayarı
  ///
  /// In tr, this message translates to:
  /// **'Aydınlık Mod'**
  String get lightMode;

  /// Sistem varsayılanı
  ///
  /// In tr, this message translates to:
  /// **'Sistem Varsayılanı'**
  String get systemDefault;

  /// Kart teması ayarı
  ///
  /// In tr, this message translates to:
  /// **'Kart Teması'**
  String get cardTheme;

  /// Rastgele tema seçeneği
  ///
  /// In tr, this message translates to:
  /// **'Rastgele'**
  String get randomTheme;

  /// Hayvanlar teması
  ///
  /// In tr, this message translates to:
  /// **'Hayvanlar'**
  String get animals;

  /// Meyveler teması
  ///
  /// In tr, this message translates to:
  /// **'Meyveler'**
  String get fruits;

  /// Bayraklar teması
  ///
  /// In tr, this message translates to:
  /// **'Bayraklar'**
  String get flags;

  /// Sporlar teması
  ///
  /// In tr, this message translates to:
  /// **'Sporlar'**
  String get sports;

  /// Doğa teması
  ///
  /// In tr, this message translates to:
  /// **'Doğa'**
  String get nature;

  /// Ulaşım teması
  ///
  /// In tr, this message translates to:
  /// **'Ulaşım'**
  String get travel;

  /// Yiyecekler teması
  ///
  /// In tr, this message translates to:
  /// **'Yiyecekler'**
  String get food;

  /// Objeler teması
  ///
  /// In tr, this message translates to:
  /// **'Objeler'**
  String get objects;

  /// Yıldız etiketi
  ///
  /// In tr, this message translates to:
  /// **'Yıldız'**
  String get stars;

  /// En iyi skor etiketi
  ///
  /// In tr, this message translates to:
  /// **'En İyi Skor'**
  String get bestScore;

  /// En iyi süre etiketi
  ///
  /// In tr, this message translates to:
  /// **'En İyi Süre'**
  String get bestTime;

  /// İstatistikler başlığı
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler'**
  String get statistics;

  /// Toplam oyun etiketi
  ///
  /// In tr, this message translates to:
  /// **'Toplam Oyun'**
  String get totalGames;

  /// Kazanılan oyun etiketi
  ///
  /// In tr, this message translates to:
  /// **'Kazanılan'**
  String get gamesWon;

  /// Toplam oynama süresi
  ///
  /// In tr, this message translates to:
  /// **'Toplam Süre'**
  String get totalPlayTime;

  /// Kilitli seviye
  ///
  /// In tr, this message translates to:
  /// **'Kilitli'**
  String get locked;

  /// Açık seviye
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get unlocked;

  /// No description provided for @overview.
  ///
  /// In tr, this message translates to:
  /// **'Genel Bakış'**
  String get overview;

  /// No description provided for @performance.
  ///
  /// In tr, this message translates to:
  /// **'Performans'**
  String get performance;

  /// No description provided for @records.
  ///
  /// In tr, this message translates to:
  /// **'Rekorlar'**
  String get records;

  /// No description provided for @progress.
  ///
  /// In tr, this message translates to:
  /// **'İlerleme'**
  String get progress;

  /// No description provided for @playTime.
  ///
  /// In tr, this message translates to:
  /// **'Oynama Süresi'**
  String get playTime;

  /// No description provided for @winRate.
  ///
  /// In tr, this message translates to:
  /// **'Kazanma Oranı'**
  String get winRate;

  /// No description provided for @avgMoves.
  ///
  /// In tr, this message translates to:
  /// **'Ort. Hamle'**
  String get avgMoves;

  /// No description provided for @totalMatches.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Eşleşme'**
  String get totalMatches;

  /// No description provided for @starsEarned.
  ///
  /// In tr, this message translates to:
  /// **'Kazanılan Yıldız'**
  String get starsEarned;

  /// No description provided for @highestCombo.
  ///
  /// In tr, this message translates to:
  /// **'En İyi Combo'**
  String get highestCombo;

  /// No description provided for @longestStreak.
  ///
  /// In tr, this message translates to:
  /// **'En Uzun Seri'**
  String get longestStreak;

  /// No description provided for @perfectGames.
  ///
  /// In tr, this message translates to:
  /// **'Mükemmel Oyun'**
  String get perfectGames;

  /// No description provided for @threeStarLevels.
  ///
  /// In tr, this message translates to:
  /// **'3 Yıldızlı Seviye'**
  String get threeStarLevels;

  /// No description provided for @levelProgress.
  ///
  /// In tr, this message translates to:
  /// **'Seviye İlerlemesi'**
  String get levelProgress;

  /// No description provided for @achievements.
  ///
  /// In tr, this message translates to:
  /// **'Başarımlar'**
  String get achievements;

  /// No description provided for @achievementUnlocked.
  ///
  /// In tr, this message translates to:
  /// **'Başarım Kazanıldı!'**
  String get achievementUnlocked;

  /// No description provided for @achievementsEarned.
  ///
  /// In tr, this message translates to:
  /// **'{count} / {total} Kazanıldı'**
  String achievementsEarned(Object count, Object total);

  /// No description provided for @locked_achievement.
  ///
  /// In tr, this message translates to:
  /// **'Oynamaya devam et'**
  String get locked_achievement;

  /// No description provided for @dailyQuests.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Görevler'**
  String get dailyQuests;

  /// No description provided for @questsCompleted.
  ///
  /// In tr, this message translates to:
  /// **'{count} / {total} Tamamlandı'**
  String questsCompleted(Object count, Object total);

  /// No description provided for @claimReward.
  ///
  /// In tr, this message translates to:
  /// **'Al'**
  String get claimReward;

  /// No description provided for @claimed.
  ///
  /// In tr, this message translates to:
  /// **'Alındı'**
  String get claimed;

  /// No description provided for @questRefresh.
  ///
  /// In tr, this message translates to:
  /// **'Yeni görevler: {hours}s {minutes}dk'**
  String questRefresh(Object hours, Object minutes);

  /// No description provided for @leaderboard.
  ///
  /// In tr, this message translates to:
  /// **'Liderlik Tablosu'**
  String get leaderboard;

  /// No description provided for @yourRank.
  ///
  /// In tr, this message translates to:
  /// **'Sıralamanız'**
  String get yourRank;

  /// No description provided for @topPlayers.
  ///
  /// In tr, this message translates to:
  /// **'En İyi Oyuncular'**
  String get topPlayers;

  /// No description provided for @noScoresYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz skor yok'**
  String get noScoresYet;

  /// No description provided for @playGamesToSeeScores.
  ///
  /// In tr, this message translates to:
  /// **'Skorlarını görmek için oyna!'**
  String get playGamesToSeeScores;

  /// No description provided for @allLevels.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Seviyeler'**
  String get allLevels;

  /// No description provided for @you.
  ///
  /// In tr, this message translates to:
  /// **'Sen'**
  String get you;

  /// No description provided for @playerName.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncu Adı'**
  String get playerName;

  /// No description provided for @tapToChange.
  ///
  /// In tr, this message translates to:
  /// **'Değiştirmek için dokun'**
  String get tapToChange;

  /// No description provided for @enterYourName.
  ///
  /// In tr, this message translates to:
  /// **'Adınızı girin'**
  String get enterYourName;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @dailyReward.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Ödül'**
  String get dailyReward;

  /// No description provided for @dailyRewardClaimed.
  ///
  /// In tr, this message translates to:
  /// **'Yarın tekrar gel!'**
  String get dailyRewardClaimed;

  /// No description provided for @claimDailyReward.
  ///
  /// In tr, this message translates to:
  /// **'Ödülünü Al'**
  String get claimDailyReward;

  /// No description provided for @streakBonus.
  ///
  /// In tr, this message translates to:
  /// **'Seri Bonusu: Gün {day}'**
  String streakBonus(Object day);

  /// No description provided for @memorize.
  ///
  /// In tr, this message translates to:
  /// **'Ezberle!'**
  String get memorize;

  /// No description provided for @localMultiplayer.
  ///
  /// In tr, this message translates to:
  /// **'Yerel Çok Oyunculu'**
  String get localMultiplayer;

  /// No description provided for @localMultiplayerDesc.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşlarınla oyna'**
  String get localMultiplayerDesc;

  /// No description provided for @playerCount.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncu Sayısı'**
  String get playerCount;

  /// No description provided for @players.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncular'**
  String get players;

  /// No description provided for @startGame.
  ///
  /// In tr, this message translates to:
  /// **'Oyunu Başlat'**
  String get startGame;

  /// No description provided for @yourTurn.
  ///
  /// In tr, this message translates to:
  /// **'Senin Sıran'**
  String get yourTurn;

  /// No description provided for @gameOver.
  ///
  /// In tr, this message translates to:
  /// **'Oyun Bitti'**
  String get gameOver;

  /// No description provided for @wins.
  ///
  /// In tr, this message translates to:
  /// **'kazandı'**
  String get wins;

  /// No description provided for @player.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncu'**
  String get player;

  /// No description provided for @signIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get signOut;

  /// No description provided for @signInWithGoogle.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Giriş'**
  String get signInWithGoogle;

  /// No description provided for @continueAsGuest.
  ///
  /// In tr, this message translates to:
  /// **'Misafir Olarak Devam Et'**
  String get continueAsGuest;

  /// No description provided for @signInToSaveProgress.
  ///
  /// In tr, this message translates to:
  /// **'İlerlemenizi kaydetmek ve skor tablosunda yarışmak için giriş yapın'**
  String get signInToSaveProgress;

  /// No description provided for @privacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicy;

  /// No description provided for @account.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get account;

  /// No description provided for @guest.
  ///
  /// In tr, this message translates to:
  /// **'Misafir'**
  String get guest;

  /// No description provided for @linkAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Bağla'**
  String get linkAccount;

  /// No description provided for @linkAccountDesc.
  ///
  /// In tr, this message translates to:
  /// **'İlerlemenizi kaydetmek için hesabınızı bağlayın'**
  String get linkAccountDesc;

  /// No description provided for @deleteAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'**
  String get deleteAccountConfirm;

  /// No description provided for @accountLinked.
  ///
  /// In tr, this message translates to:
  /// **'Hesap başarıyla bağlandı!'**
  String get accountLinked;

  /// No description provided for @signInRequired.
  ///
  /// In tr, this message translates to:
  /// **'Giriş gerekli'**
  String get signInRequired;

  /// No description provided for @signInToSubmitScore.
  ///
  /// In tr, this message translates to:
  /// **'Skorunuzu global skor tablosuna göndermek için giriş yapın'**
  String get signInToSubmitScore;

  /// No description provided for @globalLeaderboard.
  ///
  /// In tr, this message translates to:
  /// **'Global Skor Tablosu'**
  String get globalLeaderboard;

  /// No description provided for @localLeaderboard.
  ///
  /// In tr, this message translates to:
  /// **'Yerel Skorlar'**
  String get localLeaderboard;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @dailyReminder.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Hatırlatıcı'**
  String get dailyReminder;

  /// No description provided for @dailyReminderDesc.
  ///
  /// In tr, this message translates to:
  /// **'Oynamam için hatırlat'**
  String get dailyReminderDesc;

  /// No description provided for @achievementAlerts.
  ///
  /// In tr, this message translates to:
  /// **'Başarım Uyarıları'**
  String get achievementAlerts;

  /// No description provided for @achievementAlertsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Başarımlar açıldığında bildir'**
  String get achievementAlertsDesc;

  /// No description provided for @questAlerts.
  ///
  /// In tr, this message translates to:
  /// **'Görev Uyarıları'**
  String get questAlerts;

  /// No description provided for @questAlertsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Görevler tamamlandığında bildir'**
  String get questAlertsDesc;

  /// No description provided for @reminderTime.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatma Saati'**
  String get reminderTime;

  /// No description provided for @coins.
  ///
  /// In tr, this message translates to:
  /// **'Altın'**
  String get coins;

  /// No description provided for @gems.
  ///
  /// In tr, this message translates to:
  /// **'Elmas'**
  String get gems;

  /// No description provided for @wallet.
  ///
  /// In tr, this message translates to:
  /// **'Cüzdan'**
  String get wallet;

  /// No description provided for @notEnoughCoins.
  ///
  /// In tr, this message translates to:
  /// **'Yeterli altın yok'**
  String get notEnoughCoins;

  /// No description provided for @notEnoughGems.
  ///
  /// In tr, this message translates to:
  /// **'Yeterli elmas yok'**
  String get notEnoughGems;

  /// No description provided for @purchase.
  ///
  /// In tr, this message translates to:
  /// **'Satın Al'**
  String get purchase;

  /// No description provided for @purchaseSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Satın alma başarılı!'**
  String get purchaseSuccess;

  /// No description provided for @powerUps.
  ///
  /// In tr, this message translates to:
  /// **'Güç-Uplar'**
  String get powerUps;

  /// No description provided for @powerUpPeek.
  ///
  /// In tr, this message translates to:
  /// **'Göz At'**
  String get powerUpPeek;

  /// No description provided for @powerUpPeekDesc.
  ///
  /// In tr, this message translates to:
  /// **'Tüm kartları birkaç saniye göster'**
  String get powerUpPeekDesc;

  /// No description provided for @powerUpFreeze.
  ///
  /// In tr, this message translates to:
  /// **'Dondur'**
  String get powerUpFreeze;

  /// No description provided for @powerUpFreezeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Zamanlayıcıyı 10 saniye durdur'**
  String get powerUpFreezeDesc;

  /// No description provided for @powerUpHint.
  ///
  /// In tr, this message translates to:
  /// **'İpucu'**
  String get powerUpHint;

  /// No description provided for @powerUpHintDesc.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşen bir çifti vurgula'**
  String get powerUpHintDesc;

  /// No description provided for @powerUpShuffle.
  ///
  /// In tr, this message translates to:
  /// **'Karıştır'**
  String get powerUpShuffle;

  /// No description provided for @powerUpShuffleDesc.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşmemiş kartları yeniden karıştır'**
  String get powerUpShuffleDesc;

  /// No description provided for @powerUpTimeBonus.
  ///
  /// In tr, this message translates to:
  /// **'Süre Bonusu'**
  String get powerUpTimeBonus;

  /// No description provided for @powerUpTimeBonusDesc.
  ///
  /// In tr, this message translates to:
  /// **'Ekstra süre ekle'**
  String get powerUpTimeBonusDesc;

  /// No description provided for @powerUpMagnet.
  ///
  /// In tr, this message translates to:
  /// **'Mıknatıs'**
  String get powerUpMagnet;

  /// No description provided for @powerUpMagnetDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki kart otomatik eşini bulur'**
  String get powerUpMagnetDesc;

  /// No description provided for @powerUpUsed.
  ///
  /// In tr, this message translates to:
  /// **'Güç-up kullanıldı!'**
  String get powerUpUsed;

  /// No description provided for @powerUpActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif: {seconds}sn'**
  String powerUpActive(Object seconds);

  /// No description provided for @powerUpLimitReached.
  ///
  /// In tr, this message translates to:
  /// **'Bu oyun için limit doldu'**
  String get powerUpLimitReached;

  /// No description provided for @timedModeOnly.
  ///
  /// In tr, this message translates to:
  /// **'Sadece Zamanlı Modda'**
  String get timedModeOnly;

  /// No description provided for @buyPowerUp.
  ///
  /// In tr, this message translates to:
  /// **'Güç-Up Satın Al'**
  String get buyPowerUp;

  /// No description provided for @usePowerUp.
  ///
  /// In tr, this message translates to:
  /// **'Kullan'**
  String get usePowerUp;

  /// No description provided for @owned.
  ///
  /// In tr, this message translates to:
  /// **'Sahip: {count}'**
  String owned(Object count);

  /// No description provided for @shop.
  ///
  /// In tr, this message translates to:
  /// **'Mağaza'**
  String get shop;

  /// No description provided for @inventory.
  ///
  /// In tr, this message translates to:
  /// **'Envanter'**
  String get inventory;

  /// No description provided for @emptyInventory.
  ///
  /// In tr, this message translates to:
  /// **'Henüz güç-up yok'**
  String get emptyInventory;

  /// No description provided for @timeFrozen.
  ///
  /// In tr, this message translates to:
  /// **'SÜRE DONDURULDU'**
  String get timeFrozen;

  /// No description provided for @tapAnyCard.
  ///
  /// In tr, this message translates to:
  /// **'HERHANGİ BİR KARTA DOKUN'**
  String get tapAnyCard;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
