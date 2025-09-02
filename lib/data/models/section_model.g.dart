// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SectionModelAdapter extends TypeAdapter<SectionModel> {
  @override
  final int typeId = 1;

  @override
  SectionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SectionModel(
      id: fields[0] as int,
      courseId: fields[1] as int,
      instructorName: fields[2] as String,
      times: (fields[3] as List?)?.cast<SectionTimeModel>(),
      classes: (fields[4] as List?)?.cast<String>(),
      description: fields[5] as String?,
      examTime: fields[6] as DateTime?,
      capacity: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SectionModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseId)
      ..writeByte(2)
      ..write(obj.instructorName)
      ..writeByte(3)
      ..write(obj.times)
      ..writeByte(4)
      ..write(obj.classes)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.examTime)
      ..writeByte(7)
      ..write(obj.capacity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SectionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
