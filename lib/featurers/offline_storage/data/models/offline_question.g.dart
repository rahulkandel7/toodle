// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_question.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineQuestionsAdapter extends TypeAdapter<OfflineQuestions> {
  @override
  final int typeId = 1;

  @override
  OfflineQuestions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineQuestions(
      id: fields[0] as int,
      question: fields[1] as String?,
      subQuestion: fields[2] as String?,
      option1: fields[3] as String,
      option2: fields[4] as String,
      option3: fields[5] as String,
      option4: fields[6] as String,
      correctOption: fields[7] as String,
      filePath: fields[8] as String?,
      questionSetsId: fields[9] as String,
      isImage: fields[10] as String,
      isAudio: fields[11] as String,
      isOptionAudio: fields[12] as String,
      selectedOption: fields[13] as String?,
      audioPath: fields[14] as String?,
      category: fields[15] as String,
      questionCount: fields[16] as int,
      audioPathcount: fields[17] as int,
      option1Count: fields[18] as int,
      option2Count: fields[19] as int,
      option3Count: fields[20] as int,
      option4Count: fields[21] as int,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineQuestions obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.subQuestion)
      ..writeByte(3)
      ..write(obj.option1)
      ..writeByte(4)
      ..write(obj.option2)
      ..writeByte(5)
      ..write(obj.option3)
      ..writeByte(6)
      ..write(obj.option4)
      ..writeByte(7)
      ..write(obj.correctOption)
      ..writeByte(8)
      ..write(obj.filePath)
      ..writeByte(9)
      ..write(obj.questionSetsId)
      ..writeByte(10)
      ..write(obj.isImage)
      ..writeByte(11)
      ..write(obj.isAudio)
      ..writeByte(12)
      ..write(obj.isOptionAudio)
      ..writeByte(13)
      ..write(obj.selectedOption)
      ..writeByte(14)
      ..write(obj.audioPath)
      ..writeByte(15)
      ..write(obj.category)
      ..writeByte(16)
      ..write(obj.questionCount)
      ..writeByte(17)
      ..write(obj.audioPathcount)
      ..writeByte(18)
      ..write(obj.option1Count)
      ..writeByte(19)
      ..write(obj.option2Count)
      ..writeByte(20)
      ..write(obj.option3Count)
      ..writeByte(21)
      ..write(obj.option4Count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineQuestionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
