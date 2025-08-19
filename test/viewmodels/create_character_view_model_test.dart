import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

import 'package:coc_sheet/models/occupation.dart';
import 'package:coc_sheet/models/classic_rules.dart' show AttrKey;
import 'package:coc_sheet/viewmodels/create_character_view_model.dart';

/// Helpers that replicate the VM’s dice usage exactly.
/// Keep these in sync with CreateCharacterViewModel.
class _Dice {
  final Random r;
  _Dice(this.r);

  int d6() => r.nextInt(6) + 1;
  int d10() => r.nextInt(10) + 1;
  int roll3d6() => d6() + d6() + d6();
  int roll2d6() => d6() + d6();

  int roll3d6x5() => roll3d6() * 5;
  int roll2d6p6x5() => ((roll2d6() + 6) * 5);
}

Map<String, int> _expectedInitialAttributes(Random seeded) {
  final d = _Dice(seeded);
  return {
    AttrKey.str: d.roll3d6x5(),
    AttrKey.con: d.roll3d6x5(),
    AttrKey.dex: d.roll3d6x5(),
    AttrKey.app: d.roll3d6x5(),
    AttrKey.pow: d.roll3d6x5(),
    AttrKey.siz: d.roll2d6p6x5(),
    AttrKey.intg: d.roll2d6p6x5(),
    AttrKey.edu: d.roll2d6p6x5(),
  };
}

int _expectedInitialLuck(Random seeded) {
  final d = _Dice(seeded);
  // consume the same 8 attributes as in _expectedInitialAttributes
  d.roll3d6x5(); // STR
  d.roll3d6x5(); // CON
  d.roll3d6x5(); // DEX
  d.roll3d6x5(); // APP
  d.roll3d6x5(); // POW
  d.roll2d6p6x5(); // SIZ
  d.roll2d6p6x5(); // INT
  d.roll2d6p6x5(); // EDU
  return d.roll3d6x5(); // LUCK
}

int _calcHP(int con, int siz) => ((con + siz) / 10).floor();
int _calcMP(int pow) => (pow / 5).floor();
int _calcSanity(int pow) => pow.clamp(0, 99);

int _calcMoveFromBase({required int str, required int dex, required int siz, required int age}) {
  final strBase = (str / 5).floor();
  final dexBase = (dex / 5).floor();
  final sizBase = (siz / 5).floor();

  int move;
  if (dexBase < sizBase && strBase < sizBase) {
    move = 7;
  } else if (dexBase > sizBase && strBase > sizBase) {
    move = 9;
  } else {
    move = 8;
  }

  if (age >= 40 && age <= 49) {
    move -= 1;
  } else if (age >= 50 && age <= 59) {
    move -= 2;
  } else if (age >= 60) {
    move -= 3;
  }
  return max(1, min(12, move));
}

