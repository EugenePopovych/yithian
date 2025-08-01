import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/character.dart';
import '../models/hive_character.dart';

class CharacterViewModel extends ChangeNotifier {
  static const String lastCharacterIdKey = 'lastCharacterId';

  late Character _character;
  String? _characterId;
  bool _hasCharacter = false;

  Character get character => _character;
  String? get characterId => _characterId;
  bool get hasCharacter => _hasCharacter;

  Future<void> init() async {
    var box = Hive.box<HiveCharacter>('characters');
    String? lastId = box.get(lastCharacterIdKey) as String?;
    if (lastId != null && box.containsKey(lastId)) {
      await loadCharacter(lastId);
    } else if (box.isNotEmpty) {
      var firstEntry = box.toMap().entries.first;
      await loadCharacter(firstEntry.key as String);
    } else {
      _hasCharacter = false;
      notifyListeners();
    }
  }

  Future<void> loadCharacter(String id) async {
    final box = Hive.box<HiveCharacter>('characters');
    final settingsBox = Hive.box('settings');
    final hiveChar = box.get(id);
    if (hiveChar != null) {
      _character = hiveChar.toCharacter();
      _characterId = id;
      _hasCharacter = true;
      await settingsBox.put(lastCharacterIdKey, id);
      notifyListeners();
    }
  }

  Future<void> createCharacter(Character newChar, {String? id}) async {
    final box = Hive.box<HiveCharacter>('characters');
    final settingsBox = Hive.box('settings');
    final newId = id ?? UniqueKey().toString();
    await box.put(newId, HiveCharacter.fromCharacter(newChar));
    await settingsBox.put(lastCharacterIdKey, newId);
    _character = newChar;
    _characterId = newId;
    _hasCharacter = true;
    notifyListeners();
    await saveCharacter();
  }

  Future<void> saveCharacter() async {
    if (_characterId == null) return;
    final box = Hive.box<HiveCharacter>('characters');
    await box.put(_characterId!, HiveCharacter.fromCharacter(_character));
  }

  void setCharacter(Character newCharacter, {String? id}) {
    _character = newCharacter;
    _characterId = id;
    _hasCharacter = true;
    notifyListeners();
    saveCharacter();
  }

  // ------- All update methods auto-save -------

  void updateCharacterName(String newName) {
    _character.name = newName;
    notifyListeners();
    saveCharacter();
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
    saveCharacter();
  }

  void updateAttribute(String name, int newValue) {
    _character.updateAttribute(name, newValue);
    notifyListeners();
    saveCharacter();
  }

  void updateSkill(String name, int newValue) {
    _character.updateSkill(name, newValue);
    notifyListeners();
    saveCharacter();
  }

  void updateHealth(int currentHP, int maxHP) {
    _character.currentHP = currentHP.clamp(0, maxHP);
    _character.maxHP = maxHP;
    notifyListeners();
    saveCharacter();
  }

  void updateSanity(int currentSanity, int startingSanity) {
    _character.currentSanity = currentSanity.clamp(0, _character.maxSanity);
    _character.startingSanity = startingSanity;
    notifyListeners();
    saveCharacter();
  }

  void updateMagicPoints(int currentMP, int startingMP) {
    _character.currentMP = currentMP;
    _character.startingMP = startingMP;
    notifyListeners();
    saveCharacter();
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
    saveCharacter();
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
    saveCharacter();
  }

  void updateLuck(int luck) {
    _character.updateLuck(luck);
    notifyListeners();
    saveCharacter();
  }
}
