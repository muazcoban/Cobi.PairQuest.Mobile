# PairQuest - Memory Card Matching Game

A beautiful and addictive memory card matching game built with Flutter.

## Features

### Core Gameplay
- 10 difficulty levels (2x2 to 8x8 grids)
- Classic and Timed game modes
- Smooth card flip animations
- Score system with combo bonuses
- Star rating based on performance

### Gamification
- 20 unique achievements with rarity levels (Common, Rare, Epic, Legendary)
- Daily quests with rewards
- Global leaderboard
- 7-day daily reward streak system
- Player statistics tracking

### Customization
- Multiple card themes
- Dark/Light mode support
- Sound effects and background music with toggle
- Haptic feedback
- Multi-language support (English, Turkish)

## Screenshots

*Coming soon*

## Tech Stack

- **Framework:** Flutter 3.x
- **State Management:** Riverpod
- **Architecture:** Clean Architecture
- **Local Storage:** SharedPreferences
- **Audio:** AudioPlayers
- **Code Generation:** Freezed, JSON Serializable

## Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+

### Installation

```bash
# Clone the repository
git clone https://github.com/muazcoban/Cobi.PairQuest.Mobile.git

# Navigate to project directory
cd Cobi.PairQuest.Mobile

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

## Project Structure

```
lib/
├── core/
│   ├── constants/      # App colors, game config
│   ├── router/         # Navigation
│   ├── services/       # Audio, haptic services
│   ├── theme/          # App theming
│   └── utils/          # Utilities
├── domain/
│   └── entities/       # Game models (Card, Game, Player, etc.)
├── l10n/               # Localization files
├── presentation/
│   ├── providers/      # Riverpod state management
│   ├── screens/        # App screens
│   └── widgets/        # Reusable widgets
└── services/           # Business logic services
```

## Roadmap

- [ ] More card themes (Animals, Food, Sports, etc.)
- [ ] Multiplayer mode
- [ ] Cloud sync for progress
- [ ] Weekly challenges
- [ ] Social features (share scores, challenge friends)

## License

This project is licensed under the MIT License.

## Author

**Muaz Coban**
- GitHub: [@muazcoban](https://github.com/muazcoban)

---

Made with Flutter
