# Blazing Fruits — Project Specification

## 1. Overview

**Blazing Fruits** is a mobile arcade reflex game built with [Flutter](https://flutter.dev/) and the [Flame](https://flame-engine.org/) game engine. Players tap colored lanes to fire lasers that burn incoming fruits whose color does **not** match the lane. The game is single-screen, portrait-oriented, and targets Android (with no current iOS target).

---

## 2. Goals & Non-Goals

### Goals
- Deliver a fast-paced, pick-up-and-play reflex experience on Android.
- Provide a clear difficulty progression that ramps up over time.
- Persist local high scores across sessions.
- Keep all tunable gameplay values centralized in a single constants file.

### Non-Goals
- Online multiplayer or leaderboards.
- iOS or Web release (Android is the primary target).
- In-app purchases or monetization.
- Server-side backend or cloud sync.

---

## 3. Tech Stack

| Layer | Technology |
|---|---|
| Language | Dart |
| UI / App Shell | Flutter |
| Game Engine | Flame (FlameGame) |
| Persistence | Local storage (score persistence via `score_manager`) |
| Build Target | Android (APK / App Bundle) |
| Testing | `flutter test` (unit tests in `/test`) |

---

## 4. Core Game Loop

1. **Spawn** — Fruits fall down colored lanes at a configurable rate and speed.
2. **React** — The player taps a lane to fire its laser for a brief moment.
3. **Judge** — If the laser hits a fruit whose color does **not** match the lane → correct burn (score + combo). If the fruit's color **matches** the lane → let it pass safely; burning it incorrectly is a mistake.
4. **Fail state** — If a wrong-color fruit reaches the bottom without being burned, the player loses a life.
5. **Game Over** — Three lives lost ends the game; the score is persisted and compared against the leaderboard.

---

## 5. Gameplay Rules

| Rule | Detail |
|---|---|
| Lives | 3 lives per session |
| Combo multiplier | Consecutive correct burns build a multiplier up to **5×** |
| Difficulty | Speed and spawn rate increase every **10 fruits** |
| Speed range | 180 px/s (initial) → 420 px/s (max) |
| Spawn interval | 1.6 s (initial) → 0.45 s (minimum) |
| Laser zone | Bottom **15%** of screen triggers laser hit detection |

---

## 6. Project Structure

```
blazing-fruits/
├── android/                    # Android platform project
├── assets/
│   ├── audio/                  # Sound effect & music files (WAV/MP3)
│   └── fonts/                  # Optional custom game font (TTF)
├── lib/
│   ├── constants.dart          # All game tuning values (single source of truth)
│   ├── main.dart               # App entry point
│   ├── app.dart                # MaterialApp root
│   ├── game/
│   │   ├── blazing_game.dart   # FlameGame root; orchestrates all components
│   │   ├── components/
│   │   │   ├── lane.dart       # Tappable lane component
│   │   │   ├── fruit.dart      # Falling fruit + particle effects
│   │   │   ├── laser.dart      # Laser beam + hit detection
│   │   │   └── hud.dart        # Score / lives / wave display
│   │   ├── managers/
│   │   │   ├── score_manager.dart   # Points, combo logic, local persistence
│   │   │   ├── life_manager.dart    # Life tracking + game-over event stream
│   │   │   └── fruit_spawner.dart   # Spawn timing and wave difficulty logic
│   │   └── overlays/
│   │       ├── pause_overlay.dart
│   │       └── game_over_overlay.dart
│   └── screens/
│       ├── home_screen.dart         # Lane picker + Play / Leaderboard entry
│       └── leaderboard_screen.dart  # Top 10 local scores
├── temp_flutter_sample/        # Temporary reference code (not production)
├── test/                       # Unit and widget tests
├── pubspec.yaml                # Flutter dependencies & asset declarations
└── analysis_options.yaml       # Dart linter configuration
```

---

## 7. Component Responsibilities

### 7.1 `blazing_game.dart` — Game Root
- Initializes and mounts all Flame components (lanes, HUD, spawner).
- Manages game state transitions: `playing → paused → game_over`.
- Registers Flutter overlays (`pause_overlay`, `game_over_overlay`).

### 7.2 `lane.dart`
- Renders a vertically-oriented colored lane.
- Handles tap input and triggers `laser.dart` on tap.

### 7.3 `fruit.dart`
- Represents a falling fruit with a color property.
- Moves downward at the current speed from `constants.dart`.
- Plays particle effect on burn.
- Notifies `score_manager` or `life_manager` on collision result.

### 7.4 `laser.dart`
- Renders a brief laser beam animation within the laser zone (bottom 15% of screen).
- Performs hit detection against all fruits currently in the laser zone.
- Delegates burn/miss outcome to `score_manager` / `life_manager`.

### 7.5 `hud.dart`
- Displays current score, active combo multiplier, remaining lives, and current wave number.
- Listens to streams/notifiers from `score_manager` and `life_manager`.

### 7.6 `score_manager.dart`
- Tracks the current score and combo multiplier (max 5×).
- Resets combo on a miss.
- Persists scores locally; exposes the top-10 list for the leaderboard.

### 7.7 `life_manager.dart`
- Tracks remaining lives (starts at 3).
- Exposes a stream that fires a game-over event when lives reach 0.

### 7.8 `fruit_spawner.dart`
- Controls spawn timing (`spawnIntervalInitial` → `spawnIntervalMin`).
- Increments difficulty (speed + spawn rate) every `fruitsPerWave` fruits.
- Randomly assigns a fruit color from the available lane colors.

---

## 8. Screens

### 8.1 Home Screen (`home_screen.dart`)
- Entry point after app launch.
- Displays a lane color picker (allows players to preview lane setup).
- Buttons: **Play** and **Leaderboard**.

### 8.2 Leaderboard Screen (`leaderboard_screen.dart`)
- Shows top 10 locally persisted scores.
- No online integration.

### 8.3 Game Over Overlay (`game_over_overlay.dart`)
- Displayed when `life_manager` fires the game-over event.
- Shows final score and prompts: **Retry** or **Home**.

### 8.4 Pause Overlay (`pause_overlay.dart`)
- Pauses the Flame game loop.
- Options: **Resume** or **Quit to Home**.

---

## 9. Assets

### 9.1 Audio
All audio files live in `assets/audio/`. The game degrades gracefully if files are empty placeholders.

| File | Trigger |
|---|---|
| `laser.wav` | Lane tap |
| `burn.wav` | Correct fruit burn |
| `life_lost.wav` | Life lost event |
| `music_loop.mp3` | Background music (looping) |

### 9.2 Fonts
- Optional custom font: `assets/fonts/GameFont.ttf`
- Enabled by uncommenting the `fonts:` section in `pubspec.yaml`.

---

## 10. Tunable Constants (`lib/constants.dart`)

All difficulty and layout values are defined here. No magic numbers elsewhere in the codebase.

| Constant | Default | Description |
|---|---|---|
| `fruitSpeedInitial` | 180 px/s | Starting fall speed |
| `fruitSpeedMax` | 420 px/s | Maximum fall speed ceiling |
| `spawnIntervalInitial` | 1.6 s | Starting time between fruit spawns |
| `spawnIntervalMin` | 0.45 s | Fastest possible spawn rate |
| `fruitsPerWave` | 10 | Number of fruits before a difficulty step-up |
| `laserZoneFraction` | 0.15 | Fraction of screen height used as laser hit zone |

---

## 11. Build & Release

### Development
```bash
flutter pub get                          # Install dependencies
flutter emulators --launch blazing_pixel # Launch emulator
flutter run                              # Run in debug mode
flutter test                             # Run test suite
```

### Android Release
```bash
# APK (direct install)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# App Bundle (Google Play Store)
flutter build appbundle --release
```

---

## 12. Testing Strategy

- Tests live in `/test/`.
- Run with `flutter test`.
- Coverage focus areas:
  - `score_manager`: combo accumulation, multiplier cap, persistence read/write.
  - `life_manager`: life decrement, game-over stream emission.
  - `fruit_spawner`: wave progression, speed/interval clamping.

---

## 13. Known Constraints & Future Considerations

| Area | Note |
|---|---|
| iOS | Not currently targeted; project is Android-only. |
| Audio assets | Placeholder files are in place; real audio files must be added separately. |
| `temp_flutter_sample/` | Contains reference sample code; should be removed before production release. |
| Online leaderboard | Not in scope; all scores are stored locally. |
| Accessibility | No current a11y requirements defined; consider for future versions. |
