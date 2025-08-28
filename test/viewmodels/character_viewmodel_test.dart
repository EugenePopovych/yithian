// test/character_viewmodel_rules_test.dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

import 'package:coc_sheet/models/attribute.dart';
import 'package:coc_sheet/models/character.dart';
import 'package:coc_sheet/models/sheet_status.dart';
import 'package:coc_sheet/models/skill.dart';
import 'package:coc_sheet/models/occupation.dart';
import 'package:coc_sheet/models/skill_bases.dart';
import 'package:coc_sheet/models/skill_specialization.dart';
import 'package:coc_sheet/models/classic_rules.dart';
import 'package:coc_sheet/models/create_character_spec.dart';
import 'package:coc_sheet/services/character_storage.dart';
import 'package:coc_sheet/services/sheet_id_generator.dart';
import 'package:coc_sheet/services/occupation_storage.dart';
import 'package:coc_sheet/viewmodels/character_viewmodel.dart';

/// ---------- Fakes ----------
class SeqIdGen implements SheetIdGenerator {
  int _i = 0;
  @override
  String newId() => 'id-${++_i}';
}

class FakeCharacterStorage implements CharacterStorage {
  final _db = <String, Character>{};
  String? _recentId;
  final _bus = StreamController<List<Character>>.broadcast();

  Character? get lastStored => _recentId != null ? _db[_recentId] : null;

  void dispose() => _bus.close();

  void _emit() {
    _bus.add(_db.values.toList(growable: false));
  }

  @override
  Stream<List<Character>> getCharacters({
    Set<SheetStatus> statuses = const {
      SheetStatus.active,
      SheetStatus.archived
    },
  }) {
    late StreamController<List<Character>> out;
    late StreamSubscription sub;

    List<Character> snapshot() => _db.values
        .where((c) => statuses.contains(c.sheetStatus))
        .toList(growable: false);

    void forward([_]) => out.add(snapshot());

    out = StreamController<List<Character>>.broadcast(
      onListen: () {
        forward(); // emit AFTER a subscriber attaches
        sub = _bus.stream.listen(forward);
      },
      onCancel: () async {
        await sub.cancel();
        await out.close();
      },
    );

    return out.stream;
  }

  @override
  Future<void> store(Character c) async {
    _db[c.sheetId] = c;
    _recentId = c.sheetId;
    _emit();
  }

  @override
  Future<Character?> getRecent() async {
    if (_recentId != null) return _db[_recentId];
    return _db.isNotEmpty ? _db.values.first : null;
  }

  @override
  Future<void> delete(String id) async {
    _db.remove(id);
    if (_recentId == id) _recentId = null;
    _emit();
  }
}

class FakeOccupationStorage implements OccupationStorage {
  final Map<String, Occupation> _byId;

  FakeOccupationStorage(Occupation occ) : _byId = {occ.id: occ};

