import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:coc_sheet/models/character.dart';
import 'package:coc_sheet/models/attribute.dart';
import 'package:coc_sheet/models/skill.dart';
import 'package:coc_sheet/models/sheet_status.dart';
import 'package:coc_sheet/models/creation_rule_set.dart';
import 'package:coc_sheet/models/creation_update_event.dart';
import 'package:coc_sheet/models/credit_rating_range.dart';
import 'package:coc_sheet/models/create_character_spec.dart';
import 'package:coc_sheet/models/classic_rules.dart';
import 'package:coc_sheet/models/skill_bases.dart';
import 'package:coc_sheet/models/skill_specialization.dart';
import 'package:coc_sheet/services/character_storage.dart';
import 'package:coc_sheet/services/sheet_id_generator.dart';
import 'package:coc_sheet/services/occupation_storage.dart';

class CharacterViewModel extends ChangeNotifier {
  CharacterViewModel(this._storage, {SheetIdGenerator? ids})
      : _ids = ids ?? UuidSheetIdGenerator();

  final CharacterStorage _storage;
  final SheetIdGenerator _ids;

  Character? _character;
  CreationRuleSet? _rules;
  Set<String>? _seededOccupationSkills;

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
  CreditRatingRange? get creditRatingRange => _rules?.creditRatingRange;

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
      sheetStatus: status ?? SheetStatus.draftClassic,
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

  // ----- Specialization helpers (Step 3) -----

  /// Add a new specialized skill under a given family (e.g., "Science", "Art/Craft").
  /// - Ensures the generic family skill exists (locked at its base).
  /// - Avoids duplicates by display name "Family (Spec)".
  /// - Inserts and persists the updated skills list.
  Future<void> addSpecializedSkill({
    required String category,
    required String specialization,
  }) async {
    if (_character == null) return;

    final c = _character!;

    // 1) Ensure the generic family skill exists (locked at base, no specialization)
    final genericIndex = c.skills.indexWhere((s) => s.name == category);
    if (genericIndex < 0) {
      c.skills.add(Skill(
        name: category,
        base: SkillBases.baseForGeneric(category),
        canUpgrade: false, // locked in creation; UI can also reflect this
        category: category,
        specialization: null,
      ));
    }

    // 2) Create the specialized display name and check for duplicates
    final display = SkillSpecialization.displayName(category, specialization);
    final exists = c.skills.any((s) => s.name == display);
    if (exists) {
      notifyListeners(); // nothing changed, but keep UI responsive
      return;
    }

    // 3) Insert the new specialized skill with its base
    c.skills.add(Skill(
      name: display, // keep .name as canonical display for compatibility
      base: SkillBases.baseForSpecialized(category, specialization),
      canUpgrade: true,
      category: category,
      specialization: specialization,
    ));

    // 4) Sort for stable UI: generic family first, then its specializations A→Z, then others
    c.skills.sort((a, b) {
      final aCat = a.category ?? a.name;
      final bCat = b.category ?? b.name;

      // Group by category/family first
      final catCmp = aCat.compareTo(bCat);
      if (catCmp != 0) return catCmp;

      // Place generic (no specialization) before specializations within the same family
      final aIsGen = a.specialization == null;
      final bIsGen = b.specialization == null;
      if (aIsGen != bIsGen) {
        return aIsGen ? -1 : 1;
      }

      // Then by display name
      return a.displayName.compareTo(b.displayName);
    });

    notifyListeners();
    await saveCharacter();
  }

  /// Remove a skill by its display name (e.g., "Science (Biology)").
  /// Does not remove the generic family skill.
  Future<void> removeSkillByName(String name) async {
    if (_character == null) return;
    final c = _character!;

    // Prevent removing generic family skills by mistake
    if (SkillSpecialization.isGenericFamily(name)) {
      notifyListeners();
      return;
    }

    c.skills.removeWhere((s) => s.name == name);
    notifyListeners();
    await saveCharacter();
  }

