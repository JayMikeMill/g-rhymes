// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'g_dict.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GDictAdapter extends TypeAdapter<GDict> {
  @override
  final int typeId = 0;

  @override
  GDict read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GDict()
      ..entries = (fields[0] as List).cast<DictEntry>()
      ..tokenMap = (fields[1] as Map).cast<String, int>()
      ..senseMap = (fields[2] as List)
          .map((dynamic e) => (e as List).cast<int>())
          .toList();
  }

  @override
  void write(BinaryWriter writer, GDict obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.entries)
      ..writeByte(1)
      ..write(obj.tokenMap)
      ..writeByte(2)
      ..write(obj.senseMap);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GDictAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DictEntryAdapter extends TypeAdapter<DictEntry> {
  @override
  final int typeId = 1;

  @override
  DictEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DictEntry()
      ..token = fields[0] as String
      ..rarity = fields[1] as Rarity
      ..senses = (fields[2] as List).cast<DictSense>();
  }

  @override
  void write(BinaryWriter writer, DictEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.token)
      ..writeByte(1)
      ..write(obj.rarity)
      ..writeByte(2)
      ..write(obj.senses);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DictEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DictSenseAdapter extends TypeAdapter<DictSense> {
  @override
  final int typeId = 2;

  @override
  DictSense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DictSense()
      ..ipak = fields[0] as Uint8List
      ..pos = fields[1] as PartOfSpeech
      ..tag = fields[2] as SenseTag
      ..meaning = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, DictSense obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.ipak)
      ..writeByte(1)
      ..write(obj.pos)
      ..writeByte(2)
      ..write(obj.tag)
      ..writeByte(3)
      ..write(obj.meaning);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DictSenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RarityAdapter extends TypeAdapter<Rarity> {
  @override
  final int typeId = 3;

  @override
  Rarity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Rarity.common;
      case 1:
        return Rarity.uncommon;
      case 2:
        return Rarity.rare;
      case 3:
        return Rarity.obsolete;
      default:
        return Rarity.common;
    }
  }

  @override
  void write(BinaryWriter writer, Rarity obj) {
    switch (obj) {
      case Rarity.common:
        writer.writeByte(0);
        break;
      case Rarity.uncommon:
        writer.writeByte(1);
        break;
      case Rarity.rare:
        writer.writeByte(2);
        break;
      case Rarity.obsolete:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RarityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SenseTagAdapter extends TypeAdapter<SenseTag> {
  @override
  final int typeId = 4;

  @override
  SenseTag read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SenseTag.none;
      case 1:
        return SenseTag.offensive;
      case 2:
        return SenseTag.vulgar;
      case 3:
        return SenseTag.slang;
      case 4:
        return SenseTag.informal;
      case 5:
        return SenseTag.archaic;
      case 6:
        return SenseTag.historical;
      case 7:
        return SenseTag.literary;
      default:
        return SenseTag.none;
    }
  }

  @override
  void write(BinaryWriter writer, SenseTag obj) {
    switch (obj) {
      case SenseTag.none:
        writer.writeByte(0);
        break;
      case SenseTag.offensive:
        writer.writeByte(1);
        break;
      case SenseTag.vulgar:
        writer.writeByte(2);
        break;
      case SenseTag.slang:
        writer.writeByte(3);
        break;
      case SenseTag.informal:
        writer.writeByte(4);
        break;
      case SenseTag.archaic:
        writer.writeByte(5);
        break;
      case SenseTag.historical:
        writer.writeByte(6);
        break;
      case SenseTag.literary:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SenseTagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PartOfSpeechAdapter extends TypeAdapter<PartOfSpeech> {
  @override
  final int typeId = 5;

  @override
  PartOfSpeech read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PartOfSpeech.other;
      case 1:
        return PartOfSpeech.noun;
      case 2:
        return PartOfSpeech.verb;
      case 3:
        return PartOfSpeech.adjective;
      case 4:
        return PartOfSpeech.name;
      case 5:
        return PartOfSpeech.adverb;
      case 6:
        return PartOfSpeech.interjection;
      case 7:
        return PartOfSpeech.contraction;
      case 8:
        return PartOfSpeech.preposition;
      case 9:
        return PartOfSpeech.pronoun;
      case 10:
        return PartOfSpeech.phrase;
      case 11:
        return PartOfSpeech.numeral;
      case 12:
        return PartOfSpeech.determiner;
      case 13:
        return PartOfSpeech.conjunction;
      case 14:
        return PartOfSpeech.particle;
      default:
        return PartOfSpeech.other;
    }
  }

  @override
  void write(BinaryWriter writer, PartOfSpeech obj) {
    switch (obj) {
      case PartOfSpeech.other:
        writer.writeByte(0);
        break;
      case PartOfSpeech.noun:
        writer.writeByte(1);
        break;
      case PartOfSpeech.verb:
        writer.writeByte(2);
        break;
      case PartOfSpeech.adjective:
        writer.writeByte(3);
        break;
      case PartOfSpeech.name:
        writer.writeByte(4);
        break;
      case PartOfSpeech.adverb:
        writer.writeByte(5);
        break;
      case PartOfSpeech.interjection:
        writer.writeByte(6);
        break;
      case PartOfSpeech.contraction:
        writer.writeByte(7);
        break;
      case PartOfSpeech.preposition:
        writer.writeByte(8);
        break;
      case PartOfSpeech.pronoun:
        writer.writeByte(9);
        break;
      case PartOfSpeech.phrase:
        writer.writeByte(10);
        break;
      case PartOfSpeech.numeral:
        writer.writeByte(11);
        break;
      case PartOfSpeech.determiner:
        writer.writeByte(12);
        break;
      case PartOfSpeech.conjunction:
        writer.writeByte(13);
        break;
      case PartOfSpeech.particle:
        writer.writeByte(14);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartOfSpeechAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
