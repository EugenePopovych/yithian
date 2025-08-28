import 'package:hive/hive.dart';
import 'skill.dart';

part 'hive_skill.g.dart';

@HiveType(typeId: 2)
class HiveSkill extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int base;

  /// New: specialization support (nullable, added after initial schema)
  @HiveField(2)
  String? category;

  @HiveField(3)
  String? specialization;

  /// Whether this skill is marked as an occupation skill during creation.
  /// Added after initial schema; defaults to false for old records.
  @HiveField(4)
  bool isOccupation;

  HiveSkill({
    required this.name,
    required this.base,
    this.category,
    this.specialization,
    this.isOccupation = false,
  });

  factory HiveSkill.fromSkill(Skill s) => HiveSkill(
        name: s.name,
        base: s.base,
        category: s.category,
        specialization: s.specialization,
        isOccupation: s.isOccupation,
      );

  Skill toSkill() {
    final sk = Skill(
      name: name,
      base: base,
      category: category,
      specialization: specialization,
    );
    sk.isOccupation = isOccupation;
    return sk;
  }
}
