import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../blazing_game.dart';

class FruitComponent extends PositionComponent with HasGameRef<BlazingGame> {
  final int colorIndex;
  final int laneIndex;
  final double speed;
  final int fruitVariant; // 0–2: selects which emoji within the lane’s fruit set

  bool _burned = false;

  FruitComponent({
    required this.colorIndex,
    required this.laneIndex,
    required this.speed,
    this.fruitVariant = 0,
  }) : super(size: Vector2.all(fruitSize));

  bool get isMatching => colorIndex == laneIndex;
  Color get fruitColor => laneColors[colorIndex];
  String get _emoji => laneFruitEmojis[colorIndex][fruitVariant];

  @override
  void update(double dt) {
    super.update(dt);
    if (_burned) return;

    position.y += speed * dt;

    if (position.y > gameRef.size.y + fruitSize) {
      if (!isMatching) {
        // Wrong-color fruit escaped — penalise
        gameRef.lifeManager.loseLife();
        gameRef.playSfxLifeLost();
      }
      // Matching fruit at bottom = correct play, no penalty
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2 - 2;

    // Fill
    canvas.drawCircle(center, radius, Paint()..color = fruitColor);

    // White outline
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Emoji label
    final tp = TextPainter(
      text: TextSpan(
        text: _emoji,
        style: const TextStyle(fontSize: 26),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  void burn() {
    if (_burned) return;
    _burned = true;
    // Capture world position before removal
    final worldCenter = absolutePosition + size / 2;
    _spawnBurnParticles(worldCenter);
    removeFromParent();
  }

  void _spawnBurnParticles(Vector2 worldCenter) {
    final rng = Random();
    final color = fruitColor;

    gameRef.add(
      ParticleSystemComponent(
        position: worldCenter,
        particle: Particle.generate(
          count: burnParticleCount,
          lifespan: burnParticleLifetime,
          generator: (i) {
            final angle =
                (i / burnParticleCount) * 2 * pi + rng.nextDouble() * 0.6;
            final spd = burnParticleSpeed * (0.6 + rng.nextDouble() * 0.8);
            return AcceleratedParticle(
              acceleration: Vector2(0, 80),
              speed: Vector2(cos(angle), sin(angle)) * spd,
              child: CircleParticle(
                radius: 3.5 + rng.nextDouble() * 3,
                paint: Paint()..color = color.withOpacity(0.85),
              ),
            );
          },
        ),
      ),
    );
  }
}
