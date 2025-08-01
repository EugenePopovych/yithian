import 'package:hive/hive.dart';
import 'skill.dart';

part 'hive_skill.g.dart';

@HiveType(typeId: 2)
class HiveSkill extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int base;

  HiveSkill({required this.name, required this.base});

  factory HiveSkill.fromSkill(Skill s) => HiveSkill(
    name: s.name,
    base: s.base,
  );

  Skill toSkill() => Skill(name: name, base: base);
}
