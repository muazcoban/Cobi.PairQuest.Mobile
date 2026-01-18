# PairQuest - Geliştirme Yol Haritası (Roadmap)

## Faz Yapısı Özeti

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PairQuest Development Roadmap                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  FAZ 1: Temel Oyun        ──▶  FAZ 2: Oyun Modları    ──▶  FAZ 3: İçerik   │
│  (Foundation)                   (Game Modes)               (Content)        │
│  ════════════                   ══════════════              ═════════       │
│  • Proje yapısı                 • Zamanlı mod               • Temalar       │
│  • Kart mekaniği                • Seviye sistemi            • Ses/Müzik     │
│  • Temel UI                     • Temel puanlama            • Animasyonlar  │
│  • Tek tema                     • Yerel kayıt               • Power-ups     │
│                                                                              │
│       │                              │                           │          │
│       ▼                              ▼                           ▼          │
│                                                                              │
│  FAZ 4: Gamification      ──▶  FAZ 5: Online           ──▶  FAZ 6: Polish  │
│  (Engagement)                   (Multiplayer)               (Release)       │
│  ═══════════════                ══════════════              ═══════════     │
│  • Başarılar                    • Firebase Auth             • Performans    │
│  • Günlük görevler              • Online Leaderboard        • Erişilebilirlik│
│  • Yerel leaderboard            • Çoklu oyuncu              • i18n          │
│  • İstatistikler                • Profil sistemi            • Store yayını  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Bağımlılık Matrisi

| Özellik | Bağımlı Olduğu |
|---------|----------------|
| Zamanlı Mod | Temel oyun mekaniği |
| Seviye Sistemi | Temel oyun mekaniği |
| Puanlama | Temel oyun mekaniği |
| Başarılar | Puanlama + İstatistik takibi |
| Yerel Leaderboard | Puanlama + Yerel kayıt |
| Online Leaderboard | Yerel Leaderboard + Firebase |
| Günlük Görevler | Başarı sistemi altyapısı |
| Power-ups | Oyun mekaniği + UI altyapısı |
| Çoklu Oyuncu | Online altyapı + Oyun mekaniği |
| Profil Sistemi | Firebase Auth |

---

## FAZ 1: Temel Oyun (Foundation)
**Öncelik: KRİTİK** | **Tahmini Süre: 2-3 hafta**

> Bu faz olmadan hiçbir şey çalışmaz. Tüm diğer fazların temelidir.

### 1.1 Proje Altyapısı
- [ ] Flutter proje oluşturma
- [ ] Klasör yapısı (Clean Architecture)
- [ ] Temel paketlerin eklenmesi
  - `flutter_riverpod`
  - `go_router`
  - `hive_flutter`
  - `freezed`
- [ ] Tema ve renk sistemi
- [ ] Temel widget'lar (Button, Card container, vb.)

### 1.2 Veri Modelleri
- [ ] `CardModel` - Kart veri yapısı
- [ ] `GameModel` - Oyun durumu
- [ ] `GridSize` - Izgara boyutları
- [ ] Enum'lar (CardState, GameState)

### 1.3 Oyun Mekaniği (Core)
- [ ] Kart karıştırma algoritması (Fisher-Yates)
- [ ] Kart seçme mantığı
- [ ] Eşleşme kontrolü
- [ ] Oyun durumu yönetimi (başla/bitir/reset)
- [ ] Temel state management (GameProvider)

### 1.4 Temel UI
- [ ] Ana menü ekranı (basit)
- [ ] Oyun ekranı layout
- [ ] Kart widget'ı (ön/arka yüz)
- [ ] Kart grid'i (responsive)
- [ ] Oyun sonu ekranı (basit)

### 1.5 Kart Görselleri
- [ ] 1 tema hazırlama (Hayvanlar - 16 görsel)
- [ ] Kart arka yüzü tasarımı
- [ ] Placeholder görseller

### 1.6 Temel Animasyonlar
- [ ] Kart çevirme animasyonu
- [ ] Eşleşme gösterimi (basit)

### Faz 1 Çıktısı (Deliverable)
✅ Tek bir ızgara boyutunda (4x4) oynanabilir temel oyun

---

## FAZ 2: Oyun Modları ve Seviye Sistemi
**Öncelik: YÜKSEK** | **Tahmini Süre: 2-3 hafta**

