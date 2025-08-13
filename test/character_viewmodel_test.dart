// test/character_viewmodel_rules_test.dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

import 'package:coc_sheet/models/attribute.dart';
import 'package:coc_sheet/models/character.dart';
import 'package:coc_sheet/models/sheet_status.dart';
import 'package:coc_sheet/models/skill.dart';

import 'package:coc_sheet/services/character_storage.dart';
import 'package:coc_sheet/services/sheet_id_generator.dart';

import 'package:coc_sheet/viewmodels/character_viewmodel.dart';

/// ---------- Fakes ----------
class SeqIdGen implements SheetIdGenerator {
  int _i = 0;
  @override
  String newId() => 'id-${++_i}';
}

class FakeStorage implements CharacterStorage {
  final _db = <String, Character>{};
  String? _recentId;
  final _bus = StreamController<List<Character>>.broadcast();

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

/// ---------- Tests ----------
void main() {
  group('CharacterViewModel (with rules)', () {
    test('Initial character data should be correct (seeded storage)', () async {
      final storage = FakeStorage();
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
      final storage = FakeStorage();
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
      final storage = FakeStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());
      await vm.createCharacter(); // draft_classic

      // Seed pool and skill
      vm.updateAttribute('Intelligence', 40); // personal pool = 80
      vm.character!.skills = [Skill(name: 'Spot Hidden', base: 25)];

      var notified = false;
      vm.addListener(() => notified = true);

      vm.updateSkill('Spot Hidden', 90); // spends 65 of 80

      expect(
        vm.character!.skills.firstWhere((s) => s.name == 'Spot Hidden').base,
        90,
      );
      expect(vm.personalPointsRemaining, 15);
      expect(notified, isTrue);
    });

    test('createCharacter generates id and binds classic rules', () async {
      final storage = FakeStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());

      await vm.createCharacter(name: 'Jane', occupation: 'Detective');

      final c = vm.character!;
      expect(c.sheetId, equals('id-1'));
      expect(c.sheetStatus, SheetStatus.draft_classic);
      expect(vm.rules, isNotNull);
      expect(vm.rules!.label, contains('Classic'));
    });

    test('Classic: attribute clamp to max 90', () async {
      final storage = FakeStorage();
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
      final storage = FakeStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());
      await vm.createCharacter();

      // Set INT=40 => personal pool = 80 (via rules update path)
      vm.updateAttribute('Intelligence', 40);
      expect(vm.personalPointsRemaining, 80);

      // Seed skill base 25, try to raise by 95 -> should grant only 80 -> 105
      vm.character!.skills = [Skill(name: 'Spot Hidden', base: 25)];
      vm.updateSkill('Spot Hidden', 120);

      expect(
        vm.character!.skills.firstWhere((s) => s.name == 'Spot Hidden').base,
        equals(105),
      );
      expect(vm.personalPointsRemaining, 0);
    });

    test('Classic: Cthulhu Mythos increase is blocked', () async {
      final storage = FakeStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());
      await vm.createCharacter();
      vm.updateAttribute('Intelligence', 40); // establish pool

      vm.character!.skills = [Skill(name: 'Cthulhu Mythos', base: 0)];

      vm.updateSkill('Cthulhu Mythos', 10); // should be blocked

      expect(
        vm.character!.skills.firstWhere((s) => s.name == 'Cthulhu Mythos').base,
        0,
      );
    });

    test('finalizeCreation respects rules (not allowed while points remain)',
        () async {
      final storage = FakeStorage();
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
    final storage = FakeStorage();
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
      sheetStatus: SheetStatus.draft_classic,
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
      final storage = FakeStorage();
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
        sheetStatus: SheetStatus.draft_classic,
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
      final storage = FakeStorage();
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
}
