# AGENTS.md — Blazing Fruits

This file provides guidance for AI coding agents (e.g. Claude, Codex, Copilot) working on the **Blazing Fruits** codebase.

> **Specifications reference:** All game rules, component responsibilities, tunable constants, project structure, and build instructions are defined in [`SPEC.md`](./SPEC.md). Read it before making any changes.

---

## 1. Codebase Orientation

- **Language:** Dart
- **Framework:** Flutter + Flame game engine
- **Entry point:** `lib/main.dart` → `lib/app.dart` → `lib/game/blazing_game.dart`
- **All magic numbers live in:** `lib/constants.dart` — never hardcode values elsewhere
- **Tests:** `/test/` — run with `flutter test`

Refer to `SPEC.md §6` for the full annotated project structure.

---

## 2. Ground Rules

1. **Read SPEC.md first.** Before adding, editing, or removing any feature, verify it aligns with the goals and non-goals in `SPEC.md §2`.
2. **No magic numbers.** Any gameplay value (speeds, timings, fractions) must be defined in `lib/constants.dart` and referenced from there. See `SPEC.md §10` for the current constants table.
3. **No backend calls.** This is a fully offline game. Do not introduce network requests, cloud sync, or remote APIs. See `SPEC.md §2` (Non-Goals).
4. **One responsibility per file.** Each component, manager, screen, and overlay has a clearly defined role (see `SPEC.md §7` and `§8`). Do not mix concerns across files.
5. **Do not touch `temp_flutter_sample/`.** This directory contains reference code and must not be imported or depended upon. It should eventually be deleted before release (`SPEC.md §13`).

---

## 3. Working with Game Components

### Adding a new component
- Place it under `lib/game/components/`.
- Mount it inside `blazing_game.dart`.
- If it needs tuning values, add constants to `lib/constants.dart`.

### Adding a new manager
- Place it under `lib/game/managers/`.
- Managers should expose streams or `ValueNotifier`s — never hold direct references to UI widgets.

### Adding a new screen
- Place it under `lib/screens/`.
- Wire navigation from `home_screen.dart` or `blazing_game.dart` as appropriate.

### Adding a new overlay
- Place it under `lib/game/overlays/`.
- Register it with the Flame overlay system in `blazing_game.dart`.

---

## 4. Modifying Difficulty or Game Feel

All difficulty tuning goes through `lib/constants.dart`. Do **not** scatter values across component files. When proposing a difficulty change, reference the constant name and its current default from `SPEC.md §10`.

---

## 5. Audio & Assets

- Audio files belong in `assets/audio/`. Placeholder (empty) files are acceptable — the game degrades gracefully.
- A custom font can be added at `assets/fonts/GameFont.ttf`; enable it by uncommenting the `fonts:` block in `pubspec.yaml`.
- After adding any new asset, run `flutter pub get` to ensure `pubspec.yaml` is up to date.

See `SPEC.md §9` for the full asset list and trigger events.

---

## 6. Testing Expectations

- All logic changes to `score_manager`, `life_manager`, and `fruit_spawner` must be accompanied by or verified against unit tests in `/test/`.
- Key areas to cover (see `SPEC.md §12`):
  - Combo accumulation and 5× multiplier cap
  - Life decrement and game-over stream emission
  - Wave progression and speed/interval clamping
- Run the full suite before considering a task complete:
  ```bash
  flutter test
  ```

---

## 7. Build Verification

Before submitting any change, verify the app compiles:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release   # optional: full release smoke check
```

See `SPEC.md §11` for full build and release instructions.

---

## 8. Out-of-Scope — Do Not Implement

The following are explicitly outside the project's scope. Do not introduce them unless `SPEC.md` is updated first:

- iOS or Web build targets
- Online/remote leaderboards
- In-app purchases or ads
- Server-side logic or cloud persistence
- Accessibility (a11y) features (deferred to a future version)
