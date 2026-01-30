# PairQuest Online Multiplayer - Implementasyon Roadmap

## Genel Bakış

**Hedef:** Turn-based online multiplayer memory card oyunu
**Platform:** Firebase (Firestore + Cloud Functions)
**Tahmini Süre:** 8-12 hafta

---

## FAZ 1: Temel Altyapı (2-3 hafta)

### 1.1 Firestore Veri Modeli

```
Firestore Collections:
├── users/{userId}
│   ├── displayName, photoUrl, rating
│   ├── stats: {wins, losses, totalGames, winRate}
│   ├── onlineStatus: "online" | "offline" | "inGame"
│   └── lastSeenAt: timestamp
│
├── games/{gameId}
│   ├── status: "waiting" | "inProgress" | "completed" | "abandoned"
│   ├── mode: "ranked" | "casual" | "friend"
│   ├── level: 1-20
│   ├── players: [{userId, displayName, score, matches, combo}]
│   ├── currentPlayerIndex: 0
│   ├── cards: [encrypted card positions]
│   ├── matchedPairIds: []
│   ├── createdAt, startedAt, completedAt
│   ├── winnerId: string?
│   └── moves/{moveId}
│       ├── playerId, card1, card2
│       ├── matched: boolean
│       └── timestamp
│
├── matchmaking/{queueId}
│   ├── userId, rating, level
│   ├── status: "waiting" | "matched"
│   ├── createdAt, expiresAt
│   └── matchedGameId: string?
│
├── invitations/{invitationId}
│   ├── fromUserId, toUserId
│   ├── status: "pending" | "accepted" | "declined"
│   ├── level, gameId?
│   └── createdAt, expiresAt
│
└── friends/{friendshipId}
    ├── user1Id, user2Id
    ├── status: "pending" | "accepted" | "blocked"
    └── createdAt
```

### 1.2 Yeni Entity'ler

**Dosya:** `lib/domain/entities/online_game.dart`
```dart
@freezed
class OnlineGame {
  - id: String
  - status: OnlineGameStatus
  - mode: OnlineGameMode (ranked, casual, friend)
  - level: int
  - players: List<OnlinePlayer>
  - currentPlayerIndex: int
  - cards: List<GameCard>
  - matchedPairIds: Set<String>
  - createdAt, startedAt, completedAt
  - winnerId: String?
}

enum OnlineGameStatus { waiting, inProgress, completed, abandoned }
enum OnlineGameMode { ranked, casual, friend }
```

**Dosya:** `lib/domain/entities/online_player.dart`
```dart
@freezed
class OnlinePlayer {
  - userId: String
  - displayName: String
  - photoUrl: String?
  - rating: int
  - score: int
  - matches: int
  - combo: int
  - isConnected: bool
  - isCurrentTurn: bool
}
```

**Dosya:** `lib/domain/entities/game_move.dart`
```dart
@freezed
class GameMove {
  - id: String
  - playerId: String
  - cardId1, cardId2: String
  - matched: bool
  - scoreAwarded: int
  - timestamp: DateTime
}
```

### 1.3 Repository Katmanı

**Dosya:** `lib/data/repositories/online_game_repository.dart`
```dart
class OnlineGameRepository {
  // Game CRUD
  Future<String> createGame(OnlineGame game);
  Stream<OnlineGame?> watchGame(String gameId);
  Future<void> updateGameStatus(String gameId, OnlineGameStatus status);

  // Moves
  Future<void> submitMove(String gameId, GameMove move);
  Stream<List<GameMove>> watchMoves(String gameId);

  // Player state
  Future<void> updatePlayerScore(String gameId, String playerId, int score);
  Future<void> setPlayerDisconnected(String gameId, String playerId);
}
```

**Dosya:** `lib/data/repositories/matchmaking_repository.dart`
```dart
class MatchmakingRepository {
  Future<String> joinQueue(String userId, int rating, int preferredLevel);
  Future<void> leaveQueue(String queueId);
  Stream<MatchmakingStatus> watchQueueStatus(String queueId);
  Future<String?> findMatch(String userId); // Returns gameId if matched
}
```