  @override
  Future<Occupation?> findById(String id) async => _byId[id];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// ---------- Utilities -----

int skill(List<Skill> skills, String name) {
  final found = skills.firstWhere(
    (sk) => sk.displayName == name || sk.name == name,
    orElse: () => Skill(name: name, base: 0),
  );
  return found.base;
}

/// ---------- Tests ----------
void main() {
  group('CharacterViewModel (with rules)', () {
    test('Initial character data should be correct (seeded storage)', () async {
      final storage = FakeCharacterStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());

      final seeded = Character(
        sheetId: 'seed-1',
        sheetStatus: SheetStatus.active,
        sheetName: 'Seed',
        name: 'Investigator',
        age: 28,
        pronouns: 'they/them',
        birthplace: 'Arkham',
        occupation: 'PI',
        residence: 'Arkham, MA',
        currentHP: 10,
        maxHP: 12,
        currentSanity: 50,
        startingSanity: 60,
        currentMP: 8,
        startingMP: 8,
        currentLuck: 40,
        attributes: [Attribute(name: 'Strength', base: 50)],
        skills: [Skill(name: 'Spot Hidden', base: 25)],
      );
      await storage.store(seeded);

      await vm.init();

      expect(vm.character, isNotNull);
      expect(vm.character!.name, equals('Investigator'));
      expect(vm.character!.attributes.length, greaterThan(0));
      expect(vm.character!.skills.length, greaterThan(0));
    });

    test('Updating an attribute should notify listeners', () async {
      final storage = FakeCharacterStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());
      await vm.createCharacter(); // draft_classic by default
      // seed attribute
      vm.character!.attributes = [Attribute(name: 'Strength', base: 40)];

      var notified = false;
      vm.addListener(() => notified = true);

      vm.updateAttribute('Strength', 80);

      expect(
        vm.character!.attributes.firstWhere((a) => a.name == 'Strength').base,
        equals(80),
      );
      expect(notified, isTrue);
    });

    test('Updating a skill should notify listeners', () async {
      final storage = FakeCharacterStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());
      await vm.createCharacter(); // draft_classic

      // Seed pool and skill
      vm.updateAttribute('Intelligence', 40); // personal pool = 80
      final skill = Skill(name: 'Spot Hidden', base: 25);
      vm.character!.skills = [skill];

      var notified = false;
      vm.addListener(() => notified = true);

      vm.updateSkill(skill: skill, newValue: 90); // spends 65 of 80

      expect(
        vm.character!.skills.firstWhere((s) => s.name == 'Spot Hidden').base,
        90,
      );
      expect(vm.personalPointsRemaining, 15);
      expect(notified, isTrue);
    });