  /// Expanded occupation check:
  /// - If [name] is a specialization "Family (Spec)", treat it as occupational if
  ///   either the exact name OR its family is allowed by the rules.
  /// - Falls back to the rules' own check and previously seeded picks.
  bool isOccupationSkill(String name) {
    // Prefer pre-seeded set if present (mandatory + user picks)
    final chosen = _seededOccupationSkills;
    if (chosen != null && chosen.contains(name)) {
      return true;
    }

    // Parse specialization; if a family is present, check family as a wildcard.
    final parsed = SkillSpecialization.parse(name);
    final fam = parsed.category;

    // Rules may know exact names; check both exact and family.
    final byRulesExact = _rules?.isOccupationSkill(name) ?? false;
    if (byRulesExact) return true;

    if (fam != null) {
      final byRulesFamily = _rules?.isOccupationSkill(fam) ?? false;
      if (byRulesFamily) return true;
    }

    // Finally, fall back to rules on the given name as before
    return _rules?.isOccupationSkill(name) ?? false;
  }

  @override
  void dispose() {
    lastCreationUpdate.dispose();
    super.dispose();
  }

  Future<void> createFromSpec(
    CreateCharacterSpec spec, {
    required OccupationStorage occupationStorage,
  }) async {
    // 1) Resolve occupation id → model/name
    final occ = await occupationStorage.findById(spec.occupationId);
    final occName = occ?.name ?? spec.occupationId;

    // 2) Create the draft shell (defaults to SheetStatus.draft_classic)
    await createCharacter(
      name: spec.name,
      occupation: occName,
      // status: SheetStatus.draft_classic, // implicit default in createCharacter
    );

    // 3) Compute Classic values (pure functions)
    final attrs = Map<String, int>.from(spec.attributes);

    final hp = calcHP(attrs[AttrKey.con]!, attrs[AttrKey.siz]!);
    final mp = calcMP(attrs[AttrKey.pow]!);
    final sanity = calcSanity(attrs[AttrKey.pow]!);
    final move = calcMove(
      str: attrs[AttrKey.str]!,
      dex: attrs[AttrKey.dex]!,
      siz: attrs[AttrKey.siz]!,
      age: spec.age,
    );
    final dbb = calcDamageBonus(attrs[AttrKey.str]!, attrs[AttrKey.siz]!);

    final baseSkills =
        buildBaseSkills(attrs); // includes Dodge & Language (Own)
    final occupationPoints = (attrs[AttrKey.edu] ?? 0) * 4;
    final personalPoints = (attrs[AttrKey.intg] ?? 0) * 2;

    // 4) Apply to the current Character (real assignments & save)
    await _applyClassicToCurrentCharacter(
      name: spec.name,
      age: spec.age,
      occupationName: occName,
      attributes: attrs,
      luck: spec.luck,
      hp: hp,
      mp: mp,
      sanity: sanity,
      move: move,
      damageBonus: dbb.db,
      build: dbb.build,
      baseSkills: baseSkills,
      selectedOccupationSkills: spec.selectedSkills,
      creditMin: occ?.creditMin ?? 0,
      creditMax: occ?.creditMax ?? 0,
      occupationPoints: occupationPoints,
      personalPoints: personalPoints,
    );

    // Seed for UX badges in the sheet (mandatory + user picks from pre-sheet).
    _seededOccupationSkills = spec.selectedSkills.toSet();
    // Tell the rules about the chosen occupation skills and initial pools
    _rules?.seedOccupationSkills(spec.selectedSkills.toSet());
    _rules?.seedPools(
      occupation: (spec.attributes[AttrKey.edu] ?? 0) * 4,
      personal:   (spec.attributes[AttrKey.intg] ?? 0) * 2,
    );
    _rules?.seedCreditRatingRange(
      CreditRatingRange(min: occ?.creditMin ?? 0, max: occ?.creditMax ?? 0),
    );

    notifyListeners();
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
      _seededOccupationSkills = null;
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
     _seededOccupationSkills = null;
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

    // If we’re in a draft with rules, finalize the draft first.
    if (_rules != null) {
      if (!(_rules!.canFinalize)) return;
      _rules!.finalizeDraft();
    }

    // Ensure status is ACTIVE regardless of what finalizeDraft() does internally.
    _character!.sheetStatus = SheetStatus.active;

    // Clean up rule-set binding.
    _rules?.onExit();
    _rules = null;
    _seededOccupationSkills = null;

    await saveCharacter(); // persist the status change so the List can see it

    notifyListeners();
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

  Future<void> _applyClassicToCurrentCharacter({
    required String name,
    required int age,
    required String occupationName,
    required Map<String, int> attributes,
    required int luck,
    required int hp,
    required int mp,
    required int sanity,
    required int move, // computed but not stored in Character (has a getter)
    required String damageBonus, // not stored in current Character model
    required int build, // not stored in current Character model
    required Map<String, int> baseSkills,
    required List<String>
        selectedOccupationSkills, // not persisted in Character model
    required int creditMin, // not persisted in Character model
    required int creditMax, // not persisted in Character model
    required int occupationPoints, // not persisted in Character model
    required int personalPoints, // not persisted in Character model
  }) async {
    if (_character == null) return;
    final c = _character!;

    // ---------- Identity / Demographics ----------
    c.name = name; // allow override to keep in sync with spec
    c.occupation = occupationName;
    c.age = age;

    // ---------- Luck ----------
    c.updateLuck(luck);

    // ---------- Attributes (replace full list) ----------
    // Map AttrKey -> Character attribute names used in your model
    final attrsList = <Attribute>[
      Attribute(name: 'Strength', base: attributes[AttrKey.str] ?? 0),
      Attribute(name: 'Constitution', base: attributes[AttrKey.con] ?? 0),
      Attribute(name: 'Dexterity', base: attributes[AttrKey.dex] ?? 0),
      Attribute(name: 'Appearance', base: attributes[AttrKey.app] ?? 0),
      Attribute(name: 'Intelligence', base: attributes[AttrKey.intg] ?? 0),
      Attribute(name: 'Power', base: attributes[AttrKey.pow] ?? 0),
      Attribute(name: 'Size', base: attributes[AttrKey.siz] ?? 0),
      Attribute(name: 'Education', base: attributes[AttrKey.edu] ?? 0),
    ];
    c.attributes = attrsList;

    // ---------- HP / MP / Sanity ----------
    c.maxHP = hp;
    c.currentHP = hp;

    c.startingMP = mp;
    c.currentMP = mp;

    // ---------- Skills ----------
    // Seed base skill values (before any spend). Keep Credit Rating at base = 0.
    final skillsList = baseSkills.entries
        .map((e) => Skill(name: e.key, base: e.value))
        .toList();

    // Ensure Credit Rating is present and at least the occupation minimum.
    {
      final idx = skillsList.indexWhere((s) => s.name == 'Credit Rating');
      if (idx >= 0) {
        if (skillsList[idx].base < creditMin) {
          skillsList[idx].base = creditMin; // mutable Skill.base in your model
        }
      } else {
        skillsList.add(Skill(name: 'Credit Rating', base: creditMin));
      }
    }

    // Sort for stable UI, then assign.
    skillsList.sort((a, b) => a.name.compareTo(b.name));
    c.skills = skillsList;

    c.startingSanity = sanity;
    // Clamp currentSanity to computed maxSanity (uses Mythos in skills)
    final maxSan = c.maxSanity;
    c.currentSanity = (sanity > maxSan) ? maxSan : sanity;

    // ---------- Rebind rules so they see the updated character ----------
    _setCharacterInternal(
        c); // rebinds CreationRuleSet if it's a draft; no re-initialize

    // ---------- Persist ----------
    await saveCharacter();
  }
  // ----- Derived for Attributes tab -----

  /// Movement rate derived from the Character model (getter on Character).
  int? get movementRate => _character?.movementRate;

  /// Damage Bonus string (e.g., "-1d4", "0", "+1d4", "+1d6") derived from STR & SIZ.
  String get damageBonusText {
    if (_character == null) return '—';
    int str = 0, siz = 0;
    for (final a in _character!.attributes) {
      if (a.name == 'Strength') {
        str = a.base;
      } else if (a.name == 'Size') {
        siz = a.base;
      }
    }
    return calcDamageBonus(str, siz).db;
  }

  /// Build value (integer) derived from STR & SIZ.
  int? get buildValue {
    if (_character == null) return null;
    int str = 0, siz = 0;
    for (final a in _character!.attributes) {
      if (a.name == 'Strength') {
        str = a.base;
      } else if (a.name == 'Size') { 
        siz = a.base;
      }
    }
    return calcDamageBonus(str, siz).build;
  }

}
