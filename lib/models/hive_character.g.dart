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
      name: fields[0] as String,
      age: fields[1] as int,
      pronouns: fields[2] as String,
      birthplace: fields[3] as String,
      occupation: fields[4] as String,
      residence: fields[5] as String,
      currentHP: fields[6] as int,
      maxHP: fields[7] as int,
      currentSanity: fields[8] as int,
      startingSanity: fields[9] as int,
      currentMP: fields[10] as int,
      startingMP: fields[11] as int,
      currentLuck: fields[12] as int,
      attributes: (fields[13] as List).cast<HiveAttribute>(),
      skills: (fields[14] as List).cast<HiveSkill>(),
      personalDescription: fields[15] as String,
      ideologyAndBeliefs: fields[16] as String,
      significantPeople: fields[17] as String,
      meaningfulLocations: fields[18] as String,
      treasuredPossessions: fields[19] as String,
      traitsAndMannerisms: fields[20] as String,
      injuriesAndScars: fields[21] as String,
      phobiasAndManias: fields[22] as String,
      arcaneTomesAndSpells: fields[23] as String,
      encountersWithEntities: fields[24] as String,
      gear: fields[25] as String,
      wealth: fields[26] as String,
      notes: fields[27] as String,
      hasMajorWound: fields[28] as bool,
      isIndefinitelyInsane: fields[29] as bool,
      isTemporarilyInsane: fields[30] as bool,
      isUnconscious: fields[31] as bool,
      isDying: fields[32] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HiveCharacter obj) {
    writer
      ..writeByte(33)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.pronouns)
      ..writeByte(3)
      ..write(obj.birthplace)
      ..writeByte(4)
      ..write(obj.occupation)
      ..writeByte(5)
      ..write(obj.residence)
      ..writeByte(6)
      ..write(obj.currentHP)
      ..writeByte(7)
      ..write(obj.maxHP)
      ..writeByte(8)
      ..write(obj.currentSanity)
      ..writeByte(9)
      ..write(obj.startingSanity)
      ..writeByte(10)
      ..write(obj.currentMP)
      ..writeByte(11)
      ..write(obj.startingMP)
      ..writeByte(12)
      ..write(obj.currentLuck)
      ..writeByte(13)
      ..write(obj.attributes)
      ..writeByte(14)
      ..write(obj.skills)
      ..writeByte(15)
      ..write(obj.personalDescription)
      ..writeByte(16)
      ..write(obj.ideologyAndBeliefs)
      ..writeByte(17)
      ..write(obj.significantPeople)
      ..writeByte(18)
      ..write(obj.meaningfulLocations)
      ..writeByte(19)
      ..write(obj.treasuredPossessions)
      ..writeByte(20)
      ..write(obj.traitsAndMannerisms)
      ..writeByte(21)
      ..write(obj.injuriesAndScars)
      ..writeByte(22)
      ..write(obj.phobiasAndManias)
      ..writeByte(23)
      ..write(obj.arcaneTomesAndSpells)
      ..writeByte(24)
      ..write(obj.encountersWithEntities)
      ..writeByte(25)
      ..write(obj.gear)
      ..writeByte(26)
      ..write(obj.wealth)
      ..writeByte(27)
      ..write(obj.notes)
      ..writeByte(28)
      ..write(obj.hasMajorWound)
      ..writeByte(29)
      ..write(obj.isIndefinitelyInsane)
      ..writeByte(30)
      ..write(obj.isTemporarilyInsane)
      ..writeByte(31)
      ..write(obj.isUnconscious)
      ..writeByte(32)
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
