import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:coc_sheet/models/attribute.dart';
import 'package:coc_sheet/models/character.dart';
import 'package:coc_sheet/models/sheet_status.dart';
import 'package:coc_sheet/models/skill.dart';
import 'package:coc_sheet/services/character_storage.dart';
import 'package:coc_sheet/services/sheet_id_generator.dart';
import 'package:coc_sheet/viewmodels/character_viewmodel.dart';

/// ---- Fakes ----
class SeqIdGen implements SheetIdGenerator {
  int _i = 0;
  @override
  String newId() => 'id-${++_i}';
}

class FakeStorage implements CharacterStorage {
  final _db = <String, Character>{};
  String? _recentId;
  int storeCount = 0;

  final _bus = StreamController<List<Character>>.broadcast();

  void _emit() => _bus.add(_db.values.toList(growable: false));

  @override
  Future<void> store(Character c) async {
    _db[c.sheetId] = c;
    _recentId = c.sheetId;
    storeCount++;
    _emit();
  }

  @override
  Stream<List<Character>> getCharacters({Set<SheetStatus> statuses = const {SheetStatus.active, SheetStatus.archived}}) {
    // Filter per-subscriber
    final out = StreamController<List<Character>>.broadcast();
    void forward(List<Character> all) =>
        out.add(all.where((c) => statuses.contains(c.sheetStatus)).toList());
    final sub = _bus.stream.listen(forward);
    // initial
    forward(_db.values.toList(growable: false));
    out.onCancel = () async => sub.cancel();
    return out.stream;
  }

  @override
  Future<Character?> getRecent() async {
    if (_recentId != null && _db.containsKey(_recentId)) return _db[_recentId];
    if (_db.isNotEmpty) return _db.values.first;
    return null;
  }

  @override
  Future<void> delete(String id) async {
    _db.remove(id);
    if (_recentId == id) _recentId = null;
    _emit();
  }
}

/// ---- Tests ----
void main() {
  group('CharacterViewModel', () {
    test('createCharacter creates, assigns id, notifies, and persists', () async {
      final storage = FakeStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());

      var notified = false;
      vm.addListener(() => notified = true);

      await vm.createCharacter(); // defaults
      expect(vm.character, isNotNull);
      expect(vm.character!.sheetId, 'id-1');
      expect(vm.character!.sheetStatus, SheetStatus.draft_classic);
      expect(vm.character!.sheetName, 'New Sheet');
      expect(notified, isTrue);
      expect(storage.storeCount, 1);
    });

    test('createCharacter with params applies name, occupation, and status', () async {
      final storage = FakeStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());

      await vm.createCharacter(
        name: 'Jane',
        occupation: 'Detective',
        status: SheetStatus.draft_points,
      );

      final c = vm.character!;
      expect(c.sheetId, 'id-1');
      expect(c.name, 'Jane');
      expect(c.occupation, 'Detective');
      expect(c.sheetStatus, SheetStatus.draft_points);
    });

    test('updateAttribute notifies and persists', () async {
      final storage = FakeStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());
      await vm.createCharacter();

      // seed attribute so update hits existing entry
      vm.character!.attributes = [Attribute(name: 'Strength', base: 10)];

      var notified = false;
      vm.addListener(() => notified = true);

      vm.updateAttribute('Strength', 80);

      expect(
        vm.character!.attributes.firstWhere((a) => a.name == 'Strength').base,
        80,
      );
      expect(notified, isTrue);
      expect(storage.storeCount, greaterThan(1)); // create + update
    });

    test('updateSkill notifies and persists', () async {
      final storage = FakeStorage();
      final vm = CharacterViewModel(storage, ids: SeqIdGen());
      await vm.createCharacter();

      // seed skill so update hits existing entry
      vm.character!.skills = [Skill(name: 'Spot Hidden', base: 10)];

      var notified = false;
      vm.addListener(() => notified = true);

      vm.updateSkill('Spot Hidden', 90);

      expect(
        vm.character!.skills.firstWhere((s) => s.name == 'Spot Hidden').base,
        90,
      );
      expect(notified, isTrue);
      expect(storage.storeCount, greaterThan(1));
    });


    test('init loads recent if available (drafts allowed)', () async {
      final storage = FakeStorage();
      final ids = SeqIdGen();
      // Pre-seed storage
      final seeded = Character(
        sheetId: ids.newId(),
        sheetStatus: SheetStatus.draft_free,
        sheetName: 'Seed',
        name: 'Seed',
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
        attributes: const <Attribute>[],
        skills: const <Skill>[],
      );
      await storage.store(seeded);

      final vm = CharacterViewModel(storage, ids: ids);
      await vm.init();

      expect(vm.character, isNotNull);
      expect(vm.character!.sheetId, 'id-1');
      expect(vm.character!.sheetStatus, SheetStatus.draft_free);
      expect(vm.character!.name, 'Seed');
    });
  });
}
