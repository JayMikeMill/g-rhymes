// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rhyme_dict.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RhymeDictAdapter extends TypeAdapter<RhymeDict> {
  @override
  final int typeId = 6;

  @override
  RhymeDict read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RhymeDict(dict:
      fields[0] as GDict,
    )
      ..sounds = (fields[1] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<int>()))
      ..vocals = (fields[2] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<int>()))
      ..consonants = (fields[3] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<int>()));
  }

  @override
  void write(BinaryWriter writer, RhymeDict obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.dict)
      ..writeByte(1)
      ..write(obj.sounds)
      ..writeByte(2)
      ..write(obj.vocals)
      ..writeByte(3)
      ..write(obj.consonants);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RhymeDictAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
