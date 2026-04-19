import 'package:flutter_test/flutter_test.dart';
import 'package:blazing_fruits/game/managers/score_manager.dart';
import 'package:blazing_fruits/constants.dart';

void main() {
  group('ScoreManager', () {
    late ScoreManager mgr;

    setUp(() => mgr = ScoreManager());
    tearDown(() => mgr.dispose());

    test('starts at zero score and multiplier 1', () {
      expect(mgr.score, 0);
      expect(mgr.combo, 0);
      expect(mgr.comboMultiplier, 1);
    });

    test('addPoints increases score by pointsPerBurn at 1x', () {
      mgr.addPoints();
      expect(mgr.score, pointsPerBurn * 1);
    });

    test('second addPoints gives 1x (combo=2, not yet stepped up)', () {
      mgr.addPoints(); // combo=1 → mult=1
      mgr.addPoints(); // combo=2 → mult=1 (step is 5)
      expect(mgr.score, pointsPerBurn * 2);
    });

    test('multiplier steps up after pointsComboMultiplierStep burns', () {
      for (int i = 0; i < pointsComboMultiplierStep; i++) {
        mgr.addPoints();
      }
      // combo=5 → 1 + 5÷5 = 2x
      expect(mgr.comboMultiplier, 2);
    });

    test('multiplier caps at maxComboMultiplier', () {
      for (int i = 0; i < pointsComboMultiplierStep * (maxComboMultiplier + 10); i++) {
        mgr.addPoints();
      }
      expect(mgr.comboMultiplier, maxComboMultiplier);
    });

    test('resetCombo resets multiplier to 1 and combo to 0', () {
      for (int i = 0; i < pointsComboMultiplierStep; i++) {
        mgr.addPoints();
      }
      expect(mgr.comboMultiplier, 2);
      mgr.resetCombo();
      expect(mgr.comboMultiplier, 1);
      expect(mgr.combo, 0);
    });

    test('reset clears score, combo, and multiplier', () {
      mgr.addPoints();
      mgr.addPoints();
      mgr.reset();
      expect(mgr.score, 0);
      expect(mgr.combo, 0);
      expect(mgr.comboMultiplier, 1);
    });

    test('scoreStream emits on addPoints', () async {
      final emitted = <int>[];
      final sub = mgr.scoreStream.listen(emitted.add);
      mgr.addPoints();
      mgr.addPoints();
      await Future.delayed(Duration.zero);
      expect(emitted.length, 2);
      expect(emitted[0], pointsPerBurn);
      sub.cancel();
    });

    test('comboStream emits on resetCombo', () async {
      final emitted = <int>[];
      final sub = mgr.comboStream.listen(emitted.add);
      mgr.addPoints();
      mgr.resetCombo();
      await Future.delayed(Duration.zero);
      // addPoints emits multiplier, resetCombo emits 1
      expect(emitted.last, 1);
      sub.cancel();
    });

    test('saveScore returns false for zero score', () async {
      // score is still 0 — should not save
      final isHigh = await mgr.saveScore();
      expect(isHigh, false);
    });
  });
}
