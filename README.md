# Blazing Fruits v2 🔥

Arcade reflex game built with Flutter + Flame. Tap a lane to fire its laser and burn fruits whose color doesn't match the lane — before they reach the bottom.

## Quick Start

```bash
# 1. Install dependencies
flutter pub get

# 2. Launch emulator (or connect a device)
flutter emulators --launch blazing_pixel

# 3. Run
flutter run

# 4. Run tests
flutter test
```

## How to Play

- Colored fruits fall down colored lanes
- **Tap a lane** to fire its laser
- Burn fruits whose color **does NOT match** the lane
- Let matching fruits pass through safely
- 3 lives — don't let wrong-color fruits reach the bottom!
- Combo multiplier builds with consecutive correct burns (up to 5×)
- Speed increases every 10 fruits

## Project Structure

```
lib/
├── constants.dart              # All game tuning values
├── main.dart                   # Entry point
├── app.dart                    # MaterialApp root
├── game/
│   ├── blazing_game.dart       # FlameGame root
│   ├── components/
│   │   ├── lane.dart           # Tappable lane
│   │   ├── fruit.dart          # Falling fruit + particles
│   │   ├── laser.dart          # Beam + hit detection
│   │   └── hud.dart            # Score / lives / wave display
│   ├── managers/
│   │   ├── score_manager.dart  # Points + combo + persistence
│   │   ├── life_manager.dart   # Lives + game-over stream
│   │   └── fruit_spawner.dart  # Spawn timing + wave logic
│   └── overlays/
│       ├── pause_overlay.dart
│       └── game_over_overlay.dart
└── screens/
    ├── home_screen.dart        # Lane picker + play/leaderboard
    └── leaderboard_screen.dart # Top 10 local scores
```

## Adding Audio

Place real `.wav` / `.mp3` files in `assets/audio/`:

| File | Event |
|------|-------|
| `laser.wav` | Lane tap |
| `burn.wav` | Correct fruit burn |
| `life_lost.wav` | Life lost |
| `music_loop.mp3` | Background music (loops) |

Audio degrades gracefully — empty placeholder files are safe.

## Adding a Custom Font

1. Drop a `.ttf` file into `assets/fonts/GameFont.ttf`
2. Uncomment the `fonts:` block in `pubspec.yaml`
3. Run `flutter pub get`

## Tuning the Game

All difficulty values are in `lib/constants.dart`. No magic numbers anywhere else.

Key values to tweak:

| Constant | Default | Effect |
|---|---|---|
| `fruitSpeedInitial` | 180 px/s | Starting speed |
| `fruitSpeedMax` | 420 px/s | Speed ceiling |
| `spawnIntervalInitial` | 1.6 s | Starting spawn rate |
| `spawnIntervalMin` | 0.45 s | Fastest spawn rate |
| `fruitsPerWave` | 10 | Fruits before difficulty step-up |
| `laserZoneFraction` | 0.15 | Bottom % of screen = laser zone |

## Building for Release

```bash
# Android APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Android App Bundle (for Play Store)
flutter build appbundle --release
```
