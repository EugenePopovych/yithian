import 'package:flutter_test/flutter_test.dart';
import 'package:coc_sheet/models/creation_rule_set.dart';
import 'package:coc_sheet/models/character.dart';
import 'package:coc_sheet/models/sheet_status.dart';
import 'package:coc_sheet/models/attribute.dart';
import 'package:coc_sheet/models/skill.dart';

void main() {
  Character blankClassic() => Character(
        sheetId: 't',
        sheetStatus: SheetStatus.draftClassic,
        sheetName: 't',
        name: 't',
        age: 30,
        pronouns: '',
        birthplace: '',
        occupation: '',
        residence: '',
        currentHP: 10,
        maxHP: 10,
        currentSanity: 50,
        startingSanity: 50,
        currentMP: 10,
        startingMP: 10,
        currentLuck: 50,
        attributes: <Attribute>[
          Attribute(name: 'Strength', base: 50),
          Attribute(name: 'Constitution', base: 50),
          Attribute(name: 'Dexterity', base: 50),
          Attribute(name: 'Appearance', base: 50),
          Attribute(name: 'Intelligence', base: 50),
          Attribute(name: 'Power', base: 50),
          Attribute(name: 'Size', base: 50),
          Attribute(name: 'Education', base: 50),
        ],
        skills: <Skill>[],
      );

  test('Seeds structured generic family rows with correct names', () {
    final ch = blankClassic();
    final rules = CreationRules.forStatus(ch.sheetStatus);
    rules.bind(ch);
    rules.initialize(); 

    Skill? find(String fam, String expectedName) {
      return ch.skills.firstWhere(
        (s) =>
            s.category == fam &&
            s.specialization == null &&
            s.name == expectedName,
        orElse: () => null as Skill,
      );
    }

    expect(find('Science', 'Science (Any)'), isNotNull);
    expect(find('Art/Craft', 'Art/Craft (Any)'), isNotNull);
    expect(find('Pilot', 'Pilot (Any)'), isNotNull);
    expect(find('Survival', 'Survival (Any)'), isNotNull);
    expect(find('Firearms', 'Firearms (Any)'), isNotNull);

    // Language: special-case generic must be "Language (Other)"
    expect(find('Language', 'Language (Other)'), isNotNull);
  });

  test('Generic rows are idempotent (no duplicates on reseed)', () {
    final ch = blankClassic();
    final rules = CreationRules.forStatus(ch.sheetStatus);
    rules.bind(ch);
    rules.initialize();
    rules.initialize();

    int count(String fam, String name) => ch.skills
        .where((s) =>
            s.category == fam && s.specialization == null && s.name == name)
        .length;

    expect(count('Science', 'Science (Any)'), 1);
    expect(count('Art/Craft', 'Art/Craft (Any)'), 1);
    expect(count('Pilot', 'Pilot (Any)'), 1);
    expect(count('Survival', 'Survival (Any)'), 1);
    expect(count('Firearms', 'Firearms (Any)'), 1);
    expect(count('Language', 'Language (Other)'), 1);
  });
}
