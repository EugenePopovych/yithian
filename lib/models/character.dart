import 'attribute.dart';
import 'skill.dart';

class Character {
  String name;
  int age;
  String pronouns;
  String birthplace;
  String occupation;
  String residence;
  
  int currentHP;
  int maxHP;
  int currentSanity;
  int startingSanity;
  int get maxSanity => 99 - (skills.firstWhere((s) => s.name == "Cthulhu Mythos", orElse: () => Skill(name: "Cthulhu Mythos", base: 0)).base);
  int currentMP;
  int startingMP;
  List<Attribute> attributes;
  List<Skill> skills;

  // Background information
  String personalDescription;
  String ideologyAndBeliefs;
  String significantPeople;
  String meaningfulLocations;
  String treasuredPossessions;
  String traitsAndMannerisms;
  String injuriesAndScars;
  String phobiasAndManias;
  String arcaneTomesAndSpells;
  String encountersWithEntities;
  String gear;
  String wealth;
  String notes;

  // Status tracking
  bool hasMajorWound;
  bool isIndefinitelyInsane;
  bool isTemporarilyInsane;
  bool isUnconscious;
  bool isDying;

  Character({
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

  int get movementRate {
    final str = attributes.firstWhere((a) => a.name == "Strength").base;
    final dex = attributes.firstWhere((a) => a.name == "Dexterity").base;
    final siz = attributes.firstWhere((a) => a.name == "Size").base;
    
    if (dex > siz && str > siz) return 9;
    if (dex == siz || str == siz) return 8;
    return 7;
  }

  void updateAttribute(String attributeName, int newValue) {
    for (var attribute in attributes) {
      if (attribute.name == attributeName) {
        attribute.base = newValue >= 0 ? newValue : 0;
        break;
      }
    }
  }

  void updateSkill(String skillName, int newValue) {
    for (var skill in skills) {
      if (skill.name == skillName) {
        skill.base = newValue >= 0 ? newValue : 0;
        break;
      }
    }
  }
}
