import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:coc_sheet/models/character.dart';
import 'package:coc_sheet/models/sheet_status.dart';
import 'package:coc_sheet/models/creation_rule_set.dart';
import 'package:coc_sheet/models/creation_update_event.dart';
import 'package:coc_sheet/services/character_storage.dart';
import 'package:coc_sheet/services/sheet_id_generator.dart';

class CharacterViewModel extends ChangeNotifier {
  CharacterViewModel(this._storage, {SheetIdGenerator? ids})
      : _ids = ids ?? UuidSheetIdGenerator();

  final CharacterStorage _storage;
  final SheetIdGenerator _ids;

  Character? _character;
  CreationRuleSet? _rules;

  /// Emits the latest creation-time update (accepted/partial/rejected).
  /// UI can listen to this to show inline messages and snap inputs back.
  final ValueNotifier<CreationUpdateEvent?> lastCreationUpdate =
      ValueNotifier<CreationUpdateEvent?>(null);

  Character? get character => _character;
  bool get hasCharacter => _character != null;

  // Expose rule-set driven UI data
  CreationRuleSet? get rules => _rules;
  int? get occupationPointsRemaining => _rules?.occupationPointsRemaining;
  int? get personalPointsRemaining => _rules?.personalPointsRemaining;
  bool get canFinalizeCreation => _rules?.canFinalize ?? true;

  Future<void> init() async {
    final recent = await _storage.getRecent();
    if (recent != null) {
      _setCharacterInternal(recent);
      return;
    }
    final list = await _storage.getCharacters().first;
    if (list.isNotEmpty) {
      _setCharacterInternal(list.first);
      return;
    }
    _character = null;
    _rules = null;
    notifyListeners();
  }

  Future<void> loadCharacter(String id) async {
    final all = await _storage
        .getCharacters(statuses: SheetStatus.values.toSet())
        .first;
    final found = all.where((c) => c.sheetId == id).toList();
    if (found.isEmpty) return;
    _setCharacterInternal(found.first);
    await saveCharacter(); // mark recent
  }

  // Create a new sheet, bind rules, let rules initialize the draft.
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

    _setCharacterInternal(c,
        callInitialize: true, initName: name, initOccupation: occupation);
    await _storage.store(_character!);
    notifyListeners();
  }

  Stream<List<Character>> charactersStream({
    Set<SheetStatus> statuses = const {
      SheetStatus.active,
      SheetStatus.archived
    },
  }) =>
      _storage.getCharacters(statuses: statuses);

  Future<void> deleteById(String sheetId) async {
    await _storage.delete(sheetId);
    if (_character?.sheetId == sheetId) clearCharacter();
  }

  @override
  void dispose() {
    lastCreationUpdate.dispose();
    super.dispose();
  }

  // -------- internal helpers --------

  void _setCharacterInternal(
    Character c, {
    bool callInitialize = false,
    String? initName,
    String? initOccupation,
  }) {
    _character = c;

    // Bind a fresh rule set for drafts
    _rules?.onExit();
    _rules = null;
    if (c.sheetStatus.isDraft) {
      final rs = CreationRules.forStatus(c.sheetStatus);
      rs.bind(c);
      rs.onEnter();
      if (callInitialize) {
        rs.initialize(
            sheetName: c.sheetName, name: initName, occupation: initOccupation);
      }
      _rules = rs;
    }

    notifyListeners();
  }

  Future<void> saveCharacter() async {
    if (_character == null) return;
    await _storage.store(_character!);
  }

  void setCharacter(Character newCharacter) {
    _setCharacterInternal(newCharacter);
    saveCharacter();
  }

  void clearCharacter() {
    _rules?.onExit();
    _rules = null;
    _character = null;
    notifyListeners();
  }

  // ------- Creation helpers -------

  void rollAttributes() {
    _rules?.rollAttributes();
    notifyListeners();
    saveCharacter();
  }

  void rollSkills() {
    _rules?.rollSkills();
    notifyListeners();
    saveCharacter();
  }

  Future<void> finalizeCreation() async {
    if (_character == null) return;
    if (_rules != null) {
      if (!(_rules!.canFinalize)) return;
      _rules!.finalizeDraft();
      _rules!.onExit();
      _rules = null;
    } else {
      _character!.sheetStatus = SheetStatus.active;
    }
    notifyListeners();
    await saveCharacter();
  }

  Future<void> discardCurrent() async {
    if (_character == null) return;
    final id = _character!.sheetId;
    await _storage.delete(id);
    clearCharacter();
  }

  // ------- Existing update API routed through rules -------

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

    if (_rules != null) {
      final res = _rules!.update(CreationChange.attribute(name, newValue));
      final event = CreationUpdateEvent(
        target: ChangeTarget.attribute,
        name: name,
        attemptedValue: newValue,
        result: res,
      );

      if (!res.applied) {
        // For completeness (rare in classic, but future-proof):
        lastCreationUpdate.value = event;
        notifyListeners();
        return;
      }

      _character!.updateAttribute(name, res.effectiveValue ?? newValue);

      // Typically no messages here, but clear just in case.
      if ((res.messages.isNotEmpty)) {
        lastCreationUpdate.value = event;
      } else {
        lastCreationUpdate.value = null;
      }
    } else {
      _character!.updateAttribute(name, newValue);
    }

    notifyListeners();
    saveCharacter();
  }

  void updateSkill(String name, int newValue) {
    if (_character == null) return;

    if (_rules != null) {
      final res = _rules!.update(CreationChange.skill(name, newValue));
      final event = CreationUpdateEvent(
        target: ChangeTarget.skill,
        name: name,
        attemptedValue: newValue,
        result: res,
      );

      if (!res.applied) {
        // Rejected: emit event and rebuild so the editor snaps back.
        lastCreationUpdate.value = event;
        notifyListeners();
        return; // don’t mutate model or save
      }

      // Applied: update the model.
      _character!.updateSkill(name, res.effectiveValue ?? newValue);

      // If there were warnings (e.g., partial due to pools), emit; else clear.
      if ((res.messages.isNotEmpty)) {
        lastCreationUpdate.value = event;
      } else {
        lastCreationUpdate.value = null;
      }
    } else {
      _character!.updateSkill(name, newValue);
    }

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
    if (isIndefinitelyInsane != null) {
      _character!.isIndefinitelyInsane = isIndefinitelyInsane;
    }
    if (isTemporarilyInsane != null) {
      _character!.isTemporarilyInsane = isTemporarilyInsane;
    }
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
    if (personalDescription != null) {
      _character!.personalDescription = personalDescription;
    }
    if (ideologyAndBeliefs != null) {
      _character!.ideologyAndBeliefs = ideologyAndBeliefs;
    }
    if (significantPeople != null) {
      _character!.significantPeople = significantPeople;
    }
    if (meaningfulLocations != null) {
      _character!.meaningfulLocations = meaningfulLocations;
    }
    if (treasuredPossessions != null) {
      _character!.treasuredPossessions = treasuredPossessions;
    }
    if (traitsAndMannerisms != null) {
      _character!.traitsAndMannerisms = traitsAndMannerisms;
    }
    if (injuriesAndScars != null) {
      _character!.injuriesAndScars = injuriesAndScars;
    }
    if (phobiasAndManias != null) {
      _character!.phobiasAndManias = phobiasAndManias;
    }
    if (arcaneTomesAndSpells != null) {
      _character!.arcaneTomesAndSpells = arcaneTomesAndSpells;
    }
    if (encountersWithEntities != null) {
      _character!.encountersWithEntities = encountersWithEntities;
    }
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
