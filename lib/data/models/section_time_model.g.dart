// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section_time_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SectionTimeModelAdapter extends TypeAdapter<SectionTimeModel> {
  @override
  final int typeId = 2;

  @override
  SectionTimeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SectionTimeModel(
      day: fields[0] as String,
      startTime: fields[1] as String,
      endTime: fields[2] as String,
      location: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SectionTimeModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.location);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SectionTimeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
