import 'package:flutter/material.dart';
import 'package:coc_sheet/models/character.dart';
import 'package:coc_sheet/models/sheet_status.dart';
import 'package:coc_sheet/services/character_storage.dart';
import 'package:coc_sheet/services/sheet_id_generator.dart';

class CharacterViewModel extends ChangeNotifier {
  CharacterViewModel(this._storage, {SheetIdGenerator? ids})
    : _ids = ids ?? UuidSheetIdGenerator();

  final CharacterStorage _storage;
  final SheetIdGenerator _ids;

  Character? _character;

  Character? get character => _character;
  String? get characterId => _character?.sheetId;
  bool get hasCharacter => _character != null;

  Future<void> init() async {
    // 1) Try the most recent sheet stored by CharacterStorage
    final recent = await _storage.getRecent();
    if (recent != null) {
      _character = recent;
      notifyListeners();
      return;
    }

    // 2) Fallback to first available character (active+archived by default)
    final list = await _storage.getCharacters().first;
    if (list.isNotEmpty) {
      _character = list.first;
      notifyListeners();
      return;
    }

    // 3) Nothing found
    _character = null;
    notifyListeners();
  }

  Future<void> loadCharacter(String id) async {
    // Fetch a snapshot including drafts to ensure we can load any sheet
    final all = await _storage
        .getCharacters(statuses: SheetStatus.values.toSet())
        .first;
    final found = all.where((c) => c.sheetId == id).toList();
    if (found.isEmpty) return;

    _character = found.first;
    notifyListeners();

    // Mark as recent via store (no-op data wise, updates “recent” in storage)
    await saveCharacter();
  }

  Future<void> createCharacter({
    String? name,
    String? occupation,
    SheetStatus? status,
  }) async {
    final id = _ids.newId();

    final c = Character(
      sheetId: id,
      sheetStatus: status ?? SheetStatus.draft_classic,
      sheetName: (name != null && name.isNotEmpty) ? name : 'New Sheet',
      name: name ?? '',
      age: 0,
      pronouns: '',
      birthplace: '',
      occupation: occupation ?? '',
      residence: '',
      currentHP: 0,
      maxHP: 0,
      currentSanity: 0,
      startingSanity: 0,
      currentMP: 0,
      startingMP: 0,
      currentLuck: 0,
      attributes: [],
      skills: [],
    );

    await _storage.store(c); // persists and marks as recent
    _character = c;
    notifyListeners();
  }

  Future<void> saveCharacter() async {
    if (_character == null) return;
    await _storage.store(_character!);
  }

  void setCharacter(Character newCharacter) {
    _character = newCharacter;
    notifyListeners();
    saveCharacter();
  }

  void clearCharacter() {
    _character = null;
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
