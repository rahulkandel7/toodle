// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_answers.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineAnswersAdapter extends TypeAdapter<OfflineAnswers> {
  @override
  final int typeId = 3;

  @override
  OfflineAnswers read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineAnswers(
      answers: (fields[1] as List).cast<String>(),
      questions: (fields[0] as List).cast<String>(),
      examTypeId: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineAnswers obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.questions)
      ..writeByte(1)
      ..write(obj.answers)
      ..writeByte(2)
      ..write(obj.examTypeId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineAnswersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