### 1.4 İş Parçacıkları

| # | İş | Dosya | Durum |
|---|---|---|---|
| 1.1.1 | OnlineGame entity oluştur | `online_game.dart` | ⬜ |
| 1.1.2 | OnlinePlayer entity oluştur | `online_player.dart` | ⬜ |
| 1.1.3 | GameMove entity oluştur | `game_move.dart` | ⬜ |
| 1.1.4 | Freezed code generation | `flutter pub run build_runner` | ⬜ |
| 1.2.1 | Firestore security rules | `firestore.rules` | ⬜ |
| 1.2.2 | OnlineGameRepository | `online_game_repository.dart` | ⬜ |
| 1.2.3 | MatchmakingRepository | `matchmaking_repository.dart` | ⬜ |
| 1.2.4 | UserRepository (online status) | `user_repository.dart` | ⬜ |
| 1.3.1 | Card encryption utility | `card_encryption.dart` | ⬜ |
| 1.3.2 | Game ID generation | UUID v4 | ⬜ |

---

## FAZ 2: Real-Time Senkronizasyon (2-3 hafta)

### 2.1 Game Sync Provider

**Dosya:** `lib/presentation/providers/online_game_provider.dart`
```dart
// Ana oyun state'i
final onlineGameProvider = StreamProvider.family<OnlineGame?, String>((ref, gameId) {
  return ref.watch(onlineGameRepositoryProvider).watchGame(gameId);
});

// Hamle stream'i
final gameMovesProvider = StreamProvider.family<List<GameMove>, String>((ref, gameId) {
  return ref.watch(onlineGameRepositoryProvider).watchMoves(gameId);
});

// Sıradaki oyuncu
final currentTurnProvider = Provider.family<bool, String>((ref, gameId) {
  final game = ref.watch(onlineGameProvider(gameId)).value;
  final userId = ref.watch(currentUserIdProvider);
  return game?.players[game.currentPlayerIndex].userId == userId;
});
```

### 2.2 Optimistic Updates

```dart
class OnlineGameNotifier extends StateNotifier<OnlineGameState> {
  // 1. Kart seçildiğinde UI hemen güncellenir
  void selectCard(String cardId) {
    state = state.copyWith(selectedCards: [...state.selectedCards, cardId]);
    // UI anında react eder
  }

  // 2. Sunucuya hamle gönderilir
  Future<void> submitMove(String card1, String card2) async {
    final move = GameMove(...);

    // Optimistic: UI'da eşleşme göster
    _showOptimisticMatch(card1, card2);

    try {
      await _repository.submitMove(gameId, move);
      // Sunucu onayladı - state zaten doğru
    } catch (e) {
      // Sunucu reddetti - rollback
      _rollbackMove(card1, card2);
    }
  }
}
```

### 2.3 Connection & Presence

```dart
class PresenceService {
  // Online durumu Firestore'a yaz
  Future<void> setOnline(String userId);
  Future<void> setOffline(String userId);
  Future<void> setInGame(String userId, String gameId);

  // Bağlantı koptuğunda (onDisconnect)
  void setupDisconnectHandler(String userId);
}
```

### 2.4 İş Parçacıkları

| # | İş | Dosya | Durum |
|---|---|---|---|
| 2.1.1 | OnlineGameProvider | `online_game_provider.dart` | ⬜ |
| 2.1.2 | GameMovesProvider | `online_game_provider.dart` | ⬜ |
| 2.1.3 | CurrentTurnProvider | `online_game_provider.dart` | ⬜ |
| 2.2.1 | OnlineGameNotifier | `online_game_notifier.dart` | ⬜ |
| 2.2.2 | Optimistic update logic | `online_game_notifier.dart` | ⬜ |
| 2.2.3 | Rollback mechanism | `online_game_notifier.dart` | ⬜ |
| 2.3.1 | PresenceService | `presence_service.dart` | ⬜ |
| 2.3.2 | onDisconnect handler | Firebase RTDB | ⬜ |
| 2.4.1 | Network status provider | `network_provider.dart` | ⬜ |
| 2.4.2 | Reconnection logic | `reconnection_handler.dart` | ⬜ |

