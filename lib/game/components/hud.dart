import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../managers/score_manager.dart';
import '../managers/life_manager.dart';
import '../blazing_game.dart';

class HudComponent extends Component with HasGameRef<BlazingGame> {
  final ScoreManager scoreManager;
  final LifeManager lifeManager;

  int _score = 0;
  int _lives = startingLives;

  late StreamSubscription<int> _scoreSub;
  late StreamSubscription<int> _livesSub;

  HudComponent({required this.scoreManager, required this.lifeManager});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _score = scoreManager.score;
    _lives = lifeManager.lives;

    _scoreSub = scoreManager.scoreStream.listen((s) => _score = s);
    _livesSub = lifeManager.livesStream.listen((l) => _lives = l);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final sw = gameRef.size.x;

    // ── HUD background bar ─────────────────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, sw, 80),
      Paint()..color = const Color(0xDD000000),
    );

    // ── Lives — top left ─────────────────────────────────────────────────────
    for (int i = 0; i < startingLives; i++) {
      _drawHeart(canvas, Offset(12 + i * 30.0, 40), i < _lives);
    }

    // ── Score — top centre ─────────────────────────────────────────────────
    _drawText(
      canvas,
      text: _score.toString().padLeft(6, '0'),
      offset: Offset(sw / 2, 40),
      fontSize: 22,
      align: TextAlign.center,
      bold: true,
    );
  }

  void _drawHeart(Canvas canvas, Offset topLeft, bool filled) {
    // Use emoji — no unused Paint variable
    final tp = TextPainter(
      text: TextSpan(
        text: filled ? '❤️' : '🤍',
        style: const TextStyle(fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, topLeft);
  }

  void _drawText(
    Canvas canvas, {
    required String text,
    required Offset offset,
    required double fontSize,
    TextAlign align = TextAlign.left,
    Color color = hudTextColor,
    bool bold = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          fontFamily: 'monospace',
          letterSpacing: 1.2,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();

    double dx = offset.dx;
    if (align == TextAlign.center) dx -= tp.width / 2;
    if (align == TextAlign.right) dx -= tp.width;

    tp.paint(canvas, Offset(dx, offset.dy));
  }

  @override
  void onRemove() {
    _scoreSub.cancel();
    _livesSub.cancel();
    super.onRemove();
  }
}
