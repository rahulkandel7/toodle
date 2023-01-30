class ExamType {
  final String examType;
  final int time;
  final String maxModelSet;

  ExamType({
    required this.examType,
    required this.maxModelSet,
    required this.time,
  });

  factory ExamType.fromMap(Map<String, dynamic> map) {
    return ExamType(
      examType: map['exam_type'] as String,
      time: map['time'] as int,
      maxModelSet: map['maxmodelset'] as String,
    );
  }
}
