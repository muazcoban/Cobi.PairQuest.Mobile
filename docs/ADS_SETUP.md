# Reklam ve "Reklamları kaldır" kurulumu

Kod `feat/ads` dalında hazır ve Google'ın test reklamlarıyla çalışıyor. Gerçek gelir için
aşağıdaki konsol adımları gerekiyor. Bu adımlar hesap ve ödeme bilgisi istediği için senin işin.
Gerçek kimlikleri bana verirsen koda ben işlerim; bu kimlikler gizli değil.

## Uygulamada ne var

| Format | Nerede | Kural |
|---|---|---|
| Ödüllü video | Galibiyet penceresi: "Reklam izle: 2× altın" | Yalnız oyuncu seçerse oynar |
| Ödüllü video | Zamanlı modda süre bitince: "Reklam izle: +30 sn" | Oyun başına bir kez; kayıp, oyuncu vazgeçince yazılır |
| Ödüllü video | Günlük ödül: "Reklam izle: 2× altın" | Ödülün altın kısmı ikiye katlanır |
| Ödüllü video | İpucu bitince güçlendirici çubuğunda ▶ rozetli ipucu | İpucunun oyun başına 2 kullanım sınırı geçerli; reklam süresince oyun ve sayaç duraklar |
| Geçiş reklamı | Sonuç penceresinden sonraki geçişte | İlk 3 oyunda ve ilk 2 günde yok; iki reklam arası en az 3 dakika; yalnız önceden yüklenmişse |
| Banner, açılış reklamı | Yok | |
| Çok oyunculu maç | Yok | |

**Çocuk güvenli ayarlar (her istekte):**
- `ageRestrictedTreatment: child`: Kişiselleştirilmiş reklam, remarketing ve üçüncü taraf reklam sunucuları kapalı. Reklam kimliği (AAID, IDFA) gönderilmiyor.
- `maxAdContentRating: G`: Yalnız tüm yaşlara uygun reklam geliyor.
- UMP onay aracında `tagForUnderAgeOfConsent: true`: Kullanıcıya onay penceresi çıkmıyor.
- Android'de `AD_ID` izni manifestten kaldırıldı. iOS'ta ATT (izleme izni) penceresi yok.

**Ayarlar → Reklamlar** bölümünde dört satır var:
- **Reklamları kaldır:** Mağaza fiyatıyla gösterilir.
- **Satın alımları geri yükle:** Apple 3.1.1 geri yükleme mekanizması istiyor.
- **Uygunsuz reklamı bildir:** Destek adresine e-posta açar.
- **Reklam gizlilik tercihleri:** Yalnız Google bu girişi istediğinde görünür.

## 1. AdMob konsolu (admob.google.com)

1. AdMob hesabını aç, ödeme profilini doldur.
2. **Uygulamaları ekle:**
   - iOS: App Store'daki Memoko'yu seç.
   - Android: Play'de henüz yayında olmadığı için "listelenmemiş" diye ekle; yayımlanınca mağazaya bağla.
3. **Reklam birimleri:** Her platformda iki birim oluştur: `memoko_rewarded` (Ödüllü) ve `memoko_interstitial` (Geçiş).
4. **Kimlikler (bana verirsen ben yaparım):**
   - Uygulama kimlikleri (`ca-app-pub-…~…`) `android/app/src/main/AndroidManifest.xml` ve `ios/Runner/Info.plist` dosyalarına girer; bugün ikisinde de Google'ın test kimliği var.
   - Birim kimlikleri (`ca-app-pub-…/…`) `lib/core/constants/ad_config.dart` dosyasına girer.
   - Debug derlemesi her zaman test birimlerini kullanır. Geliştirirken gerçek reklama dokunmak AdMob politikasına aykırı.
5. **Blocking controls → Ad content rating:**
   - Uygulama düzeyinde "Match account-level setting" seçeneğini kapat, G seç.
   - Koddaki G zaten bu ayarı ezer; konsoldaki ayar yedek.
6. **Blocking controls → Sensitive categories:** Gambling & Betting ve Alcohol varsayılan olarak engelli. Şunları da engelle:
   - Dating
   - Social Casino Games
   - Get rich quick
   - Reference to sex
   - Sexual and reproductive health
   - Birth control
   - Cosmetic procedures & body modification
   - Weight loss
   - Drugs & supplements
   - Politics
   - Religion
   - Sensationalism

   Google sınıflandırmayı otomatik yaptığı için engel garanti değil. Uygunsuz reklam bildirimi gelirse reklamveren **Ad review center** üzerinden engellenir.