> Oyuna derinlik katan temel özellikler. Kullanıcı deneyimini zenginleştirir.

### Bağımlılık: Faz 1 tamamlanmalı

### 2.1 Seviye Sistemi
- [ ] Seviye konfigürasyonu (10 level)
  ```
  Level 1: 2x2 (Tutorial)
  Level 2: 2x3
  Level 3: 2x4
  Level 4: 3x4
  Level 5: 4x4
  Level 6: 4x5
  Level 7: 5x6
  Level 8: 6x6
  Level 9: 6x7
  Level 10: 8x8
  ```
- [ ] Seviye seçim ekranı
- [ ] Seviye ilerleme takibi
- [ ] Seviye kilitleme/açma mantığı
- [ ] Yıldız sistemi (1-3 yıldız)

### 2.2 Klasik Mod (Geliştirme)
- [ ] Hamle sayacı
- [ ] Hamle bazlı değerlendirme
- [ ] En iyi hamle kaydı

### 2.3 Zamanlı Mod
- [ ] Timer widget'ı
- [ ] Seviyeye göre süre limitleri
- [ ] Süre dolduğunda oyun sonu
- [ ] Kalan süre gösterimi
- [ ] Süre uyarısı (son 10 saniye)

### 2.4 Puanlama Sistemi
- [ ] Temel puan hesaplama (+100 eşleşme)
- [ ] Combo sistemi (+50 ardışık)
- [ ] Hata penaltısı (-10)
- [ ] Zorluk çarpanı
- [ ] Zaman bonusu (zamanlı mod)
- [ ] Puan animasyonu (popup)

### 2.5 Yerel Veri Kaydetme
- [ ] Hive veritabanı kurulumu
- [ ] Oyuncu ilerlemesi kaydetme
- [ ] Seviye skorları kaydetme
- [ ] Ayarlar kaydetme

### 2.6 UI Geliştirmeleri
- [ ] Skor gösterimi (GameHeader)
- [ ] Combo göstergesi
- [ ] Pause menüsü
- [ ] Oyun sonu detaylı ekran (yıldızlar, skor breakdown)

### Faz 2 Çıktısı (Deliverable)
✅ 10 seviyeli, zamanlı/klasik modlu, puan sistemli oyun
✅ İlerleme kaydedilen tam fonksiyonel single-player deneyim

---

## FAZ 3: İçerik ve Zenginleştirme
**Öncelik: ORTA-YÜKSEK** | **Tahmini Süre: 2-3 hafta**

> Görsel ve işitsel deneyimi zenginleştirir. Kullanıcı bağlılığını artırır.

### Bağımlılık: Faz 2 tamamlanmalı

### 3.1 Tema Sistemi
- [ ] Tema veri yapısı
- [ ] Tema seçim ekranı
- [ ] 5 temel tema hazırlama:
  - 🐾 Hayvanlar (mevcut)
  - 🍎 Meyveler
  - 🚗 Araçlar
  - 🌍 Bayraklar
  - 🌟 Emoji
- [ ] Her tema için 32 görsel (8x8 için yeterli)
- [ ] Tema kilitleme/açma sistemi

### 3.2 Ses Sistemi
- [ ] AudioService oluşturma
- [ ] Ses efektleri entegrasyonu:
  - Kart çevirme
  - Eşleşme
  - Hata
  - Combo
  - Seviye tamamlama
- [ ] Arka plan müziği
- [ ] Ses ayarları (açma/kapama, ses seviyesi)

### 3.3 Gelişmiş Animasyonlar
- [ ] Eşleşme animasyonu (parıldama)
- [ ] Hata animasyonu (sallanma)
- [ ] Combo animasyonu
- [ ] Seviye tamamlama animasyonu (confetti)
- [ ] UI geçiş animasyonları

### 3.4 Power-up Sistemi (Temel)
- [ ] Power-up veri yapısı
- [ ] Power-up UI (bar)
- [ ] 3 temel power-up:
  - 👁️ Göz At (tüm kartları 2sn göster)
  - 💡 İpucu (bir eşleşmeyi göster)
  - ⏱️ Zaman Ekle (+30sn)
- [ ] Power-up kullanım mantığı
- [ ] Power-up envanter yönetimi

### 3.5 Görsel İyileştirmeler
- [ ] Kart arka yüzü alternatifleri
- [ ] Arka plan tasarımları
- [ ] Dark/Light mod
- [ ] UI polish (gölgeler, gradientlar)

