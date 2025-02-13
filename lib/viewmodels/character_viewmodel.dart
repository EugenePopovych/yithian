import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/attribute.dart';
import '../models/skill.dart';

class CharacterViewModel extends ChangeNotifier {
  final Character _character = Character(
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
    attributes: [
      Attribute(name: "Strength", base: 50),
      Attribute(name: "Dexterity", base: 50),
      Attribute(name: "Constitution", base: 50),
      Attribute(name: "Intelligence", base: 50),
      Attribute(name: "Power", base: 50),
      Attribute(name: "Size", base: 50),
      Attribute(name: "Education", base: 50),
      Attribute(name: "Appearance", base: 50),
      Attribute(name: "Luck", base: 50),
    ],
    skills: [
      Skill(name: "Accounting", base: 5),
      Skill(name: "Anthropology", base: 1),
      Skill(name: "Appraise", base: 5),
      Skill(name: "Archaeology", base: 1),
      Skill(name: "Art/Craft", base: 5),
      Skill(name: "Charm", base: 15),
      Skill(name: "Climb", base: 20),
      Skill(name: "Credit Rating", base: 0),
      Skill(name: "Cthulhu Mythos", base: 0),
      Skill(name: "Disguise", base: 5),
      Skill(name: "Dodge", base: 50),
      Skill(name: "Drive Auto", base: 20),
      Skill(name: "Electrical Repair", base: 10),
      Skill(name: "Fast Talk", base: 5),
      Skill(name: "Fighting (Brawl)", base: 25),
      Skill(name: "Firearms (Handgun)", base: 20),
      Skill(name: "Firearms (Rifle/Shotgun)", base: 25),
      Skill(name: "First Aid", base: 30),
      Skill(name: "History", base: 5),
      Skill(name: "Intimidate", base: 15),
      Skill(name: "Jump", base: 20),
      Skill(name: "Language (Own)", base: 50),
      Skill(name: "Law", base: 5),
      Skill(name: "Library Use", base: 20),
      Skill(name: "Listen", base: 20),
      Skill(name: "Locksmith", base: 1),
      Skill(name: "Mechanical Repair", base: 10),
      Skill(name: "Medicine", base: 1),
      Skill(name: "Natural World", base: 10),
      Skill(name: "Navigate", base: 10),
      Skill(name: "Occult", base: 5),
      Skill(name: "Operate Heavy Machinery", base: 1),
      Skill(name: "Persuade", base: 10),
      Skill(name: "Pilot", base: 1),
      Skill(name: "Psychology", base: 10),
      Skill(name: "Psychoanalysis", base: 1),
      Skill(name: "Ride", base: 5),
      Skill(name: "Science", base: 1),
      Skill(name: "Sleight of Hand", base: 10),
      Skill(name: "Spot Hidden", base: 25),
      Skill(name: "Stealth", base: 20),
      Skill(name: "Survival", base: 10),
      Skill(name: "Swim", base: 20),
      Skill(name: "Throw", base: 20),
      Skill(name: "Track", base: 10),
    ],
  );

  Character get character => _character;

  void updateCharacterName(String newName) {
    _character.name = newName;
    notifyListeners();
  }

  void updateCharacterInfo({
    String? pronouns,
    String? birthplace,
    String? occupation,
    String? residence,
    int? age,
  }) {
    if (pronouns != null) _character.pronouns = pronouns;
    if (birthplace != null) _character.birthplace = birthplace;
    if (occupation != null) _character.occupation = occupation;
    if (residence != null) _character.residence = residence;
    if (age != null) _character.age = age;
    notifyListeners();
  }

  void updateAttribute(String name, int newValue) {
    _character.updateAttribute(name, newValue);
    notifyListeners();
  }

  void updateSkill(String name, int newValue) {
    _character.updateSkill(name, newValue);
    notifyListeners();
  }

  void updateHealth(int currentHP, int maxHP) {
    _character.currentHP = currentHP.clamp(0, maxHP);
    _character.maxHP = maxHP;
    notifyListeners();
  }

  void updateSanity(int currentSanity, int startingSanity) {
    _character.currentSanity = currentSanity.clamp(0, _character.maxSanity);
    _character.startingSanity = startingSanity;
    notifyListeners();
  }

  void updateMagicPoints(int currentMP, int startingMP) {
    _character.currentMP = currentMP;
    _character.startingMP = startingMP;
    notifyListeners();
  }

  void updateStatus({
    bool? hasMajorWound,
    bool? isIndefinitelyInsane,
    bool? isTemporarilyInsane,
    bool? isUnconscious,
    bool? isDying,
  }) {
    if (hasMajorWound != null) _character.hasMajorWound = hasMajorWound;
    if (isIndefinitelyInsane != null) _character.isIndefinitelyInsane = isIndefinitelyInsane;
    if (isTemporarilyInsane != null) _character.isTemporarilyInsane = isTemporarilyInsane;
    if (isUnconscious != null) _character.isUnconscious = isUnconscious;
    if (isDying != null) _character.isDying = isDying;
    notifyListeners();
  }

  void updateBackground({
    String? personalDescription,
    String? ideologyAndBeliefs,
    String? significantPeople,
    String? meaningfulLocations,
    String? treasuredPossessions,
    String? traitsAndMannerisms,
    String? injuriesAndScars,
    String? phobiasAndManias,
    String? arcaneTomesAndSpells,
    String? encountersWithEntities,
    String? gear,
    String? wealth,
    String? notes,
  }) {
    if (personalDescription != null) _character.personalDescription = personalDescription;
    if (ideologyAndBeliefs != null) _character.ideologyAndBeliefs = ideologyAndBeliefs;
    if (significantPeople != null) _character.significantPeople = significantPeople;
    if (meaningfulLocations != null) _character.meaningfulLocations = meaningfulLocations;
    if (treasuredPossessions != null) _character.treasuredPossessions = treasuredPossessions;
    if (traitsAndMannerisms != null) _character.traitsAndMannerisms = traitsAndMannerisms;
    if (injuriesAndScars != null) _character.injuriesAndScars = injuriesAndScars;
    if (phobiasAndManias != null) _character.phobiasAndManias = phobiasAndManias;
    if (arcaneTomesAndSpells != null) _character.arcaneTomesAndSpells = arcaneTomesAndSpells;
    if (encountersWithEntities != null) _character.encountersWithEntities = encountersWithEntities;
    if (gear != null) _character.gear = gear;
    if (wealth != null) _character.wealth = wealth;
    if (notes != null) _character.notes = notes;
    notifyListeners();
  }

  int get movementRate => _character.movementRate;
}
