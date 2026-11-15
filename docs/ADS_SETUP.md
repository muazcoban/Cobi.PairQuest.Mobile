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

**Durum (15 Kasım 2026):** Hesap (`pub-5547492389514605`) var, ödeme profili tamam, hesap onayı bekleniyor. Onay gelene kadar reklam istekleri "Account not approved yet" yanıtı alıyor. Memoko için yapılanlar:

| | Android | iOS |
|---|---|---|
| Uygulama kimliği | `ca-app-pub-5547492389514605~4676860498` | `ca-app-pub-5547492389514605~8616105504` |
| `memoko_rewarded` | `…/4470131881` | `…/2035365228` |
| `memoko_interstitial` | `…/9610777928` | `…/5783038542` |

- **İçerik ve kategori:** İki uygulamada da uygulama düzeyinde içerik derecesi G yapıldı ve 13 hassas kategorinin hepsi engellendi. Cobi Paint'in ayarlarına dokunulmadı.
- **Android mağaza bağlantısı:** Uygulama Play'de listelenmemiş olarak eklendi. Yayımlanınca AdMob'da "Mağaza ekle" ile bağlanacak.
- **iOS doğrulaması:** `app-ads.txt` dosyası olmadığı için iOS uygulaması doğrulanamadı. Dosyaya girecek satır şu: `google.com, pub-5547492389514605, DIRECT, f08c47fec0942fa0`
- **Kimlikler kodda:** Kimlikler `ad_config.dart`, `AndroidManifest.xml` ve `Info.plist` dosyalarına işlendi. Debug derlemesi yine test birimlerini kullanıyor.
- **Uyarı:** Release ve TestFlight derlemeleri gerçek reklam isteyecek. Kendi cihazında gerçek reklama dokunma; AdMob bunu geçersiz trafik sayar.

- **GDPR mesajı:** "Avrupa tüzükleri" mesajı iki Memoko uygulaması için yayımlandı. Dil İngilizce; "İzin vermeyin" seçeneği tüm ülkelerde açık; gizlilik politikası bağlantısı girildi. Uygulama her kullanıcıyı rıza yaşının altında etiketlediği için mesaj gösterilmiyor.

Aşağıdaki adımlar ilk kurulum içindi; yalnız `app-ads.txt` (8. madde) kaldı.


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

**Geliştirici hesabı (15 Kasım 2026):**
- **Hesap:** `cobistudio44@gmail.com` ile kişisel hesap açıldı; hesap kimliği `6559163290636255355`. Eski kapatılan hesap kayıt formunda beyan edildi.
- **Uygulama oluşturma:** Önce kimlik doğrulaması, Android cihaz doğrulaması ve telefon doğrulaması bitmeli.
- **Satıcı statüsü:** "Tacir" seçildi. Play'de herkese açık görünecekler: e-posta, ödeme profilindeki yasal ad ve adres, doğrulanan telefon numarası.
- **Kullanım şartları:** Tacir olarak her uygulama için kullanım şartları bağlantısı isteniyor: `https://github.com/muazcoban/Cobi.PairQuest.Mobile/blob/master/docs/TERMS.md`. Bu bağlantı `feat/ads` dalı `master`'a birleşince çalışır; Play'e göndermeden önce birleşmiş olmalı.


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
5. **Target audience and content:** 6–8, 9–12, 13–15, 16–17 ve 18+ yaş gruplarını seç. Bu karma kitle (mixed audience) beyanıdır ve Families politikasını devreye sokar.
   - **Neden 13+ değil:** Maskot ve çizgi film görünümü yüzünden Play 13+ beyanını "çocuklara hitap ediyor" diye reddedebilir. Oyunu çocuklar da oynadığı için doğru beyan bu.
   - **Ads adımı:** Hem "Families Self-Certified Ads SDK kullanıyorum" hem de "nötr yaş ekranı var" seçeneklerini işaretle.
     - Google AdMob (`play-services-ads`) bu listede, 19.0.0 ve sonrası için; uygulama 25.5.0 kullanıyor.
     - Kaynak: support.google.com/googleplay/android-developer/answer/12289447.
   - **Uygulamanın karşıladıkları:**
     - **Nötr yaş ekranı:** İlk açılışta doğum yılı soruluyor. Varsayılan yıl yok; hangi yaşın neyi açtığı söylenmiyor; cevap değiştirilemiyor. Cihazda yalnız "13 altı / 13 ve üstü" sonucu tutuluyor.
     - **13 altında kapalı olanlar:** giriş, online oyun, arkadaşlar, global skor tablosu ve push token. Cuma hatırlatması da girişe çağırmıyor. Daha önce giriş yapılmış cihazda hesaptan çıkılıyor.
     - **Yaş ekranından önce ağa çıkan bir şey yok:** AdMob ve push yaş ekranından sonra başlıyor.
     - **Reklamlar:** Her oyuncuda çocuk muamelesi ve G derecesi var. Uygulama açılışında geçiş reklamı yok, sayfa başına tek reklam var, reklam kimliği gönderilmiyor.
     - **Google hesabı zorunlu değil:** Online oyun misafir hesabıyla da oynanıyor. Google'ın kullanıcı verisi politikası karma kitlede hiçbir özelliğin Google girişine bağlanmamasını istiyor.
   - **Content rating anketi:** Kullanıcılar etkileşime giriyor (online maç, arkadaşlık, görünen adlar) sorusuna "Yes" de. Raporlama ve engelleme var.
   - **Doğrulayamadığım:** Families politikası, oyunu kesen reklamların ödüllü olanlar dahil 5 saniye sonra kapatılabilmesini istiyor. Uygulama bu süreyi ayarlayamıyor. Sertifikalı SDK'nın çocuk isteklerinde bunu kendisinin sağladığını varsayıyorum, ama resmî bir cümle bulamadım.