---

## FAZ 3: Matchmaking Sistemi (1-2 hafta)

### 3.1 Matchmaking Flow

```
User taps "Find Match"
       ↓
Join matchmaking queue
       ↓
Server checks for compatible opponents
(±200 rating, same level preference)
       ↓
Match found? ──No──→ Wait (max 60s) ──Timeout──→ Expand search or cancel
       ↓ Yes
Create game document
       ↓
Notify both players
       ↓
Navigate to game screen
```

### 3.2 Matchmaking Provider

**Dosya:** `lib/presentation/providers/matchmaking_provider.dart`
```dart
enum MatchmakingState { idle, searching, matched, timeout, error }

class MatchmakingNotifier extends StateNotifier<MatchmakingState> {
  Future<void> startSearching(int preferredLevel) async {
    state = MatchmakingState.searching;

    final queueId = await _repository.joinQueue(userId, rating, preferredLevel);

    // Listen for match
    _subscription = _repository.watchQueueStatus(queueId).listen((status) {
      if (status.matched) {
        state = MatchmakingState.matched;
        _navigateToGame(status.gameId);
      }
    });

    // 60 saniye timeout
    Future.delayed(Duration(seconds: 60), () {
      if (state == MatchmakingState.searching) {
        cancelSearch();
        state = MatchmakingState.timeout;
      }
    });
  }

  void cancelSearch() {
    _subscription?.cancel();
    _repository.leaveQueue(queueId);
    state = MatchmakingState.idle;
  }
}
```

### 3.3 Cloud Function: Matchmaking

```typescript
// functions/src/matchmaking.ts
export const onMatchmakingQueueWrite = functions.firestore
  .document('matchmaking/{queueId}')
  .onCreate(async (snap, context) => {
    const newPlayer = snap.data();

    // Find compatible opponent
    const opponents = await db.collection('matchmaking')
      .where('status', '==', 'waiting')
      .where('rating', '>=', newPlayer.rating - 200)
      .where('rating', '<=', newPlayer.rating + 200)
      .limit(1)
      .get();

    if (!opponents.empty) {
      const opponent = opponents.docs[0];

      // Create game
      const gameRef = await db.collection('games').add({
        status: 'waiting',
        players: [newPlayer.userId, opponent.data().userId],
        // ... game setup
      });

      // Update both queue entries
      await snap.ref.update({ status: 'matched', gameId: gameRef.id });
      await opponent.ref.update({ status: 'matched', gameId: gameRef.id });
    }
  });
```

### 3.4 İş Parçacıkları

| # | İş | Dosya | Durum |
|---|---|---|---|
| 3.1.1 | MatchmakingNotifier | `matchmaking_provider.dart` | ⬜ |
| 3.1.2 | Queue join/leave logic | `matchmaking_repository.dart` | ⬜ |
| 3.1.3 | Match status listener | `matchmaking_provider.dart` | ⬜ |
| 3.2.1 | Cloud Function setup | `functions/` | ⬜ |
| 3.2.2 | onMatchmakingQueueWrite | `matchmaking.ts` | ⬜ |
| 3.2.3 | Rating-based matching | `matchmaking.ts` | ⬜ |
| 3.3.1 | Timeout handling | `matchmaking_provider.dart` | ⬜ |
| 3.3.2 | Cancel search | `matchmaking_provider.dart` | ⬜ |

---

## FAZ 4: UI Ekranları (2-3 hafta)

### 4.1 Yeni Ekranlar

