import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:coc_sheet/models/hive_character.dart';
import 'package:coc_sheet/models/hive_attribute.dart';
import 'package:coc_sheet/models/hive_skill.dart';

/// Schema versioning kept simple: store a single int in a tiny meta box.
/// Bump [Schema.current] only when you add a migration step.
class Schema {
  static const current = 1;
  static const metaBox = 'meta';
  static const key = 'schemaVersion';
}

/// Call once before any repository/box usage.
Future<void> initHive() async {
  await Hive.initFlutter();
  _registerAdapters();

  // Ensure meta box exists and schema is initialized.
  final meta = await Hive.openBox<int>(Schema.metaBox);
  if (!meta.containsKey(Schema.key)) {
    await meta.put(Schema.key, Schema.current);
  }
}

void _registerAdapters() {
  if (!Hive.isAdapterRegistered(HiveCharacterAdapter().typeId)) {
    Hive.registerAdapter(HiveCharacterAdapter());
  }
  if (!Hive.isAdapterRegistered(HiveAttributeAdapter().typeId)) {
    Hive.registerAdapter(HiveAttributeAdapter());
  }
  if (!Hive.isAdapterRegistered(HiveSkillAdapter().typeId)) {
    Hive.registerAdapter(HiveSkillAdapter());
  }
}