## 4. ABD eyalet yasaları (Texas SB 2420)

**Durum (Kasım 2026):**
- **Texas:** Yasa yürürlükte. Fifth Circuit ihtiyati tedbiri 4 Haziran 2026'da durdurdu, Supreme Court da 6 Temmuz 2026'da bu kararı bozmayı reddetti. Esas hakkında karar yok; dava sürüyor.
- **Utah ve Louisiana:** Geliştirici yükümlülükleri Utah'ta 6 Mayıs 2027'ye, Louisiana'da 1 Temmuz 2027'ye ertelendi. Bu bilgi hukuk firması kaynaklarından; resmî meclis siteleri açılmadı.
- **Kaynaklar:** capitol.texas.gov/tlodocs/89R/billtext/html/SB02420F.htm, ca5.uscourts.gov (26-50001), developer.apple.com/support/age-assurance, support.google.com/googleplay/android-developer/answer/16569691.

**Yasanın geliştiriciden istedikleri:**
- **§121.052:** Uygulamaya ve her uygulama içi satın almaya yaş derecesi vermek.
- **§121.053:** "Önemli değişikliği" önceden mağazaya bildirmek. Yeni reklam ya da satın alma eklemek önemli değişiklik sayılıyor.
- **§121.054:** Kullanıcının yaş kategorisini ve reşit olmayanlarda ebeveyn onayını mağaza verisiyle doğrulamak.
- **§121.055:** Bu veriyi yalnız yaş kısıtlaması için kullanmak ve doğrulamadan sonra silmek.

**Android'de yapılanlar (Google Play Age Signals, `age-signals` 0.0.4):**
1. **Okuma:** Açılışta önce erişim isteniyor, sonra yaş aralığı okunuyor. Yasa olan eyaletlerde Play bunu ekran göstermeden yapıyor. Başka yerlerde Play kullanıcıya yaşını paylaşmak isteyip istemediğini sorabilir.
2. **Birleştirme:** Mağaza aralığı yaş ekranı cevabıyla birleşiyor ve daha sıkı olan kazanıyor.
   - 13 altı aralık çocuk modunu açıyor.
   - Cevap yoksa mağaza aralığı yaş ekranının yerini alıyor.
   - Mağaza 18+ dese bile çocuğun kendi cevabı ("13 altı") korunuyor, çünkü telefon ebeveynin olabilir.
3. **Doğrulanmamış kullanıcı:** Play "doğrulama gerekli" derse, yani Texas'ta yaşını doğrulamamış bir kullanıcıysa, o oturumda çocuk modu uygulanıyor.
4. **Ebeveyn onayı:** Onay beklemedeyse ya da reddedildiyse reklam teklifleri, reklamlar ve "Reklamları kaldır" o kullanıcıda gizleniyor.
5. **Veri:** Mağaza verisi diske yazılmıyor, hiçbir yere gönderilmiyor; yalnız oturum boyunca bellekte duruyor. Install ID Kotlin tarafında kalıyor.
6. **Sinyal olmayınca:** Mağaza sinyal vermezse (ABD dışı, paylaşmayan kullanıcı, mağaza dışı kurulum) yaş ekranı çalışıyor.

