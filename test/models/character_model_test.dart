import 'package:flutter_test/flutter_test.dart';
import 'package:coc_sheet/models/character.dart';
import 'package:coc_sheet/models/attribute.dart';
import 'package:coc_sheet/models/skill.dart';
import 'package:coc_sheet/models/sheet_status.dart';

void main() {
  group('Character Model Tests', () {
    test('Character should initialize with correct general info', () {
      final character = Character(
        sheetId: 't1',
        sheetStatus: SheetStatus.active,
        sheetName: 'Sheet 1',
        name: "John Doe",
        age: 32,
        pronouns: "He/Him",
        birthplace: "Arkham",
        occupation: "Detective",
        residence: "Arkham, MA",
        currentHP: 10,
        maxHP: 12,
        currentSanity: 40,
        startingSanity: 60,
        currentMP: 8,
        startingMP: 8,
        currentLuck: 50,
        attributes: const [],
        skills: [Skill(name: "Cthulhu Mythos", base: 10)],
      );

      expect(character.name, equals("John Doe"));
      expect(character.age, equals(32));
      expect(character.occupation, equals("Detective"));
      expect(character.maxSanity, equals(99 - 10)); // 99 - Cthulhu Mythos
    });

    test('Updating Cthulhu Mythos skill should correctly update maxSanity', () {
      final character = Character(
        sheetId: 't2',
        sheetStatus: SheetStatus.active,
        sheetName: 'Sheet 2',
        name: "John Doe",
        age: 32,
        pronouns: "He/Him",
        birthplace: "Arkham",
        occupation: "Detective",
        residence: "Arkham, MA",
        currentHP: 10,
        maxHP: 12,
        currentSanity: 40,
        startingSanity: 60,
        currentMP: 8,
        startingMP: 8,
        currentLuck: 50,
        attributes: const [],
        skills: [Skill(name: "Cthulhu Mythos", base: 20)],
      );

      expect(character.maxSanity, equals(99 - 20));

      character.updateSkill("Cthulhu Mythos", 30);
      expect(character.maxSanity, equals(99 - 30));
    });

    test('Current HP should not exceed Max HP', () {
      final character = Character(
        sheetId: 't3',
        sheetStatus: SheetStatus.active,
        sheetName: 'Sheet 3',
        name: "John Doe",
        age: 32,
        pronouns: "He/Him",
        birthplace: "Arkham",
        occupation: "Detective",
        residence: "Arkham, MA",
        currentHP: 12,
        maxHP: 12,
        currentSanity: 40,
        startingSanity: 60,
        currentMP: 8,
        startingMP: 8,
        currentLuck: 50,
        attributes: const [],
        skills: const [],
      );

      expect(character.currentHP, lessThanOrEqualTo(character.maxHP));
    });

    test('Sanity should not exceed Max Sanity', () {
      final character = Character(
        sheetId: 't4',
        sheetStatus: SheetStatus.active,
        sheetName: 'Sheet 4',
        name: "John Doe",
        age: 32,
        pronouns: "He/Him",
        birthplace: "Arkham",
        occupation: "Detective",
        residence: "Arkham, MA",
        currentHP: 10,
        maxHP: 12,
        currentSanity: 99,
        startingSanity: 99,
        currentMP: 8,
        startingMP: 8,
        currentLuck: 50,
        attributes: const [],
        skills: const [],
      );

      expect(character.currentSanity, lessThanOrEqualTo(character.maxSanity));
    });

    test('Status flags should toggle correctly', () {
      final character = Character(
        sheetId: 't5',
        sheetStatus: SheetStatus.active,
        sheetName: 'Sheet 5',
        name: "John Doe",
        age: 32,
        pronouns: "He/Him",
        birthplace: "Arkham",
        occupation: "Detective",
        residence: "Arkham, MA",
        currentHP: 10,
        maxHP: 12,
        currentSanity: 40,
        startingSanity: 60,
        currentMP: 8,
        startingMP: 8,
        currentLuck: 50,
        attributes: const [],
        skills: const [],
      );

      expect(character.isDying, isFalse);
      expect(character.isUnconscious, isFalse);
      expect(character.hasMajorWound, isFalse);

      character.hasMajorWound = true;
      character.isDying = true;

      expect(character.hasMajorWound, isTrue);
      expect(character.isDying, isTrue);
    });

    test('Background fields should be correctly stored and retrievable', () {
      final character = Character(
        sheetId: 't6',
        sheetStatus: SheetStatus.active,
        sheetName: 'Sheet 6',
        name: "John Doe",
        age: 32,
        pronouns: "He/Him",
        birthplace: "Arkham",
        occupation: "Detective",
        residence: "Arkham, MA",
        currentHP: 10,
        maxHP: 12,
        currentSanity: 40,
        startingSanity: 60,
        currentMP: 8,
        startingMP: 8,
        currentLuck: 50,
        attributes: const [],
        skills: const [],
        personalDescription: "A tall man with sharp eyes.",
        ideologyAndBeliefs: "Trust no one.",
        significantPeople: "Detective Harrison, his mentor.",
        meaningfulLocations: "The old police station.",
        treasuredPossessions: "His father's watch.",
        traitsAndMannerisms: "Always wears a fedora.",
        injuriesAndScars: "Scar over right eye.",
        phobiasAndManias: "Claustrophobia.",
        arcaneTomesAndSpells: "Necronomicon (fragments).",
        encountersWithEntities: "Saw a Deep One once.",
        gear: "Revolver, flashlight, notepad.",
        wealth: "Moderate savings.",
        notes: "Investigating the Arkham disappearances.",
      );

      expect(character.personalDescription, contains("sharp eyes"));
      expect(character.ideologyAndBeliefs, contains("Trust no one"));
      expect(character.encountersWithEntities, contains("Deep One"));
    });

    test('Movement Rate should be 9 when DEX and STR are greater than SIZ', () {
      final character = Character(
        sheetId: 't7',
        sheetStatus: SheetStatus.active,
        sheetName: 'Sheet 7',
        name: "Investigator",
        age: 30,
        pronouns: "They/Them",
        birthplace: "Unknown",
        occupation: "Private Investigator",
        residence: "Arkham, MA",
        currentHP: 10,
        maxHP: 10,
        currentSanity: 50,
        startingSanity: 50,
        currentMP: 10,
        startingMP: 10,
        currentLuck: 50,
        attributes: [
          Attribute(name: "Strength", base: 60),
          Attribute(name: "Dexterity", base: 50),
          Attribute(name: "Size", base: 40),
        ],
        skills: const [],
      );

      expect(character.movementRate, equals(9));
    });

    test('Movement Rate should be 8 when either DEX or STR is equal to SIZ', () {
      final character = Character(
        sheetId: 't8',
        sheetStatus: SheetStatus.active,
        sheetName: 'Sheet 8',
        name: "Investigator",
        age: 30,
        pronouns: "They/Them",
        birthplace: "Unknown",
        occupation: "Private Investigator",
        residence: "Arkham, MA",
        currentHP: 10,
        maxHP: 10,
        currentSanity: 50,
        startingSanity: 50,
        currentMP: 10,
        startingMP: 10,
        currentLuck: 50,
        attributes:  [
          Attribute(name: "Strength", base: 40),
          Attribute(name: "Dexterity", base: 50),
          Attribute(name: "Size", base: 40),
        ],
        skills: const [],
      );

      expect(character.movementRate, equals(8));
    });

    test('Movement Rate should be 7 when both DEX and STR are less than SIZ', () {
      final character = Character(
        sheetId: 't9',
        sheetStatus: SheetStatus.active,
        sheetName: 'Sheet 9',
        name: "Investigator",
        age: 30,
        pronouns: "They/Them",
        birthplace: "Unknown",
        occupation: "Private Investigator",
        residence: "Arkham, MA",
        currentHP: 10,
        maxHP: 10,
        currentSanity: 50,
        startingSanity: 50,
        currentMP: 10,
        startingMP: 10,
        currentLuck: 50,
        attributes:  [
          Attribute(name: "Strength", base: 30),
          Attribute(name: "Dexterity", base: 30),
          Attribute(name: "Size", base: 40),
        ],
        skills: const [],
      );

      expect(character.movementRate, equals(7));
    });

    // New: SheetStatus.isDraft behavior
    test('SheetStatus isDraft helper works', () {
      expect(SheetStatus.active.isDraft, isFalse);
      expect(SheetStatus.archived.isDraft, isFalse);
      expect(SheetStatus.draftClassic.isDraft, isTrue);
      expect(SheetStatus.draftPoints.isDraft, isTrue);
      expect(SheetStatus.draftFree.isDraft, isTrue);
    });
  });
}
