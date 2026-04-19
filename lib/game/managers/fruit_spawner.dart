import 'dart:math';
import 'package:flame/components.dart';
import '../../constants.dart';
import '../components/fruit.dart';
import '../blazing_game.dart';

class FruitSpawner {
  final BlazingGame game;
  final int laneCount;

  // ── Wave state ─────────────────────────────────────────────────────────────
  int _wave = 1;
  int _fruitsSpawnedThisWave = 0;

  double _fruitSpeed = fruitSpeedInitial;
  double _spawnInterval = spawnIntervalInitial;
  double _elapsed = 0;

  final _rng = Random();

  FruitSpawner({required this.game, required this.laneCount});

  int get wave => _wave;
  double get currentFruitSpeed => _fruitSpeed;

  void update(double dt) {
    _elapsed += dt;
    if (_elapsed >= _spawnInterval) {
      _elapsed -= _spawnInterval; // subtract rather than reset — no drift
      _spawnFruit();
    }
  }

  void _spawnFruit() {
    final laneIndex = _rng.nextInt(laneCount);

    // 60% chance fruit is wrong-color (must be burned)
    int colorIndex;
    if (_rng.nextDouble() < 0.60) {
      // Pick any color that is NOT the lane color
      // Build list of valid wrong-color indices (capped to available colors)
      final available = List.generate(laneColors.length, (i) => i)
          .where((i) => i != laneIndex)
          .toList();
      colorIndex = available.isEmpty ? 0 : available[_rng.nextInt(available.length)];
    } else {
      colorIndex = laneIndex; // matching — safe to let through
    }

    final laneWidth = game.size.x / laneCount;
    final x = laneIndex * laneWidth + laneWidth / 2 - fruitSize / 2;

    final fruit = FruitComponent(
      colorIndex: colorIndex,
      laneIndex: laneIndex,
      speed: _fruitSpeed,
      fruitVariant: _rng.nextInt(laneFruitEmojis[colorIndex].length),
    )..position = Vector2(x, -fruitSize);

    game.add(fruit);

    _fruitsSpawnedThisWave++;
    if (_fruitsSpawnedThisWave >= fruitsPerWave) {
      _incrementWave();
    }
  }

  void _incrementWave() {
    _wave++;
    _fruitsSpawnedThisWave = 0;
    _fruitSpeed = (_fruitSpeed + fruitSpeedIncrement).clamp(0, fruitSpeedMax);
    _spawnInterval =
        (_spawnInterval - spawnIntervalDecrement).clamp(spawnIntervalMin, double.infinity);
  }

  void reset() {
    _wave = 1;
    _fruitsSpawnedThisWave = 0;
    _fruitSpeed = fruitSpeedInitial;
    _spawnInterval = spawnIntervalInitial;
    _elapsed = 0;
  }
}
