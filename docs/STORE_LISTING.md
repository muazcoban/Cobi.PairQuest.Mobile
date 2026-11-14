# Memoko - Store Listing (formerly PairQuest)

Metadata for App Store Connect and Google Play Console. The limits in brackets are the
store limits; the number after each line is its length. Name research:
`reports/PairQuest için yeni uygulama adı.md` (kept outside git).

Rules for the keyword field: commas without spaces, no word that is already in the name
or subtitle, no category names ("puzzle", "bulmaca"), no competitor names.

---

## App Store: English (U.S.)

Use the same text for English (U.K.). The Turkish storefront also indexes the U.K.
localization, so English searches in Turkey find the game too.

**Name** [30]: Memoko: Memory Match Game (25)

**Subtitle** [30]: Find Card Pairs, Duel Online (28)

**Keywords** [100]: `matching,concentration,multiplayer,pvp,brain,flip,versus,friends,leaderboard,classic,race,2 player` (98)

**Promotional text** [170]: PairQuest is now Memoko. Same game, new name. Challenge real players in online memory duels and climb the ranked leagues from Bronze to Master. (143)

**What's New in 2.3.0**:

PairQuest is now Memoko. Your progress, coins and online profile stay the same.
• The game now asks for a rating only after a few won levels
• Turkish name on the Home Screen and in the App Store

**Description** [4000]:

Memoko (formerly PairQuest) is a memory card matching game you can play alone or against real players online.

Flip two cards, find the pair, clear the board. Start on a 2×2 grid and work up to a 10×10 board across 20 levels.

PLAY YOUR WAY
• Classic mode: no timer, take your time
• Timed mode: race the clock for bonus points
• Online 1v1: play real players and climb the ranked leagues from Bronze to Master
• Friends: add friends and invite them to a duel
• Local multiplayer: 2 to 4 players on one device

8 CARD THEMES
Animals, fruits, flags, sports, nature, travel, food and objects.

KEEP COMING BACK
• 20 achievements
• Daily quests and a 7-day reward streak
• Power-ups such as peek, hint and freeze the timer
• Global leaderboard and detailed statistics

FOR EVERYONE
• Dark and light mode
• Screen reader support
• English and Turkish

Online play needs a sign-in with Apple or Google. Single-player games work offline.

---

## App Store: Turkish

**Ad** [30]: Memoko: Hafıza Kartı Oyunu (26)

**Alt başlık** [30]: Kart Eşleştirme, Online Düello (30)

**Anahtar kelimeler** [100]: `oyunları,hafiza,eslestirme,kartları,eşleme,yarış,akıl,iki kişilik,beyin,zeka,konsantrasyon` (90 karakter, 97 bayt)

ASCII yazımlar (`hafiza`, `eslestirme`) bilerek var: Türkiye mağazası "hafiza oyunu" ile
"hafıza oyunu" aramalarına farklı sonuç döndürüyor. "Çift", "eşini bul" ve "çocuk" bilerek
yok: ilk ikisi flört uygulamalarına gidiyor, üçüncüsü 9+ bir oyunda App Review 2.3.8'e takılabilir.

**Promosyon metni** [170]: PairQuest artık Memoko! Oyun aynı, adı yeni. Online hafıza düellolarında gerçek oyunculara meydan oku, Bronz'dan Usta'ya liglerde yüksel. (137)

**Yenilikler (2.3.0)**:

PairQuest artık Memoko. İlerlemen, altınların ve online profilin olduğu gibi duruyor.
• Oyun puan isteğini yalnızca birkaç kazanılmış seviyeden sonra gösteriyor
• Ana ekranda ve App Store'da Türkçe görünüm

**Açıklama** [4000]:

Memoko (eski adıyla PairQuest), tek başına ya da online gerçek oyunculara karşı oynayabileceğin bir hafıza kartı eşleştirme oyunu.

İki kartı çevir, eşini bul, tahtayı temizle. 2×2 tahtayla başla, 20 seviyede 10×10 tahtaya kadar ilerle.

İSTEDİĞİN GİBİ OYNA
• Klasik Mod: süre yok, acele etme
• Zamanlı Mod: bonus puan için saate karşı yarış
• Online 1v1: gerçek oyuncularla oyna, Bronz'dan Usta'ya liglerde yüksel
• Arkadaşlar: arkadaş ekle, düelloya davet et
• Yerel çok oyunculu: aynı cihazda 2-4 oyuncu

8 KART TEMASI
Hayvanlar, meyveler, bayraklar, sporlar, doğa, seyahat, yiyecekler ve nesneler.

HER GÜN YENİ BİR HEDEF
• 20 başarım
• Günlük görevler ve 7 günlük ödül serisi
• Kartlara göz atma, ipucu ve süreyi dondurma gibi güçlendiriciler
• Dünya sıralaması ve ayrıntılı istatistikler

HERKES İÇİN
• Karanlık ve aydınlık mod
• Ekran okuyucu desteği
• Türkçe ve İngilizce

Online oyun için Apple ya da Google ile giriş gerekir. Tek oyunculu oyunlar internetsiz çalışır.

---

## Google Play

Google Play has no subtitle or keyword field; the title and the short description carry
the search words. Android shows only Google sign-in, so the description says "Google".

| Field | English (en-US) | Turkish (tr-TR) |
|---|---|---|
| Title [30] | Memoko: Memory Match Game (25) | Memoko: Hafıza Kartı Oyunu (26) |
| Short description [80] | Flip cards, find pairs and beat friends in ranked online memory duels. (70) | Kartları çevir, eşleştir, arkadaşlarınla online hafıza düellosuna gir. (70) |

**Full description** [4000]: the App Store description above, with the last line changed to
"Online play needs a sign-in with Google." / "Online oyun için Google ile giriş gerekir."

---

## Screenshots

Ready for Google Play in `docs/store/screenshots/` (1080×1920 PNG, Turkish `tr_*` and
English `en_*`), taken from the release build on an Android 14 emulator:

| File | Caption (TR / EN) |
|---|---|
| `*_1_board.png` | Kartları çevir, eşini bul / Flip cards, find the pairs |
| `*_2_levels.png` | 20 seviye: 2×2'den 10×10'a / 20 levels: from 2×2 to 10×10 |
| `*_3_win.png` | Yıldızları topla, altın kazan / Collect stars, earn coins |
| `*_4_quests.png` | Her gün yeni görevler / New quests every day |
| `*_5_achievements.png` | 20 başarımı aç / Unlock 20 achievements |
| `*_6_multiplayer.png` | Arkadaşlarınla aynı cihazda yarış / Play friends on one device |

Missing: an online 1v1 screenshot (the feature most memory games do not have). It needs
a signed-in account, so take it on a device and put it first. The App Store needs its own
iPhone sizes (6.9" and 6.5"); these Android images are not used there.

Captions use Poppins ExtraBold (SIL Open Font License, the app's own font).

## Feature graphic (Google Play, 1024×500)

`docs/store/feature_graphic_tr.png` and `docs/store/feature_graphic_en.png`: the Memo
mascot, "Memoko" and the tagline "Eşini bul. Arkadaşlarını yen." / "Find the pair. Beat
your friends."

## Category and rating

- App Store: Games > Puzzle, secondary Card; age rating 9+
- Google Play: Game > Puzzle; target audience 13+ (see `docs/ANDROID_RELEASE.md`)
