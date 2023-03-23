// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:hive/hive.dart';

part 'offline_question.g.dart';

@HiveType(typeId: 1)
class OfflineQuestions extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String? question;

  @HiveField(2)
  final String? subQuestion;

  @HiveField(3)
  final String option1;

  @HiveField(4)
  final String option2;

  @HiveField(5)
  final String option3;

  @HiveField(6)
  final String option4;

  @HiveField(7)
  final String correctOption;

  @HiveField(8)
  final String? filePath;

  @HiveField(9)
  final String questionSetsId;

  @HiveField(10)
  final String isImage;

  @HiveField(11)
  final String isAudio;

  @HiveField(12)
  final String isOptionAudio;

  @HiveField(13)
  final String? selectedOption;

  @HiveField(14)
  final String? audioPath;

  @HiveField(15)
  final String category;

  @HiveField(16)
  int questionCount;

  @HiveField(17)
  int audioPathcount;

  @HiveField(18)
  int option1Count;

  @HiveField(19)
  int option2Count;

  @HiveField(20)
  int option3Count;

  @HiveField(21)
  int option4Count;

  OfflineQuestions({
    required this.id,
    required this.question,
    required this.subQuestion,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.correctOption,
    required this.filePath,
    required this.questionSetsId,
    required this.isImage,
    required this.isAudio,
    required this.isOptionAudio,
    required this.selectedOption,
    required this.audioPath,
    required this.category,
    this.questionCount = 0,
    this.audioPathcount = 0,
    this.option1Count = 0,
    this.option2Count = 0,
    this.option3Count = 0,
    this.option4Count = 0,
  });

  factory OfflineQuestions.fromMap(Map<String, dynamic> map) {
    return OfflineQuestions(
      id: map['id'] as int,
      question: map['question'] != null ? map['question'] as String : '',
      option1: map['option1'] as String,
      option2: map['option2'] as String,
      option3: map['option3'] as String,
      option4: map['option4'] as String,
      category: map['category'] as String,
      correctOption: map['correct_option'].toString(),
      filePath: map['filepath'] != null ? map['filepath'] as String : '',
      subQuestion:
          map['sub_question'] != null ? map['sub_question'] as String : null,
      questionSetsId: map['question_sets_id'].toString(),
      isImage: map['isImage'] as String,
      isAudio: map['isAudio'] as String,
      isOptionAudio: map['isOptionAudio'] as String,
      selectedOption: map['selected_option'] != null
          ? map['selected_option'] as String
          : null,
      audioPath: map['audiopath'] != null ? map['audiopath'] as String : null,
    );
  }
}