**Online Lobby Screen**
```
┌─────────────────────────────────┐
│  ← Online Multiplayer           │
├─────────────────────────────────┤
│                                 │
│  ┌───────────┐ ┌───────────┐   │
│  │  🎮       │ │  👥       │   │
│  │ Quick     │ │ Play with │   │
│  │ Match     │ │ Friend    │   │
│  └───────────┘ └───────────┘   │
│                                 │
│  ┌───────────┐ ┌───────────┐   │
│  │  🏆       │ │  👤       │   │
│  │ Ranked    │ │ My        │   │
│  │ Match     │ │ Profile   │   │
│  └───────────┘ └───────────┘   │
│                                 │
│  ─────── Leaderboard ───────   │
│  🥇 Player1     2450 pts       │
│  🥈 Player2     2380 pts       │
│  🥉 Player3     2290 pts       │
│                                 │
└─────────────────────────────────┘
```

**Matchmaking Screen**
```
┌─────────────────────────────────┐
│                                 │
│         🔍 Searching...         │
│                                 │
│      ┌─────────────────┐       │
│      │   ⏳ 0:23       │       │
│      │                 │       │
│      │  Finding a      │       │
│      │  worthy         │       │
│      │  opponent...    │       │
│      │                 │       │
│      └─────────────────┘       │
│                                 │
│      [ Cancel Search ]          │
│                                 │
└─────────────────────────────────┘
```

**Online Game Screen**
```
┌─────────────────────────────────┐
│ Player1: 250    Player2: 180   │
│ ⭐⭐⭐ Your Turn   ⭐⭐          │
├─────────────────────────────────┤
│                                 │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐          │
│  │🃏│ │🃏│ │🎴│ │🃏│          │
│  └──┘ └──┘ └──┘ └──┘          │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐          │
│  │🃏│ │🎴│ │🃏│ │🃏│          │
│  └──┘ └──┘ └──┘ └──┘          │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐          │
│  │🃏│ │🃏│ │🃏│ │🃏│          │
│  └──┘ └──┘ └──┘ └──┘          │
│                                 │
├─────────────────────────────────┤
│  💬 Chat          ⏸️ Pause     │
└─────────────────────────────────┘
```

### 4.2 Widget'lar

| Widget | Açıklama |
|--------|----------|
| `OnlinePlayerCard` | Oyuncu bilgisi (avatar, isim, puan, online status) |
| `MatchmakingAnimation` | Arama animasyonu |
| `TurnIndicator` | Kimin sırası olduğunu gösterir |
| `OnlineGameHeader` | İki oyuncunun skorlarını gösterir |
| `ConnectionStatusBadge` | Online/Offline göstergesi |
| `GameResultOverlay` | Kazanan/Kaybeden sonuç ekranı |

### 4.3 İş Parçacıkları

| # | İş | Dosya | Durum |
|---|---|---|---|
| 4.1.1 | OnlineLobbyScreen | `online_lobby_screen.dart` | ⬜ |
| 4.1.2 | MatchmakingScreen | `matchmaking_screen.dart` | ⬜ |
| 4.1.3 | OnlineGameScreen | `online_game_screen.dart` | ⬜ |
| 4.1.4 | GameResultScreen | `game_result_screen.dart` | ⬜ |
| 4.2.1 | OnlinePlayerCard widget | `online_player_card.dart` | ⬜ |
| 4.2.2 | MatchmakingAnimation | `matchmaking_animation.dart` | ⬜ |
| 4.2.3 | OnlineGameHeader | `online_game_header.dart` | ⬜ |
| 4.2.4 | ConnectionStatusBadge | `connection_status_badge.dart` | ⬜ |
| 4.3.1 | Router entegrasyonu | `app_router.dart` | ⬜ |
| 4.3.2 | Ana menüye online butonu | `home_screen.dart` | ⬜ |

---

## FAZ 5: Arkadaş Sistemi (1-2 hafta)

### 5.1 Friend Features

- Arkadaş ekleme (kullanıcı adı ile arama)
- Arkadaş listesi
- Arkadaşa oyun daveti gönderme
- Arkadaşın online durumunu görme
- Arkadaşlar arası skor karşılaştırma

