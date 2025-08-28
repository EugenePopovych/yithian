// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_skill.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveSkillAdapter extends TypeAdapter<HiveSkill> {
  @override
  final int typeId = 2;

  @override
  HiveSkill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveSkill(
      name: fields[0] as String,
      base: fields[1] as int,
      category: fields[2] as String?,
      specialization: fields[3] as String?,
      isOccupation: (fields[4] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, HiveSkill obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.base)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.specialization)
      ..writeByte(4)
      ..write(obj.isOccupation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveSkillAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
