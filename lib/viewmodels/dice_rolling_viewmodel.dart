import 'dart:math';
import 'package:flutter/foundation.dart';

/// Supported die types. Keep d100 here so ad-hoc pools can include it too.
enum DieType { d3, d4, d6, d8, d10, d12, d20, d100 }

int _sidesOf(DieType t) {
  switch (t) {
    case DieType.d3:
      return 3;
    case DieType.d4:
      return 4;
    case DieType.d6:
      return 6;
    case DieType.d8:
      return 8;
    case DieType.d10:
      return 10;
    case DieType.d12:
      return 12;
    case DieType.d20:
      return 20;
    case DieType.d100:
      return 100;
  }
}

/// UI modes:
/// - skillD100: opened via a skill; show thresholds/evaluation in UI; use d100 with bonus/penalty
/// - plainD100: user chose d100 without a skill; bonus/penalty still apply
/// - adHoc: user builds a pool of multiple dice (can include d100); bonus/penalty affect d100 parts
enum DiceMode { skillD100, plainD100, adHoc }

/// Per-die details for ad-hoc rolls.
class SingleDieRoll {
  final DieType type;
  final List<int> rolls; // for multiple dice of same type in pool
  final int subtotal;

  SingleDieRoll({
    required this.type,
    required this.rolls,
  }) : subtotal = rolls.fold(0, (s, v) => s + v);
}

/// Aggregate result for ad-hoc multi-dice roll.
class DiceRollResult {
  final List<SingleDieRoll> details;
  final int total;

  DiceRollResult({
    required this.details,
  }) : total = details.fold(0, (s, d) => s + d.subtotal);
}

/// Detailed breakdown for a single d100 roll with bonus/penalty dice.
class D100RollBreakdown {
  /// Final value 1..100 after bonus/penalty choice.
  final int value;

  /// Ones digit rolled (0..9), where 0 stands for '0'.
  final int onesDigit;

  /// All tens candidates rolled (including the base tens die).
  /// Each is 0..9, where 0 stands for '00' tens.
  final List<int> tensCandidates;

  /// The chosen tens digit from [tensCandidates].
  final int chosenTensDigit;

  /// Net counts used during the roll (after canceling).
  final int netBonusCount;
  final int netPenaltyCount;

  D100RollBreakdown({
    required this.value,
    required this.onesDigit,
    required this.tensCandidates,
    required this.chosenTensDigit,
    required this.netBonusCount,
    required this.netPenaltyCount,
  });
}

/// Result holder for the last d100 action (skill or plain).
class D100RollResult {
  final D100RollBreakdown breakdown;

  D100RollResult({required this.breakdown});
}

/// Optional context passed when rolling against a Skill.
/// Keep this minimal; evaluation/threshold rendering can stay in UI if you prefer.
class SkillContext {
  final String skillName;
  final int target; // base %
  final int hard;   // usually target / 2
  final int extreme; // usually target / 5

  const SkillContext({
    required this.skillName,
    required this.target,
    required this.hard,
    required this.extreme,
  });
}

class DiceRollingViewModel extends ChangeNotifier {
  DiceMode _mode = DiceMode.adHoc;
  final Random _rng = Random();

  // Skill context is only meaningful in skillD100 mode.
  SkillContext? _skill;

  // Bonus/Penalty counts (apply to d100 rolls in plain + skill + adHoc for the d100 parts).
  int _bonusDice = 0;
  int _penaltyDice = 0;

  // Ad-hoc dice pool. Key = die type, value = count.
  final Map<DieType, int> _dicePool = {
    // Start empty.
  };

  // Results cache (useful for UI to re-render last outcome).
  DiceRollResult? _lastAdHocResult;
  D100RollResult? _lastD100Result;

  /// ---------- Getters ----------
  DiceMode get mode => _mode;
  bool get hasSkillContext => _mode == DiceMode.skillD100 && _skill != null;

  SkillContext? get skillContext => _skill;

  int get bonusDice => _bonusDice;
  int get penaltyDice => _penaltyDice;

  Map<DieType, int> get dicePool => Map.unmodifiable(_dicePool);

  DiceRollResult? get lastAdHocResult => _lastAdHocResult;
  D100RollResult? get lastD100Result => _lastD100Result;