### 5.2 Friend Provider

```dart
final friendsProvider = StreamProvider<List<Friend>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return ref.watch(friendsRepositoryProvider).watchFriends(userId);
});

final friendRequestsProvider = StreamProvider<List<FriendRequest>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return ref.watch(friendsRepositoryProvider).watchPendingRequests(userId);
});
```

### 5.3 Game Invitation Flow

```
User A sends invitation to User B
       ↓
Create invitation document (pending)
       ↓
User B receives push notification
       ↓
User B accepts/declines
       ↓
If accepted: Create game, navigate both players
If declined: Notify User A
```

### 5.4 İş Parçacıkları

| # | İş | Dosya | Durum |
|---|---|---|---|
| 5.1.1 | Friend entity | `friend.dart` | ⬜ |
| 5.1.2 | FriendRequest entity | `friend_request.dart` | ⬜ |
| 5.1.3 | GameInvitation entity | `game_invitation.dart` | ⬜ |
| 5.2.1 | FriendsRepository | `friends_repository.dart` | ⬜ |
| 5.2.2 | InvitationRepository | `invitation_repository.dart` | ⬜ |
| 5.3.1 | FriendsProvider | `friends_provider.dart` | ⬜ |
| 5.3.2 | InvitationsProvider | `invitations_provider.dart` | ⬜ |
| 5.4.1 | FriendsScreen | `friends_screen.dart` | ⬜ |
| 5.4.2 | AddFriendDialog | `add_friend_dialog.dart` | ⬜ |
| 5.4.3 | InvitationDialog | `invitation_dialog.dart` | ⬜ |
| 5.5.1 | Push notification for invites | `notification_service.dart` | ⬜ |

---

## FAZ 6: Rating & Ranking (1 hafta)

### 6.1 ELO Rating System

```dart
class RatingCalculator {
  static const int K_FACTOR = 32;

  static (int, int) calculateNewRatings(int winnerRating, int loserRating) {
    final expectedWinner = 1 / (1 + pow(10, (loserRating - winnerRating) / 400));
    final expectedLoser = 1 - expectedWinner;

    final newWinnerRating = (winnerRating + K_FACTOR * (1 - expectedWinner)).round();
    final newLoserRating = (loserRating + K_FACTOR * (0 - expectedLoser)).round();

    return (newWinnerRating, newLoserRating);
  }
}
```

### 6.2 Ranking Tiers

| Tier | Rating Range | Icon |
|------|-------------|------|
| Bronze | 0-999 | 🥉 |
| Silver | 1000-1499 | 🥈 |
| Gold | 1500-1999 | 🥇 |
| Platinum | 2000-2499 | 💎 |
| Diamond | 2500-2999 | 💠 |
| Master | 3000+ | 👑 |

### 6.3 İş Parçacıkları

| # | İş | Dosya | Durum |
|---|---|---|---|
| 6.1.1 | RatingCalculator | `rating_calculator.dart` | ⬜ |
| 6.1.2 | Cloud Function: updateRatings | `rating.ts` | ⬜ |
| 6.2.1 | PlayerRanking entity | `player_ranking.dart` | ⬜ |
| 6.2.2 | RankingRepository | `ranking_repository.dart` | ⬜ |
| 6.3.1 | GlobalRankingScreen | `global_ranking_screen.dart` | ⬜ |
| 6.3.2 | PlayerProfileScreen | `player_profile_screen.dart` | ⬜ |
| 6.3.3 | RankBadge widget | `rank_badge.dart` | ⬜ |

---

## FAZ 7: Test & Optimizasyon (1 hafta)

### 7.1 Test Senaryoları

| Senaryo | Test Tipi |
|---------|-----------|
| İki oyuncu eşzamanlı hamle | Integration |
| Oyuncu bağlantı kopması | Integration |
| Matchmaking timeout | Unit |
| Rating hesaplama | Unit |
| Optimistic update rollback | Unit |
| Firestore security rules | Security |

