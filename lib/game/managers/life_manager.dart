import 'dart:async';
import '../../constants.dart';

class LifeManager {
  // ── State ──────────────────────────────────────────────────────────────────
  int _lives = startingLives;

  // ── Streams ────────────────────────────────────────────────────────────────
  final _livesController = StreamController<int>.broadcast();
  final _gameOverController = StreamController<void>.broadcast();

  Stream<int> get livesStream => _livesController.stream;
  Stream<void> get gameOverStream => _gameOverController.stream;

  // ── Getters ────────────────────────────────────────────────────────────────
  int get lives => _lives;
  bool get isAlive => _lives > 0;

  // ── Actions ────────────────────────────────────────────────────────────────
  void loseLife() {
    if (_lives <= 0) return;
    _lives--;
    _livesController.add(_lives);
    if (_lives == 0) {
      _gameOverController.add(null);
    }
  }

  void reset() {
    _lives = startingLives;
    _livesController.add(_lives);
  }

  void dispose() {
    _livesController.close();
    _gameOverController.close();
  }
}
