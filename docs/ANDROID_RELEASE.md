# Android yayın rehberi (Google Play)

Bu belge, uygulamayı Google Play'e ilk kez yüklemek için gereken adımları sırayla verir.
Koddaki hazırlık `chore/android-release` dalında; buradaki adımlar konsolda ve senin
bilgisayarında yapılır.

## Mevcut yapılandırma

| Ayar | Değer | Not |
|---|---|---|
| Paket adı (`applicationId`) | `com.cobistudio.pairquest` | Firebase Android uygulaması bu adla kayıtlı. Play'e ilk yüklemeden sonra değiştirilemez. iOS paket adından (`com.cobi.pairQuest`) farklı olması sorun değil. |
| `targetSdk` / `compileSdk` | 36 | Play, 31 Ağustos 2026'dan beri yeni uygulamalarda API 36 istiyor. |
| `minSdk` | 24 | Android 7.0 ve üstü. |
| NDK | 28.2 | 16 KB bellek sayfası şartını karşılar. |
| Sürüm | `pubspec.yaml` içindeki `version` | `2.3.0+7` → versionName 2.3.0, versionCode 7. Her yüklemede `+` sonrasındaki sayı artmalı. |
| Giriş yöntemleri | Google ve misafir | Sign in with Apple Android'de gizli (`AppleSignInButton.isAvailable`). |

## Doğrulananlar (14 Kasım 2026)

- `flutter build appbundle --release` başarılı. AAB 51,9 MB; bunun büyük kısmı Play'e giden
  sembol ve R8 eşleme dosyası, cihaza inen boyut daha küçük. arm64 release APK 25,3 MB.
- Bütün `.so` dosyalarının LOAD hizası en az 16 KB.
- Birleşik release manifestinde `SCHEDULE_EXACT_ALARM` yok. İzinler: INTERNET,
  ACCESS_NETWORK_STATE, POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED, VIBRATE, WAKE_LOCK ve
  Firebase Cloud Messaging izinleri.
- Release APK Android 14 emülatöründe açıldı: ana ekran, günlük ödül, yerel çok oyunculu
  ekranı, Klasik Mod oyun tahtası ve sistem geri tuşu çalışıyor.
- İlk denemede R8, bildirim eklentisinin kullandığı Gson sınıflarını bozuyordu ve bildirim
  iptali `TypeToken must be created with a type argument` hatası veriyordu.
  `proguard-rules.pro` içine kural ekledim; yeniden denemede hata yok ve haftalık
  hatırlatmalar zamanlandı.

Doğrulanmayanlar: Google ile giriş (SHA parmak izi kaydı bekliyor), Android 15 ve 16'da
kenardan kenara (edge-to-edge) görünüm, gerçek cihazda performans.

## 1. Yükleme anahtarını oluştur (bir kez)

Play'e yüklenen paket bu anahtarla imzalanır. Parolayı kendin belirle ve parola
yöneticine kaydet. Anahtar dosyasını repo dışında tut ve yedekle; kaybedersen Play
Console'dan anahtar sıfırlama istemen gerekir.

