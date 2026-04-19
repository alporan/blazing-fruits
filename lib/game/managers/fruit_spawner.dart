import 'dart:math';
import 'package:flame/components.dart';
import '../../constants.dart';
import '../components/fruit.dart';
import '../blazing_game.dart';

class FruitSpawner {
  final BlazingGame game;
  final int laneCount;

  double _fruitSpeed = fruitSpeedInitial;
  double _spawnInterval = spawnIntervalInitial;
  double _elapsed = 0;

  final _rng = Random();

  FruitSpawner({required this.game, required this.laneCount});

  double get currentFruitSpeed => _fruitSpeed;

  /// Called by the game whenever a fruit is successfully burned.
  void accelerate() {
    _fruitSpeed = (_fruitSpeed + fruitSpeedPerBurn).clamp(0, fruitSpeedMax);
  }

  void update(double dt) {
    _elapsed += dt;
    if (_elapsed >= _spawnInterval) {
      _elapsed -= _spawnInterval;
      _spawnFruit();
    }
  }

  void _spawnFruit() {
    final laneIndex = _rng.nextInt(laneCount);

    // 60% chance fruit is wrong-color (must be burned)
    int colorIndex;
    if (_rng.nextDouble() < 0.60) {
      final available = List.generate(laneColors.length, (i) => i)
          .where((i) => i != laneIndex)
          .toList();
      colorIndex = available.isEmpty ? 0 : available[_rng.nextInt(available.length)];
    } else {
      colorIndex = laneIndex;
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
  }

  void reset() {
    _fruitSpeed = fruitSpeedInitial;
    _spawnInterval = spawnIntervalInitial;
    _elapsed = 0;
  }
}
