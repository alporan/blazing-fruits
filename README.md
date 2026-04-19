# Blazing Fruits 🔥

Arcade reflex game built with Flutter + Flame. Tap a lane to fire its flamethrower and burn fruits whose color doesn't match the lane — before they reach the impact zone.

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

- Colored fruits fall down **green**, **yellow**, and **red** lanes
- **Tap a lane** to fire its horizontal flamethrowers (one on each side)
- Burn fruits whose color **does NOT match** the lane — including **blue blueberries**, which always must be burned regardless of the lane
- Let matching fruits pass through the impact zone safely
- 3 lives — don't let wrong-color fruits reach the bottom!
- Every successful burn nudges the fruit speed up (up to 420 px/s)

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
│   │   ├── fruit.dart          # Falling fruit + particles (3 variants per color)
│   │   ├── flamethrower.dart   # Horizontal flame beam + hit detection
│   │   └── hud.dart            # Score / lives display
│   ├── managers/
│   │   ├── score_manager.dart  # Points + local persistence
│   │   ├── life_manager.dart   # Lives + game-over stream
│   │   └── fruit_spawner.dart  # Spawn timing + per-burn acceleration
│   └── overlays/
│       ├── pause_overlay.dart
│       └── game_over_overlay.dart
└── screens/
    ├── home_screen.dart        # Lane picker + play/leaderboard
    └── leaderboard_screen.dart # Top 10 local scores
```

## Fruit Colors & Lane Matching

| Color | Lane | Fruits | Rule |
|-------|------|--------|------|
| 🟢 Green | Lane 0 | 🍏 🍐 🥝 | Burn if in any other lane |
| 🟡 Yellow | Lane 1 | 🍋 🍌 🌽 | Burn if in any other lane |
| 🔴 Red | Lane 2 | 🍎 🍓 🍒 | Burn if in any other lane |
| 🔵 Blue | — | 🫐 🫐 🫐 | **Always burn** (no matching lane) |

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

| Constant | Value | Effect |
|----------|-------|--------|
| `fruitSpeedInitial` | 185 px/s | Starting fall speed |
| `fruitSpeedMax` | 420 px/s | Speed ceiling |
| `fruitSpeedPerBurn` | 2.5 px/s | Speed bump per successful burn |
| `spawnIntervalInitial` | 1.6 s | Starting spawn rate |
| `spawnIntervalMin` | 0.45 s | Fastest spawn rate |
| `flamethrowerYFraction` | 0.85 | Impact zone Y position (fraction from top) |
| `flamethrowerImpactHalfHeight` | 55 px | Impact zone vertical reach |

## Building for Release

```bash
# Android APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Android App Bundle (for Play Store)
flutter build appbundle --release
```

