import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

import 'package:coc_sheet/models/character.dart';
import 'package:coc_sheet/models/sheet_status.dart';
import 'package:coc_sheet/models/create_character_spec.dart';
import 'package:coc_sheet/models/classic_rules.dart' show AttrKey, calcHP, calcMP, calcSanity, buildBaseSkills;
import 'package:coc_sheet/models/occupation.dart';
import 'package:coc_sheet/models/attribute.dart';
import 'package:coc_sheet/models/skill.dart';

import 'package:coc_sheet/viewmodels/character_viewmodel.dart';
import 'package:coc_sheet/services/character_storage.dart';
import 'package:coc_sheet/services/occupation_storage.dart';
import 'package:coc_sheet/services/sheet_id_generator.dart';

/// -------------------- Fakes --------------------

class _FakeCharacterStorage implements CharacterStorage {
  final Map<String, Character> _byId = {};
  Character? lastStored;

  @override
  Future<void> store(Character character) async {
    _byId[character.sheetId] = character;
    lastStored = character;
  }

  @override
  Stream<List<Character>> getCharacters({Set<SheetStatus> statuses = const {SheetStatus.active, SheetStatus.archived}}) {
    final filtered = _byId.values
        .where((c) => statuses.contains(c.sheetStatus))
        .toList(growable: false);
    return Stream<List<Character>>.value(filtered);
  }

  @override
  Future<Character?> getRecent() async {
    // Not needed for this test
    return null;
  }

  @override
  Future<void> delete(String id) async {
    _byId.remove(id);
    if (lastStored?.sheetId == id) lastStored = null;
  }
}

class _FakeOccupationStorage implements OccupationStorage {
  _FakeOccupationStorage(this._occ);
  final Occupation _occ;

  @override
  Future<List<Occupation>> getAll() async => <Occupation>[_occ];

  @override
  Future<Occupation?> findById(String id) async {
    return _occ.id == id ? _occ : null;
  }

  @override
  Future<Occupation?> findByName(String name) async {
    return _occ.name == name ? _occ : null;
  }

  @override
  Future<int> getVersion() async => 1;
}

class _FixedSheetIdGenerator implements SheetIdGenerator {
  _FixedSheetIdGenerator(this._id);
  final String _id;
  @override
  String newId() => _id;
}

/// Convenience accessors
int _attr(List<Attribute> list, String name) =>
    list.firstWhere((a) => a.name == name).base;

int _skill(List<Skill> list, String name) =>
    list.firstWhere((s) => s.name == name).base;

/// -------------------- Test --------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('createFromSpec populates Character with classic values and saves it', () async {
    // Arrange
    final storage = _FakeCharacterStorage();
    final ids = _FixedSheetIdGenerator('TEST-1');

    final vm = CharacterViewModel(storage, ids: ids);

    final occupation = Occupation(
      id: 'police-detective',
      name: 'Police Detective',
      creditMin: 20,
      creditMax: 50,
      selectCount: 4,
      mandatorySkills: const ['Law', 'Psychology'],
      skillPool: const ['Listen', 'Spot Hidden', 'Drive Auto', 'First Aid'],
    );
    final occStorage = _FakeOccupationStorage(occupation);

    // Rolled/aged attributes in percent scale
    final attrs = <String, int>{
      AttrKey.str: 60,
      AttrKey.con: 65,
      AttrKey.dex: 55,
      AttrKey.app: 50,
      AttrKey.pow: 70,
      AttrKey.siz: 70,
      AttrKey.intg: 60,
      AttrKey.edu: 65,
    };

    final spec = CreateCharacterSpec(
      name: 'Jane Doe',
      age: 28,
      attributes: attrs,
      luck: 45,
      occupationId: 'police-detective',
      selectedSkills: const ['Law', 'Psychology', 'Listen', 'Spot Hidden'],
    );

    // Expected derived from helpers
    final expectedHP = calcHP(attrs[AttrKey.con]!, attrs[AttrKey.siz]!); // (65+70)/10 = 13
    final expectedMP = calcMP(attrs[AttrKey.pow]!);                      // 70/5 = 14
    final expectedSanity = calcSanity(attrs[AttrKey.pow]!);              // 70
    final expectedBaseSkills = buildBaseSkills(attrs);

    // Act
    await vm.createFromSpec(spec, occupationStorage: occStorage);

    // Assert storage was called and character exists
    final c = storage.lastStored;
    expect(c, isNotNull, reason: 'Character should have been saved');

    // Identity / status
    expect(c!.sheetId, 'TEST-1');
    expect(c.sheetStatus, SheetStatus.draft_classic, reason: 'Should remain a draft after creation');
    expect(c.name, 'Jane Doe');
    expect(c.occupation, 'Police Detective');
    expect(c.age, 28);

    // Luck
    expect(c.currentLuck, 45);

    // Attributes mapped to your names
    expect(_attr(c.attributes, 'Strength'), attrs[AttrKey.str]);
    expect(_attr(c.attributes, 'Constitution'), attrs[AttrKey.con]);
    expect(_attr(c.attributes, 'Dexterity'), attrs[AttrKey.dex]);
    expect(_attr(c.attributes, 'Appearance'), attrs[AttrKey.app]);
    expect(_attr(c.attributes, 'Power'), attrs[AttrKey.pow]);
    expect(_attr(c.attributes, 'Size'), attrs[AttrKey.siz]);
    expect(_attr(c.attributes, 'Intelligence'), attrs[AttrKey.intg]);
    expect(_attr(c.attributes, 'Education'), attrs[AttrKey.edu]);

    // HP / MP / Sanity
    expect(c.maxHP, expectedHP);
    expect(c.currentHP, expectedHP);
    expect(c.startingMP, expectedMP);
    expect(c.currentMP, expectedMP);

    // Skills seeded with bases (including dynamic)
    expect(_skill(c.skills, 'Dodge'), (attrs[AttrKey.dex]! / 2).floor());
    expect(_skill(c.skills, 'Language (Own)'), attrs[AttrKey.edu]);
    expect(_skill(c.skills, 'Credit Rating'), 0);
    expect(_skill(c.skills, 'Spot Hidden'), expectedBaseSkills['Spot Hidden']);

    // Sanity after skills set (Mythos base is 0 → maxSanity 99)
    expect(c.startingSanity, expectedSanity);
    expect(c.maxSanity, 99);
    expect(c.currentSanity, expectedSanity);
  });
}