```bash
mkdir -p ~/keys && keytool -genkeypair -v -keystore ~/keys/pairquest-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Sonra `android/key.properties` dosyasını oluştur (git'e girmez, `.gitignore`'da):

```properties
storePassword=<parola>
keyPassword=<parola>
keyAlias=upload
storeFile=/Users/muazcobanos/keys/pairquest-upload.jks
```

`key.properties` yoksa release derlemesi debug anahtarıyla imzalanır ve Gradle uyarı
basar. Play debug imzalı paketi reddeder, yani yanlışlıkla yüklenemez.

## 2. SHA parmak izlerini Firebase'e ekle

Google ile giriş, Android'de uygulamanın imza parmak izi Firebase'de kayıtlı değilse
`ApiException: 10` hatasıyla başarısız olur. Şu an `google-services.json` içinde Android
OAuth istemcisi yok, yani Android'de Google girişi henüz çalışmaz.

Üç anahtarın SHA-1 ve SHA-256 değerleri eklenmeli:

| Anahtar | Değeri nereden alırsın |
|---|---|
| Debug | `cd android && ./gradlew signingReport` → `Variant: debug` |
| Yükleme anahtarı | `keytool -list -v -keystore ~/keys/pairquest-upload.jks -alias upload` |
| Play uygulama imzalama anahtarı | Play Console → uygulama → Test edin ve yayınlayın → Kurulum → Uygulama imzalama (ilk yüklemeden sonra görünür) |

Firebase Console → Proje ayarları → Genel → Android uygulaması `com.cobistudio.pairquest`
→ "Parmak izi ekle". Ekledikten sonra yeni `google-services.json` dosyasını indir ve
`android/app/google-services.json` dosyasının yerine koy.

## 3. Paketi derle

```bash
flutter build appbundle --release
```

Çıktı: `build/app/outputs/bundle/release/app-release.aab`

## 4. Play Console

### Hesap şartı

Kişisel geliştirici hesabı 13 Kasım 2023'ten sonra açıldıysa, her yeni uygulama üretime
çıkmadan önce kapalı testten geçmeli: en az 12 test kullanıcısı 14 gün boyunca testte
kalmalı. Kuruluş (organization) hesaplarında bu şart yok. 14 günlük süre en uzun adım
olduğu için kapalı testi isim kararı beklenmeden başlatmak mantıklı: kapalı testteki mağaza
adı üretimden önce değiştirilebilir.

### Uygulama oluşturma

- Uygulama türü: Oyun. Ücretsiz.
- Uygulama adı: "Memoko: Memory Match Game" (İngilizce), "Memoko: Hafıza Kartı Oyunu" (Türkçe). Metinler `docs/STORE_LISTING.md` içinde.
- Varsayılan dil: Türkçe ya da İngilizce; diğerini çeviri olarak ekle.

### Uygulama içeriği (App content) beyanları

| Beyan | Önerilen yanıt |
|---|---|
| Gizlilik politikası | `https://github.com/muazcoban/Cobi.PairQuest.Mobile/blob/master/docs/PRIVACY.md` |
| Uygulama erişimi | Özel erişim gerekmiyor: online özellikler herhangi bir Google hesabıyla açılıyor. |
| Reklamlar | Şimdilik "Hayır". Reklamlı sürümle birlikte "Evet" yapılmalı. |
| İçerik derecelendirmesi (IARC) | Oyun. Kullanıcılar etkileşimde bulunuyor: online oyun, görünen adlar, arkadaşlık istekleri. Konum paylaşımı yok. Dijital satın alma yok (mağaza yalnız oyun içi jeton ve elmasla). |
| Hedef kitle | Karar bekliyor: 13 yaş altını seçmek Aileler politikasını devreye sokar ve reklam SDK'sı seçimini kısıtlar. Reklam araştırmasıyla birlikte karar verilecek. |
| Hesap silme | Uygulama içi silme var (Ayarlar → Hesap → Hesabı Sil). Web bağlantısı: `https://github.com/muazcoban/Cobi.PairQuest.Mobile/blob/master/docs/PRIVACY.md#deleting-your-account-and-data` |
| Veri güvenliği | Aşağıdaki taslak. |

### Veri güvenliği (Data safety) taslağı

Kaynak: `docs/PRIVACY.md` ve kullanılan SDK'lar (Firebase Authentication, Cloud Firestore,
Cloud Messaging, Google Sign-In). Firebase hizmet sağlayıcı sayıldığı için "paylaşım"
değildir. Formu doldurmadan önce gizlilik politikasıyla karşılaştır.

| Veri türü | Toplanıyor | Paylaşılıyor | İsteğe bağlı | Amaç |
|---|---|---|---|---|
| Kişisel bilgiler → Ad (görünen ad) | Evet | Hayır | Evet | Uygulama işlevi, hesap yönetimi |
| Kişisel bilgiler → E-posta adresi (Google girişi) | Evet | Hayır | Evet | Hesap yönetimi |
| Kişisel bilgiler → Kullanıcı kimlikleri (Firebase kullanıcı kimliği) | Evet | Hayır | Evet | Uygulama işlevi, hesap yönetimi |
| Kişisel bilgiler → Diğer (profil fotoğrafı bağlantısı) | Evet | Hayır | Evet | Uygulama işlevi |
| Uygulama etkinliği → Diğer işlemler (skor, online oyun kaydı, puan) | Evet | Hayır | Evet | Uygulama işlevi |
| Uygulama etkinliği → Kullanıcı tarafından oluşturulan diğer içerik (şikayet nedeni) | Evet | Hayır | Evet | Dolandırıcılık önleme, güvenlik ve uyumluluk |
| Cihaz veya diğer kimlikler (Firebase Cloud Messaging belirteci) | Evet | Hayır | Hayır | Uygulama işlevi (bildirim) |

- Veriler aktarım sırasında şifreleniyor: Evet (Firebase HTTPS kullanır).
- Kullanıcı veri silme isteyebilir: Evet.

### Mağaza girişi varlıkları

| Varlık | Ölçü |
|---|---|
| Uygulama simgesi | 512×512 PNG |
| Öne çıkan grafik | 1024×500 PNG ya da JPG |
| Telefon ekran görüntüleri | En az 2 adet, 9:16 ya da 16:9, kenar 320–3840 px |
| Kısa açıklama | En fazla 80 karakter |
| Tam açıklama | En fazla 4000 karakter |

Simgede "PairQuest" yazısı var; Memoko adıyla yayından önce yeni simge gerekiyor.
