import 'package:flutter_test/flutter_test.dart';
import 'package:blazing_fruits/game/managers/life_manager.dart';
import 'package:blazing_fruits/constants.dart';

void main() {
  group('LifeManager', () {
    late LifeManager mgr;

    setUp(() => mgr = LifeManager());
    tearDown(() => mgr.dispose());

    test('starts with startingLives', () {
      expect(mgr.lives, startingLives);
      expect(mgr.isAlive, isTrue);
    });

    test('loseLife decrements lives', () {
      mgr.loseLife();
      expect(mgr.lives, startingLives - 1);
    });

    test('lives cannot go below zero', () {
      for (int i = 0; i <= startingLives + 2; i++) {
        mgr.loseLife();
      }
      expect(mgr.lives, 0);
    });

    test('isAlive is false when lives reach zero', () {
      for (int i = 0; i < startingLives; i++) {
        mgr.loseLife();
      }
      expect(mgr.isAlive, isFalse);
    });

    test('gameOverStream emits when lives hit zero', () async {
      bool fired = false;
      final sub = mgr.gameOverStream.listen((_) => fired = true);

      for (int i = 0; i < startingLives; i++) {
        mgr.loseLife();
      }
      await Future.delayed(Duration.zero);

      expect(fired, isTrue);
      sub.cancel();
    });

    test('gameOverStream does not emit before lives reach zero', () async {
      bool fired = false;
      final sub = mgr.gameOverStream.listen((_) => fired = true);

      mgr.loseLife(); // still has lives left
      await Future.delayed(Duration.zero);

      expect(fired, isFalse);
      sub.cancel();
    });

    test('reset restores lives to startingLives', () {
      mgr.loseLife();
      mgr.loseLife();
      mgr.reset();
      expect(mgr.lives, startingLives);
      expect(mgr.isAlive, isTrue);
    });

    test('livesStream emits on loseLife', () async {
      final emitted = <int>[];
      final sub = mgr.livesStream.listen(emitted.add);
      mgr.loseLife();
      mgr.loseLife();
      await Future.delayed(Duration.zero);
      expect(emitted, [startingLives - 1, startingLives - 2]);
      sub.cancel();
    });
  });
}