  /// ---------- Setters / Configuration ----------
  void setMode(DiceMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void setSkillContext(SkillContext? ctx) {
    _skill = ctx;
    if (ctx != null) {
      _mode = DiceMode.skillD100;
    }
    notifyListeners();
  }

  /// Ensures the "both set" rule: they can be non-zero simultaneously,
  /// but each penalty die cancels one bonus die at roll time.
  void setBonusDice(int value) {
    _bonusDice = value.clamp(0, 10);
    notifyListeners();
  }

  void setPenaltyDice(int value) {
    _penaltyDice = value.clamp(0, 10);
    notifyListeners();
  }

  void addDie(DieType type, [int count = 1]) {
    if (count <= 0) return;
    _dicePool[type] = (_dicePool[type] ?? 0) + count;
    notifyListeners();
  }

  void removeDie(DieType type, [int count = 1]) {
    if (!_dicePool.containsKey(type) || count <= 0) return;
    final left = (_dicePool[type]! - count);
    if (left <= 0) {
      _dicePool.remove(type);
    } else {
      _dicePool[type] = left;
    }
    notifyListeners();
  }

  void clearDice() {
    _dicePool.clear();
    notifyListeners();
  }

  void resetResults() {
    _lastAdHocResult = null;
    _lastD100Result = null;
    notifyListeners();
  }

  /// ---------- Rolling API ----------

  /// Rolls a single d100 with current bonus/penalty settings.
  /// Used in plainD100 mode and skillD100 mode.
  D100RollResult rollD100() {
    final breakdown = _rollSingleD100WithBonusPenalty(
      bonus: _bonusDice,
      penalty: _penaltyDice,
    );
    final res = D100RollResult(breakdown: breakdown);
    _lastD100Result = res;
    notifyListeners();
    return res;
  }

  /// Rolls the current ad-hoc pool. If the pool contains d100,
  /// bonus/penalty are applied to the d100 part only.
  DiceRollResult rollAdHoc() {
    final details = <SingleDieRoll>[];

    for (final entry in _dicePool.entries) {
      final type = entry.key;
      final count = entry.value;
      if (count <= 0) continue;

      if (type == DieType.d100) {
        // Each d100 in the pool is rolled independently with the SAME bonus/penalty setting.
        final rolls = <int>[];
        for (int i = 0; i < count; i++) {
          final d = _rollSingleD100WithBonusPenalty(
            bonus: _bonusDice,
            penalty: _penaltyDice,
          );
          rolls.add(d.value);
        }
        details.add(SingleDieRoll(type: type, rolls: rolls));
      } else {
        final rolls = <int>[];
        final sides = _sidesOf(type);
        for (int i = 0; i < count; i++) {
          rolls.add(_rollSingle(sides));
        }
        details.add(SingleDieRoll(type: type, rolls: rolls));
      }
    }

    final result = DiceRollResult(details: details);
    _lastAdHocResult = result;
    notifyListeners();
    return result;
  }

  /// ---------- Internals ----------

  int _rollSingle(int sides) {
    // Returns 1..sides inclusive.
    return _rng.nextInt(sides) + 1;
  }

  /// Rolls a CoC-style d100 with bonus/penalty dice:
  /// - Roll one ones die (0..9 where 0 is '0')
  /// - Roll one base tens die (0..9 where 0 is '00')
  /// - Roll extra tens dice equal to net bonus or net penalty (not both):
  ///   * bonus: choose the LOWEST tens digit among candidates
  ///   * penalty: choose the HIGHEST tens digit among candidates
  /// - Combine with ones; 00+0 counts as 100.
  D100RollBreakdown _rollSingleD100WithBonusPenalty({
    required int bonus,
    required int penalty,
  }) {
    // Cancel out as many as possible.
    final cancel = min(bonus, penalty);
    final netBonus = bonus - cancel;
    final netPenalty = penalty - cancel;

    final ones = _rng.nextInt(10); // 0..9
    final tensCandidates = <int>[];

    // base tens die
    tensCandidates.add(_rng.nextInt(10)); // 0..9

    // extra tens dice (all are candidates; selection rule comes later)
    final extraCount = (netBonus > 0) ? netBonus : netPenalty;
    for (int i = 0; i < extraCount; i++) {
      tensCandidates.add(_rng.nextInt(10));
    }

    int chosenTens;
    if (netBonus > 0) {
      chosenTens = tensCandidates.reduce((a, b) => a < b ? a : b);
    } else if (netPenalty > 0) {
      chosenTens = tensCandidates.reduce((a, b) => a > b ? a : b);
    } else {
      chosenTens = tensCandidates.first; // no bonus/penalty
    }

    // Compute final value (1..100).
    int value;
    if (chosenTens == 0 && ones == 0) {
      value = 100;
    } else {
      value = chosenTens * 10 + ones;
    }

    return D100RollBreakdown(
      value: value,
      onesDigit: ones,
      tensCandidates: List.unmodifiable(tensCandidates),
      chosenTensDigit: chosenTens,
      netBonusCount: netBonus,
      netPenaltyCount: netPenalty,
    );
  }
}
