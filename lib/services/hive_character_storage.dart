import 'dart:async';

import 'package:hive/hive.dart';
import 'package:coc_sheet/models/character.dart';
import 'package:coc_sheet/models/hive_character.dart';
import 'package:coc_sheet/models/sheet_status.dart';
import 'package:coc_sheet/services/character_storage.dart';

const String _charactersBox = 'characters';
const String _recentBox = 'recent';
const String _recentKey = 'recentCharacterId';

class HiveCharacterStorage implements CharacterStorage {
  Future<Box<HiveCharacter>> _openCharacters() async {
    if (Hive.isBoxOpen(_charactersBox)) {
      return Hive.box<HiveCharacter>(_charactersBox);
    }
    return Hive.openBox<HiveCharacter>(_charactersBox);
  }

  Future<Box<String>> _openRecent() async {
    if (Hive.isBoxOpen(_recentBox)) {
      return Hive.box<String>(_recentBox);
    }
    return Hive.openBox<String>(_recentBox);
  }

  @override
  Future<void> store(Character character) async {
    final box = await _openCharacters();
    final hiveObj = HiveCharacter.fromCharacter(character);
    await box.put(character.sheetId, hiveObj);

    final recent = await _openRecent();
    await recent.put(_recentKey, character.sheetId);
  }

  @override
  Stream<List<Character>> getCharacters({
    Set<SheetStatus> statuses = const {
      SheetStatus.active,
      SheetStatus.archived
    },
  }) async* {
    final box = await _openCharacters();

    List<Character> snapshot() {
      final out = <Character>[];
      for (final key in box.keys) {
        if (key is! String) continue;
        final h = box.get(key);
        if (h == null) continue;
        final c = h.toCharacter();
        if (statuses.contains(c.sheetStatus)) out.add(c);
      }
      return out;
    }

    final controller = StreamController<List<Character>>.broadcast();
    void emit() => controller.add(snapshot());

    final sub = box.watch().listen((_) => emit());
    emit();

    controller.onCancel = () async {
      await sub.cancel();
      await controller.close();
    };

    yield* controller.stream;
  }

  @override
  Future<Character?> getRecent() async {
    final recent = await _openRecent();
    final lastId = recent.get(_recentKey);
    final box = await _openCharacters();

    Character? byId(String id) {
      final h = box.get(id);
      return h?.toCharacter(); // adjust if needed
    }

    if (lastId != null) {
      final c = byId(lastId);
      if (c != null) return c;
    }

    // Fallback: first non-draft, else any.
    for (final k in box.keys) {
      if (k is! String) continue;
      final c = byId(k);
      if (c != null) return c;
    }
    for (final k in box.keys) {
      if (k is! String) continue;
      final c = byId(k);
      if (c != null) return c;
    }
    return null;
  }

  @override
  Future<void> delete(SheetId id) async {
    final box = await _openCharacters();
    await box.delete(id);

    final recent = await _openRecent();
    if (recent.get(_recentKey) == id) {
      await recent.delete(_recentKey);
    }
  }
}
