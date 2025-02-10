import 'package:flutter_test/flutter_test.dart';
import 'package:coc_sheet/models/character.dart';
import 'package:coc_sheet/models/attribute.dart';
import 'package:coc_sheet/models/skill.dart';

void main() {
  group('Attribute Tests', () {
    test('Hard and extreme values should be calculated correctly', () {
      final attr = Attribute(name: "Strength", base: 50);
      expect(attr.hard, equals(25));
      expect(attr.extreme, equals(10));
    });

    test('Base value should update correctly', () {
      final attr = Attribute(name: "Dexterity", base: 40);
      attr.base = 80;
      expect(attr.base, equals(80));
      expect(attr.hard, equals(40));
      expect(attr.extreme, equals(16));
    });

    test('Base value should not be negative', () {
      final attr = Attribute(name: "Constitution", base: -20);
      expect(attr.base, isNonNegative);
    });

    test('Zero base should calculate correctly', () {
      final attr = Attribute(name: "Power", base: 0);
      expect(attr.hard, equals(0));
      expect(attr.extreme, equals(0));
    });
  });

  group('Skill Tests', () {
    test('Skill values should be calculated correctly', () {
      final skill = Skill(name: "Spot Hidden", base: 70, canUpgrade: true);
      expect(skill.hard, equals(35));
      expect(skill.extreme, equals(14));
      expect(skill.canUpgrade, isTrue);
    });

    test('Skill base value should update correctly', () {
      final skill = Skill(name: "Persuade", base: 50);
      skill.base = 90;
      expect(skill.base, equals(90));
      expect(skill.hard, equals(45));
      expect(skill.extreme, equals(18));
    });

    test('Skill base should not be negative', () {
      final skill = Skill(name: "Stealth", base: -10);
      expect(skill.base, isNonNegative);
    });

    test('Zero base should calculate correctly', () {
      final skill = Skill(name: "Fast Talk", base: 0);
      expect(skill.hard, equals(0));
      expect(skill.extreme, equals(0));
    });
  });

  group('Character Tests', () {
    test('Character should update attributes correctly', () {
      final char = Character(
        name: "Investigator",
        attributes: [Attribute(name: "Strength", base: 60)],
        skills: [],
      );

      char.updateAttribute("Strength", 80);
      expect(char.attributes[0].base, equals(80));
      expect(char.attributes[0].hard, equals(40));
      expect(char.attributes[0].extreme, equals(16));
    });

    test('Character should update skills correctly', () {
      final char = Character(
        name: "Investigator",
        attributes: [],
        skills: [Skill(name: "Stealth", base: 50)],
      );

      char.updateSkill("Stealth", 85);
      expect(char.skills[0].base, equals(85));
      expect(char.skills[0].hard, equals(42));
      expect(char.skills[0].extreme, equals(17));
    });

    test('Updating a non-existing attribute should not crash', () {
      final char = Character(name: "Investigator", attributes: [], skills: []);
      char.updateAttribute("Nonexistent", 50);
      expect(char.attributes.isEmpty, isTrue);
    });

    test('Updating a non-existing skill should not crash', () {
      final char = Character(name: "Investigator", attributes: [], skills: []);
      char.updateSkill("Nonexistent", 50);
      expect(char.skills.isEmpty, isTrue);
    });
  });
}
