# PairQuest - Power-up & Profil Güçlendirme Sistemi Roadmap

## Genel Vizyon

Oyuncu sadakati oluşturan, profili güçlendiren ve gelecekte online multiplayer'da kullanılabilecek kapsamlı bir ekonomi sistemi.

---

## FAZ 1: Temel Altyapı (Ekonomi Sistemi)

### 1.1 Coin/Gem Sistemi
**Amaç:** Oyun içi para birimi oluştur

**Yeni Entity:** `lib/domain/entities/currency.dart`
```dart
enum CurrencyType { coins, gems }

class PlayerWallet {
  final int coins;      // Oyunarak kazanılır
  final int gems;       // Premium, nadir
}
```

**İş Parçacıkları:**
- [ ] 1.1.1 `currency.dart` entity oluştur
- [ ] 1.1.2 `wallet_provider.dart` state yönetimi
- [ ] 1.1.3 SharedPreferences ile kayıt
- [ ] 1.1.4 Mevcut puan sistemini coin'e dönüştür (1 puan = 1 coin)

**Coin Kazanım Kaynakları:**
| Kaynak | Miktar |
|--------|--------|
| Oyun kazanma | 10-50 coin (seviyeye göre) |
| 3 yıldız | +20 bonus coin |
| Daily reward | Mevcut puanlar coin olarak |
| Quest tamamlama | 20-100 coin |
| Achievement | 50-500 coin (rarity'e göre) |

---

### 1.2 Power-up Entity & Envanter

**Yeni Entity:** `lib/domain/entities/power_up.dart`
```dart
enum PowerUpType { peek, freeze, hint, shuffle, timeBonus, magnet }

class PowerUp {
  final PowerUpType type;
  final String nameKey;        // Localization key
  final String descriptionKey;
  final String icon;           // Emoji veya asset
  final int cost;              // Coin maliyeti
  final int duration;          // Süre (saniye) - nullable
  final bool consumable;       // Tek kullanımlık mı
}

class PowerUpInventory {
  final Map<PowerUpType, int> quantities;  // Her power-up'tan kaç adet var
}
```

**İş Parçacıkları:**
- [ ] 1.2.1 `power_up.dart` entity oluştur
- [ ] 1.2.2 6 power-up tanımla (statik liste)
- [ ] 1.2.3 `power_up_provider.dart` envanter yönetimi
- [ ] 1.2.4 SharedPreferences ile envanter kayıt
- [ ] 1.2.5 Localization key'leri ekle (EN/TR)

---

## FAZ 2: Power-up Mekanikleri

### 2.1 Peek (Göz) - Kartları Göster
**Etki:** Tüm kartları 2-3 saniye göster
**Kısıt:** Oyun başına 1 kez

**İş Parçacıkları:**
- [ ] 2.1.1 GameProvider'a `usePowerUp(PowerUpType)` metodu
- [ ] 2.1.2 Peek aktivasyonu: tüm kartları `CardState.faceUp`
- [ ] 2.1.3 Timer ile 2-3 saniye sonra gizle
- [ ] 2.1.4 Kullanım sonrası envanterden düş
- [ ] 2.1.5 Kullanım animasyonu

### 2.2 Freeze (Dondur) - Süreyi Durdur
**Etki:** Zamanlı modda 10 saniye durdur
**Kısıt:** Sadece timed mode, oyun başına 1 kez

**İş Parçacıkları:**
- [ ] 2.2.1 Timer pause mekanizması
- [ ] 2.2.2 Freeze aktifken UI göstergesi (mavi overlay)
- [ ] 2.2.3 10 saniye sonra timer devam
- [ ] 2.2.4 Classic mode'da disabled göster

### 2.3 Hint (İpucu) - Eşleşen Çifti Göster
**Etki:** Rastgele bir eşleşen çifti vurgula
**Kısıt:** Oyun başına 2 kez

**İş Parçacıkları:**
- [ ] 2.3.1 Eşleşmemiş kartlardan random çift bul
- [ ] 2.3.2 2 kartı highlight animasyonu (glow/pulse)
- [ ] 2.3.3 3 saniye sonra highlight kaldır
- [ ] 2.3.4 Hint kullanım sayacı

### 2.4 Shuffle (Karıştır) - Kartları Yeniden Dağıt
**Etki:** Eşleşmemiş kartları yeniden karıştır
**Kısıt:** Oyun başına 1 kez, matched kartlar yerinde kalır

**İş Parçacıkları:**
- [ ] 2.4.1 Sadece hidden kartları topla
- [ ] 2.4.2 Pozisyonları shuffle et
- [ ] 2.4.3 Shuffle animasyonu
- [ ] 2.4.4 Yeni pozisyonlara yerleştir

### 2.5 Time Bonus (Süre Ekle)
**Etki:** +15 saniye ekstra süre
**Kısıt:** Sadece timed mode, oyun başına 1 kez

**İş Parçacıkları:**
- [ ] 2.5.1 Timer'a +15 saniye ekle
- [ ] 2.5.2 "+15" animasyonu UI'da
- [ ] 2.5.3 Classic mode'da disabled

### 2.6 Magnet (Mıknatıs) - Otomatik Eşleşme
**Etki:** Sonraki açtığın kart otomatik eşini bulur
**Kısıt:** Oyun başına 1 kez, en güçlü power-up

**İş Parçacıkları:**
- [ ] 2.6.1 Magnet aktif flag'i
- [ ] 2.6.2 Kart seçildiğinde eşini otomatik aç
- [ ] 2.6.3 Özel eşleşme animasyonu
- [ ] 2.6.4 Flag'i sıfırla

---

## FAZ 3: Oyun İçi UI

### 3.1 Power-up Bar (Oyun Ekranı)
**Konum:** Oyun ekranının alt kısmı veya üst kısmı

**İş Parçacıkları:**
- [ ] 3.1.1 `power_up_bar.dart` widget oluştur
- [ ] 3.1.2 6 power-up butonu (ikon + miktar)
- [ ] 3.1.3 Disabled state (miktar=0 veya kullanıldı)
- [ ] 3.1.4 Cooldown/kullanıldı göstergesi
- [ ] 3.1.5 game_screen.dart'a entegre et

### 3.2 Power-up Aktivasyon UI
**İş Parçacıkları:**
- [ ] 3.2.1 Aktivasyon onay dialog (opsiyonel)
- [ ] 3.2.2 Aktivasyon animasyonu (ekran efekti)
- [ ] 3.2.3 Aktif power-up göstergesi (Freeze için timer vb.)

---

## FAZ 4: Ekonomi Entegrasyonu

### 4.1 Mağaza (Shop Screen)
**İş Parçacıkları:**
- [ ] 4.1.1 `shop_screen.dart` oluştur
- [ ] 4.1.2 Power-up satın alma listesi
- [ ] 4.1.3 Bundle paketleri (5'li, 10'lu)
- [ ] 4.1.4 Satın alma işlemi (coin düş, envanter artır)
- [ ] 4.1.5 Ana menüye shop butonu ekle
- [ ] 4.1.6 Localization

### 4.2 Coin/Gem Göstergesi
**İş Parçacıkları:**
- [ ] 4.2.1 AppBar'da coin göstergesi
- [ ] 4.2.2 Kazanım animasyonu (+coin popup)
- [ ] 4.2.3 Harcama animasyonu

### 4.3 Kazanım Entegrasyonları
**İş Parçacıkları:**
- [ ] 4.3.1 Oyun sonu: Coin kazanımı göster
- [ ] 4.3.2 Daily reward: Coin + bazen power-up
- [ ] 4.3.3 Quest reward: Coin + bazen power-up
- [ ] 4.3.4 Achievement reward: Coin + gem + power-up

---

## FAZ 5: Daily Reward Güncelleme

### 5.1 Yeni Reward Türleri
**Güncellenecek:** `daily_reward.dart`

```dart
enum RewardType {
  coins,      // Eski points → coins
  gems,       // Premium para
  powerUp,    // Tek power-up
  bundle,     // Power-up paketi
  special     // Özel gün ödülü
}

class DailyReward {
  final RewardType type;
  final int amount;           // Coin/gem miktarı
  final PowerUpType? powerUp; // Power-up türü (nullable)
  final int powerUpCount;     // Power-up adedi
}
```

**Yeni 7 Günlük Döngü:**
| Gün | Ödül |
|-----|------|
| 1 | 50 coin |
| 2 | 75 coin + 1 Hint |
| 3 | 100 coin |
| 4 | 150 coin + 1 Peek |
| 5 | 125 coin + 1 Freeze |
| 6 | 200 coin |
| 7 | 300 coin + 5 gem + 1 Magnet |

**İş Parçacıkları:**
- [ ] 5.1.1 RewardType enum güncelle
- [ ] 5.1.2 DailyReward model güncelle
- [ ] 5.1.3 7 günlük rewards listesi güncelle
- [ ] 5.1.4 claimReward() power-up envanter entegrasyonu
- [ ] 5.1.5 UI güncelle (power-up ikonu göster)

---

## FAZ 6: Quest Sistemi Güncelleme

### 6.1 Yeni Quest Türleri
**Eklenecek Quest'ler:**
- "Power-up kullanarak oyun kazan"
- "Peek kullanmadan 3 yıldız al"
- "Aynı oyunda 2 farklı power-up kullan"

**İş Parçacıkları:**
- [ ] 6.1.1 QuestType enum'a yeni tipler ekle
- [ ] 6.1.2 Power-up kullanım tracking
- [ ] 6.1.3 Quest reward'larına power-up ekle

---

## FAZ 7: Profil & İstatistik Genişletme

### 7.1 Yeni İstatistikler
**PlayerStats'a eklenecek:**
```dart
// Power-up istatistikleri
int totalPowerUpsUsed;
Map<PowerUpType, int> powerUpUsageCount;

// Ekonomi istatistikleri
int totalCoinsEarned;
int totalCoinsSpent;
int totalGemsEarned;

// Başarı istatistikleri
int gamesWonWithoutPowerUps;  // "Pure" kazanımlar
```

**İş Parçacıkları:**
- [ ] 7.1.1 PlayerStats model güncelle
- [ ] 7.1.2 StatsProvider güncelle
- [ ] 7.1.3 Statistics screen'e yeni sekme
- [ ] 7.1.4 Power-up usage chart/grafik

### 7.2 Profil Rozet Sistemi
**Rozetler (Badges):**
- "Power User" - 50 power-up kullan
- "Purist" - 10 oyunu power-up'sız kazan
- "Collector" - Her power-up'tan en az 10 adet biriktir
- "Big Spender" - 1000 coin harca
- "Saver" - 500 coin biriktir

**İş Parçacıkları:**
- [ ] 7.2.1 `badge.dart` entity oluştur
- [ ] 7.2.2 Badge unlock mekanizması
- [ ] 7.2.3 Profil ekranında rozet gösterimi

---

## FAZ 8: Online Multiplayer Hazırlığı

### 8.1 Power-up Multiplayer Kuralları
**Kurallar:**
- Peek: Sadece kendi kartlarını gösterir (rakip görmez)
- Freeze: Kendi süresini durdurur
- Hint: Kendi için ipucu
- Magnet: Kendi turunda geçerli

**İş Parçacıkları:**
- [ ] 8.1.1 Multiplayer power-up rules tanımla
- [ ] 8.1.2 Power-up state sync (Firestore için hazırlık)
- [ ] 8.1.3 Rakibe power-up kullanımı göster (notification)

### 8.2 Matchmaking Hazırlığı
**Profil Verileri (Online için):**
```dart
class OnlineProfile {
  final String odludUserId;
  final int level;           // Hesaplanmış seviye
  final int totalWins;
  final int powerUpInventory;
  final List<String> badges;
  final int elo;            // Ranking sistemi
}
```

**İş Parçacıkları:**
- [ ] 8.2.1 OnlineProfile entity oluştur
- [ ] 8.2.2 Firestore profile document yapısı
- [ ] 8.2.3 Level hesaplama formülü (XP bazlı)

---

## UYGULAMA SIRASI (Önerilen)

### Sprint 1 (Temel)
1. Currency entity & provider
2. Power-up entity & provider
3. Mevcut puanları coin'e dönüştür

### Sprint 2 (Power-up Mekanik)
4. Peek implementasyonu
5. Hint implementasyonu
6. Freeze implementasyonu

### Sprint 3 (UI)
7. Power-up bar widget
8. Game screen entegrasyonu
9. Aktivasyon animasyonları

### Sprint 4 (Ekonomi)
10. Shop screen
11. Satın alma mekanizması
12. Daily reward güncelleme

### Sprint 5 (Kalan Power-ups)
13. Shuffle implementasyonu
14. Time Bonus implementasyonu
15. Magnet implementasyonu

### Sprint 6 (Polish)
16. İstatistik güncelleme
17. Rozet sistemi
18. Quest güncelleme

### Sprint 7 (Online Hazırlık)
19. Online profile entity
20. Firestore yapısı
21. Multiplayer kuralları

---

## TEKNİK NOTLAR

### State Yönetimi
- Tüm yeni provider'lar Riverpod StateNotifier kullanacak
- SharedPreferences ile local persist
- Gelecekte Firestore sync

### Localization Keys
Tüm yeni string'ler için EN/TR key'leri eklenecek:
- `powerUpPeek`, `powerUpPeekDesc`
- `powerUpFreeze`, `powerUpFreezeDesc`
- `shopTitle`, `buyButton`, `notEnoughCoins`
- vs.

### Animasyonlar
- Flutter Animate paketi kullanılacak (mevcut)
- Power-up aktivasyonu: scale + glow
- Coin kazanım: fly + fade
- Magnet: özel parıltı efekti

---

## DOSYA YAPISI (Yeni)

```
lib/
├── domain/entities/
│   ├── currency.dart          # YENİ
│   ├── power_up.dart          # YENİ
│   ├── badge.dart             # YENİ
│   └── online_profile.dart    # YENİ
├── presentation/providers/
│   ├── wallet_provider.dart   # YENİ
│   ├── power_up_provider.dart # YENİ
│   └── badge_provider.dart    # YENİ
├── presentation/screens/
│   └── shop/
│       └── shop_screen.dart   # YENİ
├── presentation/widgets/
│   ├── power_up_bar.dart      # YENİ
│   ├── power_up_button.dart   # YENİ
│   ├── coin_display.dart      # YENİ
│   └── coin_animation.dart    # YENİ
```

---

*Bu roadmap, PairQuest'i kapsamlı bir oyuncu ekonomisi ve power-up sistemiyle güçlendirecek ve online multiplayer için hazırlayacaktır.*