7. **Privacy & messaging:**
   - Bir GDPR (Avrupa) mesajı oluştur ve yayımla.
   - Uygulama her kullanıcıyı onay yaşının altında etiketlediği için mesaj kimseye gösterilmez.
   - Google'ın tarif ettiği kurulum bu.
8. **app-ads.txt:**
   - Mağaza kaydındaki geliştirici web sitesinin kök dizininde bir `app-ads.txt` dosyası olmalı. Dosyanın içeriğini AdMob verir.
   - Bugün bir web sitesi yok. En kolay yol, `muazcoban.github.io` adlı bir GitHub Pages deposu açıp dosyayı köke koymak ve bu adresi iki mağazaya geliştirici sitesi olarak yazmak.

## 2. App Store Connect

1. **Agreements, Tax, and Banking:** Paid Apps Agreement'ı imzala; banka ve vergi bilgilerini gir. Bunlar olmadan uygulama içi satın alma çalışmaz.
2. **In-App Purchases:**
   - Tür Non-Consumable, Product ID `remove_ads`. Bu ID'yi değiştirme; kodda aynı ID var.
   - Türkçe ve İngilizce ad ile açıklamayı gir, fiyat seviyesini seç.
   - İnceleme için Ayarlar ekranının bir görüntüsünü ekle.
3. Satın almayı ilk reklamlı sürümle birlikte incelemeye gönder.
4. **App Privacy:** Google'ın listesine göre şunları ekle:
   - Device ID
   - Advertising Data
   - Coarse Location
   - Product Interaction
   - Crash Data
   - Performance Data

   Amaç olarak Third-Party Advertising ve Analytics seç. Kaynak: developers.google.com/admob/ios/privacy/data-disclosure.
   - "Used to track you" için resmî bir cevap yok. Reklam kimliği gönderilmediği ve ATT sorulmadığı için önerim "No"; bu bir hukuki yorum.
5. **Yaş derecelendirme anketi:** Reklam sorusunu "Yes" yap. 9+ derecesi değişmemeli.

## 3. Google Play Console

1. **Monetize → Products → One-time products:**
   - Product ID `remove_ads`, fiyat ve Türkçe ile İngilizce açıklama gir.
   - Bunun için Play'de bir ödeme profili gerekiyor.
2. **App content → Ads:** "Yes, my app contains ads".
3. **App content → Advertising ID:** "No"; izin manifestten kaldırıldı.
4. **Data safety:** AdMob için "collected and shared" olarak şunları işaretle:
   - Approximate location
   - App interactions
   - Diagnostics
   - Device or other IDs

   Amaç Advertising or marketing ve Analytics.
5. **Target audience:** 13+.
   - **Risk:** Play, mağaza sayfası çocuklara hitap ediyor derse 13+ beyanını reddedebilir; örnek olarak çizgi film karakter ve maskot sayılıyor. İnceleme en fazla 7 gün sürebilir.
   - **Reddederse iki yol var:** İşaretlenen öğeleri değiştirmek ya da kitleye 13 yaş altını eklemek.
   - İkinci yol Families politikasını devreye sokar. Reklam tarafı buna hazır (çocuk muamelesi, G derecesi, reklam kimliği yok). Online giriş ve arkadaş özellikleri ise ayrıca değerlendirilmeli.

## 4. Test etme

- **Test reklamları:**
  - Debug ve şimdiki release derlemesi "Test Ad" etiketli reklam gösterir.
  - Test birimleri ara sıra "No fill" döner. Düğme bu durumda bir kez daha dener, olmazsa "Şu an reklam yok" yazar.
- **Satın alma:**
  - iOS'ta Sandbox hesabıyla ya da Xcode StoreKit yapılandırmasıyla denenir.
  - Android'de ürün Play Console'da tanımlanınca kapalı test kanalından denenir.
  - O zamana kadar Ayarlar'da "Mağaza şu an kullanılamıyor" görünür.
- **Geçiş reklamı:** Kural sınıfı birim testli (`test/unit/interstitial_policy_test.dart`). Cihazda görmek için 3 oyun ve 2 gün beklemek gerekir.

## Bilinen sınırlar

- Satın alma makbuzu sunucuda doğrulanmıyor; satın alma cihazda saklanıyor. Tek seferlik, düşük fiyatlı bir ürün için sunucu maliyeti buna değmez.
- KVKK'nın reklam için açık rıza isteyip istemediğini önceki araştırma netleştiremedi. Reklam kimliği hiç kullanılmadığı için risk düşük, ama bir hukukçuya sorulmalı.
