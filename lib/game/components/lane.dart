import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../blazing_game.dart';
import 'laser.dart';

class LaneComponent extends PositionComponent
    with HasGameRef<BlazingGame>, TapCallbacks {
  final int laneIndex;
  final int laneCount;
  late final LaserComponent _laser;

  LaneComponent({
    required this.laneIndex,
    required this.laneCount,
    required Vector2 laneSize,
    required Vector2 lanePosition,
  }) : super(size: laneSize, position: lanePosition);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _laser = LaserComponent(
      laneIndex: laneIndex,
      laneWidth: size.x,
    )..position = Vector2.zero();
    await add(_laser);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Tinted lane background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = laneColors[laneIndex].withOpacity(laneBgOpacity),
    );

    // Right-edge divider (skip last lane)
    if (laneIndex < laneCount - 1) {
      canvas.drawLine(
        Offset(size.x, 0),
        Offset(size.x, size.y),
        Paint()
          ..color = dividerColor
          ..strokeWidth = 1.5,
      );
    }

    // Lane colour indicator bar at the very bottom
    canvas.drawRect(
      Rect.fromLTWH(0, size.y - 8, size.x, 8),
      Paint()..color = laneColors[laneIndex],
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!gameRef.isRunning) return;
    gameRef.playSfxLaser();
    _laser.fire();
  }
}
