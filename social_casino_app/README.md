# Social Casino Flutter App

A native Flutter mobile application for the Social Casino platform, providing a seamless casino gaming experience on iOS and Android devices.

## Features

- **Game Lobby**: Browse games with personalized recommendations
- **Category Filtering**: Slots, Live Casino, Table Games, Instant Win
- **PlayModal**: Full-screen game info with hero image, stats, and actions
  - Safe area handling for device notches/camera cutouts
  - Rounded image corners with overlay close button
  - Game statistics (RTP, volatility, min/max bet, jackpot)
- **Game Play Tracking**: Duration tracking for play sessions
- **Review System**: Star ratings with optional text reviews
- **AI Chat Assistant**: Integrated chat for game questions
- **Countdown Timers**: Promotional countdown widgets

## Architecture

```
lib/
├── config/
│   ├── api_config.dart      # API endpoints configuration
│   ├── routes.dart          # GoRouter navigation setup
│   └── theme/
│       └── app_colors.dart  # Casino theme colors
│
├── models/
│   ├── game.dart            # Game model with badges, stats
│   └── user.dart            # User model
│
├── providers/
│   ├── lobby_provider.dart  # Game data & recommendations
│   ├── user_provider.dart   # User state & reviews
│   └── chat_provider.dart   # Chat session management
│
├── screens/
│   ├── lobby_screen.dart    # Main casino lobby
│   ├── category_screen.dart # Category-filtered games
│   └── [type]_screen.dart   # Sports, Poker, Live Casino
│
├── services/
│   ├── api_service.dart     # HTTP client wrapper
│   └── recommendation_service.dart
│
└── widgets/
    ├── chat/
    │   └── chat_window.dart # AI chat interface
    │
    ├── game/
    │   ├── play_modal.dart       # Game info modal
    │   ├── game_play_dialog.dart # Play tracking dialog
    │   ├── review_form.dart      # Rating & review form
    │   ├── rating_stars.dart     # Interactive star rating
    │   └── game_badge.dart       # Badge display widget
    │
    ├── layout/
    │   ├── main_scaffold.dart    # App scaffold with bottom nav
    │   └── bottom_nav_bar.dart   # Navigation bar
    │
    └── lobby/
        ├── game_grid.dart        # Grid of game cards
        ├── game_card.dart        # Individual game card
        └── countdown_timer.dart  # Promotional timer
```

## Getting Started

### Prerequisites

- Flutter SDK 3.24+
- Dart SDK 3.5+
- iOS: Xcode 15+ (for iOS development)
- Android: Android Studio with SDK 34+

### Installation

1. Install dependencies:
```bash
cd social_casino_app
flutter pub get
```

2. Configure API endpoint (optional):
Edit `lib/config/api_config.dart` to point to your backend:
```dart
class ApiConfig {
  static const String baseUrl = 'http://your-server:3001';
  static const String recommendationUrl = 'http://your-server:8081';
  static const String chatUrl = 'http://your-server:8082';
}
```

3. Run the app:
```bash
# iOS Simulator
flutter run -d ios

# Android Emulator
flutter run -d android

# Chrome (for debugging)
flutter run -d chrome
```

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `go_router` | Declarative navigation |
| `cached_network_image` | Image caching & placeholders |
| `dio` | HTTP client |
| `intl` | Number/date formatting |
| `shimmer` | Loading skeleton animations |

## State Management

Uses Riverpod for reactive state management:

- **lobbyProvider**: Fetches and caches game data from CMS
- **recommendationsProvider**: User-personalized game recommendations
- **userProvider**: User ID, preferences, and review submissions
- **chatProvider**: Chat session state and message history

## Navigation

Uses GoRouter with shell routes:

- `/` - Casino lobby (default)
- `/live-casino` - Live casino games
- `/sports` - Sports betting (placeholder)
- `/poker` - Poker games (placeholder)
- `/category/[slug]` - Category-specific game lists

The PlayModal is shown using the root navigator for full-screen display above the shell.

## UI Components

### PlayModal
Full-screen game information modal with:
- Hero image (16:9 aspect ratio, rounded corners)
- Close button overlay on image
- Safe area handling for notches
- Badges, title, provider info
- Stats grid (RTP, volatility, bet limits)
- Jackpot display (if applicable)
- "Play Now" and "Ask AI" action buttons
- Expandable "Rate & Review" section

### GameCard
Compact card for game grid display:
- Thumbnail image with shimmer loading
- Title and provider
- Badge indicators
- Tap to open PlayModal

### ChatWindow
AI-powered chat assistant:
- Session-based conversations
- RAG-powered responses
- Citation display
- Suggested questions

## API Integration

Consumes three backend services:

1. **PayloadCMS** (port 3001)
   - Game catalog
   - Media assets
   - Badges & providers

2. **Recommendation Service** (port 8081)
   - Event tracking (impressions, play time)
   - Personalized recommendations
   - Review submissions

3. **Chat Service** (port 8082)
   - Chat sessions
   - AI-powered responses

## Building for Production

### iOS
```bash
flutter build ios --release
```

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

## License

This is a proof-of-concept project for demonstration purposes.
