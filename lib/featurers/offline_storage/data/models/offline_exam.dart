import 'package:hive/hive.dart';
import 'package:toddle/featurers/offline_storage/data/models/offline_question.dart';

part 'offline_exam.g.dart';

@HiveType(typeId: 2)
class OfflineExam extends HiveObject {
  @HiveField(0)
  final String examType;

  @HiveField(1)
  final String setNumber;

  @HiveField(2)
  final List<OfflineQuestions> questions;

  OfflineExam({
    required this.examType,
    required this.questions,
    required this.setNumber,
  });
}
