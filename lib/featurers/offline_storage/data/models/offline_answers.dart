import 'package:hive/hive.dart';

part 'offline_answers.g.dart';

@HiveType(typeId: 3)
class OfflineAnswers extends HiveObject {
  @HiveField(0)
  final List<String> questions;

  @HiveField(1)
  final List<String> answers;

  @HiveField(2)
  final String examTypeId;

  OfflineAnswers(
      {required this.answers,
      required this.questions,
      required this.examTypeId});
}
