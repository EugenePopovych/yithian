// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_attribute.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveAttributeAdapter extends TypeAdapter<HiveAttribute> {
  @override
  final int typeId = 1;

  @override
  HiveAttribute read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveAttribute(
      name: fields[0] as String,
      base: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HiveAttribute obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.base);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveAttributeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
