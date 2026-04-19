import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../blazing_game.dart';
import 'fruit.dart';

class LaserComponent extends PositionComponent with HasGameRef<BlazingGame> {
  final int laneIndex;
  final double laneWidth;

  double _opacity = 0;
  double _timer = 0;
  bool _firing = false;

  LaserComponent({required this.laneIndex, required this.laneWidth});

  Color get _laserColor => laneColors[laneIndex];

  @override
  void update(double dt) {
    super.update(dt);
    if (!_firing) return;

    _timer += dt;
    final progress = (_timer / laserDuration).clamp(0.0, 1.0);
    // Triangle envelope 0→1→0
    _opacity = progress < 0.5 ? progress * 2 : (1.0 - progress) * 2;

    if (_timer >= laserDuration) {
      _firing = false;
      _opacity = 0;
      _timer = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_opacity <= 0) return;

    final screenH = gameRef.size.y;

    // Glow — full lane width, blurred
    canvas.drawRect(
      Rect.fromLTWH(0, 0, laneWidth, screenH),
      Paint()
        ..color = _laserColor.withOpacity(_opacity * 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Core beam
    final beamX = laneWidth / 2 - laserWidth / 2;
    canvas.drawRect(
      Rect.fromLTWH(beamX, 0, laserWidth, screenH),
      Paint()..color = _laserColor.withOpacity(_opacity * 0.9),
    );

    // Bright centre line
    canvas.drawRect(
      Rect.fromLTWH(beamX + laserWidth / 2 - 2, 0, 4, screenH),
      Paint()..color = Colors.white.withOpacity(_opacity * 0.7),
    );
  }

  void fire() {
    _firing = true;
    _timer = 0;
    _hitFruitsInZone();
  }

  void _hitFruitsInZone() {
    final screenH = gameRef.size.y;
    final zoneTop = screenH * (1 - laserZoneFraction);

    final fruits = gameRef.children.whereType<FruitComponent>().toList();
    for (final fruit in fruits) {
      if (fruit.laneIndex != laneIndex) continue;
      final inZone = (fruit.position.y + fruitSize) >= zoneTop;
      if (!inZone) continue;

      if (!fruit.isMatching) {
        fruit.burn();
        gameRef.scoreManager.addPoints();
        gameRef.playSfxBurn();
      } else {
        fruit.burn();
        gameRef.lifeManager.loseLife();
        gameRef.scoreManager.resetCombo();
        gameRef.playSfxLifeLost();
      }
    }
  }
}