DamageBonus _calcDB(int strPlusSiz) {
  final totalBase = (strPlusSiz / 5).floor();
  if (totalBase <= 64) return const DamageBonus('-2', -2);
  if (totalBase <= 84) return const DamageBonus('-1', -1);
  if (totalBase <= 124) return const DamageBonus('0', 0);
  if (totalBase <= 164) return const DamageBonus('+1D4', 1);
  if (totalBase <= 204) return const DamageBonus('+1D6', 2);
  return const DamageBonus('+2D6', 3);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CreateCharacterViewModel - deterministic rolls & derived', () {
    test('initial roll matches seeded RNG and derived stats are correct', () {
      // Arrange: two RNGs with the same seed
      const seed = 12345;
      final vm = CreateCharacterViewModel(rng: Random(seed));
      final mirror = Random(seed);

      final expectedAttrs = _expectedInitialAttributes(mirror);
      final expectedLuck = _expectedInitialLuck(Random(seed));

      // Assert attributes & luck
      expect(vm.attributes, equals(expectedAttrs));
      expect(vm.luck, equals(expectedLuck));

      // Derived expectations from attributes
      final hp = _calcHP(expectedAttrs[AttrKey.con]!, expectedAttrs[AttrKey.siz]!);
      final mp = _calcMP(expectedAttrs[AttrKey.pow]!);
      final sanity = _calcSanity(expectedAttrs[AttrKey.pow]!);
      final move = _calcMoveFromBase(
        str: expectedAttrs[AttrKey.str]!,
        dex: expectedAttrs[AttrKey.dex]!,
        siz: expectedAttrs[AttrKey.siz]!,
        age: vm.age, // default 20
      );
      final db = _calcDB(expectedAttrs[AttrKey.str]! + expectedAttrs[AttrKey.siz]!);

      expect(vm.hp, hp);
      expect(vm.mp, mp);
      expect(vm.sanity, sanity);
      expect(vm.move, move);
      expect(vm.damageBonus.db, db.db);
      expect(vm.damageBonus.build, db.build);

      // Pools
      expect(vm.occupationPoints, expectedAttrs[AttrKey.edu]! * 4);
      expect(vm.personalPoints, expectedAttrs[AttrKey.intg]! * 2);
    });

    test('teen age (17): Luck advantage applied and EDU reduced by 5', () {
      // Arrange
      const seed = 424242;
      final vm = CreateCharacterViewModel(rng: Random(seed));
      final mirror = Random(seed);

      // Compute pre-age attributes and luck consumption count (24 d6 for rollAll)
      final expectedAttrsBefore = _expectedInitialAttributes(mirror);

      // Advance mirror RNG through initial LUCK roll (3d6×5)
      final _ = _expectedInitialLuck(Random(seed)); // not used further; just to document flow

      // Now compute teen advantage luck: consume two 3d6 rolls next.
      final advRng = Random(seed);
      final d = _Dice(advRng);
      // consume initial 8 attributes (24 d6 calls) + luck (3 d6 calls)
      _expectedInitialAttributes(advRng);
      _expectedInitialLuck(advRng);

      final a = d.roll3d6x5();
      final b = d.roll3d6x5();
      final expectedTeenLuck = max(a, b);

      // Act
      vm.setAge(17);

      // Assert
      expect(vm.age, 17);
      expect(vm.luck, expectedTeenLuck);

      final expectedEduAfter = max(5, expectedAttrsBefore[AttrKey.edu]! - 5);
      expect(vm.attributes[AttrKey.edu], expectedEduAfter);

      // Non-teen attributes should be unchanged in this scoped pass
      expect(vm.attributes[AttrKey.str], expectedAttrsBefore[AttrKey.str]);
      expect(vm.attributes[AttrKey.intg], expectedAttrsBefore[AttrKey.intg]);

      // Pools recomputed from adjusted EDU/INT
      expect(vm.occupationPoints, vm.attributes[AttrKey.edu]! * 4);
      expect(vm.personalPoints, vm.attributes[AttrKey.intg]! * 2);
    });
  });

  group('CreateCharacterViewModel - occupation & skills', () {
    test('selectOccupation seeds mandatory; setOccupationSkills clamps and validates isReadyToCreate', () {
      final vm = CreateCharacterViewModel(rng: Random(7));

      final occ = const Occupation(
        id: 'police-detective',
        name: 'Police Detective',
        creditMin: 20,
        creditMax: 50,
        selectCount: 4,
        mandatorySkills: ['Law', 'Psychology'],
        skillPool: ['Listen', 'Spot Hidden', 'Drive Auto', 'First Aid'],
      );

      // Initially not ready (no name / no occupation)
      expect(vm.isReadyToCreate, isFalse);

      // Select occupation -> mandatory preselected
      vm.selectOccupation(occ);
      expect(vm.occupation, isNotNull);
      expect(vm.selectedSkills.contains('Law'), isTrue);
      expect(vm.selectedSkills.contains('Psychology'), isTrue);
      expect(vm.selectedSkills.length, 2);

      // Still not ready (no name, not enough skills)
      expect(vm.isReadyToCreate, isFalse);

      // Set name
      vm.setName('Jane Doe');
      expect(vm.name, 'Jane Doe');

      // Add two legal optional skills to reach selectCount = 4
      vm.setOccupationSkills({'Law', 'Psychology', 'Listen', 'Spot Hidden'});
      expect(vm.selectedSkills.length, 4);
      expect(vm.selectedSkills.containsAll(['Law', 'Psychology', 'Listen', 'Spot Hidden']), isTrue);

      // Now should be ready
      expect(vm.isReadyToCreate, isTrue);

      // Provide over-selection; VM should clamp back to selectCount while keeping mandatory
      vm.setOccupationSkills({'Law', 'Psychology', 'Listen', 'Spot Hidden', 'Drive Auto', 'First Aid'});
      expect(vm.selectedSkills.length, occ.selectCount);
      expect(vm.selectedSkills.contains('Law'), isTrue);
      expect(vm.selectedSkills.contains('Psychology'), isTrue);
      // The two extras should be a subset from the pool (order-dependent due to clamping rule)
      final nonMandatory = vm.selectedSkills.where((s) => !occ.mandatorySkills.contains(s)).toList();
      expect(nonMandatory.length, 2);
      for (final s in nonMandatory) {
        expect(occ.skillPool.contains(s), isTrue);
      }

      // Illegal skills should be ignored
      vm.setOccupationSkills({'Law', 'Psychology', 'Bogus Skill'});
      expect(vm.selectedSkills.contains('Bogus Skill'), isFalse);
      expect(vm.selectedSkills.containsAll(['Law', 'Psychology']), isTrue);
      // Not enough total -> not ready
      expect(vm.isReadyToCreate, isFalse);
    });
  });
}
