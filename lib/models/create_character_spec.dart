import 'package:flutter/foundation.dart';

/// Minimal spec used to materialize a draft character later.
/// Derived stats and pools will be computed by CharacterViewModel rules.
@immutable
class CreateCharacterSpec {
  final String name;
  final int age;
  final Map<String, int> attributes; // keys from AttrKey
  final int luck;
  final String occupationId;
  final List<String> selectedSkills; // includes mandatory

  const CreateCharacterSpec({
    required this.name,
    required this.age,
    required this.attributes,
    required this.luck,
    required this.occupationId,
    required this.selectedSkills,
  });
}
