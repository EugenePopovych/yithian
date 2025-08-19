// test/rules/classic_rules_test.dart
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:coc_sheet/models/classic_rules.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Derived calculators', () {
    test('HP/MP/Sanity basic math', () {
      expect(calcHP(40, 60), 10);
      expect(calcMP(55), 11);
      expect(calcSanity(99), 99);
      expect(calcSanity(-10), 0);
    });

    test('Move & age modifiers', () {
      // STR/DEX > SIZ -> base 9
      final m9 = calcMove(str: 80, dex: 85, siz: 60, age: 25);
      expect(m9, 9);

      // both < SIZ -> base 7; age 55 -> -2 => 5, clamped to >=1
      final m7 = calcMove(str: 50, dex: 45, siz: 80, age: 55);
      expect(m7, 5);
    });

    test('Damage Bonus / Build bands (raw STR+SIZ)', () {
      // -2 band: ≤ 64
      expect(calcDamageBonus(30, 30).db, '-2'); // 60
      expect(calcDamageBonus(32, 32).db,
          '-2'); // 64+? -> use 32+33 = 65 for clarity below

      // -1 band: 65–84
      expect(calcDamageBonus(30, 35).db, '-1'); // 65
      expect(calcDamageBonus(50, 34).db, '-1'); // 84

      // 0 band: 85–124
      expect(calcDamageBonus(50, 35).db, '0'); // 85
      expect(calcDamageBonus(70, 54).db, '0'); // 124

      // +1D4 band: 125–164
      expect(calcDamageBonus(70, 55).db, '+1D4'); // 125
      expect(calcDamageBonus(90, 74).db, '+1D4'); // 164

      // +1D6 band: 165–204
      expect(calcDamageBonus(90, 75).db, '+1D6'); // 165
      expect(calcDamageBonus(99, 105).db, '+1D6'); // 204 (monstrous SIZ)

      // +2D6 (extended): 205–284
      expect(calcDamageBonus(120, 90).db, '+2D6'); // 210
    });
  });

  group('Age adjustments', () {
    test('EDU checks count', () {
      expect(eduChecksForAge(19), 0);
      expect(eduChecksForAge(49), 1);
      expect(eduChecksForAge(59), 2);
      expect(eduChecksForAge(69), 3);
      expect(eduChecksForAge(79), 4);
    });

    test('Teen rule applies EDU -5 and then checks (none for teens)', () {
      final attrs = {
        AttrKey.edu: 60,
        AttrKey.dex: 50,
      };
      final next = applyAgeToAttributes(attrs, age: 17, rng: Random(1));
      expect(next[AttrKey.edu], 55);
      // DEX unchanged in minimal scope
      expect(next[AttrKey.dex], 50);
    });
  });

  group('Skill bases', () {
    test('Dodge = DEX/2, Language (Own) = EDU; includes static bases', () {
      final attrs = {AttrKey.dex: 60, AttrKey.edu: 70};
      final skills = buildBaseSkills(attrs);
      expect(skills['Dodge'], 30);
      expect(skills['Language (Own)'], 70);
      expect(skills['Spot Hidden'], 25);
      expect(skills['Credit Rating'], 0);
    });
  });

  group('Roll helpers', () {
    test('Luck teen advantage takes max of two rolls', () {
      final r = ClassicRolls(Random(123));
      // consume nothing else—just check teen vs adult
      final adult = ClassicRolls(Random(123)).rollLuck(age: 25);
      final teen = r.rollLuck(age: 17);
      expect(teen >= adult, isTrue);
    });
  });
}
