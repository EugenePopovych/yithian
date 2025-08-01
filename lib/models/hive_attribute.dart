import 'package:hive/hive.dart';
import 'attribute.dart';

part 'hive_attribute.g.dart';

@HiveType(typeId: 1)
class HiveAttribute extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int base;

  HiveAttribute({required this.name, required this.base});

  factory HiveAttribute.fromAttribute(Attribute a) => HiveAttribute(
    name: a.name,
    base: a.base,
  );

  Attribute toAttribute() => Attribute(name: name, base: base);
}
