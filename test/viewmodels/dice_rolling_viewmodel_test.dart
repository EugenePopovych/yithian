import 'package:flutter_test/flutter_test.dart';
import 'package:coc_sheet/viewmodels/dice_rolling_viewmodel.dart';

void main() {
  group('DiceRollingViewModel — configuration & basics', () {
    test('initial state is adHoc with empty pool, zero bonus/penalty', () {
      final vm = DiceRollingViewModel();
      expect(vm.mode, DiceMode.adHoc);
      expect(vm.hasSkillContext, isFalse);
      expect(vm.dicePool, isEmpty);
      expect(vm.bonusDice, 0);
      expect(vm.penaltyDice, 0);
      expect(vm.lastAdHocResult, isNull);
      expect(vm.lastD100Result, isNull);
    });

    test('add/remove/clear dice pool works', () {
      final vm = DiceRollingViewModel();
      vm.addDie(DieType.d6);
      expect(vm.dicePool[DieType.d6], 1);

      vm.addDie(DieType.d6, 2);
      expect(vm.dicePool[DieType.d6], 3);

      vm.removeDie(DieType.d6);
      expect(vm.dicePool[DieType.d6], 2);

      vm.removeDie(DieType.d6, 2);
      expect(vm.dicePool.containsKey(DieType.d6), isFalse);

      vm.addDie(DieType.d8, 5);
      expect(vm.dicePool[DieType.d8], 5);
      vm.clearDice();
      expect(vm.dicePool, isEmpty);
    });

    test('bonus/penalty clamped to [0, 10]', () {
      final vm = DiceRollingViewModel();
      vm.setBonusDice(12);
      vm.setPenaltyDice(-7);
      expect(vm.bonusDice, 10);
      expect(vm.penaltyDice, 0);
    });
  });

  group('d100 rolls — bonus/penalty cancellation & bounds', () {
    test('plain d100 roll returns 1..100', () {
      final vm = DiceRollingViewModel();
      vm.setMode(DiceMode.plainD100);
      final r = vm.rollD100().breakdown;
      expect(r.value, inInclusiveRange(1, 100));
      // No bonus/penalty by default.
      expect(r.netBonusCount, 0);
      expect(r.netPenaltyCount, 0);
      // Base tens + 0 extra candidates.
      expect(r.tensCandidates.length, 1);
      expect(r.chosenTensDigit, inInclusiveRange(0, 9));
      expect(r.onesDigit, inInclusiveRange(0, 9));
    });

    test('bonus and penalty cancel each other for d100', () {
      final vm = DiceRollingViewModel();
      vm.setMode(DiceMode.plainD100);

      vm.setBonusDice(2);
      vm.setPenaltyDice(1);
      final r1 = vm.rollD100().breakdown;
      expect(r1.netBonusCount, 1);
      expect(r1.netPenaltyCount, 0);
      // Base tens + 1 extra candidate due to net bonus.
      expect(r1.tensCandidates.length, 2);
      expect(r1.value, inInclusiveRange(1, 100));

      vm.setBonusDice(0);
      vm.setPenaltyDice(3);
      final r2 = vm.rollD100().breakdown;
      expect(r2.netBonusCount, 0);
      expect(r2.netPenaltyCount, 3);
      // Base tens + 3 extra candidates due to net penalty.
      expect(r2.tensCandidates.length, 4);
      expect(r2.value, inInclusiveRange(1, 100));
    });

    test('skill context can be set and used in skillD100 mode', () {
      final vm = DiceRollingViewModel();
      vm.setSkillContext(const SkillContext(
        skillName: 'Spot Hidden',
        target: 60,
        hard: 30,
        extreme: 12,
      ));
      expect(vm.mode, DiceMode.skillD100);
      expect(vm.hasSkillContext, isTrue);

      final r = vm.rollD100().breakdown;
      expect(r.value, inInclusiveRange(1, 100));
    });
  });

  group('Ad-hoc multi-dice rolling — pool and totals', () {
    test('rolling empty pool returns total 0 and no details', () {
      final vm = DiceRollingViewModel();
      final res = vm.rollAdHoc();
      expect(res.details, isEmpty);
      expect(res.total, 0);
    });

    test('2×d6 + 1×d8 produces correct counts and ranges', () {
      final vm = DiceRollingViewModel();
      vm.addDie(DieType.d6, 2);
      vm.addDie(DieType.d8, 1);

      final res = vm.rollAdHoc();
      expect(res.details.length, 2);

      final d6 = res.details.firstWhere((d) => d.type == DieType.d6);
      final d8 = res.details.firstWhere((d) => d.type == DieType.d8);

      expect(d6.rolls.length, 2);
      for (final v in d6.rolls) {
        expect(v, inInclusiveRange(1, 6));
      }

      expect(d8.rolls.length, 1);
      for (final v in d8.rolls) {
        expect(v, inInclusiveRange(1, 8));
      }

      final computedTotal = res.details.fold<int>(0, (s, d) => s + d.subtotal);
      expect(res.total, computedTotal);
    });

    test('d100 inside ad-hoc uses bonus/penalty cancellation and stays in 1..100', () {
      final vm = DiceRollingViewModel();
      vm.addDie(DieType.d100, 3);
      vm.addDie(DieType.d4, 2);
      vm.setBonusDice(2);
      vm.setPenaltyDice(1);

      final res = vm.rollAdHoc();

      // Find entries
      final d100 = res.details.firstWhere((d) => d.type == DieType.d100);
      final d4 = res.details.firstWhere((d) => d.type == DieType.d4);

      // We can only verify ranges here (RNG is non-deterministic).
      expect(d100.rolls.length, 3);
      for (final v in d100.rolls) {
        expect(v, inInclusiveRange(1, 100));
      }

      expect(d4.rolls.length, 2);
      for (final v in d4.rolls) {
        expect(v, inInclusiveRange(1, 4));
      }

      // Totals should match sum of subtotals.
      final computedTotal = res.details.fold<int>(0, (s, d) => s + d.subtotal);
      expect(res.total, computedTotal);
    });

    test('resetResults clears cached results but not the pool', () {
      final vm = DiceRollingViewModel();
      vm.addDie(DieType.d6, 1);
      vm.rollAdHoc();
      expect(vm.lastAdHocResult, isNotNull);

      vm.setMode(DiceMode.plainD100);
      vm.rollD100();
      expect(vm.lastD100Result, isNotNull);

      vm.resetResults();
      expect(vm.lastAdHocResult, isNull);
      expect(vm.lastD100Result, isNull);
      // Pool remains unchanged.
      expect(vm.dicePool[DieType.d6], 1);
    });
  });
}
