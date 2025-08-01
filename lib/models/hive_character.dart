import 'package:hive/hive.dart';
import 'hive_attribute.dart';
import 'hive_skill.dart';
import 'character.dart';

part 'hive_character.g.dart';

@HiveType(typeId: 0)
class HiveCharacter extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  @HiveField(2)
  String pronouns;

  @HiveField(3)
  String birthplace;

  @HiveField(4)
  String occupation;

  @HiveField(5)
  String residence;

  @HiveField(6)
  int currentHP;

  @HiveField(7)
  int maxHP;

  @HiveField(8)
  int currentSanity;

  @HiveField(9)
  int startingSanity;

  @HiveField(10)
  int currentMP;

  @HiveField(11)
  int startingMP;

  @HiveField(12)
  int currentLuck;

  @HiveField(13)
  List<HiveAttribute> attributes;

  @HiveField(14)
  List<HiveSkill> skills;

  // Background info
  @HiveField(15)
  String personalDescription;

  @HiveField(16)
  String ideologyAndBeliefs;

  @HiveField(17)
  String significantPeople;

  @HiveField(18)
  String meaningfulLocations;

  @HiveField(19)
  String treasuredPossessions;

  @HiveField(20)
  String traitsAndMannerisms;

  @HiveField(21)
  String injuriesAndScars;

  @HiveField(22)
  String phobiasAndManias;

  @HiveField(23)
  String arcaneTomesAndSpells;

  @HiveField(24)
  String encountersWithEntities;

  @HiveField(25)
  String gear;

  @HiveField(26)
  String wealth;

  @HiveField(27)
  String notes;

  // Status
  @HiveField(28)
  bool hasMajorWound;

  @HiveField(29)
  bool isIndefinitelyInsane;

  @HiveField(30)
  bool isTemporarilyInsane;

  @HiveField(31)
  bool isUnconscious;

  @HiveField(32)
  bool isDying;

  HiveCharacter({
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
