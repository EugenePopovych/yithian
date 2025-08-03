import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/character.dart';
import '../models/hive_character.dart';

class CharacterViewModel extends ChangeNotifier {
  static const String lastCharacterIdKey = 'lastCharacterId';

  Character? _character;
  String? _characterId;

  Character? get character => _character;
  String? get characterId => _characterId;
  bool get hasCharacter => _character != null;

  Future<void> init() async {
    var box = Hive.box<HiveCharacter>('characters');
    var settingsBox = Hive.box('settings');
    String? lastId = settingsBox.get(lastCharacterIdKey) as String?;
    if (lastId != null && box.containsKey(lastId)) {
      await loadCharacter(lastId);
    } else if (box.isNotEmpty) {
      var firstEntry = box.toMap().entries.first;
      await loadCharacter(firstEntry.key as String);
    } else {
      _character = null;
      _characterId = null;
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
    notifyListeners();
    await saveCharacter();
  }

  Future<void> saveCharacter() async {
    if (_characterId == null || _character == null) return;
    final box = Hive.box<HiveCharacter>('characters');
    await box.put(_characterId!, HiveCharacter.fromCharacter(_character!));
  }

  void setCharacter(Character newCharacter, {String? id}) {
    _character = newCharacter;
    _characterId = id;
    notifyListeners();
    saveCharacter();
  }

  void clearCharacter() {
    _character = null;
    _characterId = null;
    notifyListeners();
  }

  // ------- All update methods auto-save -------

  void updateCharacterSheetName(String newSheetName) {
    if (_character == null) return;
    _character!.sheetName = newSheetName;
    notifyListeners();
    saveCharacter();
  }

  void updateCharacterName(String newName) {
    if (_character == null) return;
    _character!.name = newName;
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
    if (_character == null) return;
    if (pronouns != null) _character!.pronouns = pronouns;
    if (birthplace != null) _character!.birthplace = birthplace;
    if (occupation != null) _character!.occupation = occupation;
    if (residence != null) _character!.residence = residence;
    if (age != null) _character!.age = age;
    notifyListeners();
    saveCharacter();
  }

  void updateAttribute(String name, int newValue) {
    if (_character == null) return;
    _character!.updateAttribute(name, newValue);
    notifyListeners();
    saveCharacter();
  }

  void updateSkill(String name, int newValue) {
    if (_character == null) return;
    _character!.updateSkill(name, newValue);
    notifyListeners();
    saveCharacter();
  }

  void updateHealth(int currentHP, int maxHP) {
    if (_character == null) return;
    _character!.currentHP = currentHP.clamp(0, maxHP);
    _character!.maxHP = maxHP;
    notifyListeners();
    saveCharacter();
  }

  void updateSanity(int currentSanity, int startingSanity) {
    if (_character == null) return;
    _character!.currentSanity = currentSanity.clamp(0, _character!.maxSanity);
    _character!.startingSanity = startingSanity;
    notifyListeners();
    saveCharacter();
  }

  void updateMagicPoints(int currentMP, int startingMP) {
    if (_character == null) return;
    _character!.currentMP = currentMP;
    _character!.startingMP = startingMP;
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
    if (_character == null) return;
    if (hasMajorWound != null) _character!.hasMajorWound = hasMajorWound;
    if (isIndefinitelyInsane != null) _character!.isIndefinitelyInsane = isIndefinitelyInsane;
    if (isTemporarilyInsane != null) _character!.isTemporarilyInsane = isTemporarilyInsane;
    if (isUnconscious != null) _character!.isUnconscious = isUnconscious;
    if (isDying != null) _character!.isDying = isDying;
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
    if (_character == null) return;
    if (personalDescription != null) _character!.personalDescription = personalDescription;
    if (ideologyAndBeliefs != null) _character!.ideologyAndBeliefs = ideologyAndBeliefs;
    if (significantPeople != null) _character!.significantPeople = significantPeople;
    if (meaningfulLocations != null) _character!.meaningfulLocations = meaningfulLocations;
    if (treasuredPossessions != null) _character!.treasuredPossessions = treasuredPossessions;
    if (traitsAndMannerisms != null) _character!.traitsAndMannerisms = traitsAndMannerisms;
    if (injuriesAndScars != null) _character!.injuriesAndScars = injuriesAndScars;
    if (phobiasAndManias != null) _character!.phobiasAndManias = phobiasAndManias;
    if (arcaneTomesAndSpells != null) _character!.arcaneTomesAndSpells = arcaneTomesAndSpells;
    if (encountersWithEntities != null) _character!.encountersWithEntities = encountersWithEntities;
    if (gear != null) _character!.gear = gear;
    if (wealth != null) _character!.wealth = wealth;
    if (notes != null) _character!.notes = notes;
    notifyListeners();
    saveCharacter();
  }

  void updateLuck(int luck) {
    if (_character == null) return;
    _character!.updateLuck(luck);
    notifyListeners();
    saveCharacter();
  }
}
