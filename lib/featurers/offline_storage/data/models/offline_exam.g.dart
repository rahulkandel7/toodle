// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_exam.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineExamAdapter extends TypeAdapter<OfflineExam> {
  @override
  final int typeId = 2;

  @override
  OfflineExam read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineExam(
      examType: fields[0] as String,
      questions: (fields[2] as List).cast<OfflineQuestions>(),
      setNumber: fields[1] as String,
      examTypeID: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineExam obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.examType)
      ..writeByte(1)
      ..write(obj.setNumber)
      ..writeByte(2)
      ..write(obj.questions)
      ..writeByte(3)
      ..write(obj.examTypeID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineExamAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