    test('createCharacter generates id and binds classic rules', () async {
      final storage = FakeCharacterStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());

      await vm.createCharacter(name: 'Jane', occupation: 'Detective');

      final c = vm.character!;
      expect(c.sheetId, equals('id-1'));
      expect(c.sheetStatus, SheetStatus.draftClassic);
      expect(vm.rules, isNotNull);
      expect(vm.rules!.label, contains('Classic'));
    });

    test('Classic: attribute clamp to max 90', () async {
      final storage = FakeCharacterStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());
      await vm.createCharacter();

      vm.character!.attributes = [Attribute(name: 'Strength', base: 50)];
      vm.updateAttribute('Strength', 200); // exceeds classic cap

      expect(
        vm.character!.attributes.firstWhere((a) => a.name == 'Strength').base,
        equals(90),
      );
    });

    test(
        'Classic: INT drives personal points; spend partially when exceeding pool',
        () async {
      final storage = FakeCharacterStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());
      await vm.createCharacter();

      // Set INT=40 => personal pool = 80 (via rules update path)
      vm.updateAttribute('Intelligence', 40);
      expect(vm.personalPointsRemaining, 80);

      // Seed skill base 25, try to raise by 95 -> should grant only 80 -> 105
      final skill = Skill(name: 'Spot Hidden', base: 25);
      vm.character!.skills = [skill];
      vm.updateSkill(skill: skill, newValue: 120);

      expect(
        vm.character!.skills.firstWhere((s) => s.name == 'Spot Hidden').base,
        equals(105),
      );
      expect(vm.personalPointsRemaining, 0);
    });

    test('Classic: Cthulhu Mythos increase is blocked', () async {
      final storage = FakeCharacterStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());
      await vm.createCharacter();
      vm.updateAttribute('Intelligence', 40); // establish pool

      final skill = Skill(name: 'Cthulhu Mythos', base: 0);
      vm.character!.skills = [skill];

      vm.updateSkill(skill: skill, newValue: 10); // should be blocked

      expect(
        vm.character!.skills.firstWhere((s) => s.name == 'Cthulhu Mythos').base,
        0,
      );
    });

    test('finalizeCreation respects rules (not allowed while points remain)',
        () async {
      final storage = FakeCharacterStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());
      await vm.createCharacter();
      vm.updateAttribute('Education', 40); // occ = 160
      vm.updateAttribute('Intelligence', 40); // per = 80

      expect(vm.canFinalizeCreation, isFalse);
      await vm.finalizeCreation();
      // still draft because pools not zero
      expect(vm.character!.sheetStatus.isDraft, isTrue);
    });
  });

  test('init loads recent if available (drafts allowed)', () async {
    final storage = FakeCharacterStorage();
    final vm = CharacterViewModel(storage, ids: SeqIdGen());

    // seed: active first, then draft so draft becomes "recent"
    await storage.store(Character(
      sheetId: 'a1',
      sheetStatus: SheetStatus.active,
      sheetName: 'A',
      name: 'Active',
      age: 0,
      pronouns: '',
      birthplace: '',
      occupation: '',
      residence: '',
      currentHP: 0,
      maxHP: 0,
      currentSanity: 0,
      startingSanity: 0,
      currentMP: 0,
      startingMP: 0,
      currentLuck: 0,
      attributes: const [],
      skills: const [],
    ));
    await storage.store(Character(
      sheetId: 'd1',
      sheetStatus: SheetStatus.draftClassic,
      sheetName: 'D',
      name: 'Draft',
      age: 0,
      pronouns: '',
      birthplace: '',
      occupation: '',
      residence: '',
      currentHP: 0,
      maxHP: 0,
      currentSanity: 0,
      startingSanity: 0,
      currentMP: 0,
      startingMP: 0,
      currentLuck: 0,
      attributes: const [],
      skills: const [],
    ));

    await vm.init();

    expect(vm.character, isNotNull);
    expect(vm.character!.sheetId, 'd1'); // recent draft picked
    expect(vm.character!.sheetStatus.isDraft, true);
  });

  group('CharacterViewModel stream + delete', () {
    test('charactersStream emits only non-drafts and updates on changes',
        () async {
      final storage = FakeCharacterStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());

      // Seed data BEFORE listening (initial emission exists but we will trigger another)
      await storage.store(Character(
        sheetId: 'a1',
        sheetStatus: SheetStatus.active,
        sheetName: 'A1',
        name: 'Active One',
        age: 0,
        pronouns: '',
        birthplace: '',
        occupation: '',
        residence: '',
        currentHP: 0,
        maxHP: 0,
        currentSanity: 0,
        startingSanity: 0,
        currentMP: 0,
        startingMP: 0,
        currentLuck: 0,
        attributes: const [],
        skills: const [],
      ));
      await storage.store(Character(
        sheetId: 'ar2',
        sheetStatus: SheetStatus.archived,
        sheetName: 'AR2',
        name: 'Archived Two',
        age: 0,
        pronouns: '',
        birthplace: '',
        occupation: '',
        residence: '',
        currentHP: 0,
        maxHP: 0,
        currentSanity: 0,
        startingSanity: 0,
        currentMP: 0,
        startingMP: 0,
        currentLuck: 0,
        attributes: const [],
        skills: const [],
      ));
      await storage.store(Character(
        sheetId: 'd1',
        sheetStatus: SheetStatus.draftClassic,
        sheetName: 'D1',
        name: 'Draft One',
        age: 0,
        pronouns: '',
        birthplace: '',
        occupation: '',
        residence: '',
        currentHP: 0,
        maxHP: 0,
        currentSanity: 0,
        startingSanity: 0,
        currentMP: 0,
        startingMP: 0,
        currentLuck: 0,
        attributes: const [],
        skills: const [],
      ));

      final emissions = <Set<String>>[];
      final sub = vm
          .charactersStream() // defaults to {active, archived}
          .listen((list) => emissions.add(list.map((c) => c.sheetId).toSet()));

      // Trigger an update after we are listening
      await storage.store(Character(
        sheetId: 'a3',
        sheetStatus: SheetStatus.active,
        sheetName: 'A3',
        name: 'Active Three',
        age: 0,
        pronouns: '',
        birthplace: '',
        occupation: '',
        residence: '',
        currentHP: 0,
        maxHP: 0,
        currentSanity: 0,
        startingSanity: 0,
        currentMP: 0,
        startingMP: 0,
        currentLuck: 0,
        attributes: const [],
        skills: const [],
      ));

      // Allow stream microtask to deliver
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(emissions.isNotEmpty, true);
      // Draft 'd1' must be excluded; 'a1','ar2','a3' must be present
      expect(emissions.last, equals({'a1', 'ar2', 'a3'}));

      await sub.cancel();
    });

    test('deleteById removes from storage and clears current if it matches',
        () async {
      final storage = FakeCharacterStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());

      await storage.store(Character(
        sheetId: 'x1',
        sheetStatus: SheetStatus.active,
        sheetName: 'X1',
        name: 'One',
        age: 0,
        pronouns: '',
        birthplace: '',
        occupation: '',
        residence: '',
        currentHP: 0,
        maxHP: 0,
        currentSanity: 0,
        startingSanity: 0,
        currentMP: 0,
        startingMP: 0,
        currentLuck: 0,
        attributes: const [],
        skills: const [],
      ));
      await storage.store(Character(
        sheetId: 'x2',
        sheetStatus: SheetStatus.active,
        sheetName: 'X2',
        name: 'Two',
        age: 0,
        pronouns: '',
        birthplace: '',
        occupation: '',
        residence: '',
        currentHP: 0,
        maxHP: 0,
        currentSanity: 0,
        startingSanity: 0,
        currentMP: 0,
        startingMP: 0,
        currentLuck: 0,
        attributes: const [],
        skills: const [],
      ));

      await vm.loadCharacter('x2');
      expect(vm.character?.sheetId, 'x2');

      final next = vm
          .charactersStream(statuses: SheetStatus.values.toSet())
          .firstWhere((list) => list.every((c) => c.sheetId != 'x2'));

      await vm.deleteById('x2');

      final list = await next.timeout(const Duration(seconds: 2));
      expect(list.map((c) => c.sheetId).toSet(), equals({'x1'}));
      expect(vm.hasCharacter, isFalse);
    });
  });

  // -------------------------
  // NEW: Specialization helpers
  // -------------------------
  group('CharacterViewModel specialization helpers', () {
    test(
        'addSpecializedSkill creates generic family if missing and adds spec with correct base',
        () async {
      final storage = FakeCharacterStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());
      await vm.createCharacter();

      // Start with no skills to make assertions clear
      vm.character!.skills = [];

      // Add "Science (Biology)"
      await vm.addSpecializedSkill(
          category: SkillSpecialization.familyScience,
          specialization: 'Biology');

      final skills = vm.character!.skills;

      // Generic "Science" exists
      final generic = skills.firstWhere(
          (s) => s.name == SkillSpecialization.familyScience,
          orElse: () => Skill(name: '!', base: -1));
      expect(generic.name, SkillSpecialization.familyScience);
      expect(generic.category, SkillSpecialization.familyScience);
      expect(generic.specialization, isNull);
      expect(generic.base,
          SkillBases.baseForGeneric(SkillSpecialization.familyScience));

      // Specialized "Science (Biology)" exists with correct base
      final specName = SkillSpecialization.displayName(
          SkillSpecialization.familyScience, 'Biology');
      final bio = skills.firstWhere((s) => s.name == specName,
          orElse: () => Skill(name: '!', base: -1));
      expect(bio.name, specName);
      expect(bio.category, SkillSpecialization.familyScience);
      expect(bio.specialization, 'Biology');
      expect(
          bio.base,
          SkillBases.baseForSpecialized(
              SkillSpecialization.familyScience, 'Biology'));
    });

    test('addSpecializedSkill is idempotent (no duplicates on same spec)',
        () async {
      final storage = FakeCharacterStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());
      await vm.createCharacter();

      vm.character!.skills = [];

      await vm.addSpecializedSkill(
          category: SkillSpecialization.familyArtCraft,
          specialization: 'Painting');
      await vm.addSpecializedSkill(
          category: SkillSpecialization.familyArtCraft,
          specialization: 'Painting');

      final count = vm.character!.skills
          .where((s) => s.name == 'Art/Craft (Painting)')
          .length;
      expect(count, 1);

      // Generic exists exactly once too
      final genCount =
          vm.character!.skills.where((s) => s.name == 'Art/Craft').length;
      expect(genCount, 1);
    });

    test('removeSkillByName removes only specialization, keeps generic family',
        () async {
      final storage = FakeCharacterStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());
      await vm.createCharacter();

      vm.character!.skills = [];

      await vm.addSpecializedSkill(
          category: SkillSpecialization.familyScience,
          specialization: 'Biology');
      await vm.addSpecializedSkill(
          category: SkillSpecialization.familyScience,
          specialization: 'Chemistry');

      // Remove Biology
      await vm.removeSkillByName('Science (Biology)');

      final names = vm.character!.skills.map((s) => s.name).toSet();

      // Biology removed, Chemistry still there, generic Science still there
      expect(names.contains('Science (Biology)'), isFalse);
      expect(names.contains('Science (Chemistry)'), isTrue);
      expect(names.contains('Science'), isTrue);
    });
  });

  group('Specialization skills — classic rules', () {
    test('editing a generic template is forbidden in creation', () async {
      // Arrange
      final storage = FakeCharacterStorage();
      final ids = SeqIdGen();
      final vm = CharacterViewModel(storage, ids: ids);

      final occupation = Occupation(
        id: 'gen',
        name: 'Generalist',
        creditMin: 0,
        creditMax: 99,
        selectCount: 0,
        mandatorySkills: const [],
        skillPool: const [],
      );
      final occStorage = FakeOccupationStorage(occupation);

      final attrs = <String, int>{
        AttrKey.str: 50,
        AttrKey.con: 50,
        AttrKey.dex: 50,
        AttrKey.app: 50,
        AttrKey.pow: 50,
        AttrKey.siz: 50,
        AttrKey.intg: 50,
        AttrKey.edu: 50,
      };

      final spec = CreateCharacterSpec(
        name: 'Tester',
        age: 25,
        attributes: attrs,
        luck: 40,
        occupationId: 'gen',
        selectedSkills: const [],
      );

      await vm.createFromSpec(spec, occupationStorage: occStorage);
      await Future<void>.delayed(Duration.zero); // let initial save finish

      // Act: try to edit a LOCKED template row
      final skill = vm.character?.skills.firstWhere((s) => s.name == 'Science (Any)');
      expect(skill, isNotNull, reason: 'Skill "Science (Any)" should exist');
      if (skill != null) {
        vm.updateSkill(skill: skill, newValue: 20);
        await Future<void>.delayed(Duration.zero); // let save finish

        // Assert: change rejected with a specific message
        final evt = vm.lastCreationUpdate.value;
        expect(evt, isNotNull);
        expect(evt!.result.applied, isFalse);
        expect(evt.result.messages, contains('forbidden_generic_template'));

        // And ensure we did NOT suddenly add a 'Science (Any)' at 20
        final c = storage.lastStored!;
        final maybe20 = c.skills.any(
          (sk) =>
              (sk.displayName == 'Science (Any)' || sk.name == 'Science (Any)') &&
              sk.base == 20,
        );
        expect(maybe20, isFalse);
      }
    });

    test(
        'specialization spends from OCCUPATION pool when its category is occupational',
        () async {
      // Arrange
      final storage = FakeCharacterStorage();
      final ids = SeqIdGen();
      final vm = CharacterViewModel(storage, ids: ids);

      // Occupation with CR min = 40 (consumes 40 OCC on replay)
      final occupation = Occupation(
        id: 'researcher',
        name: 'Researcher',
        creditMin: 40,
        creditMax: 70,
        selectCount: 1,
        mandatorySkills: const [],
        // We will pick Science as the occupational category via selectedSkills:
        skillPool: const ['Science (Any)'],
      );
      final occStorage = FakeOccupationStorage(occupation);

      // EDU=50 → OCC total = 200; INT=40 → PERSONAL total = 80
      final attrs = <String, int>{
        AttrKey.str: 40,
        AttrKey.con: 40,
        AttrKey.dex: 40,
        AttrKey.app: 40,
        AttrKey.pow: 40,
        AttrKey.siz: 40,
        AttrKey.intg: 40, // personal: 80
        AttrKey.edu: 50, // occupation: 200
      };

      final spec = CreateCharacterSpec(
        name: 'Occ Spec',
        age: 30,
        attributes: attrs,
        luck: 35,
        occupationId: 'researcher',
        selectedSkills: const [
          'Science (Biology)'
        ], // treat Science category as OCC
      );

      await vm.createFromSpec(spec, occupationStorage: occStorage);
      await Future<void>.delayed(
          Duration.zero); // let initial save/replay finish

      // Act
      final sk1 = vm.character!.skills.firstWhere(
        (s) =>
            s.name == 'Science (Biology)' ||
            s.displayName == 'Science (Biology)',
      );
      expect(skill, isNotNull);
      vm.updateSkill(skill: sk1, newValue: 999);
      await Future<void>.delayed(Duration.zero);

      // Assert
      final c1 = storage.lastStored!;
      expect(skill(c1.skills, 'Science (Biology)'), 161);
    });

    test(
        'specialization spends from PERSONAL pool when its category is NOT occupational',
        () async {
      // Arrange
      final storage = FakeCharacterStorage();
      final ids = SeqIdGen();
      final vm = CharacterViewModel(storage, ids: ids);

      final occupation = Occupation(
        id: 'driver',
        name: 'Driver',
        creditMin: 20,
        creditMax: 50,
        selectCount: 0,
        mandatorySkills: const ['Drive Auto'],
        // NOT Science here
        skillPool: const ['Drive Auto', 'Listen'],
      );
      final occStorage = FakeOccupationStorage(occupation);

      // EDU=50 → OCC = 200; INT=40 → PERSONAL = 80
      final attrs = <String, int>{
        AttrKey.str: 40,
        AttrKey.con: 40,
        AttrKey.dex: 40,
        AttrKey.app: 40,
        AttrKey.pow: 40,
        AttrKey.siz: 40,
        AttrKey.intg: 40, // personal: 80
        AttrKey.edu: 50, // occupation: 200
      };

      final spec = CreateCharacterSpec(
        name: 'Per Spec',
        age: 30,
        attributes: attrs,
        luck: 35,
        occupationId: 'driver',
        selectedSkills: const ['Drive Auto'], // Science not occupational
      );

      await vm.createFromSpec(spec, occupationStorage: occStorage);
      await Future<void>.delayed(
          Duration.zero); // let initial save/replay finish

      // Add a true specialization first
      await vm.addSpecializedSkill(
          category: 'Science', specialization: 'Chemistry');
      await Future<void>.delayed(Duration.zero);

      // Act
      final sk2 = vm.character!.skills.firstWhere(
        (s) =>
            s.name == 'Science (Chemistry)' ||
            s.displayName == 'Science (Chemistry)',
      );
      vm.updateSkill(skill: sk2, newValue: 999);
      await Future<void>.delayed(Duration.zero);

      // Assert
      final c2 = storage.lastStored!;
      expect(skill(c2.skills, 'Science (Chemistry)'), 61);
    });

    test('specialized OCCUPATION pick spends from OCCUPATION pool', () async {
      // Arrange
      final storage = FakeCharacterStorage();
      final ids = SeqIdGen();
      final vm = CharacterViewModel(storage, ids: ids);

      // Occupation has Science in its pool (as a category)
      final occupation = Occupation(
        id: 'researcher',
        name: 'Researcher',
        creditMin: 40,
        creditMax: 70,
        selectCount: 1,
        mandatorySkills: const [],
        skillPool: const ['Science (Any)'],
      );

      final attrs = <String, int>{
        AttrKey.str: 50,
        AttrKey.con: 50,
        AttrKey.siz: 50,
        AttrKey.dex: 50,
        AttrKey.app: 50,
        AttrKey.intg: 40, // Personal = 80
        AttrKey.pow: 50,
        AttrKey.edu: 50, // Occupation = 200
      };

      // Note: we select a specialized skill directly as an OCCUPATION pick
      final spec = CreateCharacterSpec(
        name: 'Spec Occ',
        age: 30,
        attributes: attrs,
        luck: 35,
        occupationId: 'researcher',
        selectedSkills: const ['Science (Biology)'],
      );

      final occStorage = FakeOccupationStorage(occupation);
      await vm.createFromSpec(spec, occupationStorage: occStorage);
      await Future<void>.delayed(Duration.zero);

      // Act
      final sk3 = vm.character!.skills.firstWhere(
        (s) =>
            s.name == 'Science (Biology)' ||
            s.displayName == 'Science (Biology)',
      );
      vm.updateSkill(skill: sk3, newValue: 999);
      await Future<void>.delayed(Duration.zero);

      // Assert
      final c3 = storage.lastStored!;
      expect(skill(c3.skills, 'Science (Biology)'), 161);
    });
  });
}