### Faz 3 Çıktısı (Deliverable)
✅ 5 temalı, sesli, animasyonlu, power-up'lı zengin oyun deneyimi

---

## FAZ 4: Gamification
**Öncelik: ORTA** | **Tahmini Süre: 2-3 hafta**

> Oyuncuyu geri getiren engagement özellikleri.

### Bağımlılık: Faz 2 (Puanlama) + Faz 3 (Tema sistemi)

### 4.1 İstatistik Takibi
- [ ] PlayerStats modeli
- [ ] İstatistik kaydetme:
  - Toplam oyun
  - Toplam eşleşme
  - En iyi combo
  - Oynama süresi
  - Seviye başarıları
- [ ] İstatistik ekranı

### 4.2 Başarı Sistemi (Achievements)
- [ ] Achievement modeli
- [ ] Başarı tanımları (15-20 başarı)
- [ ] Başarı kontrol servisi
- [ ] Başarı açılma bildirimi (popup)
- [ ] Başarılar ekranı
- [ ] Başarı ödülleri (tema açma, power-up)

**Temel Başarılar:**
| Başarı | Koşul |
|--------|-------|
| İlk Adım | 1 oyun tamamla |
| Isınma | 10 oyun tamamla |
| Hafıza Ustası | 100 oyun tamamla |
| Mükemmeliyetçi | İlk mükemmel oyun |
| Combo Başlangıcı | 3 combo |
| Combo Kralı | 10 combo |
| Hız Şeytanı | 4x4'ü 30sn'de bitir |
| Tema Kaşifi | 3 farklı tema dene |
| Seviye Avcısı | 5 seviye tamamla |
| Şampiyon | Tüm seviyeleri tamamla |

### 4.3 Günlük Görevler
- [ ] DailyQuest modeli
- [ ] Günlük görev havuzu (10+ görev)
- [ ] Günlük 3 görev seçimi (rastgele)
- [ ] Görev ilerleme takibi
- [ ] Görev tamamlama ödülleri
- [ ] Günlük sıfırlama mantığı
- [ ] Günlük görevler UI

**Örnek Görevler:**
- "3 oyun tamamla"
- "5 combo yap"
- "1000 puan kazan"
- "Zamanlı modda 1 oyun bitir"
- "Mükemmel oyun yap"

### 4.4 Yerel Liderlik Tablosu
- [ ] LeaderboardEntry modeli
- [ ] Skorları sıralama ve kaydetme
- [ ] Liderlik tablosu ekranı
- [ ] Filtreleme (tüm zamanlar, haftalık, günlük)
- [ ] Seviye bazlı liderlik

### 4.5 Günlük Giriş Ödülleri
- [ ] Giriş streak takibi
- [ ] 7 günlük ödül döngüsü
- [ ] Ödül popup'ı
- [ ] Kaçırılan gün = streak sıfırlanması

### Faz 4 Çıktısı (Deliverable)
✅ Başarı sistemli, günlük görevli, leaderboard'lu engaging oyun

---

## FAZ 5: Online Özellikler
**Öncelik: DÜŞÜK-ORTA** | **Tahmini Süre: 3-4 hafta**

> Sosyal ve rekabetçi özellikler. Daha geniş kitle için.

### Bağımlılık: Faz 4 (Leaderboard yapısı) tamamlanmalı

### 5.1 Firebase Kurulumu
- [ ] Firebase projesi oluşturma
- [ ] Flutter Firebase entegrasyonu
- [ ] Firestore kuralları
- [ ] Firebase Auth kurulumu

### 5.2 Kimlik Doğrulama
- [ ] Anonim giriş (misafir modu)
- [ ] Google Sign-In
- [ ] Apple Sign-In (iOS)
- [ ] Hesap oluşturma/giriş UI
- [ ] Oturum yönetimi

### 5.3 Profil Sistemi
- [ ] Kullanıcı profili modeli
- [ ] Kullanıcı adı seçimi
- [ ] Avatar seçimi
- [ ] Profil düzenleme ekranı
- [ ] Profil görüntüleme

### 5.4 Online Liderlik Tablosu
- [ ] Firestore leaderboard yapısı
- [ ] Skor gönderme
- [ ] Global sıralama çekme
- [ ] Oyuncunun kendi sırasını gösterme
- [ ] Ülke bazlı filtreleme

