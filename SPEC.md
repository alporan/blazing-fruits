# Blazing Fruits — Project Specification

## 1. Overview

**Blazing Fruits** is a mobile arcade reflex game built with [Flutter](https://flutter.dev/) and the [Flame](https://flame-engine.org/) game engine. Players tap colored lanes to fire horizontal flamethrowers that burn incoming fruits whose color does **not** match the lane. The game is single-screen, portrait-oriented, and targets Android (with no current iOS target).

---

## 2. Goals & Non-Goals

### Goals
- Deliver a fast-paced, pick-up-and-play reflex experience on Android.
- Provide a smooth difficulty curve driven by per-burn speed acceleration.
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
| Persistence | Local storage via `SharedPreferences` |
| Build Target | Android (APK / App Bundle) |
| Testing | `flutter test` (unit + widget tests in `/test`) |

---

## 4. Core Game Loop

1. **Spawn** — Fruits fall down colored lanes at a configurable rate and speed.
2. **React** — The player taps a lane to fire its paired horizontal flamethrowers for a brief moment.
3. **Judge** — If the flame hits a fruit whose color does **not** match the lane → correct burn (score, speed bump). If the fruit's color **matches** the lane → let it pass safely; burning it is a mistake.
4. **Special rule** — Blue blueberries have no matching lane and must always be burned in any lane.
5. **Fail state** — If a wrong-color fruit reaches the bottom without being burned, the player loses a life.
6. **Game Over** — Three lives lost ends the game; the score is persisted and compared against the local leaderboard.

---

## 5. Gameplay Rules

| Rule | Detail |
|---|---|
| Lives | 3 lives per session |
| Scoring | 10 points per correct burn (flat, no multiplier) |
| Difficulty | Fruit speed increases by 2.5 px/s per successful burn |
| Speed range | 185 px/s (initial) → 420 px/s (max) |
| Spawn interval | 1.6 s (initial), fixed (no wave-based reduction) |
| Lane count | 1–3 lanes (player chooses before game) |
| Lane colors | Green (0), Yellow (1), Red (2) |
| Blue fruits | Always-burn; no matching lane; blueberry emoji only |
| Impact zone | Horizontal band at 85% of screen height (±55 px) |

---

## 6. Project Structure

```
blazing-fruits/
├── android/                    # Android platform project
├── assets/
│   ├── audio/                  # Sound effect & music files (WAV/MP3)
│   ├── fonts/                  # Optional custom game font (TTF)
│   ├── icon/                   # App launcher icon (icon.png)
│   └── images/                 # Sprite image folders (currently unused)
├── lib/
│   ├── constants.dart          # All game tuning values (single source of truth)
│   ├── main.dart               # App entry point
│   ├── app.dart                # MaterialApp root
│   ├── game/
│   │   ├── blazing_game.dart   # FlameGame root; orchestrates all components
│   │   ├── components/
│   │   │   ├── lane.dart           # Tappable lane component
│   │   │   ├── fruit.dart          # Falling fruit + particle effects
│   │   │   ├── flamethrower.dart   # Horizontal flame + hit detection
│   │   │   └── hud.dart            # Score / lives display
│   │   ├── managers/
│   │   │   ├── score_manager.dart   # Points + local persistence
│   │   │   ├── life_manager.dart    # Life tracking + game-over event stream
│   │   │   └── fruit_spawner.dart   # Spawn timing + per-burn acceleration
│   │   └── overlays/
│   │       ├── pause_overlay.dart
│   │       └── game_over_overlay.dart
│   └── screens/
│       ├── home_screen.dart         # Lane picker + Play / Leaderboard entry
│       └── leaderboard_screen.dart  # Top 10 local scores
├── test/                       # Unit and widget tests
├── flutter_launcher_icons.yaml # Launcher icon generation config
├── pubspec.yaml                # Flutter dependencies & asset declarations
└── analysis_options.yaml       # Dart linter configuration
```

---

## 7. Component Responsibilities

### 7.1 `blazing_game.dart` — Game Root
- Initializes and mounts all Flame components (lanes, HUD, spawner).
- Manages game state transitions: `playing → paused → game_over`.
- Registers Flutter overlays (`pause_overlay`, `game_over_overlay`).
- Exposes `onFruitBurned()` which atomically calls `scoreManager.addPoints()` and `_spawner.accelerate()`.

### 7.2 `lane.dart`
- Renders a vertically-oriented colored lane with a bottom color indicator bar.
- Handles tap input and triggers `flamethrower.dart` on tap.

### 7.3 `fruit.dart`
- Represents a falling fruit with a `colorIndex` and a `fruitVariant` (0–2, selecting which emoji within the lane's fruit set).
- Moves downward at the current speed.
- Plays a particle burst on burn.
- On escape: wrong-color fruit → life lost; matching fruit → no penalty.

### 7.4 `flamethrower.dart`
- Renders two mirrored horizontal nozzles (one per lane edge) at `flamethrowerYFraction` down the screen.
- Shows a persistent impact zone indicator (dashed band + inward arrows) so the player always knows the fire height.
- On `fire()`: plays a gradient flame animation shooting from both nozzles toward center; performs hit detection against fruits whose Y overlaps the impact band.
- Burns wrong-color fruits (score + accelerate); burning a matching fruit loses a life.

### 7.5 `hud.dart`
- Displays remaining lives (hearts) in the top-left.
- Displays current score (6-digit padded) centered below the hearts.
- Listens to streams from `score_manager` and `life_manager`.

### 7.6 `score_manager.dart`
- Tracks the current score (flat `pointsPerBurn` per correct burn, no multiplier).
- Persists scores locally via `SharedPreferences`; exposes the top-10 list for the leaderboard.

### 7.7 `life_manager.dart`
- Tracks remaining lives (starts at 3).
- Exposes a broadcast stream that fires a game-over event when lives reach 0.

### 7.8 `fruit_spawner.dart`
- Controls spawn timing at a fixed `spawnIntervalInitial`.
- Randomly assigns lane and color (60% chance of wrong-color; blue is always available as a 4th color with no matching lane).
- Each fruit gets a random `fruitVariant` index selecting its specific emoji.
- `accelerate()` increases `_fruitSpeed` by `fruitSpeedPerBurn` (clamped to `fruitSpeedMax`).

---

## 8. Screens

### 8.1 Home Screen (`home_screen.dart`)
- Entry point after app launch.
- Animated pulsing 🔥 title.
- Lane count selector (1–3), colored by lane color.
- Buttons: **Play** and **Leaderboard**.

### 8.2 Leaderboard Screen (`leaderboard_screen.dart`)
- Shows top 10 locally persisted scores with 🥇🥈🥉 medals for rank 1–3.
- No online integration.

### 8.3 Game Over Overlay (`game_over_overlay.dart`)
- Displayed when `life_manager` fires the game-over event.
- Shows final score; highlights new #1 high score.
- Buttons: **Play Again** and **Home**.

### 8.4 Pause Overlay (`pause_overlay.dart`)
- Pauses the Flame game loop.
- Buttons: **Resume**, **Restart**, **Home**.

---

## 9. Assets

### 9.1 Audio
All audio files live in `assets/audio/`. The game degrades gracefully if files are empty placeholders.

| File | Trigger |
|---|---|
| `laser.wav` | Lane tap (flamethrower fire) |
| `burn.wav` | Correct fruit burn |
| `life_lost.wav` | Life lost event |
| `music_loop.mp3` | Background music (looping) |

### 9.2 Fonts
- Optional custom font: `assets/fonts/GameFont.ttf`
- Enabled by uncommenting the `fonts:` section in `pubspec.yaml`.

### 9.3 Launcher Icon
- Source image: `assets/icon/icon.png`
- Generated via `flutter_launcher_icons` (`flutter_launcher_icons.yaml`).
- Adaptive icon background: `#0D0D0D`.
- Re-generate after changing the source image: `dart run flutter_launcher_icons`.

---

## 10. Tunable Constants (`lib/constants.dart`)

All difficulty and layout values are defined here. No magic numbers elsewhere in the codebase.

| Constant | Default | Description |
|---|---|---|
| `fruitSpeedInitial` | 185 px/s | Starting fall speed |
| `fruitSpeedMax` | 420 px/s | Maximum fall speed ceiling |
| `fruitSpeedPerBurn` | 2.5 px/s | Speed increase per successful burn |
| `spawnIntervalInitial` | 1.6 s | Time between fruit spawns |
| `spawnIntervalMin` | 0.45 s | Minimum spawn interval (floor) |
| `flamethrowerDuration` | 0.30 s | Flame animation length after tap |
| `flamethrowerYFraction` | 0.85 | Impact zone Y position (fraction from top) |
| `flamethrowerImpactHalfHeight` | 55 px | Half-height of the impact zone band |
| `flamethrowerCoreHeight` | 14 px | Core flame beam height |
| `pointsPerBurn` | 10 | Points awarded per correct burn |
| `startingLives` | 3 | Lives at game start |
| `leaderboardMaxEntries` | 10 | Max entries retained in local leaderboard |
| `laneBgOpacity` | 0.55 | Lane background tint opacity |
| `burnParticleCount` | 14 | Particles emitted on burn |

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

### Launcher Icon (re-generate after icon change)
```bash
dart run flutter_launcher_icons
```

---

## 12. Testing Strategy

- Tests live in `/test/`.
- Run with `flutter test`.
- Coverage focus areas:
  - `score_manager`: points accumulation, persistence read/write.
  - `life_manager`: life decrement, game-over stream emission.
  - `fruit_spawner`: speed clamping, acceleration logic.
  - `home_screen`: widget rendering, lane selection, navigation.

---

## 13. Known Constraints & Future Considerations

| Area | Note |
|---|---|
| iOS | Not currently targeted; project is Android-only. |
| Audio assets | Placeholder files are in place; real audio files must be added separately. |
| `temp_flutter_sample/` | Contains reference sample code; should be removed before production release. |
| Online leaderboard | Not in scope; all scores are stored locally. |
| Accessibility | No current a11y requirements defined; consider for future versions. |
| Spawn difficulty | Spawn interval is currently fixed; adaptive interval reduction may be added later. |

