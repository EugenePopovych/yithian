import 'dart:async';
import 'package:coc_sheet/models/character.dart';
import 'package:coc_sheet/models/sheet_status.dart';

typedef SheetId = String;

abstract class CharacterStorage {
  Future<void> store(Character character);

  Stream<List<Character>> getCharacters({
    Set<SheetStatus> statuses = const {
      SheetStatus.active,
      SheetStatus.archived,
    },
  });

  Future<Character?> getRecent();

  Future<void> delete(SheetId id);
}
