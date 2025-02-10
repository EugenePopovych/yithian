import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/attribute.dart';
import '../models/skill.dart';

class CharacterViewModel extends ChangeNotifier {
  final Character _character = Character(
    name: "Investigator",
    attributes: [
      Attribute(name: "Strength", base: 50),
      Attribute(name: "Dexterity", base: 60),
      Attribute(name: "Intelligence", base: 70),
    ],
    skills: [
      Skill(name: "Spot Hidden", base: 60),
      Skill(name: "Persuade", base: 50),
    ],
  );

  Character get character => _character;

  void updateName(String newName) {
    _character.name = newName;
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
}
