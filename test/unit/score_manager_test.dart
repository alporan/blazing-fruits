import 'package:flutter_test/flutter_test.dart';
import 'package:blazing_fruits/game/managers/score_manager.dart';
import 'package:blazing_fruits/constants.dart';

void main() {
  group('ScoreManager', () {
    late ScoreManager mgr;

    setUp(() => mgr = ScoreManager());
    tearDown(() => mgr.dispose());

    test('starts at zero score', () {
      expect(mgr.score, 0);
    });

    test('addPoints increases score by pointsPerBurn', () {
      mgr.addPoints();
      expect(mgr.score, pointsPerBurn);
    });

    test('addPoints is cumulative', () {
      mgr.addPoints();
      mgr.addPoints();
      expect(mgr.score, pointsPerBurn * 2);
    });

    test('reset clears score to zero', () {
      mgr.addPoints();
      mgr.addPoints();
      mgr.reset();
      expect(mgr.score, 0);
    });

    test('scoreStream emits on addPoints', () async {
      final emitted = <int>[];
      final sub = mgr.scoreStream.listen(emitted.add);
      mgr.addPoints();
      mgr.addPoints();
      await Future.delayed(Duration.zero);
      expect(emitted.length, 2);
      expect(emitted[0], pointsPerBurn);
      expect(emitted[1], pointsPerBurn * 2);
      sub.cancel();
    });

    test('scoreStream emits on reset', () async {
      final emitted = <int>[];
      mgr.addPoints();
      final sub = mgr.scoreStream.listen(emitted.add);
      mgr.reset();
      await Future.delayed(Duration.zero);
      expect(emitted, [0]);
      sub.cancel();
    });

    test('saveScore returns false for zero score', () async {
      final isHigh = await mgr.saveScore();
      expect(isHigh, false);
    });
  });
}