### 7.2 Performance Optimizasyonları

- Firestore batch writes
- Listener unsubscribe on dispose
- Image caching for avatars
- Lazy loading for leaderboards

### 7.3 İş Parçacıkları

| # | İş | Dosya | Durum |
|---|---|---|---|
| 7.1.1 | Unit tests | `test/` | ⬜ |
| 7.1.2 | Integration tests | `integration_test/` | ⬜ |
| 7.1.3 | Security rules test | `firestore.rules.test.js` | ⬜ |
| 7.2.1 | Performance profiling | - | ⬜ |
| 7.2.2 | Firestore cost optimization | - | ⬜ |
| 7.2.3 | Memory leak check | - | ⬜ |

---

## Localization Eklemeleri

### app_en.arb
```json
"onlineMultiplayer": "Online Multiplayer",
"quickMatch": "Quick Match",
"rankedMatch": "Ranked Match",
"playWithFriend": "Play with Friend",
"searchingForOpponent": "Searching for opponent...",
"matchFound": "Match Found!",
"yourTurn": "Your Turn",
"opponentTurn": "Opponent's Turn",
"youWin": "You Win!",
"youLose": "You Lose!",
"draw": "Draw!",
"rating": "Rating",
"rank": "Rank",
"friends": "Friends",
"addFriend": "Add Friend",
"sendInvitation": "Send Invitation",
"invitationSent": "Invitation Sent",
"invitationReceived": "Game Invitation",
"acceptInvitation": "Accept",
"declineInvitation": "Decline",
"opponentDisconnected": "Opponent disconnected",
"reconnecting": "Reconnecting...",
"connectionLost": "Connection Lost"
```

### app_tr.arb
```json
"onlineMultiplayer": "Online Çok Oyunculu",
"quickMatch": "Hızlı Eşleşme",
"rankedMatch": "Dereceli Maç",
"playWithFriend": "Arkadaşla Oyna",
"searchingForOpponent": "Rakip aranıyor...",
"matchFound": "Eşleşme Bulundu!",
"yourTurn": "Senin Sıran",
"opponentTurn": "Rakibin Sırası",
"youWin": "Kazandın!",
"youLose": "Kaybettin!",
"draw": "Berabere!",
"rating": "Puan",
"rank": "Sıralama",
"friends": "Arkadaşlar",
"addFriend": "Arkadaş Ekle",
"sendInvitation": "Davet Gönder",
"invitationSent": "Davet Gönderildi",
"invitationReceived": "Oyun Daveti",
"acceptInvitation": "Kabul Et",
"declineInvitation": "Reddet",
"opponentDisconnected": "Rakip bağlantısı koptu",
"reconnecting": "Yeniden bağlanılıyor...",
"connectionLost": "Bağlantı Kesildi"
```

---

## Özet: Toplam İş Parçacıkları

| Faz | İş Sayısı | Tahmini Süre |
|-----|-----------|--------------|
| FAZ 1: Temel Altyapı | 10 | 2-3 hafta |
| FAZ 2: Real-Time Sync | 10 | 2-3 hafta |
| FAZ 3: Matchmaking | 8 | 1-2 hafta |
| FAZ 4: UI Ekranları | 12 | 2-3 hafta |
| FAZ 5: Arkadaş Sistemi | 11 | 1-2 hafta |
| FAZ 6: Rating & Ranking | 7 | 1 hafta |
| FAZ 7: Test & Optimizasyon | 6 | 1 hafta |
| **TOPLAM** | **64** | **10-15 hafta** |

---

## Başlangıç Noktası

İlk olarak **FAZ 1.1** ile başlanması önerilir:
1. OnlineGame entity oluştur
2. Firestore security rules yaz
3. Basit bir test oyunu oluştur ve Firestore'a kaydet

Bu temel hazır olduğunda diğer fazlara geçilebilir.
