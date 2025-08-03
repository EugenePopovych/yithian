import 'package:hive/hive.dart';
import 'hive_attribute.dart';
import 'hive_skill.dart';
import 'character.dart';

part 'hive_character.g.dart';

@HiveType(typeId: 0)
class HiveCharacter extends HiveObject {
  @HiveField(0)
  String sheetName;

  @HiveField(1)
  String name;

  @HiveField(2)
  int age;

  @HiveField(3)
  String pronouns;

  @HiveField(4)
  String birthplace;

  @HiveField(5)
  String occupation;

  @HiveField(6)
  String residence;

  @HiveField(7)
  int currentHP;

  @HiveField(8)
  int maxHP;

  @HiveField(9)
  int currentSanity;

  @HiveField(10)
  int startingSanity;

  @HiveField(11)
  int currentMP;

  @HiveField(12)
  int startingMP;

  @HiveField(13)
  int currentLuck;

  @HiveField(14)
  List<HiveAttribute> attributes;

  @HiveField(15)
  List<HiveSkill> skills;

  // Background info
  @HiveField(16)
  String personalDescription;

  @HiveField(17)
  String ideologyAndBeliefs;

  @HiveField(18)
  String significantPeople;

  @HiveField(19)
  String meaningfulLocations;

  @HiveField(20)
  String treasuredPossessions;

  @HiveField(21)
  String traitsAndMannerisms;

  @HiveField(22)
  String injuriesAndScars;

  @HiveField(23)
  String phobiasAndManias;

  @HiveField(24)
  String arcaneTomesAndSpells;

  @HiveField(25)
  String encountersWithEntities;

  @HiveField(26)
  String gear;

  @HiveField(27)
  String wealth;

  @HiveField(28)
  String notes;

  // Status
  @HiveField(29)
  bool hasMajorWound;

  @HiveField(30)
  bool isIndefinitelyInsane;

  @HiveField(31)
  bool isTemporarilyInsane;

  @HiveField(32)
  bool isUnconscious;

  @HiveField(33)
  bool isDying;

  HiveCharacter({
    required this.sheetName,
    required this.name,
    required this.age,
    required this.pronouns,
    required this.birthplace,
    required this.occupation,
    required this.residence,
    required this.currentHP,
    required this.maxHP,
    required this.currentSanity,
    required this.startingSanity,
    required this.currentMP,
    required this.startingMP,
    required this.currentLuck,
    required this.attributes,
    required this.skills,
    this.personalDescription = "",
    this.ideologyAndBeliefs = "",
    this.significantPeople = "",
    this.meaningfulLocations = "",
    this.treasuredPossessions = "",
    this.traitsAndMannerisms = "",
    this.injuriesAndScars = "",
    this.phobiasAndManias = "",
    this.arcaneTomesAndSpells = "",
    this.encountersWithEntities = "",
    this.gear = "",
    this.wealth = "",
    this.notes = "",
    this.hasMajorWound = false,
    this.isIndefinitelyInsane = false,
    this.isTemporarilyInsane = false,
    this.isUnconscious = false,
    this.isDying = false,
  });

  // Conversion from Character (UI model) to HiveCharacter (storage model)
  factory HiveCharacter.fromCharacter(Character c) => HiveCharacter(
    sheetName: c.sheetName,
    name: c.name,
    age: c.age,
    pronouns: c.pronouns,
    birthplace: c.birthplace,
    occupation: c.occupation,
    residence: c.residence,
    currentHP: c.currentHP,
    maxHP: c.maxHP,
    currentSanity: c.currentSanity,
    startingSanity: c.startingSanity,
    currentMP: c.currentMP,
    startingMP: c.startingMP,
    currentLuck: c.currentLuck,
    attributes: c.attributes.map(HiveAttribute.fromAttribute).toList(),
    skills: c.skills.map(HiveSkill.fromSkill).toList(),
    personalDescription: c.personalDescription,
    ideologyAndBeliefs: c.ideologyAndBeliefs,
    significantPeople: c.significantPeople,
    meaningfulLocations: c.meaningfulLocations,
    treasuredPossessions: c.treasuredPossessions,
    traitsAndMannerisms: c.traitsAndMannerisms,
    injuriesAndScars: c.injuriesAndScars,
    phobiasAndManias: c.phobiasAndManias,
    arcaneTomesAndSpells: c.arcaneTomesAndSpells,
    encountersWithEntities: c.encountersWithEntities,
    gear: c.gear,
    wealth: c.wealth,
    notes: c.notes,
    hasMajorWound: c.hasMajorWound,
    isIndefinitelyInsane: c.isIndefinitelyInsane,
    isTemporarilyInsane: c.isTemporarilyInsane,
    isUnconscious: c.isUnconscious,
    isDying: c.isDying,
  );

  // Conversion from HiveCharacter to Character
  Character toCharacter() => Character(
    sheetName: sheetName,
    name: name,
    age: age,
    pronouns: pronouns,
    birthplace: birthplace,
    occupation: occupation,
    residence: residence,
    currentHP: currentHP,
    maxHP: maxHP,
    currentSanity: currentSanity,
    startingSanity: startingSanity,
    currentMP: currentMP,
    startingMP: startingMP,
    currentLuck: currentLuck,
    attributes: attributes.map((ha) => ha.toAttribute()).toList(),
    skills: skills.map((hs) => hs.toSkill()).toList(),
    personalDescription: personalDescription,
    ideologyAndBeliefs: ideologyAndBeliefs,
    significantPeople: significantPeople,
    meaningfulLocations: meaningfulLocations,
    treasuredPossessions: treasuredPossessions,
    traitsAndMannerisms: traitsAndMannerisms,
    injuriesAndScars: injuriesAndScars,
    phobiasAndManias: phobiasAndManias,
    arcaneTomesAndSpells: arcaneTomesAndSpells,
    encountersWithEntities: encountersWithEntities,
    gear: gear,
    wealth: wealth,
    notes: notes,
    hasMajorWound: hasMajorWound,
    isIndefinitelyInsane: isIndefinitelyInsane,
    isTemporarilyInsane: isTemporarilyInsane,
    isUnconscious: isUnconscious,
    isDying: isDying,
  );
}