### 5.5 Yerel Çoklu Oyuncu
- [ ] Multiplayer game state
- [ ] Oyuncu sırası yönetimi (2-4 oyuncu)
- [ ] Her oyuncunun puanı
- [ ] Kazanan belirleme
- [ ] Çoklu oyuncu UI

### 5.6 Veri Senkronizasyonu
- [ ] Yerel -> Cloud sync
- [ ] Çakışma çözümü
- [ ] Offline mod desteği

### Faz 5 Çıktısı (Deliverable)
✅ Online leaderboard, profil sistemi ve yerel multiplayer

---

## FAZ 6: Polish ve Yayın
**Öncelik: KRİTİK (Yayın için)** | **Tahmini Süre: 2-3 hafta**

> Uygulamayı store'a hazır hale getirir.

### Bağımlılık: Faz 1-4 minimum tamamlanmalı (Faz 5 opsiyonel)

### 6.1 Performans Optimizasyonu
- [ ] Widget rebuild optimizasyonu
- [ ] Görsel önbellekleme
- [ ] Lazy loading
- [ ] Memory profiling
- [ ] 60 FPS hedefi doğrulama

### 6.2 Erişilebilirlik
- [ ] Semantics widget'ları
- [ ] Ekran okuyucu desteği
- [ ] Yeterli kontrast oranları
- [ ] Büyük dokunma hedefleri
- [ ] Renk körü modu (opsiyonel)

### 6.3 Çoklu Dil Desteği (i18n)
- [ ] Lokalizasyon altyapısı
- [ ] Türkçe (varsayılan)
- [ ] İngilizce
- [ ] String externalization

### 6.4 Test
- [ ] Unit testler (servisler)
- [ ] Widget testler (UI)
- [ ] Integration testler (akışlar)
- [ ] Manuel QA

### 6.5 Store Hazırlığı
- [ ] App icon tasarımı
- [ ] Splash screen
- [ ] Store görselleri (screenshots)
- [ ] Store açıklaması
- [ ] Privacy policy
- [ ] App Store / Play Store hesapları

### 6.6 Yayın
- [ ] Android release build
- [ ] iOS release build
- [ ] Play Store yayını
- [ ] App Store yayını
- [ ] Web build (opsiyonel)

### Faz 6 Çıktısı (Deliverable)
✅ Store'da yayınlanmış, optimize edilmiş uygulama

---

## Gelecek Fazlar (Post-Launch)

### FAZ 7: Gelişmiş Multiplayer (Opsiyonel)
- Online 1v1 düello
- Gerçek zamanlı eşleşme
- ELO sistemi
- Turnuvalar

### FAZ 8: Monetizasyon (Opsiyonel)
- Reklam entegrasyonu
- Premium üyelik
- In-app purchases

### FAZ 9: Hikaye Modu (Opsiyonel)
- Bölümler ve chapter'lar
- Özel kartlar
- Boss seviyeleri
- Hikaye anlatımı

---

## Özet Tablo

| Faz | İçerik | Öncelik | Bağımlılık |
|-----|--------|---------|------------|
| **1** | Temel Oyun | KRİTİK | - |
| **2** | Modlar & Seviyeler | YÜKSEK | Faz 1 |
| **3** | İçerik & Ses | ORTA-YÜKSEK | Faz 2 |
| **4** | Gamification | ORTA | Faz 2, 3 |
| **5** | Online | DÜŞÜK-ORTA | Faz 4 |
| **6** | Polish & Yayın | KRİTİK | Faz 1-4 |

---

## Minimum Viable Product (MVP) Kapsamı

**Yayınlanabilir minimum ürün için gerekli fazlar:**

✅ Faz 1 (Temel Oyun) - **Zorunlu**
✅ Faz 2 (Modlar & Seviyeler) - **Zorunlu**
✅ Faz 3 (İçerik) - **Kısmen** (en az 3 tema, temel sesler)
✅ Faz 6 (Polish) - **Zorunlu** (store yayını için)

**MVP'de olmayabilir:**
- Faz 4 (Gamification) - İlk sürümde basitleştirilebilir
- Faz 5 (Online) - Post-launch eklenebilir

---

*Doküman Versiyonu: 1.0*
*Son Güncelleme: 18 Ocak 2026*
