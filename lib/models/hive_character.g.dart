// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_character.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveCharacterAdapter extends TypeAdapter<HiveCharacter> {
  @override
  final int typeId = 0;

  @override
  HiveCharacter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveCharacter(
      sheetName: fields[0] as String,
      name: fields[1] as String,
      age: fields[2] as int,
      pronouns: fields[3] as String,
      birthplace: fields[4] as String,
      occupation: fields[5] as String,
      residence: fields[6] as String,
      currentHP: fields[7] as int,
      maxHP: fields[8] as int,
      currentSanity: fields[9] as int,
      startingSanity: fields[10] as int,
      currentMP: fields[11] as int,
      startingMP: fields[12] as int,
      currentLuck: fields[13] as int,
      attributes: (fields[14] as List).cast<HiveAttribute>(),
      skills: (fields[15] as List).cast<HiveSkill>(),
      personalDescription: fields[16] as String,
      ideologyAndBeliefs: fields[17] as String,
      significantPeople: fields[18] as String,
      meaningfulLocations: fields[19] as String,
      treasuredPossessions: fields[20] as String,
      traitsAndMannerisms: fields[21] as String,
      injuriesAndScars: fields[22] as String,
      phobiasAndManias: fields[23] as String,
      arcaneTomesAndSpells: fields[24] as String,
      encountersWithEntities: fields[25] as String,
      gear: fields[26] as String,
      wealth: fields[27] as String,
      notes: fields[28] as String,
      hasMajorWound: fields[29] as bool,
      isIndefinitelyInsane: fields[30] as bool,
      isTemporarilyInsane: fields[31] as bool,
      isUnconscious: fields[32] as bool,
      isDying: fields[33] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HiveCharacter obj) {
    writer
      ..writeByte(34)
      ..writeByte(0)
      ..write(obj.sheetName)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.pronouns)
      ..writeByte(4)
      ..write(obj.birthplace)
      ..writeByte(5)
      ..write(obj.occupation)
      ..writeByte(6)
      ..write(obj.residence)
      ..writeByte(7)
      ..write(obj.currentHP)
      ..writeByte(8)
      ..write(obj.maxHP)
      ..writeByte(9)
      ..write(obj.currentSanity)
      ..writeByte(10)
      ..write(obj.startingSanity)
      ..writeByte(11)
      ..write(obj.currentMP)
      ..writeByte(12)
      ..write(obj.startingMP)
      ..writeByte(13)
      ..write(obj.currentLuck)
      ..writeByte(14)
      ..write(obj.attributes)
      ..writeByte(15)
      ..write(obj.skills)
      ..writeByte(16)
      ..write(obj.personalDescription)
      ..writeByte(17)
      ..write(obj.ideologyAndBeliefs)
      ..writeByte(18)
      ..write(obj.significantPeople)
      ..writeByte(19)
      ..write(obj.meaningfulLocations)
      ..writeByte(20)
      ..write(obj.treasuredPossessions)
      ..writeByte(21)
      ..write(obj.traitsAndMannerisms)
      ..writeByte(22)
      ..write(obj.injuriesAndScars)
      ..writeByte(23)
      ..write(obj.phobiasAndManias)
      ..writeByte(24)
      ..write(obj.arcaneTomesAndSpells)
      ..writeByte(25)
      ..write(obj.encountersWithEntities)
      ..writeByte(26)
      ..write(obj.gear)
      ..writeByte(27)
      ..write(obj.wealth)
      ..writeByte(28)
      ..write(obj.notes)
      ..writeByte(29)
      ..write(obj.hasMajorWound)
      ..writeByte(30)
      ..write(obj.isIndefinitelyInsane)
      ..writeByte(31)
      ..write(obj.isTemporarilyInsane)
      ..writeByte(32)
      ..write(obj.isUnconscious)
      ..writeByte(33)
      ..write(obj.isDying);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveCharacterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
