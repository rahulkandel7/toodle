class ExamType {
  final int id;
  final String examType;
  final int time;
  final String maxModelSet;
  final bool valid;

  ExamType({
    required this.id,
    required this.examType,
    required this.maxModelSet,
    required this.time,
    required this.valid,
  });

  factory ExamType.fromMap(Map<String, dynamic> map) {
    return ExamType(
      id: map['id'] as int,
      examType: map['exam_type'] as String,
      time: int.parse(map['time'].toString()),
      maxModelSet: map['maxmodelset'] as String,
      valid: map['valid'] as bool,
    );
  }
}
