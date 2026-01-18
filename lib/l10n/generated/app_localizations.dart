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
