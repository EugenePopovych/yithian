import 'package:flutter_test/flutter_test.dart';

import 'package:coc_sheet/models/character.dart';
import 'package:coc_sheet/models/sheet_status.dart';
import 'package:coc_sheet/models/creation_rule_set.dart';
import 'package:coc_sheet/models/attribute.dart';
import 'package:coc_sheet/models/skill.dart';
import 'package:coc_sheet/models/classic_creation_rule_set.dart'; // adjust import path if different

void main() {
  Character _emptyCharacter() => Character(
        sheetId: 't1',
        sheetStatus: SheetStatus.draft_classic,
        sheetName: 'Test',
        name: '',
        age: 0,
        pronouns: '',
        birthplace: '',
        occupation: '',
        residence: '',
        currentHP: 0,
        maxHP: 0,
        currentSanity: 0,
        startingSanity: 0,
        currentMP: 0,
        startingMP: 0,
        currentLuck: 0,
        attributes: <Attribute>[],
        skills: <Skill>[],
      );

  int _attr(Character c, String name) =>
      c.attributes.firstWhere((a) => a.name == name).base;

  int _skill(Character c, String name) =>
      c.skills.firstWhere((s) => s.name == name).base;

  late ClassicCreationRuleSet rules;
  late Character character;

  setUp(() {
    character = _emptyCharacter();
    rules = ClassicCreationRuleSet();
    rules.bind(character);
    rules.onEnter();
    rules.initialize(); // drives full seeding + rolling + pools
  });

  test('initialize seeds all core attributes in expected ranges', () {
    // Attribute presence
    final names = character.attributes.map((a) => a.name).toSet();
    expect(
      names.containsAll({
        'Strength',
        'Constitution',
        'Dexterity',
        'Appearance',
        'Power',
        'Size',
        'Intelligence',
        'Education',
      }),
      isTrue,
    );

    // Ranges: 3d6×5 → 15..90 ; (2d6+6)×5 → 40..90
    for (final n in ['Strength', 'Constitution', 'Dexterity', 'Appearance', 'Power']) {
      final v = _attr(character, n);
      expect(v, inInclusiveRange(15, 90), reason: '$n out of 3d6x5 range');
    }
    for (final n in ['Size', 'Intelligence', 'Education']) {
      final v = _attr(character, n);
      expect(v, inInclusiveRange(40, 90), reason: '$n out of 2d6+6 x5 range');
    }
  });

  test('initialize computes derived stats from rolled attributes', () {
    final con = _attr(character, 'Constitution');
    final siz = _attr(character, 'Size');
    final pow = _attr(character, 'Power');

    final expectedHP = ((con + siz) / 10).floor();
    final expectedMP = (pow / 5).floor();
    final expectedSan = pow; // maxSanity is 99 - CM (CM base=0), so pow≤90 fits.

    expect(character.maxHP, expectedHP);
    expect(character.currentHP, expectedHP);
    expect(character.startingMP, expectedMP);
    expect(character.currentMP, expectedMP);
    expect(character.startingSanity, expectedSan);
    expect(character.currentSanity, expectedSan);
  });

  test('classic skills are seeded with correct base values', () {
    // A few fixed-base checks
    expect(_skill(character, 'First Aid'), 30);
    expect(_skill(character, 'Spot Hidden'), 25);
    expect(_skill(character, 'Stealth'), 20);
    expect(_skill(character, 'Occult'), 5);
    expect(_skill(character, 'Credit Rating'), 0);
    expect(_skill(character, 'Cthulhu Mythos'), 0);
    expect(_skill(character, 'Science (Any)'), 1);
    expect(_skill(character, 'Pilot (Any)'), 1);

    // Dynamic bases
    final dex = _attr(character, 'Dexterity');
    final edu = _attr(character, 'Education');
    expect(_skill(character, 'Dodge'), (dex / 2).floor());
    expect(_skill(character, 'Language (Own)'), edu);
  });

  test('Cthulhu Mythos cannot be increased via update()', () {
    final res = rules.update(CreationChange.skill('Cthulhu Mythos', 10));
    expect(res.applied, isFalse);
    expect(res.messages, contains('forbidden_cthulhu_mythos'));
    // Base value remains 0
    expect(_skill(character, 'Cthulhu Mythos'), 0);
  });

  test('attribute clamping is enforced via update()', () {
    // Strength (3d6×5) max 90
    final r1 = rules.update(CreationChange.attribute('Strength', 200));
    expect(r1.applied, isTrue);
    expect(r1.effectiveValue, 90);

    // Size (2d6+6)×5 min 40
    final r2 = rules.update(CreationChange.attribute('Size', 5));
    expect(r2.applied, isTrue);
    expect(r2.effectiveValue, 40);
  });

  test('skill point pools are initialized from EDU and INT', () {
    final edu = _attr(character, 'Education');
    final intel = _attr(character, 'Intelligence');

    // Assuming classic 7e: Occupation = EDU*4, Personal = INT*2
    final expectedOcc = edu * 4;
    final expectedPers = intel * 2;

    // No points have been spent during seeding, so remaining == total
    expect(rules.occupationPointsRemaining, expectedOcc);
    expect(rules.personalPointsRemaining, expectedPers);
  });
}