**Play Console'da senin yapacakların:**
- **Zorunlu (§121.052):** Monetize → Products → `remove_ads` → ABD yaş derecesi: EVERYONE.
- **İlk sürümde önemli değişiklik bildirimi gerekmiyor:** Reklam ve satın alma ilk Android sürümünden beri uygulamanın parçası. Sonradan yeni bir para kazanma özelliği eklenirse önce şu adım gerekiyor:
  - App content → Age signals sayfasına ileri bir yürürlük tarihi ve ebeveyne gösterilecek İngilizce açıklama gir.
  - En fazla 90 gün önceden girilebiliyor. Uygulama onay durumunu kendisi okuyup özelliği kapatıyor.
- **Ara sıra bakılacak yer:** Age signals sayfasındaki "Revoked app approvals" sekmesi. Uygulama install ID saklamadığı için bu listeyi kendisi okumuyor. Onayı geri çekilen kullanıcı bir sonraki açılışta "reddedildi" durumunu görüyor ve reklamlar kapanıyor.
- **Test:** API, Play'den kurulmamış uygulamada `APP_NOT_OWNED` döndürüyor. Gerçek davranış ancak kapalı test kanalından kurulumla görülür. Emülatörde sideload edilen paket hata vermeden yaş ekranına düşüyor.

**iOS'ta yapılanlar (Apple Declared Age Range, `AppDelegate.swift`):**
1. **Zorunluluk kontrolü:** Uygulama önce iOS'a, ekran göstermeden, kullanıcının eyaletinde yaş aralığının zorunlu olup olmadığını soruyor. iOS 26.4'te `requiredRegulatoryFeatures`, 26.2'de uygunluk kontrolü kullanılıyor.
2. **Paylaşım istemi:** Yalnız zorunluysa Apple'ın "yaşını paylaş" istemi çıkıyor. Yaş sınırları 13, 16 ve 18; bunlar Texas'ın yaş kategorileri.
3. **Ebeveyn onayı:** Ebeveyn denetimi önemli değişikliklerde onay istiyorsa ya da yasa reşit olmayanlar için ebeveyn onayı istiyorsa, o kullanıcıda reklam ve "Reklamları kaldır" kapalı kalıyor. Uygulama PermissionKit ile onay istemiyor; değişiklik o çocuğa hiç uygulanmıyor.
4. **Yetişkin bildirimi:** Yasanın istediği yerde Apple'ın "bu güncelleme reklam ve satın alma ekliyor" penceresi yetişkinlere bir kez gösteriliyor (iOS 26.4+).
5. **Derleme koşulu:** Kod koşullu derlemeyle yazıldı. Xcode 26.2'den eski bir sürümle derlenirse yaş sinyali vermiyor ve yaş ekranı çalışıyor. Xcode Cloud workflow'u Xcode 26.6 kullanıyor.

**Yapılan konsol ayarları (15 Kasım 2026):**
- **App ID:** `com.cobi.pairQuest` App ID'sinde Declared Age Range yetkisi açıldı. Otomatik imzalama profilleri kendisi yeniliyor.
- **Xcode Cloud:** "Default" workflow'una "Manual Start - Any Branches" koşulu eklendi. Elle başlatılan derlemede her dal seçilebiliyor; otomatik derleme yine yalnız `master` için tetikleniyor.

**Kalan:**
- **`RESCIND_CONSENT` bildirimi:** Ebeveyn izni geri çektiğinde Apple, App Store Server Notifications v2 ile bunu bildiriyor. Bunu karşılayacak bir sunucu uç noktası yok; Firebase Cloud Functions olabilir. Apple izni geri çekilen çocukta uygulamanın açılmasını kendisi engelliyor. Uç nokta, sunucudaki hesap verisini temizlemek için gerekli.
- **Gerçek cihaz testi:** Apple'ın test aracı yok. Davranış ancak iOS 26.2+ cihazda, Texas'ta açılmış bir sandbox hesapla görülebilir.

## 5. Test etme

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
