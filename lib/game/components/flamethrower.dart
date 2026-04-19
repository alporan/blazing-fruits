import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../blazing_game.dart';
import 'fruit.dart';

class FlamethrowerComponent extends PositionComponent
    with HasGameRef<BlazingGame> {
  final int laneIndex;

  double _opacity = 0;
  double _timer = 0;
  bool _firing = false;

  FlamethrowerComponent({required this.laneIndex});

  Color get _laneColor => laneColors[laneIndex];

  /// Y position of the flame in local (lane-relative) coords.
  double get _flameLocalY => size.y * flamethrowerYFraction;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Size is set by LaneComponent after mounting.
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  void fire() {
    _firing = true;
    _timer = 0;
    _hitFruitsInZone();
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);
    if (!_firing) return;

    _timer += dt;
    final progress = (_timer / flamethrowerDuration).clamp(0.0, 1.0);
    // Triangle envelope: 0→1→0
    _opacity = progress < 0.5 ? progress * 2 : (1.0 - progress) * 2;

    if (_timer >= flamethrowerDuration) {
      _firing = false;
      _opacity = 0;
      _timer = 0;
    }
  }

  // ── Render ─────────────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final flameY = _flameLocalY;

    _drawImpactZone(canvas, flameY);
    _drawNozzle(canvas, flameY);

    if (_firing && _opacity > 0) {
      _drawFlame(canvas, flameY, _opacity);
    }
  }

  void _drawImpactZone(Canvas canvas, double flameY) {
    final top = flameY - flamethrowerImpactHalfHeight;
    final bot = flameY + flamethrowerImpactHalfHeight;

    // Semi-transparent fill
    canvas.drawRect(
      Rect.fromLTWH(0, top, size.x, bot - top),
      Paint()..color = _laneColor.withOpacity(0.10),
    );

    // Dashed border lines
    final borderPaint = Paint()
      ..color = _laneColor.withOpacity(0.45)
      ..strokeWidth = 1.5;
    const dashLen = 8.0;
    const gapLen = 5.0;
    double x = 0;
    while (x < size.x) {
      final end = (x + dashLen).clamp(0.0, size.x);
      canvas.drawLine(Offset(x, top), Offset(end, top), borderPaint);
      canvas.drawLine(Offset(x, bot), Offset(end, bot), borderPaint);
      x += dashLen + gapLen;
    }

    final arrowPaint = Paint()..color = _laneColor.withOpacity(0.50);

    // Left arrow → pointing right (inward)
    final lPath = Path()
      ..moveTo(18, flameY)
      ..lineTo(6, flameY - 7)
      ..lineTo(6, flameY + 7)
      ..close();
    canvas.drawPath(lPath, arrowPaint);

    // Right arrow ← pointing left (inward)
    final rPath = Path()
      ..moveTo(size.x - 18, flameY)
      ..lineTo(size.x - 6, flameY - 7)
      ..lineTo(size.x - 6, flameY + 7)
      ..close();
    canvas.drawPath(rPath, arrowPaint);
  }

  // Nozzle dimensions — 50% of original (was 26×20)
  static const double _nW = 13.0;
  static const double _nH = 10.0;
  static const double _tipLen = 5.0;

  void _drawNozzle(Canvas canvas, double flameY) {
    final bodyFill = Paint()..color = const Color(0xFF555566);
    final bodyStroke = Paint()
      ..color = _laneColor.withOpacity(0.70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final tipFill = Paint()..color = const Color(0xFF777788);
    final glowFill = Paint()..color = _laneColor.withOpacity(0.85);

    // ── Right nozzle (fires leftward) ──────────────────────────────────
    final rNozzleX = size.x - _nW;
    final rBody = RRect.fromRectAndRadius(
      Rect.fromLTWH(rNozzleX, flameY - _nH / 2, _nW, _nH),
      const Radius.circular(3),
    );
    canvas.drawRRect(rBody, bodyFill);
    canvas.drawRRect(rBody, bodyStroke);
    final rTip = Path()
      ..moveTo(rNozzleX, flameY - _nH / 2 + 2)
      ..lineTo(rNozzleX - _tipLen, flameY)
      ..lineTo(rNozzleX, flameY + _nH / 2 - 2)
      ..close();
    canvas.drawPath(rTip, tipFill);
    canvas.drawCircle(Offset(rNozzleX - _tipLen, flameY), 2.5, glowFill);

    // ── Left nozzle (fires rightward) ──────────────────────────────────
    final lBody = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, flameY - _nH / 2, _nW, _nH),
      const Radius.circular(3),
    );
    canvas.drawRRect(lBody, bodyFill);
    canvas.drawRRect(lBody, bodyStroke);
    final lTip = Path()
      ..moveTo(_nW, flameY - _nH / 2 + 2)
      ..lineTo(_nW + _tipLen, flameY)
      ..lineTo(_nW, flameY + _nH / 2 - 2)
      ..close();
    canvas.drawPath(lTip, tipFill);
    canvas.drawCircle(Offset(_nW + _tipLen, flameY), 2.5, glowFill);
  }

  void _drawFlame(Canvas canvas, double flameY, double opacity) {
    // Tip positions for left (fires right) and right (fires left) nozzles
    final lTipX = _nW + _tipLen; // ~18
    final rTipX = size.x - _nW - _tipLen;
    final centerX = size.x / 2;
    final coreH = flamethrowerCoreHeight;
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.80 * opacity)
      ..strokeWidth = 2.5;

    // ── Left flame: lTipX → centerX ────────────────────────────────────────
    final lGlowRect = Rect.fromLTWH(lTipX, flameY - 24, centerX - lTipX, 48);
    canvas.drawRect(
      lGlowRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            _laneColor.withOpacity(0.45 * opacity),
            _laneColor.withOpacity(0.20 * opacity),
            _laneColor.withOpacity(0),
          ],
          stops: const [0.0, 0.45, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(lGlowRect),
    );
    final lCoreRect =
        Rect.fromLTWH(lTipX, flameY - coreH / 2, centerX - lTipX, coreH);
    canvas.drawRect(
      lCoreRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.55 * opacity),
            _laneColor.withOpacity(0.70 * opacity),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(lCoreRect),
    );
    canvas.drawLine(Offset(lTipX, flameY), Offset(centerX, flameY), linePaint);

    // ── Right flame: centerX → rTipX ───────────────────────────────────────
    final rGlowRect =
        Rect.fromLTWH(centerX, flameY - 24, rTipX - centerX, 48);
    canvas.drawRect(
      rGlowRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            _laneColor.withOpacity(0),
            _laneColor.withOpacity(0.20 * opacity),
            _laneColor.withOpacity(0.45 * opacity),
          ],
          stops: const [0.0, 0.55, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(rGlowRect),
    );
    final rCoreRect =
        Rect.fromLTWH(centerX, flameY - coreH / 2, rTipX - centerX, coreH);
    canvas.drawRect(
      rCoreRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            _laneColor.withOpacity(0.70 * opacity),
            Colors.white.withOpacity(0.55 * opacity),
          ],
          stops: const [0.0, 0.4, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(rCoreRect),
    );
    canvas.drawLine(
        Offset(centerX, flameY), Offset(rTipX, flameY), linePaint);
  }

  // ── Hit detection ──────────────────────────────────────────────────────────

  void _hitFruitsInZone() {
    // Flame Y in world coordinates (lane.position.y == 0 always).
    final worldFlameY = absolutePosition.y + _flameLocalY;
    final zoneTop = worldFlameY - flamethrowerImpactHalfHeight;
    final zoneBot = worldFlameY + flamethrowerImpactHalfHeight;

    final fruits = gameRef.children.whereType<FruitComponent>().toList();
    for (final fruit in fruits) {
      if (fruit.laneIndex != laneIndex) continue;

      final fruitTop = fruit.position.y;
      final fruitBot = fruitTop + fruitSize;
      final inZone = fruitBot >= zoneTop && fruitTop <= zoneBot;
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
